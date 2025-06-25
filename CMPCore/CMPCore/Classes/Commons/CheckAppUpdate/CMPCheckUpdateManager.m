//
//  CMPCheckUpdateManager.m
//  CMPCore
//
//  Created by youlin on 2017/1/3.
//
//

#define KAlertViewTag_ReachabilityStatus 2001

#define kDataIncomplete							1
#define kNocorrespondingVersionInformation		2
#define kMustUpdate								3
#define kAllowedUpdate							4
#define kNoUpdate								5
#define kVerionAlertTag_MustUp					23
#define kVerionAlertTag_Optional				24

#define kAlertViewTag_DownloadError 3001
#define kAlertViewTag_NetworkStatusChanged 5001

typedef void(^DownloadApplicationZipDidFinish)(void);

#import "CMPCheckUpdateManager.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/DES3Util.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPMigrateWebDataViewController.h"
#import <CMPLib/CMPV5ProductEditionModel.h>
#import "CMPHomeAlertManager.h"
#import "AppDelegate.h"
#import <CMPLib/CMPIntercepter.h>
#import "CMPCheckUpdate2Manager.h"
#import "CMPPresetPackagesManager.h"

@implementation CMPUpdateInfoModel
@end

@interface CMPCheckUpdateManager()<CMPDataProviderDelegate>  {
    UIAlertView *_networkAlertView;
}

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *checkAppListRequestID;
@property (nonatomic, copy) NSString *checkCMPShellRequestID;
@property (nonatomic, assign) BOOL mustUpdateShell;
@property (nonatomic, retain) NSDictionary *cmpShellInfo; // CMP壳信息
@property (nonatomic, retain) NSArray *checkUpdateAppList; // 检查更新zip应用列表
@property (nonatomic, retain) NSArray *downloadAppList; // 需要下的zip包列表

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *md5TagArray;
@property (nonatomic, retain) NSDictionary *currentAppInfo;
@property (nonatomic, assign) NSInteger appsCount;
@property (nonatomic, copy) NSString *currentDownloadRequestID;
@property (nonatomic, copy) NSString *downloadApplicationZipRequestID;
@property (nonatomic, copy) void(^h5AppCheckCompletionBlock)(BOOL success);
@property (nonatomic, assign) BOOL h5AppDownloadPause; //H5应用下载暂停
@property (strong, nonatomic) NSString *currentServerID; // 当前正在下载对应的ServerID
@property (strong, nonatomic) NSOperationQueue *handleH5AppOperationQueue;


@property (nonatomic, copy) NSString *obtainAppDownloadUrlRequestId;//获取应用包下载地址

@end

@implementation CMPCheckUpdateManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static CMPCheckUpdateManager *checkUpdateManagerInstance = nil;

+ (CMPCheckUpdateManager *)sharedManager {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        checkUpdateManagerInstance = [[self alloc] init];
    });
    return checkUpdateManagerInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"update---初始化应用包下载模块，CMPCheckUpdateManagerInit");
        self.state = CMPCheckUpdateManagerInit;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNotificationName_NetworkStatusChange object:nil];
        _delegate = [CMPCheckUpdate2Manager sharedManager];
        _infoModel = [[CMPUpdateInfoModel alloc] init];
        
        //低版本升级，没有此tag
        if (![UserDefaults objectForKey:[self _localTagForCurServerDownloadStateKey]]) {
            NSArray *appList = [CMPAppManager appListWithServerId:kCMP_ServerID ownerId:kCMP_OwnerID];
            if (appList.count) {
                [self _localTagToUpdateState:@"1"];
            }else{
                [self _localTagToUpdateState:@"0"];
            }
        }
        //end
    }
    return self;
}

- (void)startCheckUpdate:(void (^)(BOOL success))completionBlock
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:startCheckUpdate:ext:)]){
        if (![_delegate checkUpdateManager:self startCheckUpdate:completionBlock ext:nil]) return;
    }
    
    NSString *serverUrl = [CMPCore sharedInstance].serverurl;
    if ([NSString isNull:serverUrl]) {
        if (completionBlock) {
            completionBlock(YES);
        }
        return;
    }
    
    DDLogDebug(@"update---[%s]", __FUNCTION__);
    if (self.currentServerID) {
        if ([self.currentServerID isEqualToString:[CMPCore sharedInstance].serverID]) {
            // 如果检查更新或者正在下载H5应用包，不做处理
            if (self.state == CMPCheckUpdateManagerCheck ||
                self.state == CMPCheckUpdateManagerDownload) {
                DDLogDebug(@"update---[%s]正在下载改服务器应用包，不做处理", __FUNCTION__);
                if (completionBlock) {
                    completionBlock(YES);
                }
                return;
            }
        } else {
            // 如果当前下载应用包的服务器不是设置的服务器，停止上一个服务器的下载
            NSLog(@"update---当前下载应用包的服务器不是设置的服务器");
            [self cancelCurrentDownload];
        }
    }
    
    // 低版本服务器，先下载底导航包
    if (![CMPCore sharedInstance].serverIsLaterV1_8_0) {
        self.h5AppCheckCompletionBlock = completionBlock;
        [self downloadApplicationZip:^{
            [self handleStart];
            [self checkH5AppsUpdate];
        }];
    } else {
        self.h5AppCheckCompletionBlock = completionBlock;
        [self handleStart];
        [self checkH5AppsUpdate];
    }
}

