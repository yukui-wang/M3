//
//  CMPContactsDownloadManager.m
//  CMPCore
//
//  Created by wujiansheng on 2017/2/18.
//
//


#define kOfflinePrepareUrl @"/rest/m3/contacts/offline/prepare"
#define kOfflineCheckUrl @"/rest/m3/contacts/offline/check"
#define kOfflineAccountSetUrl @"/rest/m3/contacts/offline/accountSet"
#define kRequestType_Prepqre @"prepare"
#define kRequestType_Check @"check"
#define kRequestType_AccountSet @"accountSet"
#define kRequestType_Download @"download"
#define kRequestKey @"requestKey"

#define kDownload_record @"0"//记录下，还没下载
#define kDownload_loading @"1"//正在下载
#define kDownload_finish @"2"//下载完成
#define kDownload_fail @"3"//下载失败

#define kmd5Value @"md5Value_seeyon"

#import "CMPContactsDownloadManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/FMDatabase.h>
#import <CMPLib/NSString+CMPString.h>


#import "MAccountAvailableEntity.h"
#import "MAccountSetting.h"
#import <CMPLib/JSONKit.h>
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import <CMPLib/Reachability.h>
#import "AppDelegate.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPFeatureSupportControlHeader.h>

@interface CMPContactsDownloadManager()<CMPDataProviderDelegate> {
    
    NSInteger _checkCount;
    NSMutableArray *_requestIDList;
    
    NSMutableDictionary *_filePathDic;//文件下载路径
    NSMutableDictionary *_fileRecordDic;//记录各种类型需要下载的文件
    NSMutableArray *_fileDownloadArray;//正在下载的文件，避免重复下载
    NSMutableDictionary *_downFinishDic;//下载完成文件，记录各种类型 对应list
    NSInteger _allNeedDownloadCount;
    
}
@property(nonatomic,assign)id<CMPContactsDownloadManagerDelegate> delegate;
@property(nonatomic,retain)NSDictionary *md5Dict;
@property(nonatomic,copy)NSString *settingInfo;

@end

@implementation CMPContactsDownloadManager

- (void)dealloc
{
    _delegate = nil;
    for (NSString * r in _requestIDList) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:r];;
    }
    [_requestIDList removeAllObjects];
    SY_RELEASE_SAFELY(_requestIDList);
    
    SY_RELEASE_SAFELY(_md5Dict);
    SY_RELEASE_SAFELY(_settingInfo);

    SY_RELEASE_SAFELY(_filePathDic);
    SY_RELEASE_SAFELY(_fileRecordDic);
    SY_RELEASE_SAFELY(_fileDownloadArray);
    SY_RELEASE_SAFELY(_downFinishDic);

    [super dealloc];
}


