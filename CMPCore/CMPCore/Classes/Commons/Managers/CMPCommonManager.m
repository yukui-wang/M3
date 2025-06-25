//
//  CMPCommonManager.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/25.
//
//

#import "CMPCommonManager.h"
#import "AppDelegate.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPScheduleManager.h>
#import "CMPStartPageView.h"
#import "CMPHandleOpenURLWebViewController.h"
#import "CMPLocalDataPlugin.h"
#import <CMPLib/JSONKit.h>
#import <Bugly/Bugly.h>
#import <CMPLib/CMPFaceImageManager.h>
#import "CMPConstant_Ext.h"
#import <UserNotifications/UNUserNotificationCenter.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPChatManager.h"
#import "M3LoginManager.h"
#import "CMPMessageManager.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/CMPURLCacheUtil.h>
#import "RCIM+InfoCache.h"
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>
#import "CMPCustomManager.h"
#import <CMPVpn/CMPVpnManager.h>

// 设备网络状态
NSString * const CMPConnectionStatusNone = @"none";
NSString * const CMPConnectionStatusCellular = @"cellular";
NSString * const CMPConnectionStatusWifi = @"wifi";
NSString * const CMPConnectionStatusUnknown = @"unknown";

// 服务器状态
NSString * const CMPServerConnect = @"connect";  // 服务器已链接
NSString * const CMPServerDisconnect = @"disconnect";  // 服务器断开链接

NSString * const CMPNetworkType = @"networkType";
NSString * const CMPServerStatus = @"serverStatus";


#define kUserDefaultKey_StartPageBackgroundImageFileId ([[CMPCore sharedInstance].serverurl stringByAppendingString:@"_startPageBackgroundImageFileId"])
#define kUserDefaultKey_StartPageBackgroundImageData ([[CMPCore sharedInstance].serverurl stringByAppendingString:@"_startPageBackgroundImageData"])
#define kUserDefaultKey_StartPageLogoData ([[CMPCore sharedInstance].serverurl stringByAppendingString:@"_startPageLogoData"])
#define kUserDefaultKey_UserHeadImageData ([[[CMPCore sharedInstance].serverurl stringByAppendingString:[CMPCore sharedInstance].userID] stringByAppendingString:@"_userHeadImageData"])

typedef enum : NSUInteger {
    AccountStartPageBGPath,
    AccountStartPageLandBGPath,
    AccountStartPageLogoPath,
    AccountStartPageDirPath,
    AllStartPageDirPath
} StartPagePaths;

@implementation CMPCommonManager

+ (AppDelegate *)appdelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UIWindow *)keyWindow
{
    AppDelegate *delegate = [CMPCommonManager appdelegate];
    return delegate.window;
}

// 开启网络类型监听
+ (void)startMonitoringForNetwork
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [CMPCommonManager sendNetworkStatusChangeNotifi];
    }];
    [mgr startMonitoring];
}

// 当前网络是否可用wifi、3G、4G
+ (BOOL)reachableNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}
// 当前网络状态
+ (NSInteger)networkReachabilityStatus
{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

// 获取设备网络类型
+ (NSString *)networkType {
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    NSString *result;
    
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            result = CMPConnectionStatusUnknown;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            result = CMPConnectionStatusNone;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            result = CMPConnectionStatusCellular;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            result = CMPConnectionStatusWifi;
            break;
        default:
            result = CMPConnectionStatusUnknown;
            break;
    }
    
    return result;
}

// 获取服务器连接状态
+ (NSString *)serverStatus
{
    NSString *result = CMPServerDisconnect;
    // 如果可以连接服务器
    if ([CMPCommonManager reachableServer]) {
        result = CMPServerConnect;
    }
    return result;
}

+ (NSDictionary *)networkStatusInfo
{
    NSString *aNetworkType = [CMPCommonManager networkType];
    NSString *aServerStatus = [CMPCommonManager serverStatus];
    NSDictionary *aValue = [NSDictionary dictionaryWithObjectsAndKeys:aNetworkType, CMPNetworkType,  aServerStatus, CMPServerStatus, nil];
    return aValue;
}