// 检查CMP壳更新
- (void)checkCMPShellUpdate:(NSString *)aStr
{
    // 首先后取检查更新服务器地址
    NSString *checkUpdateUrl = [CMPCore sharedInstance].checkUpdateUrl;
    if (aStr) {
        checkUpdateUrl = aStr;
    }
    
    if (![NSString isNull:checkUpdateUrl]) {
        [self requestCheckVersionWithUrl:checkUpdateUrl];
    }
    else {
        // 检查CMP壳的地址为空，不影响zip包的检查更新
        [self checkUpdate:nil];
    }
}

// 检查zip更新
- (void)checkH5AppsUpdate
{
    NSString *url = [CMPCore sharedInstance].serverurl;
    if (![NSString isNull:url]) {
        NSString *checkApplistUrl = [self checkApplistUrl:url];
        [self requestAppListWithUrl:checkApplistUrl];
    }
    else {
        [self handleH5AppDownloadFailByZipAppName:nil];
    }
}

// 开始H5应用下载
- (void)startDownloadH5Apps:(NSArray *)aList
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:preHandleDownloadApplist:ext:)]){
        BOOL _continue = [_delegate checkUpdateManager:self preHandleDownloadApplist:aList ext:nil];
        if (!_continue) return;
    }
    
    if (aList.count == 0) {
        [self handleSuccess];
        return;
    }
    NSMutableArray *aDownloadList = [[NSMutableArray alloc] init];
    // 判断出需要下载的zip
    for (NSDictionary *aItem in aList) {
        BOOL isUpdate = [[aItem objectForKey:@"isUpdate"] boolValue];
        if (isUpdate) {
            [aDownloadList addObject:aItem];
        }
    }
    self.downloadAppList = aDownloadList;

    if (aDownloadList.count > 0) {
        if ([CMPCommonManager networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi || self.ignoreNetworkStatus) {
            [self startDownload];
        }
        else {
            [self showAlertViewForWWANWithTag:KAlertViewTag_ReachabilityStatus];
        }
    } else {
        [self handleSuccess];
    }
}

#pragma -mark custom request

- (NSString *)checkApplistUrl:(NSString *)preUrl {
    NSString *aVersion = [CMPCore clinetVersion];
    NSString *cpath = [CMPCore serverContextPath];
    
    NSString *checkApplistUrl = [NSString stringWithFormat:@"%@%@/rest/m3/appManager/getAppList/%@/ios",preUrl,cpath, aVersion];
    return checkApplistUrl;
}

- (void)requestAppListWithUrl:(NSString *)url
{
    NSArray *appList = [CMPAppManager appListWithServerId:kCMP_ServerID ownerId:kCMP_OwnerID];
    NSMutableArray *aList = [[NSMutableArray alloc] init];
    for (CMPDBAppInfo *aInfo in appList) {
        // 修复用户更换手机，出现白屏问题，判断文件夹是否存在，如果不存在需要重新下载应用包。
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *appPath = [documentsPath stringByAppendingPathComponent:aInfo.path];
        BOOL isAppExist = [[NSFileManager defaultManager] fileExistsAtPath:appPath];
        if (!isAppExist) {
            continue;
        }
        
        NSString *md5Str = aInfo.extend1;
        if (!md5Str) {
            md5Str = @"";
        }
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:aInfo.appId, @"appId", md5Str, @"md5", nil];
        [aList addObject:aDict];
    }
    //ceshi
//    if (aList.count){
//        [aList removeAllObjects];
//    }
//    if (aList.count){
//        [aList removeLastObject];
//    }
    // 获取本地applist记录结束
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.timeout = 10; // 设置10s的timeout
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [aList JSONRepresentation];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    
    __weak typeof(self) weakSelf = self;
    void(^againRequestBlock)(void) = ^{
        NSString *url = [CMPCore sharedInstance].currentServer.fullUrl;
        if (![NSString isNull:url]) {
            NSString *checkApplistUrl = [weakSelf checkApplistUrl:url];
            [weakSelf requestAppListWithUrl:checkApplistUrl];
        }
    };
    
    aDataRequest.userInfo = @{@"againRequestBlock" : [againRequestBlock copy]};
    self.checkAppListRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)requestCheckVersionWithUrl:(NSString *)aUrl
{
    NSString *urlStr = [CMPCommonManager checkCMPShellUpdateUrl:aUrl];
    CMPDataRequest *aRequest = [[CMPDataRequest alloc] init];
    aRequest.requestMethod = kRequestMethodType_GET;
    aRequest.requestUrl = urlStr;
    aRequest.delegate = self;
    aRequest.httpShouldHandleCookies = NO;
    self.checkCMPShellRequestID = aRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aRequest];
}

- (void)checkUpdate:(NSDictionary *)aResult
{
    NSInteger msgCode = -1;
    NSString *aMsgCodeStr = [aResult objectForKey:@"msgcode"];
    if (![NSString isNull:aMsgCodeStr]) {
        msgCode = [aMsgCodeStr integerValue];
    }
    self.downloadUrl = [aResult objectForKey:@"downloadurl"];
//    NSString *lastversion = [aResult objectForKey:@"lastversion"];
//    if (/*msgCode是来自于检查CMP壳的更新接口*/msgCode == kMustUpdate || self.mustUpdateShell/*这个参数是来自检查zip包更新的接口*/) {
//        [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
//            [self mustUpdateVersion:lastversion];
//        } priority:CMPHomeAlertPriorityUpdate];
//    }
//    else if (msgCode == kAllowedUpdate) {
//        [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
//            [self optionalUpdateVersion];
//        } priority:CMPHomeAlertPriorityUpdate];
//    }
    [self startDownloadH5Apps:self.checkUpdateAppList];
}

