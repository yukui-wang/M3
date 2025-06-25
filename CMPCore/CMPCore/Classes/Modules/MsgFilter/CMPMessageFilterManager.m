//
//  CMPMessageFilterManager.m
//  M3
//
//  Created by Kaku Songu on 4/12/22.
//

#import "CMPMessageFilterManager.h"
#import <CMPLib/CMPDataProvider.h>
#import "CMPMsgFilterDBProvider.h"
#import <CMPLib/CMPServerVersionUtils.h>

#define EXIST @"isExists"

@interface CMPMessageFilterManager()<CMPDataProviderDelegate>

@property (nonatomic,strong) NSMutableDictionary *filterMap;
@property (nonatomic,assign) BOOL isFilterClose;
@property (nonatomic,strong) CMPMsgFilterDBProvider *dbProvider;

+(instancetype)shareInstance;

@end

@implementation CMPMessageFilterManager

static CMPMessageFilterManager *msgFilterManager ;
static dispatch_once_t onceToken;

+(instancetype)shareInstance
{
    dispatch_once(&onceToken, ^{
        msgFilterManager = [[[self class] alloc] init];
        //服务器版本校验
        if (![CMPServerVersionUtils serverIsLaterV8_1SP2]) {
            [msgFilterManager stopFilter:YES];
        }
    });
    return msgFilterManager;
}


-(NSMutableDictionary *)filterMap
{
    if (!_filterMap) {
        _filterMap = [[NSMutableDictionary alloc] init];
    }
    return _filterMap;
}

-(CMPMsgFilterDBProvider *)dbProvider
{
    if (!_dbProvider) {
        _dbProvider = [[CMPMsgFilterDBProvider alloc] init];
    }
    return _dbProvider;
}


+(CMPMsgFilterResult *)filterStr:(NSString *)str
{
    CMPMessageFilterManager *manager = [CMPMessageFilterManager shareInstance];
    @synchronized (manager) {
        CMPMsgFilterResult *result = [manager filter:str];
        return result;
    }
}

+(void)freeFilter
{
    CMPMessageFilterManager *manager = [CMPMessageFilterManager shareInstance];
    [manager freeFilter];
}



-(BOOL)insertFilter:(CMPMsgFilter *)filter
{
    if (!filter ||filter.matchVal.length == 0) {
        return NO;
    }
    NSMutableDictionary *dic = self.filterMap;
    NSString *words = filter.matchVal;
    for (int i = 0; i < words.length; i ++) {
        NSString *word = [words.lowercaseString substringWithRange:NSMakeRange(i, 1)];
        if (dic[word] == nil) {
            dic[word] = [NSMutableDictionary dictionary];
        }
        dic = dic[word];
    }
    dic[EXIST] = filter;
    NSLog(@"%@",self.filterMap);
    return YES;
}


- (CMPMsgFilterResult *)filter:(NSString *)str
{
    CMPMsgFilterResult *filterRslt = [[CMPMsgFilterResult alloc] init];
    filterRslt.ori = str;
    
    if (self.isFilterClose || !self.filterMap || self.filterMap.count == 0 || !str || str.length == 0) {
        filterRslt.rslt = str;
        return filterRslt;
    }

    BOOL canStop = NO;
    NSMutableString *result = result = [str mutableCopy];
    for (int i = 0; i < str.length; i ++) {
        NSString *subString = [[str substringFromIndex:i] lowercaseString];
        NSMutableDictionary *node = [self.filterMap mutableCopy] ;
        int num = 0;

        for (int j = 0; j < subString.length; j ++) {
            NSString *word = [subString substringWithRange:NSMakeRange(j, 1)];
            if (node[word] != nil) {
                num ++;
                node = node[word];
            }else{
                if (j==0) {
                    break;
                }
                //ks fix --- jira V5-28595 敏感词过滤】移动端发送替换敏感词，中间插入表情、标点符号发送后显示不正确
                //是否是表情符号等,如果不是则break，是则继续
                if(![CMPMessageFilterManager isChar:word]){
                    break;
                }
                num++;
            }

        //敏感词匹配成功
        
            CMPMsgFilter *filter = node[EXIST];
            if (filter) {
                
                filterRslt.filter = filter.yy_modelCopy;
                
                if (filter.level == CMPMsgFilterLevelIntercept) {
                    result = @"".mutableCopy;
                    canStop = YES;
                }else{
                    if (i+num > result.length) {
                        break;
                    }
                    if (filter.replaceVal) {
                        [result replaceCharactersInRange:NSMakeRange(i, num) withString:filter.replaceVal];
                        NSInteger sp = filter.replaceVal.length - filter.matchVal.length;
                        i+=sp;
                    }else{
                        NSMutableString *symbolStr = [NSMutableString string];

                        for (int k = 0; k < num; k ++) {
                            [symbolStr appendString:@"*"];
                        }
                        [result replaceCharactersInRange:NSMakeRange(i, num) withString:symbolStr];
                    }
                    

                    
                    i += j;
                }
                
                break;
            }
        }
        if (canStop) {
            break;
        }
    }
    filterRslt.rslt = result;
    
    return filterRslt;
}

+(BOOL)isChar:(NSString *)targetStr
{
    NSString *regex = @"[\u4e00-\u9fa5|0-9|a-zA-Z]";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return ![pre evaluateWithObject:targetStr];
}

- (void)freeFilter
{
    _filterMap = nil;
    [_dbProvider close];
    _dbProvider = nil;
    msgFilterManager = nil;
    onceToken = 0;
}


- (void)stopFilter:(BOOL)b
{
    self.isFilterClose = b;
}


-(void)syncFilterFromLocal
{
    NSArray<CMPMsgFilter *> *filters = [self.dbProvider allFilters];
    for (CMPMsgFilter *filter in filters) {
        [self insertFilter:filter];
    }
}


+(void)updateFilter
{
    CMPMessageFilterManager *manager = [CMPMessageFilterManager shareInstance];
    if (manager.isFilterClose) {
        return;
    }
    
    [manager fetchFilterWithCompletion:^(id respData, NSError *error, id ext) {
        if (!error) {
            if (respData && [respData isKindOfClass:[NSArray class]]) {
                NSArray<CMPMsgFilter *> *filters = [NSArray yy_modelArrayWithClass:CMPMsgFilter.class json:respData];
                [manager.dbProvider updateFilters:filters];
            }
        }else{
            
        }
        [manager syncFilterFromLocal];
        
    }];
}


-(void)fetchFilterWithCompletion:(void(^)(id respData,NSError *error,id ext))completion
{
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/uc/rong/sensitiveWord/list"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {

    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    if (responseObj) {
        NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
        if ([code isEqualToString:@"200"]) {
            id respData = responseObj[@"words"];
            completionBlk(respData,nil,responseObj);
        }else{
            NSString *msg = responseObj[@"message"] ? : @"request err";
            NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }else{
        NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
        completionBlk(nil,err,responseObj);
    }
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (completionBlk) {
        completionBlk(nil,error,nil);
    }
}

@end