- (id)init {
    self = [super init];
    if (self) {
        if (!_requestIDList) {
            _requestIDList = [[NSMutableArray alloc] init];
        }
        if (!_filePathDic) {
            _filePathDic = [[NSMutableDictionary alloc] init];
        }
        if (!_fileRecordDic) {
            _fileRecordDic = [[NSMutableDictionary alloc] init];
        }
        if (!_fileDownloadArray) {
            _fileDownloadArray = [[NSMutableArray alloc] init];
        }
        if (!_downFinishDic) {
            _downFinishDic = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)clearData
{
    //取消pperformSelector:@selector(requestCheckWithParam:)
     [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _checkCount = 0;
    _allNeedDownloadCount= 0;
    for (NSString * r in _requestIDList) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:r];;
    }
    [_requestIDList removeAllObjects];
    [_filePathDic removeAllObjects];
    [_fileRecordDic removeAllObjects];
    [_fileDownloadArray removeAllObjects];
    [_downFinishDic removeAllObjects];
}


-(BOOL)netConnectAble
{
//    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
//        return NO;
//    }
//    return YES;
    return [CMPCommonManager reachableNetwork];
}

- (void)updateContactsWithMD5Dic:(NSDictionary *)md5Dic
                     settingInfo:(NSString *)info
                        delegate:(id<CMPContactsDownloadManagerDelegate>)delegate
{
    self.md5Dict = md5Dic;
    self.settingInfo = info;
    self.delegate = delegate;
    [self requestPrepare];
}


-(void)beginUpdateContacts
{
    [self clearData];
    if (_delegate &&[_delegate respondsToSelector:@selector(managerBeginUpdateContacts:)]) {
        [_delegate managerBeginUpdateContacts:self];
    }
}

- (void)endUpdateContacts
{
    [self clearData];
    if (_delegate &&[_delegate respondsToSelector:@selector(managerEndUpdateContacts:)]) {
        [_delegate managerEndUpdateContacts:self];
    }
}

- (void)failUpdateOfflineWithMessage:(NSString *)message
{
    [self clearData];
    if (_delegate &&[_delegate respondsToSelector:@selector(manager:failUpdateContactsWithMessage:)]) {
        [_delegate manager:self failUpdateContactsWithMessage:message];
    }
}


- (void)finishDownLoadTableWithInfo:(NSDictionary *)info
                         filePaths:(NSArray *)filePath;
{
    if (_delegate &&[_delegate respondsToSelector:@selector(managerFinishDownLoadTable:info:filePaths:)]) {
        [_delegate managerFinishDownLoadTable:self info:info filePaths:filePath];
    }
}

- (void)finishLoadSettings:(NSArray *)settings
{
    if (_delegate &&[_delegate respondsToSelector:@selector(manager:finishLoadSettings:)]) {
        [_delegate manager:self finishLoadSettings:settings];
    }
}

#pragma mark 请求接口方法
- (void)requestPrepare
{
    [self beginUpdateContacts];
    NSString *url = [CMPCore fullUrlForPath:kOfflinePrepareUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo =  [NSDictionary dictionaryWithObjectsAndKeys:kRequestType_Prepqre,kRequestKey, nil] ;
    aDataRequest.headers = [CMPDataProvider headers];
    if (_md5Dict.allKeys.count >0) {
        aDataRequest.requestParam = [_md5Dict JSONRepresentation];
    }
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [_requestIDList addObject:aDataRequest.requestID];
    [aDataRequest release];
}

- (void)requestCheckWithParam:(NSArray *)param
{
    _checkCount  ++;
    NSString *url = [CMPCore fullUrlForPath:kOfflineCheckUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo =  [NSDictionary dictionaryWithObjectsAndKeys:kRequestType_Check,kRequestKey, nil] ;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [param JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [_requestIDList addObject:aDataRequest.requestID];
    [aDataRequest release];
}

- (void)requestAccountSet
{
    NSString *url = [CMPCore fullUrlForPath:kOfflineAccountSetUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"POST";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo =  [NSDictionary dictionaryWithObjectsAndKeys:kRequestType_AccountSet,kRequestKey, nil] ;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = self.settingInfo;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [_requestIDList addObject:aDataRequest.requestID];
    [aDataRequest release];
}

- (void)requestDownloadWithInfo:(NSDictionary *)info
{
    NSString *name = [info objectForKey:@"name"];
    if ([_fileDownloadArray containsObject:@"name"]) {
        //说明已经下载说明正在下载 或已经下载了 或者下载失败了
        return;
    }
    [_fileDownloadArray  addObject:name];
    NSString *path = [CMPFileManager downloadFileTempPathWithFileName:[NSString stringWithFormat:@"%@.zip",name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/seeyon/m3/offlineDownload.do"];
    if (CMPFeatureSupportControl.isOfflineDownloadRequestParamAppendByPath) {
        url = [url stringByAppendingString:name];
    } else {
        url = [url appendHtmlUrlParam:@"file" value:name];
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestType = kDataRequestType_FileDownload;
    
    aDataRequest.downloadDestinationPath = path;
    aDataRequest.headers = [CMPDataProvider headers];//[NSDictionary dictionaryWithObjectsAndKeys:[CMPCore sharedInstance].jsessionId,@"jsession", nil];
    NSMutableDictionary *userInfo  = [NSMutableDictionary dictionaryWithDictionary:info];
    [userInfo setObject:kRequestType_Download forKey:kRequestKey];
    aDataRequest.userInfo = userInfo;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [_requestIDList addObject:aDataRequest.requestID];
    [aDataRequest release];
}


#pragma -mark  接口代理方法 CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{
    
}


- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    [_requestIDList removeObject:aRequest.requestID];
    NSString *key = [[aRequest userInfo] objectForKey:kRequestKey];
    if ([key isEqualToString:kRequestType_Prepqre]) {
        [self handPrepareResult:aResponse];
    }
    else if ([key isEqualToString:kRequestType_Check]) {
        [self handCheckResult:aResponse];
    }
    else if ([key isEqualToString:kRequestType_AccountSet]) {
        [self handAccountSetResult:aResponse];
    }
    else if ([key isEqualToString:kRequestType_Download]) {
        [self handDownloadResult:aResponse userinfo:[aRequest userInfo]];
    }
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    [_requestIDList removeObject:aRequest.requestID];
    NSString *errorStr = [self netConnectAble] ?error.domain:SY_STRING(@"Common_Network_Unavailable");
    [self failUpdateOfflineWithMessage:errorStr];
    
    NSError *newError = [NSError errorWithDomain:errorStr code:error.code userInfo:nil];
    [[AppDelegate shareAppDelegate] handleError:newError];
//    if (error.code == 401 ||error.code == 1001 ||error.code == 1002 ||error.code == 1003 ||error.code == 1004 ||error.code == 1005) {
//        if (![NSString isNull:error.domain]) {
//            [self showAlertViewInMain:error.domain];
//        }
//    }
}


#pragma mark 处理接口返回
- (void)handPrepareResult:(CMPDataResponse *)aResponse{
        NSString *aStr = aResponse.responseStr;
        id jsonValue = [aStr JSONValue];
        NSArray *array = jsonValue;
        BOOL clean = NO;
        if ([jsonValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)jsonValue;
            clean = [[resultDic objectForKey:@"clean"] boolValue];
            if (clean) {
                if (_delegate && [_delegate respondsToSelector:@selector(managerShouldClearTables:)]) {
                    [_delegate managerShouldClearTables:self];
                }
            }
            array = [resultDic objectForKey:@"list"];
        }
        // 添加崩溃防护
        if (!array || ![array isKindOfClass:[NSArray class]]) {
            array = [NSArray array];
        }
        NSMutableArray *waittingList = [NSMutableArray array];
        NSMutableArray *downliadList = [NSMutableArray array];
        _allNeedDownloadCount = 0;
        for (NSDictionary *dic in array) {
            NSArray *fileCheck = [dic objectForKey:@"fileCheck"];
            BOOL isWaitting = NO;
            //md5  要对应保存 下次  prepare 要用到
            NSString *type = [dic objectForKey:@"type"];
            NSString *md5 = [dic objectForKey:@"m"];
            type = type.lowercaseString;
            if ([type.uppercaseString isEqualToString:@"MT"]||
                (!clean && [[_md5Dict objectForKey:type] isEqualToString:md5])) {
                continue;
            }
            /*无用代码
            if(fileCheck.count == 0) {
                //没有下载项  直接保存md5
                if (_delegate && [_delegate respondsToSelector:@selector(manager:saveMd5:type:)]) {
                    [_delegate manager:self saveMd5:md5 type:type.lowercaseString];
                }
                continue;
            }）
             */
            
            NSMutableArray *fileNameList = [NSMutableArray array];
            for (NSDictionary *fileDic in fileCheck) {
                //await 等待  false-- 直接下载， ture-- 调用check直到为false
                NSString *name = [fileDic objectForKey:@"name"];
                if (![NSString isNull:name]) {
                    BOOL await = [[fileDic objectForKey:@"await"] boolValue];
                    if (await) {
                        isWaitting = YES;
                    }
                    else {
                        NSDictionary *downloadDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",type,@"type",md5,@"md5", nil];
                        [downliadList addObject:downloadDict];
                    }
                    [fileNameList addObject:name];
                }
            }
            _allNeedDownloadCount += fileNameList.count;
            [_fileRecordDic setObject:fileNameList forKey:type.lowercaseString];
            
            if(isWaitting) {
                [waittingList addObject:dic];
            }
        }
        if (waittingList.count >0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(requestCheckWithParam:) withObject:waittingList afterDelay:5];
                
            });
            
        }
        for (NSDictionary *downloadDict in downliadList) {
            [self requestDownloadWithInfo:downloadDict];
        }
        if ((waittingList.count+downliadList.count) == 0) {
            //没有下载的 就直接请求单位设置
            [self requestAccountSet];
        }
}

- (void)handCheckResult:(CMPDataResponse *)aResponse
{
        NSString *aStr = aResponse.responseStr;
        NSArray *array = [aStr JSONValue];
        NSMutableArray *waittingList = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSArray *fileCheck = [dic objectForKey:@"fileCheck"];
            
            BOOL isWaitting = NO;
            NSString *type = [dic objectForKey:@"type"];
            NSString *md5 = [dic objectForKey:@"m"];
            for (NSDictionary *fileDic in fileCheck) {
                // m - md5  要对应保存 下次  prepare 要用到
                //await 等待  false-- 直接下载， ture-- 调用check直到为false
                NSString *name = [fileDic objectForKey:@"name"];
                if (![NSString isNull:name]) {
                    BOOL await = [[fileDic objectForKey:@"await"] boolValue];
                    if (await) {
                        isWaitting = YES;
                    }
                    else {
                        NSDictionary *downloadDict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",type,@"type",md5,@"md5", nil];
                        [self requestDownloadWithInfo:downloadDict];
                    }
                }
            }
            if(isWaitting) {
                [waittingList addObject:dic];
            }
        }
        if (waittingList.count >0) {
            //5s后都在等待  之后 todo
            if (_checkCount  >6) {
                // >10s了。server 还没生成  估计报错了
                [self failUpdateOfflineWithMessage:@"服务器生成文件出错了"];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(requestCheckWithParam:) withObject:waittingList afterDelay:10];
                });
            }
        }
}