- (void)mustUpdateVersion:(NSString *)upToVersion
{
    if ([NSString isNull:upToVersion]) {
        upToVersion = SY_STRING(@"Common_LatestVersion");
    }
    NSString *info = [NSString stringWithFormat:SY_STRING(@"Common_MustUpdateVersion"),upToVersion];
    UIAlertView  *versonAlert = [[UIAlertView alloc] initWithTitle:SY_STRING(@"Common_Alert")
                                                           message:info
                                                          delegate:self
                                                 cancelButtonTitle:SY_STRING(@"Common_UpdateNow")
                                                 otherButtonTitles: nil];
    
    versonAlert.tag = kVerionAlertTag_MustUp;
    [versonAlert show];
}

- (void)optionalUpdateVersion
{
    UIAlertView *versonAlert = [[UIAlertView alloc] initWithTitle:SY_STRING(@"Common_Alert")
                                                          message:SY_STRING(@"Common_Update_Download")
                                                         delegate:self
                                                cancelButtonTitle:SY_STRING(@"Common_DownloadNow")
                                                otherButtonTitles:SY_STRING(@"Common_DownloadLater"), nil];
    
    versonAlert.tag = kVerionAlertTag_Optional;
    [versonAlert show];
}

- (void)redownload
{
    if (self.h5AppDownloadPause) {
        NSInteger value = [CMPCommonManager networkReachabilityStatus];
        if (value == AFNetworkReachabilityStatusReachableViaWWAN && !self.ignoreNetworkStatus) {
            __weak __typeof(self)weakSelf = self;
            CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"UpdatePackage_TipTitle")
                                        message:SY_STRING(@"UpdatePackage_TipNotWifi")
                              cancelButtonTitle:SY_STRING(@"UpdatePackage_CloseApp")
                              otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"UpdatePackage_Download"),nil]
                                       callback:^(NSInteger buttonIndex) {
                                           if (buttonIndex == 1) {
                                               weakSelf.state = CMPCheckUpdateManagerDownload;
                                               weakSelf.h5AppDownloadPause = NO;
                                               weakSelf.ignoreNetworkStatus = YES;
                                               [weakSelf downloadWithIndex:weakSelf.index];
                                               NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"start", @"state", nil];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
                                           }
                                       }];
            [alertView show];
            return;
        }
        
        self.state = CMPCheckUpdateManagerDownload;
        self.h5AppDownloadPause = NO;
        [self downloadWithIndex:self.index];
        NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"start", @"state", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
    }
}

