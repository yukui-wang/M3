//
//  BNlpManager.m
//  M3
//
//  Created by wujiansheng on 2019/1/4.
//

#define kBNLPAccessTokenUrl @"https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=%@&client_secret=%@"
#define kBNLPAnalysisUrl @"https://aip.baidubce.com/rpc/2.0/nlp/v1/lexer_custom?charset=UTF-8&access_token=%@"

#import "BNlpManager.h"
#import "XZCore.h"


@interface BNlpManager ()
@property(nonatomic,copy)NSString *accessToken;
@property(nonatomic,copy)NSURLSessionTask * task;

@end

@implementation BNlpManager


+ (instancetype)sharedInstance {
    static BNlpManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BNlpManager alloc] init];
    });
    return instance;
}

- (void)clearData {
    self.accessToken = nil;
    if (self.task) {
        [self.task cancel];
    }
    self.task = nil;
}

- (void)requestAccessToken:(void (^)(NSString *token))completionBlock {
    
    NSString *key = [[[XZCore sharedInstance] baiduNlpInfo] nlpAPIKey];
    NSString *skey = [[[XZCore sharedInstance] baiduNlpInfo] nlpSecretKey];
    __weak typeof(self) weakSelf = self;
    
    NSString* url = [NSString stringWithFormat:kBNLPAccessTokenUrl,key,skey];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        weakSelf.task = nil;
        if (error == nil) {
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completionBlock(dict[@"access_token"]);
        }
    }];
    [self.task resume];
}

- (void)requestAnalysisTextInner:(NSString *)text
                        keyArray:(NSArray *)keyArray
                      completion:(void (^)(NSDictionary *result, NSError * error))completionBlock {
    NSString* url = [NSString stringWithFormat:kBNLPAnalysisUrl,self.accessToken];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPShouldHandleCookies = false;
    __weak typeof(self) weakSelf = self;
    
    //text ：string 待分析文本（目前仅支持GBK编码），长度不超过20000字节   但是返回乱码
   //要求使用JSON格式的结构体来描述一个请求的具体内容。**发送时默认需要对body整体进行GBK编码。**若使用UTF-8编码，请在url参数中添加charset=UTF-8 （大小写敏感）
    NSDictionary *param = @{@"text":text};
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        weakSelf.task = nil;
        if (error == nil) {
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger error_code = [dict[@"error_code"] integerValue];
            if (error_code == 0 ) {
                NSArray *items = dict[@"items"];
                NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                for ( NSDictionary *itemDic in items) {
                    NSString *ne = itemDic[@"ne"];//词语类型
                    if (![NSString isNull:ne] && [keyArray containsObject:ne]) {
                        //ne 不为nil或@“”， 并且是我们需要的key
                        NSString *item = itemDic[@"item"];
                        NSMutableArray *array = resultDic[ne];
                        if (!array) {
                            //初始化
                            array = [NSMutableArray array];
                            [resultDic setObject:array forKey:ne];
                        }
                        if (![array containsObject:item]) {
                            //去重添加到reusltDic
                            [array addObject:item];
                        }
                    }
                }
//                NSData *data1 = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:nil];
                completionBlock(resultDic,nil);
            }
            else {
                NSString * error_msg = dict[@"error_msg"]?dict[@"error_msg"]:@"未知错误";
                NSError *er = [NSError errorWithDomain:error_msg code:error_code userInfo:nil];
                completionBlock(nil,er);
            }
        }
        else {
            completionBlock(nil,error);
        }
    }];
    [self.task resume];
}

- (void)requestAnalysisText:(NSString *)text
                   keyArray:(NSArray *)keyArray
                 completion:(void (^)(NSDictionary *result, NSError * error))completionBlock{
    if ([NSString isNull:text]) {
        NSError *error = [NSError errorWithDomain:@"content can not be null" code:1 userInfo:nil];
        completionBlock(nil,error);
        return;
    }
    if (!self.accessToken) {
        __weak typeof(self) weakSelf = self;
        [self requestAccessToken:^(NSString *token) {
            weakSelf.accessToken = token;
            [weakSelf requestAnalysisTextInner:text
                                      keyArray:keyArray
                                    completion:completionBlock];
        }];
    }
    else {
        [self requestAnalysisTextInner:text
                              keyArray:keyArray
                            completion:completionBlock];
    }
}

@end