- (void)handAccountSetResult:(CMPDataResponse *)aResponse
{
        NSString *aStr = aResponse.responseStr;
        NSArray *array = [aStr JSONValue];
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            MAccountAvailableEntity *entity = [[MAccountAvailableEntity alloc] initWithDictionaryRepresentation:dic];
            [result addObject:entity];
            [entity release];
            entity = nil;
        }
        [self finishLoadSettings:result];
        [self endUpdateContacts];
}

//下载接口处理
- (void)handDownloadResult:(CMPDataResponse *)aResponse userinfo:(NSDictionary *)userInfo
{
        NSString *name = [userInfo objectForKey:@"name"];
        NSString *type = [userInfo objectForKey:@"type"];
        type = type.lowercaseString;
        NSString *downloadPath = [aResponse downloadDestinationPath];
        
        //记录文件下载的路径
        [_filePathDic setObject:downloadPath forKey:name];
        
        //记录 该type已经下载完成的文件
        NSMutableArray *fileDownloadedList = [_downFinishDic objectForKey:type];
        if (!fileDownloadedList) {
            fileDownloadedList = [NSMutableArray array];
            [_downFinishDic setObject:fileDownloadedList forKey:type];
        }
        [fileDownloadedList addObject:name];
        
        //比较需要下载文件，是否type类型的文件下载完成了
        NSArray *toLoadList = [_fileRecordDic objectForKey:type];
        
        if (toLoadList.count ==  fileDownloadedList.count) {
            //该类型·下载完成了
            NSMutableArray *pathList = [NSMutableArray array];
            for (NSString *name in toLoadList) {
                NSString *path = [_filePathDic objectForKey:name];
                if (![NSString isNull:path ]) {
                    [pathList addObject:path];
                }
            }
            [_downFinishDic removeObjectForKey:type];
            [self finishDownLoadTableWithInfo:userInfo filePaths:pathList];
        }
        if (_downFinishDic.count == 0 && _filePathDic.count == _allNeedDownloadCount) {
            _allNeedDownloadCount = -5;//防止多次调用 requestAccountSet
            //下载完成了
            [self requestAccountSet];
        }
}
@end