- (void)handleErrorCheckAppListRequest:(NSError *)error
{
    // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
    [CMPCommonManager updateReachableServer:error];
    CMPServerModel *server = [[CMPCore sharedInstance].loginDBProvider inUsedServer];
    [CMPCore sharedInstance].allowRotation = [server.extend2 boolValue];
    NSDictionary *aResponseData = [server.extend4 JSONValue];
    NSDictionary *aDict = [aResponseData objectForKey:@"data"];
    
    BOOL aAllowRotation = NO;
    NSNumber *deviceAllowRotation = [aDict objectForKey:@"deviceAllowRotation"];
    if (deviceAllowRotation && [deviceAllowRotation isKindOfClass:[NSNumber class]]) {
        aAllowRotation = [deviceAllowRotation boolValue];
    }
    [CMPCore sharedInstance].allowRotation = aAllowRotation;
    
    BOOL allowPopGesture = NO;
    NSNumber *interactivePopGesture = [aDict objectForKey:@"interactivePopGesture"];
    if (interactivePopGesture && [interactivePopGesture isKindOfClass:[NSNumber class]]) {
        allowPopGesture = [interactivePopGesture boolValue];
    }
    [CMPCore sharedInstance].allowPopGesture = allowPopGesture;
    
    NSDictionary *aProductEdition = [aDict objectForKey:@"productEdition"];
    CMPV5ProductEditionModel *aV5Product = [CMPV5ProductEditionModel yy_modelWithDictionary:aProductEdition];
    [CMPCore sharedInstance].V5ProductEdition = aV5Product;
    
    // end
    // H5应用检查更新结束回调
    if (self.h5AppCheckCompletionBlock) {
        self.h5AppCheckCompletionBlock(NO);
    }
    self.h5AppCheckCompletionBlock = nil;
    [self handleOfflineMode];
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    if ([aRequest.requestID isEqualToString:self.checkAppListRequestID]) {
        // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
       [CMPCommonManager updateReachableServer:nil];
       NSDictionary *aResponseData = [aResponse.responseStr JSONValue];
       if (![aResponseData isKindOfClass:[NSDictionary class]] || aResponseData.count == 0) {
           NSError *aError = [[NSError alloc] initWithDomain:@"返回数据格式错" code:-1 userInfo:nil];
           [self handleErrorCheckAppListRequest:aError];
           return;
        }
       NSInteger code = [aResponseData[@"code"] integerValue];
        //返回code 302 的时候去掉mobile_portal,再次以最新API请求
        if (code == 302) {
            void(^againRequestBlock)(void) = [aRequest.userInfo[@"againRequestBlock"] copy];
            if (againRequestBlock) {
                againRequestBlock();
            }
            return;
        }
        // end
        NSDictionary *aDict = [aResponseData objectForKey:@"data"];
        self.mustUpdateShell = [[aDict objectForKey:@"mustUpdateShell"] boolValue];
        NSArray *aList = [aDict objectForKey:@"list"];
        // 添加防护，如果不是NSArray类型 add by guoyl at 2018/07/24
        if (![aList isKindOfClass:[NSArray class]]) {
            aList = [NSArray array];
        }
        // add end
        [[NSUserDefaults standardUserDefaults] setObject:aList forKey:[CMPCheckUpdateManager checkUpdateAppListKey]];
        self.checkUpdateAppList = [CMPPresetPackagesManager handleServerAppList:aList movedComplete:^(BOOL success) {
            
        }];
        
        //ks add -- 530
        BOOL needHandleUrlScheme = NO;
        NSNumber *aVal = [aDict objectForKey:@"newZipSchema"];
        if (aVal && [aVal isKindOfClass:[NSNumber class]]) {
            needHandleUrlScheme = [aVal boolValue];
        }
        if ([CMPPresetPackagesManager ifNeedPresetHandle]) {
            needHandleUrlScheme = [CMPPresetPackagesManager isCMPScheme];
        }
        [CMPCore sharedInstance].needHandleUrlScheme = needHandleUrlScheme;
        AppDelegate *appDelegate = [AppDelegate shareAppDelegate];
        if (needHandleUrlScheme) {
            [[CMPIntercepter sharedInstance] unregisterClass];
        }else{
            [[CMPIntercepter sharedInstance] registerClass];
        }
        //ks end
        
        // 如果没有应用包更新，直接更新成功。
        if (aList.count == 0) {
            [self handleSuccess];
        }
        
        //验证码0次判断
        [CMPCore sharedInstance].firstShowValidateCode = NO;
        id codeTimes = [aDict objectForKey:@"codeTimes"]; //codeTimes
        if ([codeTimes respondsToSelector:@selector(integerValue)]) {
            NSInteger codeTimesNum = [codeTimes integerValue];
            id codeEnable = [aDict objectForKey:@"codeEnable"]; //enable
            if (codeTimesNum == 0 && [codeEnable respondsToSelector:@selector(stringValue)] && [codeEnable isEqualToString:@"enable"]) {
                [CMPCore sharedInstance].firstShowValidateCode = YES;
            }
        }
        
        CMPLoginDBProvider *provider = [CMPCore sharedInstance].loginDBProvider;
        CMPServerModel *server = [provider inUsedServer];
        
        // 更新serverID、serverVersion
        NSString *aServerVersion = [aDict objectForKey:@"serverVersion"];
        NSString *aServerID = [aDict objectForKey:@"identifier"];
        NSDictionary *aUpdateServer = [aDict objectForKey:@"updateServer"];
        
        BOOL aAllowRotation = NO;
        NSNumber *deviceAllowRotation = [aDict objectForKey:@"deviceAllowRotation"];
        if (deviceAllowRotation && [deviceAllowRotation isKindOfClass:[NSNumber class]]) {
            aAllowRotation = [deviceAllowRotation boolValue];
        }
        
        BOOL allowPopGesture = NO;
        NSNumber *interactivePopGesture = [aDict objectForKey:@"interactivePopGesture"];
        if (interactivePopGesture && [interactivePopGesture isKindOfClass:[NSNumber class]]) {
            allowPopGesture = [interactivePopGesture boolValue];
        }
        
        NSString *privacyViewType = [aDict objectForKey:@"privacyViewType"];
        CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:server.extend10];
        if ([NSString isNotNull:privacyViewType] && [privacyViewType isEqualToString:@"1"]) {
            serverExtradDataModel.isByPopUpPrivacyProtocolPage = YES;
        } else {
            serverExtradDataModel.isByPopUpPrivacyProtocolPage = NO;
        }
        //存储是否显示手机号快捷登录tag
        NSString *phoneNumLoginEnable = aDict[@"updateServer"][@"phoneNumLoginEnable"];
        if (phoneNumLoginEnable.length) {
            serverExtradDataModel.isShowPhoneLogin = phoneNumLoginEnable;
        }else {
            serverExtradDataModel.isShowPhoneLogin = @"1";
        }
        
        serverExtradDataModel.canUseSMS = [aDict[@"productEdition"][@"canUseSMS"] boolValue];
        
        NSString *screenshotEnable = aDict[@"productEdition"][@"screenshotEnable"];
        //screenshotEnable==nil为不支持，0表示不允许截屏 ，1表示允许截屏
        if ([screenshotEnable isEqualToString:@"1"]) {
            serverExtradDataModel.screenshotType = 1;
        }else if ([screenshotEnable isEqualToString:@"0"]) {
            serverExtradDataModel.screenshotType = 0;
        }else{
            serverExtradDataModel.screenshotType = -1;
        }
        server.extend10 = [serverExtradDataModel yy_modelToJSONString];
        
        /** V7.1新增参数，区分产品线 **/
        NSDictionary *aProductEdition = [aDict objectForKey:@"productEdition"];
        CMPV5ProductEditionModel *aV5Product = [CMPV5ProductEditionModel yy_modelWithDictionary:aProductEdition];
        [CMPCore sharedInstance].V5ProductEdition = aV5Product;

        NSString *aProductEditionStr = [aProductEdition JSONRepresentation];
        [[CMPMigrateWebDataViewController shareInstance] saveV5Product:aProductEditionStr];
        
        if (![NSString isNull:aServerVersion]) {
            server.serverVersion = aServerVersion;
        } else {
            // 解决1.6.5版本升级上来没有服务器版本号问题
            server.serverVersion = [CMPCore oldServerVersion];
        }
        
        if (![NSString isNull:aServerID]) {
            server.serverID = aServerID;
        }
        
        NSString *aStr = nil;
        if ([aUpdateServer isKindOfClass:[NSDictionary class]] && aUpdateServer.count > 0) {
            aStr = [aUpdateServer objectForKey:@"url"];
            server.updateServer = [aUpdateServer JSONRepresentation];
        }
        // edit by guoyl 2018/5/20，解决偶发使用地址空白，需要重新添加服务器地址
        [provider updateServerWithUniqueID:server.uniqueID
                                  serverID:server.serverID
                             serverVersion:server.serverVersion
                              updateServer:server.updateServer
                             allowRotation:aAllowRotation
                                   appList:aResponse.responseStr
                           extraDataString:server.extend10];
        [CMPCore sharedInstance].allowRotation = aAllowRotation;
        [CMPCore sharedInstance].allowPopGesture = allowPopGesture;
        // edit end
        [CMPCore sharedInstance].currentServer = server;
        // 设置服务器信息到H5缓存Local Storage
        [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:server.h5CacheDic.JSONRepresentation];
        
        // H5应用检查更新结束回调
        if (self.h5AppCheckCompletionBlock) {
            self.h5AppCheckCompletionBlock(YES);
        }
        self.h5AppCheckCompletionBlock = nil;
        // 更新结束
        [self checkCMPShellUpdate:aStr];
    }
    else if ([aRequest.requestID isEqualToString:self.checkCMPShellRequestID]) {
        NSDictionary *aDict = [aResponse.responseStr JSONValue];
        self.cmpShellInfo = aDict;
        [self checkUpdate:self.cmpShellInfo];
    }
    else if ([aRequest.requestID isEqualToString:self.downloadApplicationZipRequestID]) {
        CMPDataResponse *fileResponce = (CMPDataResponse *)aResponse;
        NSLog(@"下载文件储存路径：%@",fileResponce.downloadDestinationPath);
        NSString *aZipApp = fileResponce.downloadDestinationPath;
        NSString *md5 = [self.currentAppInfo objectForKey:@"md5"];
        [CMPAppManager storeAppWithZipPath:aZipApp md5:md5 restAppsMap:NO];
        DownloadApplicationZipDidFinish block = aRequest.userInfo[@"block"];
        if (block) {
            block();
        }
    }
    else if ([aRequest.requestID isEqualToString:self.obtainAppDownloadUrlRequestId]) {
        [self handleObtainAppDownloadUrl:aResponse.responseStr userInfo:aRequest.userInfo];
       
    }
    else {
        if (self.h5AppDownloadPause) {
            return;
        }
        [CMPCommonManager updateReachableServer:nil];
        // store of zip file and record
        CMPDataResponse *fileResponce = (CMPDataResponse *)aResponse;
        NSLog(@"下载文件储存路径：%@",fileResponce.downloadDestinationPath);
        NSString *aZipApp = fileResponce.downloadDestinationPath;
        NSString *md5 = [self.currentAppInfo objectForKey:@"md5"];
        [self handleH5AppWithPath:aZipApp md5:md5];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    if ([aRequest.requestID isEqualToString:self.checkAppListRequestID]) {
        [self handleErrorCheckAppListRequest:error];
    }
    else if ([aRequest.requestID isEqualToString:self.checkCMPShellRequestID]) {
        self.cmpShellInfo = nil;
        [self checkUpdate:nil];
    }
    else if ([aRequest.requestID isEqualToString:self.downloadApplicationZipRequestID]) {
        [self handleErrorCheckAppListRequest:error];
    }
    else {
        NSString *zipAppName = [aRequest.requestUrl lastPathComponent];
        if ([zipAppName containsString:@"?"]) {
            zipAppName = [zipAppName componentsSeparatedByString:@"?"].firstObject;
        }
        [self handleH5AppDownloadFailByZipAppName:zipAppName];
    }
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{
    float aProgress = [[aExt objectForKey:@"progress"] floatValue];
    CGFloat aValue = self.index + aProgress;
    CGFloat result = aValue / self.appsCount;
    NSString *zipAppName = [aRequest.requestUrl lastPathComponent];//?处理
    if ([zipAppName containsString:@"?"]) {
        zipAppName = [zipAppName componentsSeparatedByString:@"?"].firstObject;
    }
    [self handleDownloadProgress:result zipAppName:zipAppName];
}

- (void)exitLater
{
    exit(0);
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kVerionAlertTag_MustUp || (alertView.tag == kVerionAlertTag_Optional && buttonIndex == 0)) {
        NSString *aStr = [DES3Util decryptDataAES128:self.downloadUrl passwordKey:[CMPCore appDownloadUrlPwd]];
        if ([NSString isNull:aStr]) {
            aStr = [CMPCore sharedInstance].checkUpdateUrl;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:aStr]];
        [self performSelector:@selector(exitLater) withObject:nil afterDelay:2];
    }
    else if (alertView.tag == kVerionAlertTag_Optional && buttonIndex == 1) {
        // 开始H5应用下载
//        [self startDownloadH5Apps:self.checkUpdateAppList];
    }
    else if (alertView.tag == KAlertViewTag_ReachabilityStatus) {
        // 非Wi-Fi下，不允许下载H5 Apps
       //[self handleH5AppDownloadFail];
        if (buttonIndex == 0) {
            exit(0);
        }
        else {
            self.ignoreNetworkStatus = YES;
            self.h5AppDownloadPause = NO;
            [self startDownload];
        }
    }
    else if (alertView.tag == kAlertViewTag_NetworkStatusChanged) {
        if (buttonIndex == 0) {
            exit(0);
        }
        else {
            self.ignoreNetworkStatus = YES;
            self.h5AppDownloadPause = NO;
            [self downloadWithIndex:self.index];
        }
    }
    [[CMPHomeAlertManager sharedInstance] taskDone];
}