+ (void)sendNetworkStatusChangeNotifi
{
    NSDictionary *aValue = [CMPCommonManager networkStatusInfo];
    NSString *aNetworkType = aValue[CMPNetworkType];
    NSString *aServerStatus = aValue[CMPServerStatus];
    NSString *aOldNetworkType = nil;
    NSString *aOldServerStatus = nil;
    
    if (lastNetworkStatus) {
        aOldNetworkType = lastNetworkStatus[CMPNetworkType];
        aOldServerStatus = lastNetworkStatus[CMPServerStatus];
    }
    
    if ([aNetworkType isEqualToString:aOldNetworkType] && [aOldServerStatus isEqualToString:aServerStatus]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_NetworkStatusChange object:nil userInfo:aValue];
    [lastNetworkStatus release];
    lastNetworkStatus = [aValue retain];
}

// 是否可以连接服务器
static bool _reachableServer;
/** 保存上一次网络状态 **/
static NSDictionary *lastNetworkStatus;

// 是否可以连接服务器
+ (BOOL)reachableServer
{
    // 如果当前设备连接不上网络
    if (![CMPCommonManager reachableNetwork]) {
        return NO;
    }
    return _reachableServer;
}

+ (void)updateReachableServer:(NSError *)aError
{
    _reachableServer = YES;
    NSInteger errorCode = aError.code;
    if (errorCode == -998 || errorCode == -1001 || errorCode == -1002 || errorCode == -1003 || errorCode == -1004 || errorCode == -1005 || errorCode == -1009 || errorCode == 502 || errorCode == 503) {
        _reachableServer = NO;
    }
    [CMPCommonManager sendNetworkStatusChangeNotifi];
}

+ (void)userLogin
{
    // 删除当前登陆人的头像缓存
    [CMPCommonManager removeCurrentUserFaceCache];
}

+ (void)clearApplicationIconBadgeNumber
{
    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount+1];
    if (IOS10_Later) {
        UNUserNotificationCenter *aCenter = [UNUserNotificationCenter currentNotificationCenter];
        [aCenter removeAllPendingNotificationRequests];
        [aCenter removeAllDeliveredNotifications];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    [CMPCore sharedInstance].applicationIconBadgeNumber = badgeCount;
}

// 更新应用图标的数字
+ (void)updateApplicationIconBadgeNumber
{
    NSInteger number = [CMPCore sharedInstance].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

+ (void)addNotificationListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin) name:kNotificationName_UserLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyBoardInWindow) name:kNotificationName_GestureWillShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdateUserHead:) name:kNotificationName_ChangeIcon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnLogout:) name:@"kNotification_vpnLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnRenewPwd:) name:kVPNNotificationName_ProcessRenewPwd object:nil];
}

+(void)vpnRenewPwd:(NSNotification *)noti
{
    [[AppDelegate shareAppDelegate] performSelector:NSSelectorFromString(@"vpnRenewPwd:") withObject:noti];
}

+(void)vpnLogout:(NSNotification *)noti
{
    id obj = noti.object;
    if (!obj[@"errStr"] || ((NSString *)obj[@"errStr"]).length ==0 ) {
        return;
    }
    NSError *newError = [NSError errorWithDomain:[@"VPN: " stringByAppendingString:obj[@"errStr"]] code:-33001 userInfo:obj];
    [[AppDelegate shareAppDelegate] handleError:newError];
}

//OA-114074 iPhone客户端，键盘弹出的情况下。当手机锁屏后，再次开启，进入到手势密码页面。键盘不能收起
+ (void)resignKeyBoardInWindow
{
    [CMPCommonManager resignKeyBoardInView:[UIApplication sharedApplication].keyWindow];
}

+ (void)resignKeyBoardInView:(UIView *)view
{
    for (UIView *v in view.subviews) {
        if ([v.subviews count] > 0) {
            [self resignKeyBoardInView:v];
        }
        if ([v isKindOfClass:[UITextView class]] || [v isKindOfClass:[UITextField class]]) {
            if ([v isFirstResponder]) {
                [v resignFirstResponder];
            }
        }
    }
}

