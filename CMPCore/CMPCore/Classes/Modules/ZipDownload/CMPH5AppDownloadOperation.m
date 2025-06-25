//
//  CMPH5AppDownloadOperation.m
//  M3
//
//  Created by Shoujian Rao on 2023/8/17.
//

#import "CMPH5AppDownloadOperation.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPURLUtils.h>

@interface CMPH5AppDownloadOperation()<NSURLSessionDataDelegate,CMPDataProviderDelegate>
{
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_obtainReqid;
}
@property (nonatomic, strong) NSURLSession *session;//下载包的session
@property (strong, nonatomic) NSDictionary *app;
@property (nonatomic, copy) void(^completion)(id respData,NSError *error);


@end

@implementation CMPH5AppDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithApp:(NSDictionary *)app downloadSession:(NSURLSession *)session completion:(void(^)(id respData,NSError *error) )completion{
    if(self = [super init]){
        self.app = app;
        self.session = session;
        self.completion = completion;
    }
    return self;
}

- (void)start{
    self.executing = YES;
    if(self.isCancelled){
//        NSLog(@"h5zip = cancel");
        [self done];
        return;
    }
//    NSLog(@"h5zip = 执行");
    __weak typeof(self) weakSelf = self;
    [self downloadSingleZip:self.app completion:^(id respData, NSError *error) {
        if(weakSelf.completion){
            weakSelf.completion(respData, error);
        }
        [weakSelf done];
    }];
}
- (void)done {
    self.finished = YES;
    self.executing = NO;
}

//- (void)main{
//    // 新建一个自动释放池，如果是异步执行操作，那么将无法访问到主线程的自动释放池
//    @autoreleasepool {
//        if (self.isCancelled) {
//            return;
//        }
//        NSLog(@"h5zip = 执行：%@",self);
//        __weak typeof(self) weakSelf = self;
//        [self downloadSingleZip:self.app completion:^(id respData, NSError *error) {
//            if(!weakSelf.isCancelled && weakSelf.completion){
//                weakSelf.completion(respData, error);
//            }
//        }];
//    }
//
//}

- (void)downloadSingleZip:(NSDictionary *)app completion:(void(^)(id respData,NSError *error) )completion{
//    NSLog(@"h5zip-downloadSingleZip=%@",[NSThread currentThread]);
    NSString *downloadType = [app objectForKey:@"downloadType"];
    
    if (downloadType && ![downloadType isKindOfClass:[NSNull class]] && downloadType.integerValue == 1) {
        //去获取应用包下载地址，人后再下载，否者直接下载
        __weak typeof(self) weakSelf = self;
        [self obtainAppDownloadUrlWithApp:app resultBlock:^(NSString * url, NSError *error) {
            if(error){
                completion(nil,error);
            }else{
                NSString *md5 = [app objectForKey:@"md5"];
                NSString *aTitle = [NSString stringWithFormat:@"%@.zip", md5];
                NSString *donwLoadPath = [[CMPAppManager cmpH5ZipDownloadPath] stringByAppendingPathComponent:aTitle];
                
                [weakSelf downloadActionWithUrl:url appInfo:app path:donwLoadPath completion:^(id respData, NSError *error1) {
                    if(completion){
                        completion(respData,error1);
                    }
                }];
            }
        }];
        return;
    }
    
    NSString *appId = [app objectForKey:@"appId"];
    NSString *md5 = [app objectForKey:@"md5"];
    NSString *aTitle = [NSString stringWithFormat:@"%@.zip", md5];
    NSString *h5DownloadPath = [[CMPAppManager cmpH5ZipDownloadPath] stringByAppendingPathComponent:aTitle];
    NSString *url = [CMPCore sharedInstance].serverurl;
    
    NSString *checkApplistUrl = nil;
    if (![NSString isNull:url]) {
        checkApplistUrl = [NSString stringWithFormat:@"%@%@?checkCode=%@", [CMPCore fullUrlPathMapForPath:@"/api/mobile/app/download/"],appId, md5];
    }
    
    [self downloadActionWithUrl:checkApplistUrl appInfo:app path:h5DownloadPath completion:^(id respData, NSError *error) {
        if(completion){
            completion(respData,error);
        }
    }];
}