- (void)networkChanged:(NSNotification *)notification
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:networkChanged:)]){
        if (![_delegate checkUpdateManager:self networkChanged:nil]) return;
    }
    
    if (self.state != CMPCheckUpdateManagerDownload) {
        return;
    }
    
    if (![CMPCommonManager reachableServer]) {
        [self handleH5AppDownloadFailByZipAppName:nil];
    }
    
    // 如果切换到4g，弹出提示
    NSInteger value = [CMPCommonManager networkReachabilityStatus];
    if (value == AFNetworkReachabilityStatusReachableViaWWAN && !self.ignoreNetworkStatus) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.currentDownloadRequestID];
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.obtainAppDownloadUrlRequestId];
        self.h5AppDownloadPause = YES;
        _networkAlertView = [self showAlertViewForWWANWithTag:kAlertViewTag_NetworkStatusChanged];
    }
}

- (UIAlertView *)showAlertViewForWWANWithTag:(NSInteger)aTag
{
    if ([CMPPresetPackagesManager ifNeedPresetHandle]) {
        self.ignoreNetworkStatus = YES;
        self.h5AppDownloadPause = NO;
        [self startDownload];
        return nil;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:showAlertViewForWWAN:)]){
        if (![_delegate checkUpdateManager:self showAlertViewForWWAN:nil]) return nil;
    }
    // 显示提示
    CMPAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"UpdatePackage_TipTitle") message:SY_STRING(@"UpdatePackage_TipNotWifi") delegate:self cancelButtonTitle:SY_STRING(@"UpdatePackage_CloseApp") otherButtonTitles:SY_STRING(@"UpdatePackage_Download"), nil];
    alertView.tag = aTag;
    [alertView show];
    return alertView;
}