+ (NSString *)currentAccountStartPagePath:(NSUInteger)item
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *startPageDirPath = [documentPath stringByAppendingPathComponent:@"StartPageFile"];
    NSString *accountStartPageDirPath = [startPageDirPath stringByAppendingPathComponent:[CMPCore sharedInstance].currentUser.accountID];
    
    NSString *path = nil;
    if (item == AccountStartPageBGPath) {
        path = [accountStartPageDirPath stringByAppendingPathComponent:@"bg.png"];
    } if (item == AccountStartPageLandBGPath) {
        path = [accountStartPageDirPath stringByAppendingPathComponent:@"land_bg.png"];
    } else if (item == AccountStartPageLogoPath){
        path = [accountStartPageDirPath stringByAppendingPathComponent:@"logo.png"];
    } else if (item == AccountStartPageDirPath){
        path = accountStartPageDirPath;
    } else if (item == AllStartPageDirPath){
        path = startPageDirPath;
    }
    return path;
}

+ (UIImage *)getStartPageBackgroundImage
{
    return [UIImage imageWithContentsOfFile:[self currentAccountStartPagePath:AccountStartPageBGPath]];
}

+ (UIImage *)getStartPageLandscapeBackgroundImage
{
    return [UIImage imageWithContentsOfFile:[self currentAccountStartPagePath:AccountStartPageLandBGPath]];
}

+ (UIImage *)getStartPageLogoImage
{
    return [UIImage imageWithContentsOfFile:[self currentAccountStartPagePath:AccountStartPageLogoPath]];
}

+ (void)createStartPageDirPath
{
    NSString *path = [self currentAccountStartPagePath:AccountStartPageDirPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)getStartPageBackgroundPath
{
    return [self currentAccountStartPagePath:AccountStartPageBGPath];
}

+ (NSString *)getStartPageLandBackgroundPath
{
    return [self currentAccountStartPagePath:AccountStartPageLandBGPath];
}

+ (NSString *)getStartPageLogoPath
{
    return  [self currentAccountStartPagePath:AccountStartPageLogoPath];
}

+ (void)getUserHeadImageComplete:(void(^)(UIImage *image))complete cache:(BOOL)aCache
{
    [[CMPFaceImageManager sharedInstance] fetchfaceImageWithMemberId:[CMPCore sharedInstance].userID complete:complete cache:aCache];
}

+ (void)notificationUpdateUserHead:(NSNotification *)noti {
    [CMPCommonManager updateMemberIconInfo];
}

+ (void)updateMemberIconInfo {
    NSString *aMemberId = [CMPCore sharedInstance].userID;
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    [[CMPFaceImageManager sharedInstance] clearWithMemberId:aMemberId serverId:aServerId];
    // 删除当前登陆人的头像缓存
    [CMPCommonManager removeCurrentUserFaceCache];
    [[CMPCore sharedInstance] updateMemberIconTime];
    [[RCIM sharedRCIM] refreshUserPortraitUriCacheWithUserId:aMemberId];
}

+ (void)updateMemberIconInfoWithUserId:(NSString *)userId {
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    [[CMPFaceImageManager sharedInstance] clearWithMemberId:userId serverId:aServerId];
    // 删除当前登陆人的头像缓存
    [CMPCommonManager removeUserFaceCacheWithUserId:userId];
    [[RCIM sharedRCIM] refreshUserPortraitUriCacheWithUserId:userId];
}


+ (BOOL)shouldOpenHandleRemoteMessageViewController
{
    NSDictionary *dic = [CMPCore sharedInstance].remoteNotifiData;
    if (dic) {
        NSDictionary *options = [dic[@"options"] JSONValue];
        BOOL isChat = [options[@"appId"] isEqualToString:@"61"];
        BOOL isReadOnly = [options[@"readOnly"] isEqualToString:@"readonly"];
        NSString *serverId = options[@"serverId"];
        if (![serverId isEqualToString:[CMPCore sharedInstance].serverID]) {
            [CMPCore sharedInstance].remoteNotifiData = nil;
            return NO;
        }
        if (isChat || (!isChat && !isReadOnly)) {
            return YES;
        }
    }
    [CMPCore sharedInstance].remoteNotifiData = nil;
    return NO;
}

+ (void)showRobot:(BOOL)aShow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch object:[NSNumber numberWithBool:aShow]];
}