//下载请求封装
- (void)downloadActionWithUrl:(NSString *)url appInfo:(NSDictionary *)app path:(NSString *)path completion:(void(^)(id respData,NSError *error) )completion{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
    }
    if(!_session){
        // 创建NSURLSessionConfiguration对象
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        configuration.HTTPShouldSetCookies = NO;
        configuration.HTTPCookieStorage = nil;
        // 设置HTTPCookieStorage属性
        //        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        //        configuration.HTTPCookieStorage = cookieStorage;
        // 创建NSURLSession对象
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    // 创建下载任务
    //忽略默认端口号80或443
    url = [CMPURLUtils ignoreDefaultPort:url];
    
    NSURL *downloadUrl = [NSURL URLWithString:url];
    if (_downloadTask) {
        [_downloadTask cancel];
        _downloadTask = nil;
    }
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionaryWithDictionary:[CMPDataProvider headers]];
    NSString *scheme = downloadUrl.scheme;
    if (![NSString isNull:scheme]) {
        [mutableHeaders setObject:scheme forKey:@"accessm3-scheme"];
    }
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:downloadUrl];
    mutableRequest.HTTPMethod = kRequestMethodType_GET;
    if ([mutableHeaders isKindOfClass:[NSDictionary class]]) {
        NSArray *aHeaderKeys = [mutableHeaders allKeys];
        for (NSString *aKey in aHeaderKeys) {
            if ([aKey isEqualToString:@"token"] /*|| [aKey isEqualToString:@"Cookie"] */|| [aKey isEqualToString:@"Content-Type"]) {
                continue;
            }
            NSString *aValue = [mutableHeaders objectForKey:aKey];
            [mutableRequest addValue:aValue forHTTPHeaderField:aKey];
        }
    }
        
    _downloadTask = [_session downloadTaskWithRequest:mutableRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        if(resp.statusCode < 200 || resp.statusCode >= 300){ //[200,300)算下载成功
            error = [NSError errorWithDomain:@"应用包下载失败" code:resp.statusCode userInfo:nil];
        }
        
        // 下载完成后的回调
        if (error) {
            NSLog(@"h5zip-下载失败：%@", error);
            [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
            if(completion){
                completion(nil,error);
            }
        } else {
            NSLog(@"h5zip-下载成功");
            // 将下载的文件移动到指定目录
            NSError *moveError;
            if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:&moveError]) {
                NSLog(@"文件保存在：%@", path);
                if(completion){
                    completion(app,nil);
                }
            } else {
                NSLog(@"h5zip-移动文件失败：%@", moveError);
                [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
                if(completion){
                    completion(nil,moveError);
                }
            }
        }
    }];
    // 开始下载任务
    [_downloadTask resume];
}
//下载请求绕过证书验证
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

//重新获取zip包的下载地址
- (void)obtainAppDownloadUrlWithApp:(NSDictionary *)app resultBlock:(void(^)(NSString * url,NSError *error) )resultBlock{
    NSString *url = [CMPCore sharedInstance].serverurl;
    if ([NSString isNull:url]) {
        return;
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *appId = [app objectForKey:@"appId"];
    NSString *md5 = [app objectForKey:@"md5"];
    NSString *checkApplistUrl = [CMPCore fullUrlForPathFormat:@"/rest/m3/appManager/downloadUrl/%@?md5=%@",appId,md5];
    aDataRequest.requestUrl = checkApplistUrl;
    
    aDataRequest.delegate = self;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.httpShouldHandleCookies = NO;
    aDataRequest.userInfo = @{@"resultBlock":resultBlock,@"appInfo":app,@"category":@"obtainAppUrl"};
    _obtainReqid = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//重新获取zip包的下载地址
- (void)handleObtainAppDownloadUrl:(NSString *)response app:(NSDictionary *)app result:(void(^)(id respData,NSError *error) )resultBlock{
    NSDictionary *aDict = [response JSONValue];
    NSDictionary *data = aDict[@"data"];
    NSString *appId = [app objectForKey:@"appId"];
    NSString *tipStr = [NSString stringWithFormat:@"获取%@.zip下载地址失败",appId];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSString *url = data[@"url"];
        if ([NSString isNotNull:url]) {
            resultBlock(url,nil);//返回下载地址
        }else{
            if(resultBlock){
                resultBlock(nil,[NSError errorWithDomain:tipStr code:2 userInfo:nil]);
            }
        }
    }else{
        if(resultBlock){
            resultBlock(nil,[NSError errorWithDomain:tipStr code:2 userInfo:nil]);
        }
    }
}
#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSDictionary *userInfo = aRequest.userInfo;
    NSString *reqCate = userInfo[@"category"];
    if ([reqCate isEqualToString:@"obtainAppUrl"]) {
        NSDictionary *app = aRequest.userInfo[@"app"];
        void(^resultBlock)(NSString * url,NSError *err) = aRequest.userInfo[@"resultBlock"];
        NSString *appId = [app objectForKey:@"appId"];
        NSDictionary *aDict = [aResponse.responseStr JSONValue];
        NSDictionary *data = aDict[@"data"];
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *url = data[@"url"];
            if ([NSString isNotNull:url]) {
                resultBlock(url,nil);
                return;
            }
        }
        NSString *tipStr = [NSString stringWithFormat:@"获取%@.zip下载地址失败",appId];
        resultBlock(nil,[NSError errorWithDomain:tipStr code:2 userInfo:nil]);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSDictionary *userInfo = aRequest.userInfo;
    NSString *reqCate = userInfo[@"category"];
    if ([reqCate isEqualToString:@"obtainAppUrl"]) {
        NSDictionary *app = aRequest.userInfo[@"app"];
        NSString *appId = [app objectForKey:@"appId"];
        void(^resultBlock)(id data,NSError *err) = aRequest.userInfo[@"resultBlock"];
        NSString *tipStr = [NSString stringWithFormat:@"获取%@.zip下载地址失败",appId];
        resultBlock(nil,[NSError errorWithDomain:tipStr code:2 userInfo:nil]);
    }
}
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)cancel{
    if (self.isFinished) return;
    if (_downloadTask) {
        [_downloadTask cancel];
        _downloadTask = nil;
    }
    [[CMPDataProvider sharedInstance] cancelWithRequestId:_obtainReqid];
    [super cancel];
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