- (void)startDownload
{
    if (self.state == CMPCheckUpdateManagerInit) {
        NSLog(@"update---[%s]当前状态CMPCheckUpdateManagerInit，停止下载。", __FUNCTION__);
        return;
    }
    NSLog(@"update---开始下载应用包，CMPCheckUpdateManagerDownload");
    self.state = CMPCheckUpdateManagerDownload;
    self.index = 0;
    self.md5TagArray = [NSMutableArray array];
    self.appsCount = self.downloadAppList.count;
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:startDownloadApplist:ext:)]){
        if (![self.delegate checkUpdateManager:self startDownloadApplist:self.downloadAppList ext:nil]) return;
    }
    //只有审核服务器弹框
//    NSString *host = [CMPCore sharedInstance].currentServer.host;
//    if (self.appsCount>0 && ![NSString isNull:host] && [host.lowercaseString containsString:@"seeyonapp.seeyon"]) {
//        [self startDownloadAlertWithCount:self.appsCount];
//    }else{
        [self downloadWithIndex:self.index];
//    }
    
}

- (void)startDownloadAlertWithCount:(NSInteger)appCount {
    NSArray *sizeArr = @[@1235,@1989,@1307,@628,@235,@798,@123,@887,@653];//随机大小，kb
    NSInteger totalSize = 0;//总大小
    for (int i=0; i<appCount; i++) {
        NSUInteger randomIndex = arc4random_uniform((unsigned int)sizeArr.count);
        totalSize += [[sizeArr objectAtIndex:randomIndex] integerValue];
    }
        
    NSString *tipStr = [NSString stringWithFormat:@"为了完整使用APP的服务，您需要从服务器下载%ld个应用，总计大小约%ldM",appCount,totalSize/1024];
    
    // 创建一个 UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:tipStr preferredStyle:UIAlertControllerStyleAlert];

    // 添加一个取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消并退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [alertController addAction:cancelAction];

    // 添加一个确定按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self downloadWithIndex:self.index];
    }];
    [alertController addAction:okAction];

    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:alertController animated:YES completion:nil];
}


- (void)cancelCurrentDownload
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:cancelDownload:)]){
        if (![self.delegate checkUpdateManager:self cancelDownload:nil]) return;
    }
    
    if (self.state == CMPCheckUpdateManagerCheck ||
        self.state == CMPCheckUpdateManagerDownload) {
        NSLog(@"update---取消下载应用包，CMPCheckUpdateManagerInit");
        self.state = CMPCheckUpdateManagerCancel;
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.currentDownloadRequestID];
        [[CMPDataProvider sharedInstance] cancelWithRequestId:self.obtainAppDownloadUrlRequestId];
        [self.handleH5AppOperationQueue cancelAllOperations];
        self.h5AppDownloadPause = YES;
        NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cancel", @"state", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
    }
}

- (void)stopDownload {
    [self cancelCurrentDownload];
    _updateSuccess = nil;
}