+ (void)initAnalysisModule {
    [[self class] initBugly];
    [[self class] initUApp];
}

+ (void)initBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
#if DEBUG
    config.debugMode = YES;
#endif
    config.blockMonitorEnable = YES;
    config.channel = @"M3Bugly";
    config.consolelogEnable = YES;
    config.viewControllerTrackingEnable = NO;
    
    NSString *appId = @"488abd1a13";
#if APPSTORE
    appId = @"83b6635eab";
    config.consolelogEnable = NO;
#endif
    
    // NOTE:Required
    // Start the Bugly sdk with APP_ID and your config
    [Bugly startWithAppId:appId  // 测试阶段使用，正式版本需要修改
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];
    
    NSString *aUserName = [CMPCore sharedInstance].userName;
    if (!aUserName) {
        aUserName = @"user";
    }
    NSString *server = [CMPCore sharedInstance].currentServer.fullUrl;
    if (!server) {
        server = [UIDevice currentDevice].name;
    }
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"%@:%@",  aUserName,server]];
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"M3Process"];
    [config release];
}

+ (void)initUApp {
    [UMConfigure initWithAppkey:@"60371ae9425ec25f10038902" channel:[CMPCommonManager isM3InHouse] ? @"inHouse" : @"appstore"];
    [UMConfigure setEncryptEnabled:YES];
}

+ (void)reportUAppWithAccount:(NSString *)aAccount
{
    [MobClick profileSignInWithPUID:aAccount];
}

+ (void)removeCurrentUserFaceCache
{
    NSString *imageUrl = [CMPCore fullUrlForPathFormat:kMemberIconUrl_M3_Param,CMP_USERID];
    [CMPURLCacheUtil removeCachedData:imageUrl];
}

+ (void)removeUserFaceCacheWithUserId:(NSString *)userId
{
    NSString *imageUrl = [CMPCore fullUrlForPathFormat:kMemberIconUrl_M3_Param,userId];
    [CMPURLCacheUtil removeCachedData:imageUrl];
}

+ (NSString *)baiduPushKey
{
    if ([CMPCommonManager isM3InHouse]) {
        return kBaiDuPushKeyM3InHouse;
    }
    return [CMPCustomManager matchValueFromOri:kBaiDuPushKeyM3InAppStore andCus:[CMPCustomManager sharedInstance].cusModel.baiduApiKey];
}

+ (NSString *)lbsAPIKey
{
    if ([CMPCommonManager isM3InHouse]) {
        return kLBSAPIKeyM3InHouse;
    }
    return [CMPCustomManager matchValueFromOri:kLBSAPIKeyM3InAppStore andCus:[CMPCustomManager sharedInstance].cusModel.gaodeApiKey];
}

+ (NSString *)lbsGoogleAPIKey
{
    return kLBSGoogleAPIKey;
}

+ (NSString *)lbsWebAPIKey
{
    return kLBSWebAPIKeyM3;
}

+ (NSString *)pushMsgClientProtocolType
{
    if ([CMPCommonManager isM3InHouse]) {
        return kC_iMessageClientProtocolType_IPhoneInHouse;
    }
    return kC_iMessageClientProtocolType_IPhone;
}

+ (NSString *)checkCMPShellUpdateUrl:(NSString *)aUrl
{
    NSString *aClinetVersion = [CMPCore clinetVersion];
    NSString *aServerVersion = [CMPCore sharedInstance].currentServer.serverVersion;
    NSString *accountType = kAccountType_Undefined;
    //
    if ([CMPCommonManager isM3InHouse]) {
        accountType = kAccountType_InHouse;
    }
    else {
        accountType = kAccountType_AppStore;
    }
    NSString *urlStr = [NSString stringWithFormat:kCheckVersionUrl_M3_Param, aUrl, aClinetVersion, aServerVersion, accountType];
    return urlStr;
}