- (void)downloadApplicationZip:(DownloadApplicationZipDidFinish)block {
    CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:kM3AppID_Application
                                                    version:@"v"
                                                   serverId:kCMP_ServerID
                                                     owerId:kCMP_OwnerID];
    if (appInfo) {
        if (block) {
            block();
        }
        return;
    }
    NSString *url = [CMPCore sharedInstance].serverurl;
    
    if ([NSString isNull:url]) {
        if (block) {
            block();
        }
        return;
    }
    
    NSString *donwLoadPath = [[CMPAppManager cmpAppCachePath] stringByAppendingPathComponent:@"52.zip"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *checkApplistUrl = [NSString stringWithFormat:@"%@52",[CMPCore fullUrlPathMapForPath:@"/api/mobile/app/download/"]];
    aDataRequest.requestUrl = checkApplistUrl;
    aDataRequest.delegate = self;
    aDataRequest.downloadDestinationPath = donwLoadPath;
    aDataRequest.requestType = kDataRequestType_FileDownload;
    aDataRequest.userInfo = @{@"block" : [block copy]};
    aDataRequest.httpShouldHandleCookies = NO;
    self.downloadApplicationZipRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (BOOL)downloadWithIndex:(NSInteger )aIndex
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:downloadAppIndex:ext:)]){
        if (![_delegate checkUpdateManager:self downloadAppIndex:aIndex ext:nil]) return NO;
    }
    
    if (self.h5AppDownloadPause) {
        DDLogDebug(@"update---[%s]下载暂停", __FUNCTION__);
        return NO;
    }
    if (self.downloadAppList.count < aIndex || self.downloadAppList.count == aIndex) {
        // 下载下载完成
        [self handleSuccess];
        return NO;
    }
    
    self.currentAppInfo = [self.downloadAppList objectAtIndex:self.index];
    NSString *downloadType = [self.currentAppInfo objectForKey:@"downloadType"];
    if (downloadType && ![downloadType isKindOfClass:[NSNull class]] && downloadType.integerValue == 1) {
        //去获取应用包下载地址，人后再下载，否者直接下载
        [self obtainAppDownloadUrl];
        return YES;
    }

    NSString *appId = [self.currentAppInfo objectForKey:@"appId"];
    NSString *md5 = [self.currentAppInfo objectForKey:@"md5"];
    NSString *aTitle = [NSString stringWithFormat:@"%@.zip", appId];
    NSString *donwLoadPath = [[CMPAppManager cmpAppCachePath] stringByAppendingPathComponent:aTitle];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *url = [CMPCore sharedInstance].serverurl;
    
    if (![NSString isNull:url]) {
        NSString *checkApplistUrl = [NSString stringWithFormat:@"%@%@?checkCode=%@", [CMPCore fullUrlPathMapForPath:@"/api/mobile/app/download/"],appId, md5];
        aDataRequest.requestUrl = checkApplistUrl;
    }
    
    aDataRequest.delegate = self;
    aDataRequest.downloadDestinationPath = donwLoadPath;
    aDataRequest.requestType = kDataRequestType_FileDownload;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    self.currentDownloadRequestID = aDataRequest.requestID;
    
    [self _localTagToUpdateState:@"0"];
    return YES;
}

- (void)obtainAppDownloadUrl {
    NSString *url = [CMPCore sharedInstance].serverurl;
    if ([NSString isNull:url]) {
        return;
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *appId = [self.currentAppInfo objectForKey:@"appId"];
    NSString *md5 = [self.currentAppInfo objectForKey:@"md5"];
    NSString *checkApplistUrl = [CMPCore fullUrlForPathFormat:@"/rest/m3/appManager/downloadUrl/%@?md5=%@",appId,md5];
    aDataRequest.requestUrl = checkApplistUrl;
    
    aDataRequest.delegate = self;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.httpShouldHandleCookies = NO;
    aDataRequest.userInfo = self.currentAppInfo;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    self.obtainAppDownloadUrlRequestId = aDataRequest.requestID;
}

- (void)handleObtainAppDownloadUrl:(NSString *)response userInfo:(NSDictionary *)userInfo {
    NSDictionary *aDict = [response JSONValue];
    NSDictionary *data = aDict[@"data"];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
//        NSString *type = data[@"type"];//NSNumber?
        NSString *url = data[@"url"];
        if ([NSString isNotNull:url]) {
            NSString *appId = [userInfo objectForKey:@"appId"];
            NSString *aTitle = [NSString stringWithFormat:@"%@.zip", appId];
            NSString *donwLoadPath = [[CMPAppManager cmpAppCachePath] stringByAppendingPathComponent:aTitle];
            CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
            aDataRequest.requestUrl = url;
            aDataRequest.delegate = self;
            aDataRequest.downloadDestinationPath = donwLoadPath;
            aDataRequest.requestType = kDataRequestType_FileDownload;
            aDataRequest.httpShouldHandleCookies = NO;
            [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
            self.currentDownloadRequestID = aDataRequest.requestID;
            return;
        }
    }
    [self handleH5AppDownloadFailByZipAppName:nil];

}

- (void)handleH5AppWithPath:(NSString *)aZipAppPath md5:(NSString *)md5
{
    __weak typeof(self) weakSelf = self;
    NSString *md5Str = [md5 copy];
    NSString *zipAppPath = [aZipAppPath copy];
    NSString *aServerID = [self.currentServerID copy];
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if ([NSString isNull:zipAppPath]) {
            NSLog(@"download error!");
            [weakSelf handleH5AppDownloadFailByZipAppName:nil];
            return;
        }
        
        NSError *aError = [CMPAppManager storeAppWithZipPath:zipAppPath md5:md5Str restAppsMap:NO];
        
        if (![aServerID isEqualToString:self.currentServerID]) {
            NSLog(@"update---解压应用包成功，但Server ID已经变更");
            return;
        }
        
        if (!aError) {
            // 更新下载进度
            CGFloat v = weakSelf.index + 1;
            CGFloat result = v / weakSelf.appsCount;
            NSString *zipAppName = [zipAppPath lastPathComponent];
            zipAppName = [zipAppName stringByDeletingPathExtension];
            [weakSelf handleDownloadProgress:result zipAppName:zipAppName];//zipAppPath
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isContain = [self.md5TagArray containsObject:md5Str];
                if (!isContain) {
                    [self.md5TagArray addObject:md5Str];
                    weakSelf.index ++;
                    [weakSelf downloadWithIndex:weakSelf.index];
                } 
            });
        }
        else {
            NSLog(@"download error!");
            NSString *zipAppName = [zipAppPath lastPathComponent];
            zipAppName = [zipAppName stringByDeletingPathExtension];
            [weakSelf handleH5AppDownloadFailByZipAppName:zipAppName];
        }
    }];
    
    [self.handleH5AppOperationQueue addOperation:operation];
}