+ (NSString *)prefixAppID
{
    if ([CMPCommonManager isM3InHouse]) {
        return kM3PrefixAppIDInHouse;
    }
    return [CMPCustomManager matchValueFromOri:kM3PrefixAppIDInAppStore andCus:[CMPCustomManager sharedInstance].cusModel.bundleIdWithPrefix];
}

+ (NSString *)leboHpPlayAppID
{
    if ([CMPCommonManager isM3InHouse]) {
        return kM3PrefixAppIDInHouse;
    }
    return [CMPCustomManager matchValueFromOri:kM3PrefixAppIDInAppStore andCus:[CMPCustomManager sharedInstance].cusModel.bundleIdWithPrefix];
}

+ (NSString *)leboHpPlayAppKey
{
    if ([CMPCommonManager isM3InHouse]) {
        return kM3PrefixAppIDInHouse;
    }
    return [CMPCustomManager matchValueFromOri:kM3PrefixAppIDInAppStore andCus:[CMPCustomManager sharedInstance].cusModel.bundleIdWithPrefix];
}

// 是否是企业版本
+ (BOOL)isM3InHouse
{
    NSDictionary *aDict = [[NSBundle mainBundle] infoDictionary];
    NSString *aBundleIdentifier = [aDict objectForKey:@"CFBundleIdentifier"];
    if ([aBundleIdentifier isEqualToString:kM3AppIDInHouse]) {
        return YES;
    }
    return NO;
}

//隐私协议url
+ (NSString *)privacyAgreementUrl {
    NSString *language = [CMPCore languageCode];//[NSLocale preferredLanguages][0];
    NSString *urlStr = [NSString stringWithFormat:@"http://m3.seeyon.com/privacy/index.html?language=%@", language];
#if CUSTOM
    urlStr = [CMPCustomManager sharedInstance].cusModel.privacyPath;
#endif
    return urlStr;
}

+(void)outputAppStartLoadTimeCostWithDes:(NSString *)des
{
    double costTime = (CFAbsoluteTimeGetCurrent() - StartTime);
    NSLog(@"ks log --- loginopt_loadcost -- %@ : %f -- current thread：%@",des,costTime,[NSThread currentThread]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    if (paths.count) {
        NSString *docPath = paths[0];
        NSString *parPath = [docPath stringByAppendingPathComponent:@"LoadLog"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:parPath isDirectory:&isDir];
        if (existed && !isDir) {
            [fileManager removeItemAtPath:parPath error:nil];
            existed = NO;
        }
        if (!existed) {
            [fileManager createDirectoryAtPath:parPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *fileName = @"load_log.txt";// [NSString stringWithFormat:@"load_%5f.txt",[[NSDate date] timeIntervalSinceNow]*1000];
        NSString *subPath = [parPath stringByAppendingPathComponent:fileName];
        NSString *str = [NSString stringWithFormat:@"\n%@ *** %f *** current thread：%@",des,costTime,[NSThread currentThread]];
        if ([str containsString:@"Appdelegate init start"]) {
            str = [@"\n" stringByAppendingString:str];
        }
        NSData *da = [str dataUsingEncoding:NSUTF8StringEncoding];
        if (![fileManager fileExistsAtPath:subPath]) {
            BOOL su = [fileManager createFileAtPath:subPath contents:nil attributes:nil];
            if (!su) {
                
            }
            [da writeToFile:subPath atomically:YES];
        }else{
            NSMutableData *oldData = [NSMutableData dataWithContentsOfFile:subPath];
            [oldData appendData:da];
            [oldData writeToFile:subPath atomically:YES];
        }
        
    }
}

+(BOOL)isSeeyonRobotByUid:(NSString *)uid
{
    if (!uid || !uid.length) {
        return NO;
    }
    NSString *curAccId = [CMPCore sharedInstance].currentUser.accountID;
    if ([kAccountId_Seeyon isEqualToString:curAccId] && [kUserId_ZXRobot isEqualToString:uid]) {
        return YES;
    }
    return NO;
}

@end