#pragma -mark custom handle
- (void)handleStart
{
    NSLog(@"update---开始检查应用包更新，CMPCheckUpdateManagerCheck");
    self.h5AppDownloadPause = NO;
    self.state = CMPCheckUpdateManagerCheck;
    self.currentServerID = [CMPCore sharedInstance].serverID;
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"start", @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
}

- (void)handleDownloadProgress:(CGFloat)aProgess zipAppName:(NSString *)zipAppName
{
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"progress", @"state", [NSNumber numberWithFloat:aProgess], @"value",zipAppName?:@"",@"zipAppName", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
}

- (void)handleSuccess
{
    if (self.state == CMPCheckUpdateManagerSuccess) {
        return;
    }
    // 下载全部下载完成
    [CMPAppManager resetAppsMap];
    if (self.downloadAppList.count > 0) {
        // 如果有H5应用更新，就需要合并文件
        [CMPAppManager startMerge];
    }
    NSLog(@"update---应用包更新成功，CMPCheckUpdateManagerSuccess");
    self.state = CMPCheckUpdateManagerSuccess;
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"success", @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
    if (self.updateSuccess) {
        self.updateSuccess();
    }
    [self _localTagToUpdateState:@"1"];
}

// 处理H5应用下载失败
- (void)handleH5AppDownloadFailByZipAppName:(NSString *)zipAppName
{
    NSLog(@"update---应用包更新失败，CMPCheckUpdateManagerFail");
    self.state = CMPCheckUpdateManagerFail;
    self.h5AppDownloadPause = YES;
    
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:@"fail", @"state",zipAppName?:@"",@"zipAppName", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AppsDownload object:aValue];
    if (self.h5AppCheckCompletionBlock) {
        self.h5AppCheckCompletionBlock(NO);
    }
    self.h5AppCheckCompletionBlock = nil;
    [self _localTagToUpdateState:@"2"];
}

- (void)handleOfflineMode {
    NSLog(@"update---进入离线模式，CMPCheckUpdateManagerOffline");
    self.state = CMPCheckUpdateManagerOffline;
    if (self.h5AppCheckCompletionBlock) {
        self.h5AppCheckCompletionBlock(NO);
    }
    self.h5AppCheckCompletionBlock = nil;
}

+ (NSString *)checkUpdateAppListKey {
    NSString *key = [NSString stringWithFormat:@"checkUpdateAppList_%@", [CMPCore sharedInstance].serverID];
    return key;
}

- (BOOL)isDownloadAllApp {
    NSArray *currentAppList = [CMPAppManager appListWithServerId:kCMP_ServerID ownerId:kCMP_OwnerID];
    NSArray *downloadList = [[NSUserDefaults standardUserDefaults] objectForKey:[CMPCheckUpdateManager checkUpdateAppListKey]];
    
    NSMutableSet *set = [NSMutableSet set];
    __block BOOL result = YES;
    [currentAppList enumerateObjectsUsingBlock:^(CMPDBAppInfo *appInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![NSString isNull:appInfo.extend1]) {
            [set addObject:appInfo.extend1];
        }
    }];
    [downloadList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![set containsObject:dic[@"md5"]]) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)canShowApp {
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:canShowApp:)]){
        return [_delegate checkUpdateManager:self canShowApp:nil];
    }
    CMPCheckUpdateManagerState checkUpdateState = [CMPCheckUpdateManager sharedManager].state;
    if (checkUpdateState != CMPCheckUpdateManagerSuccess &&
        checkUpdateState != CMPCheckUpdateManagerOffline &&
        checkUpdateState != CMPCheckUpdateManagerCancel) {
        return NO;
    } else {
        return YES;
    }
}

-(void)checkUrlState:(NSURL *)url
{
    if (_delegate && [_delegate respondsToSelector:@selector(checkUpdateManager:checkUrlState:ext:)]){
        [_delegate checkUpdateManager:self checkUrlState:url ext:nil];
    }
}

-(void)_localTagToUpdateState:(NSString *)state{
    [UserDefaults setObject:state forKey:[self _localTagForCurServerDownloadStateKey]];
}

-(NSString *)_localTagForCurServerDownloadStateKey{
    NSString *serverId = [CMPCore sharedInstance].serverID ? : @"000000";
    return [@"h5resdownloadresult_" stringByAppendingString:serverId];
}

-(BOOL)_localTagForIfDownloadFinish{
    NSString *r = [UserDefaults objectForKey:[self _localTagForCurServerDownloadStateKey]];
    return [@"1" isEqualToString:r];
}

#pragma mark-
#pragma mark Getter

- (NSOperationQueue *)handleH5AppOperationQueue {
    if (!_handleH5AppOperationQueue) {
        _handleH5AppOperationQueue = [[NSOperationQueue alloc] init];
        _handleH5AppOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _handleH5AppOperationQueue;
}

-(BOOL)firstDownloadDone{
    if (![CMPCore sharedInstance].serverID) return NO;
    return [self _localTagForIfDownloadFinish];
}

@end
