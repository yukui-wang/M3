//
//  AppDelegate.m
//  CMPCore
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#define kDesktopUrl @"cmpDemoDesktop://"
#define kSSOLoginScheme @"seeyonm3phone"

#import "AppDelegate.h"
#import "BPush.h"
#import "CMPHandleOpenURLWebViewController.h"
#import "CMPPushRemind.h"
#import "CMPCheckUpdateManager.h"
#import "CMPGestureHelper.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPTabBarViewController.h"
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPConstant.h>
#import <AVFoundation/AVFoundation.h>
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPSafeUtils.h>
#import "CMPMigrateWebDataViewController.h"
#import "CMPServerEditViewController.h"
#import "CMPStartPageViewHelper.h"
#import "CMPGuidePagesViewHelper.h"
#import "M3LoginManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPCookieTool.h"
#import <CMPLib/CMPURLProtocol.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPSSOHelper.h"
#import <CMPLib/CMPScreenShotView.h>
#import <CMPLib/CocoaLumberjack.h>
#import "CMPLocalAuthenticationHelper.h"
#import "CMPLocalAuthenticationState.h"
#import "CMPHomeAlertManager.h"
#import "CMPWiFiClockInHelper.h"
#import "CMPLocalAuthenticationTools.h"
#import "KWOfficeApi.h"
#import "CMPAutoLockTool.h"
#import "CMPLoginConfigInfoModel.h"
#import "CMPNewVersionTipView.h"
#import "CMPTopScreenGuideView.h"
#import "CMPUpgradeToEncryptedDatabaseHelper.h"
#import "CMPCore_XiaozhiBridge.h"
#import "CMPPadTabBarViewController.h"
#import "CMPPhoneTabBarViewController.h"
#import "CMPLocationManager.h"
#import "CMPDeviceBindingProvider.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/SOLocalization.h>
#import "CMPLanguageHelper.h"
#import <CMPLib/AttachmentReaderParam.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPFileManager.h>
#import <RongIMKit/RCMessageModel.h>
#import "CMPShareManager.h"
#import "CMPScreenshotControlManager.h"
#import "CMPChatManager.h"
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPCAAnimation.h>
#import <CMPLib/GTMUtil.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPFeatureSupportControlHeader.h>
#import "CMPPrivacyProtocolWebViewController.h"
#import "CMPUserNotificationSettingHelper.h"
#import "WXApi.h"
#import <CMPLib/CMPCustomAlertView.h>
#import <CMPLib/KSLogManager.h>
#import <CMPLib/CMPDocWatcherManager.h>
#import <CMPLib/CMPJSLocalStorageManager.h>
#import "CMPInvoiceWechatHelper.h"
#import <CMPVpn/CMPVpn.h>
#import "CDVFile.h"
#import <CMPLib/KSRequestLogManager.h>
#import "M3-Swift.h"
#import "CMPCustomManager.h"
#import "CMPMsgQuickHandler.h"
#import <CMPLib/CMPIntercepter.h>
#import "CMPMessageListViewController.h"
@interface AppDelegate() <CMPGestureHelperDelegate> {
    UINavigationController *_handleNotifiWebViewNavCtrl; // 查看离线消息NavController
    CMPStartPageViewHelper *_startPageViewHelper;
    CMPGuidePagesViewHelper *_guidePagesViewHelper;
    CMPServerEditViewController *serverEditVc;
    __block BOOL _isBeingDelayed;
}

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskIdentifier; // 后台运行线程
@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, assign) BOOL isLunchNotifiViewController;// 是否是启动
@property (nonatomic, strong) CMPSSOHelper *ssoHelper; // 单点登录
@property (nonatomic, strong) CMPWiFiClockInHelper *wifiClockInHelper; // WiFi快捷打卡
@property (strong, nonatomic) CMPAutoLockTool *autoLockTool; // 自动锁屏


@end

@implementation AppDelegate

@synthesize window;


#pragma mark-
#pragma mark Init

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearViews:nil];
}

- (id)init {
    if (self = [super init]) {
#if DEBUG
        [[KSLogManager shareManager] setDev:YES];
#elif RELEASE
        [[KSLogManager shareManager] setDev:YES];
#endif
        if (![[[UIDevice currentDevice] model] hasSuffix:@"Simulator"] && !isatty(STDOUT_FILENO)) {//非连接Xcode调试
            [[KSLogManager shareManager] redirectNSlogToDocumentFolderWithIde:nil];
        }
        
//        [CMPCommonManager outputAppStartLoadTimeCostWithDes:[NSString stringWithFormat:@"Appdelegate init start (StartTime:%f)",StartTime]];
        
        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
        int cacheSizeDisk = 100 * 1024 * 1024; // 100MB
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:nil];
        [NSURLCache setSharedURLCache:cache];
        
        NSNumber *openTag = [UserDefaults valueForKey:@"udcmp_vpnopen"];
        if (openTag && openTag.integerValue == 1) {
            [CMPVpnManager sharedInstance];//初始化vpn sdk需要在NSURLProtocol拦截方法之前
        }else{
            __weak typeof(self) wSelf = self;
            [CMPVpnManager setManagerBlk:^(NSInteger act, id ext) {
                switch (act) {
                    case 1:
                        [[CMPIntercepter sharedInstance] unregisterClass];
                        break;
                    case 2:
                        [[CMPIntercepter sharedInstance] registerClass];
                        break;

                    default:
                        break;
                }
            }];
        }
        [[CMPIntercepter sharedInstance] registerClass];
    }
    return self;
}

+ (AppDelegate *)shareAppDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(dispatch_group_t)alertGroup {
    if (!_alertGroup) {
        _alertGroup = dispatch_group_create();
        NSLog(@"清空 _alertGroup");
    }
    return _alertGroup;
}

#pragma mark-
#pragma mark UIApplicationDelegate implementation
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__func__);
    //升级数据库为加密数据库
    [CMPUpgradeToEncryptedDatabaseHelper upgradeToEncryptedDatabase];
    
    [self initLauguage];
    [self initDDLog];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *aController = [[UIViewController alloc] init];
    aController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = aController;
    self.window.autoresizesSubviews = YES;
    self.launchOptions = launchOptions;
    
    if ([KSLogManager shareManager].isDev) {
//        [[CMPDocWatcherManager shareManager] watchFolderWithPath:nil];
        NSLog(@"ks log --- %s -- launchoptions:%@",__FUNCTION__,launchOptions);
        
        NSArray*libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libPath = libPaths[0];
        NSString *bundleId =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *plist = [NSString stringWithFormat:@"%@/Preferences/%@.plist",libPath,bundleId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:plist]) {
            NSDictionary *defaultDic = [NSDictionary dictionaryWithContentsOfFile:plist];
            NSLog(@"ks log -- userdefault : %@",defaultDic);
        }
        NSArray<CMPServerModel *> *serverList = [CMPCore sharedInstance].loginDBProvider.listOfServer;
        NSMutableArray *arr = [NSMutableArray array];
        for (CMPServerModel *server in serverList) {
            [arr addObject:@{@"ip":server.host,@"port":server.port}];
        }
        NSLog(@"ks log -- serverlist : %@",arr);
        
        NSString *sid = [CMPCore sharedInstance].currentUser.loginName;
        NSLog(@"ks log -- loginname : %@",sid);
        
        NSDictionary *alllocal = [CMPJSLocalStorageManager allLocalStorageInfo];
        NSLog(@"ks log -- alljslocal : %@",alllocal);
    }
    
    [self initUserInterfaceStyle];
    
    // 是否需要显示启动页
    // 1、判断是否显示启动页
    BOOL aNeedShowStartPageView = [CMPStartPageViewHelper needShowStartPageView];
    self.aNeedShowGuidePagesView = [CMPGuidePagesViewHelper needShowGuidePagesView];
    if (aNeedShowStartPageView) {
        [self showStartPageView];
    }
    
    //开启轮询定位
    //[CMPLocationManager.shareLocationManager startLastingLocationCallBack:nil];
    
    // 初始化MTA、Bugly
    //[CMPCommonManager initAnalysisModule];
    // 启动监听
    [CMPCommonManager addNotificationListener];
    // 开启网络监听
    [CMPCommonManager startMonitoringForNetwork];
    
    // 离线登陆，设置Cookie
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        [CMPCookieTool restoreCookies];
    }
    
    // 判断是否是通过URL启动
    __weak typeof(self) weakSelf = self;
    NSURL *launchUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (![CMPSSOHelper cotainSSOParam:launchUrl]) { // 不是通过SSO方式打开
        [[CMPMigrateWebDataViewController shareInstance] startMigrateWebDataToNative:^(NSError *error) {
            [weakSelf checkUpdate];
        }];
    }
    
    NSDictionary *remoteNotificationUserInfo = self.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *rcInfo = remoteNotificationUserInfo[@"rc"];
    if (rcInfo && [rcInfo isKindOfClass:[NSDictionary class]]) { // 融云消息直接跳转到消息列表界面
        self.launchFromNotification = YES;
        self.launchFromNotificationStartTime = [NSDate date];
    }
    
    //离线消息数
    [CMPCommonManager clearApplicationIconBadgeNumber];
    
    //截屏初始化配置
    [CMPScreenshotControlManager.sharedManager initializeScreenshotConfig];
    
#if DEBUG
    // DEBUG版本不需要加固
#else
    // 开启安全加固
    [self safeProtect];
#endif

    return YES;
}

//设置支持的语言及默认语言
- (void)initLauguage {
    NSString *serverId = [CMPCore sharedInstance].currentServer.serverID;
    if ([NSString isNull:serverId]) {
        [SOLocalization configSupportRegions:[SOLocalization loacalSupportRegions] fallbackRegion:SOLocalizationEnglish serverId:serverId];
        return;
    }
    
    if ([CMPCore sharedInstance].isSupportSwitchLanguage) {
        [SOLocalization configSupportRegions:[SOLocalization loacalSupportRegions] fallbackRegion:SOLocalizationEnglish serverId:serverId];
    } else{
        [SOLocalization configSupportRegions:[SOLocalization lowerVersionLoacalSupportRegions] fallbackRegion:SOLocalizationEnglish serverId:serverId];
    }
}

//设置当前显示模式
- (void)initUserInterfaceStyle {
    [[CMPThemeManager sharedManager] setUserInterfaceStyle];
}

- (void)initDDLog {
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // 打开Xcode console
#endif
    // 仅299版本打印文件日志
    if ([CMPCommonManager isM3InHouse]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *logPath = [documentsPath stringByAppendingPathComponent:@"logs"];
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:logPath]];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
    }
}

- (void)checkUpdate {
    __weak typeof(self) weakSelf = self;
    void(^aBlk)(void) = ^{
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 弹出隐私协议
                [weakSelf singlePopUpPrivacyProtocolPage];
                //[weakSelf startApp];
            });
        }];
    };
    
    NSString *serverID = [CMPCore sharedInstance].serverID;
    if (serverID && serverID.length >0) {
        CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:serverID];
        if (vpnModel.vpnUrl && ![CMPVpnManager isVpnConnected]) {
            [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                            
                        } success:^(id obj, id ext) {
                            aBlk();
                        } fail:^(id obj, id ext) {
                            NSString *errStr = @"VPN错误";
                            if ([obj isKindOfClass:NSString.class]) {
                                errStr = obj;
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf cmp_showHUDWithText:errStr completionBlock:^{
                                    CMPNavigationController *aNav = [[CMPNavigationController alloc] initWithRootViewController:[M3LoginManager loginViewController]];
                                    weakSelf.window.rootViewController = aNav;
                                }];
                            });
                        }];
        }else{
            aBlk();
        }
    }else{
        aBlk();
    }
}

- (void)judgeAndShowGuidePagesView {
    // 是否显示引导页
    if (self.aNeedShowGuidePagesView) {
           // 需要隐藏启动页
       [self hideStartPageView];
       [self showGuidePagesView];
    }
}

- (void)startApp {
    //ks fix -- 将注册消息推送移到隐私框后，里面包含百度注册推送（百度里面还包含获取定位权限，已去掉）
    // 注册消息推送token
    [self registerNotification:self.launchOptions application:(UIApplication *)self];
    // ks end
    [CMPCommonManager initAnalysisModule];
    [self judgeAndShowGuidePagesView];
    [CMPCore configLocalUiskin];
    
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    // 是否需要到登录界面,判断用户名、密码是否存在
    if (!aLoginManager.isAutoLogin) {
        UIViewController *vc = [M3LoginManager loginViewController];
        CMPNavigationController *aNav = [[CMPNavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = aNav;
        // 需要隐藏启动页
        [self hideStartPageView];
//#if CUSTOM
        if ([vc respondsToSelector:NSSelectorFromString(@"_autoConfigDefaultServer")]) {
            [vc performSelector:NSSelectorFromString(@"_autoConfigDefaultServer")];
        }
//#endif
        return;
    }
    
    
    
    // 7.1新增功能
    // 判断面容、指纹解锁是否开启
    if (([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID ||
         [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID)) {
        if ([CMPLocalAuthenticationTools supportType] == CMPLocalAuthenticationTypeNone) {
            if (aLoginManager.hasSetGesturePassword) {
                [self showGestureVerifyView:aLoginManager.currentAccount ext:nil];
            } else {
                // 清空密码，并返回登录页
                NSString *aServerId = [CMPCore sharedInstance].serverID;
                [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:aServerId];
                [M3LoginManager clearHistoryPhone];
                [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
            }
        } else {
            [self showLocalAuthViewWithExt:nil];
        }
        return;
    }
    
    // 是否需要显示手势密码解锁
    if (aLoginManager.hasSetGesturePassword) {
        // 手机盾新增：手机盾是否显示验证弱手势
        BOOL mokey_showWeak = [M3LoginManager.sharedInstance mokey_login_relevantShow];
        if (mokey_showWeak == NO) {
            [self showGestureVerifyView:aLoginManager.currentAccount ext:nil];
            return;
        }
    }
    
    // 是否自动登录, 根据用户名、密码自动登录
    __weak typeof(self) weakSelf = self;
    [self _autoLoginWithStart:^{
        
    } success:^{
        [CMPMsgQuickHandler shareInstance].enterRoute = 0;
        [weakSelf showTabBarWithHideAppIds:nil didFinished:nil];
    } fail:^(NSError *error) {
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
    } ext:nil];
}

/**
 展示面容ID识别页面
 */
- (void)showLocalAuthViewWithExt:(id __nullable)ext {
    [self hideStartPageView];
    CMPLocalAuthenticationHelper *helper = [[CMPLocalAuthenticationHelper alloc] init];
    helper.tapGestureView = ^{
        CMPLoginAccountModel *loginAccount = [M3LoginManager sharedInstance].currentAccount;
        [[AppDelegate shareAppDelegate] showGestureVerifyView:loginAccount ext:ext];
    };
    
    __weak __typeof(self)weakSelf = self;
    [helper authWithCompletion:^(BOOL result, NSError *error) {
        if (!result) {
            // 指纹被锁定，弹出手势识别、跳转到登录页面
            if ([CMPLocalAuthenticationTools isLocked]) {
                M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
                if (aLoginManager.hasSetGesturePassword) {
                    [self showGestureVerifyView:aLoginManager.currentAccount ext:ext];
                } else {
                    // 清空密码，并返回登录页
                    NSString *aServerId = [CMPCore sharedInstance].serverID;
                    [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:aServerId];
                    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
                }
                [helper hide];
                //ks fix --客户bug BUG2023121283137
                [CMPLocalAuthenticationState updateFaceID:NO];
                [CMPLocalAuthenticationState updateTouchID:NO];
                //end
                //ks fix -- V5-41284【指纹登陆】IOS指纹登陆多次失败后强制用户返回登录页，无必要提示
                NSString *typeStr = @"";
                CMPLocalAuthenticationType authType = [CMPLocalAuthenticationTools supportType];
                if (authType == CMPLocalAuthenticationTypeFaceID) {
                    typeStr = @"面部";
                }else if (authType == CMPLocalAuthenticationTypeTouchID) {
                    typeStr = @"指纹";
                }
                [[UIViewController currentViewController] cmp_showHUDToBottomWithText:[typeStr stringByAppendingString:@"解锁失败，请稍后重试"]];
                //end
            }
            return;
        }
        
        [weakSelf _autoLoginWithStart:^{
            
        } success:^{
            [[CMPMigrateWebDataViewController shareInstance] performSelector:NSSelectorFromString(@"_refreshJsAllLocalStorage")];
            [weakSelf showTabBarWithHideAppIds:nil didFinished:^{
                [helper hide];
            }];
        } fail:^(NSError *error) {
            [helper hide];
            NSError *aError = error;
            NSString *aErrorDomain = error.domain;
            if ([[M3LoginManager sharedInstance] needDeviceBind:error]) {
                aError = nil;
                aErrorDomain = nil;
            }
            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:aError.domain error:aError];
        } ext:ext];
    }];
}

- (void)showStartPageView {
    _startPageViewHelper = [[CMPStartPageViewHelper alloc] init];
    [_startPageViewHelper showStartPageView];
}

- (void)hideStartPageView {
    [_startPageViewHelper hideStartPageView];
    _startPageViewHelper = nil;
}

- (void)showGuidePagesView {
    _guidePagesViewHelper = [[CMPGuidePagesViewHelper alloc] init];
    __weak CMPGuidePagesViewHelper *weakHelper = _guidePagesViewHelper;
    [[CMPHomeAlertManager sharedInstance]pushTaskWithShowBlock:^{
        [weakHelper showGuidePagesView:nil dismissComplete:^{
            [[CMPHomeAlertManager sharedInstance] taskDone];
        }];
    } priority:CMPHomeAlertPriorityGuidePage];
   
}

- (void)singlePopUpPrivacyProtocolPage {
     __weak typeof(self) weakSelf = self;
     [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
           BOOL isPopUpPrivacyProtocolPage = [CMPPrivacyProtocolWebViewController singlePopUpPrivacyProtocolPageWithPresentedController:self.window.rootViewController beforePopPageBlock:nil agreeButtonActionBlock:^{
               [CMPPrivacyProtocolWebViewController setupSinglePopUpPrivacyProtocolPageFlag];
               [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"kM3NotAgreePrivacyKey"];
               [[NSUserDefaults standardUserDefaults] synchronize];
               [weakSelf startApp];
               [[CMPHomeAlertManager sharedInstance] taskDone];
           } notAgreeButtonActionBlock:^{
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"kM3NotAgreePrivacyKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                exit(0);
           }];
           if (!isPopUpPrivacyProtocolPage) {
               [weakSelf startApp];
               [[CMPHomeAlertManager sharedInstance] taskDone];
           }
       } priority:CMPHomeAlertPrioritySinglePopUpPrivacyProtocolPage];
   
}

- (void)hideGuidePagesView {
    [_guidePagesViewHelper hideGuidePagesView];
    _guidePagesViewHelper = nil;
}

- (void)clearViews:(void(^)(void))block {
    [MBProgressHUD cmp_hideProgressHUD];
    [self hideStartPageView];
    [self hideGuidePagesView];
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w && w != self.window && ![w isKindOfClass:NSClassFromString(@"XZTouchWindow")]) {
            //XZTouchWindow  小致悬浮框，这儿不用隐藏。小致自己会隐藏，而且会导致登录后小致悬浮框不显示
            [w setHidden:YES];
        }
    }
    // dismis打印控制器
    [[UIPrintInteractionController sharedPrintController] dismissAnimated:NO];
    _tabBarViewController.viewControllers = nil;
    [_tabBarViewController.selectedViewController cmp_removeFromParentVc];
    if (_tabBarViewController.presentedViewController) {
        __weak typeof(self) wself = self;
        [_tabBarViewController dismissViewControllerAnimated:NO completion:^{
            __strong __typeof(wself) strongSelf = wself;
            strongSelf->_handleNotifiWebViewNavCtrl = nil;
            if (block) {
                block();
            }
        }];
    } else {
        _tabBarViewController = nil;
        if (block) {
            block();
        }
    }
}

- (void)showAddServerViewController {
    CMPServerEditViewController *aController = [[CMPServerEditViewController alloc] init];
    aController.backBarButtonItemHidden = YES;
    aController.mode = CMPServerEditViewControllerModeAdd;
    self.window.rootViewController = aController;
}

// 显示设置手势密码界面
- (void)showSetGesturePwdView {
    [self hideStartPageView];
    NSString *aLoginName = [M3LoginManager sharedInstance].currentAccount.loginName;
    NSDictionary *aDict = @{@"autoHide" : @NO,
                            @"showLeftArrow" : @NO,
                            @"username" : aLoginName
    };
    [[CMPGestureHelper shareInstance] showGestureViewWithDelegate:self from:FROM_INIT object:aDict ext:nil];
}

// 显示验证手势密码界面
- (void)showGestureVerifyView:(CMPLoginAccountModel *)aM3User ext:(__nullable id)ext {
    [self hideStartPageView];
    NSString *aImgUrl = [CMPCore memberIconUrlWithId:[CMPCore sharedInstance].userID];
    NSDictionary *aDic = @{@"autoHide" : @NO ,
                           @"gespassword" : aM3User.gesturePassword,
                           @"imgUrl" : aImgUrl,
                           @"loginName" : aM3User.loginName,
                           @"username" : aM3User.name,
                           @"userpassword" : aM3User.loginPassword
    };
    [[CMPGestureHelper shareInstance] showGestureViewWithDelegate:self from:FROM_VERIFY object:aDic ext:ext];
}

- (void)updateGestureState:(NSInteger )aGestureState gesturePasswrd:(NSString *)aPwd {
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    NSString *aUserID = [CMPCore sharedInstance].userID;
    // 更新数据库
    [[CMPCore sharedInstance].loginDBProvider updateGesturePassword:aPwd serverID:aServerId userID:aUserID gestureMode:aGestureState];
    [[CMPCore sharedInstance] setup];
    // 更新到webview缓存
    [[CMPMigrateWebDataViewController shareInstance] saveGestureState:aGestureState];
}

#pragma mark-
#pragma mark CMPGestureHelperDelegate

- (void)gestureHelperDidFail:(CMPGestureHelper *)aHelper {
    [self updateGestureState:CMPLoginAccountModelGestureClose gesturePasswrd:nil];
    [self showTabBarWithHideAppIds:nil didFinished:^{
        [[CMPGestureHelper shareInstance] hideGestureView];
    }];
}

- (void)gestureHelperSkip:(CMPGestureHelper *)aHelper {
    [self updateGestureState:CMPLoginAccountModelGestureClose gesturePasswrd:nil];
    [self showTabBarWithHideAppIds:nil didFinished:^{
        [[CMPGestureHelper shareInstance] hideGestureView];
    }];
}

- (void)gestureHelperReturn:(CMPGestureHelper *)aHelper {
    [self updateGestureState:CMPLoginAccountModelGestureClose gesturePasswrd:nil];
    [self showTabBarWithHideAppIds:nil didFinished:^{
        [[CMPGestureHelper shareInstance] hideGestureView];
    }];
}

- (void)gestureHelper:(CMPGestureHelper *)aHelper didSetPassword:(NSString *)password {
    [self updateGestureState:CMPLoginAccountModelGestureOpen gesturePasswrd:password];
    [self showTabBarWithHideAppIds:nil didFinished:^{
        [[CMPGestureHelper shareInstance] hideGestureView];
    }];
}

- (void)gestureHelperDidGetCorrectPswd:(CMPGestureHelper *)aHelper {
    if (aHelper.from == FROM_BACKGROUND) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self _autoLoginWithStart:^{
        
    } success:^{
        [weakSelf showTabBarWithHideAppIds:nil didFinished:^{
            [[CMPGestureHelper shareInstance] hideGestureView];
        }];
    } fail:^(NSError *error) {
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
    } ext:aHelper.transParams];
}

- (void)_autoLoginWithStart:(void(^)(void))start success:(void(^)(void))success fail:(void(^)(NSError *))fail ext:(__nullable id)ext {
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        [aLoginManager loginWithTokenStart:start success:success fail:fail ext:ext];
    } else {
        [aLoginManager autoRequestLogin:start
                                success:success
                                   fail:fail ext:ext];
    }
}

- (void)gestureHelperDidGetIncorrectPswd:(CMPGestureHelper *)aHelper {
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    NSString *serverID = [CMPCore sharedInstance].serverID;
    NSString *userID = [CMPCore sharedInstance].userID;
    //清空密码
    [loginDBProvider clearLoginAllPasswordWithServerID:serverID userId:userID];
    [[CMPGestureHelper shareInstance] hideGestureView];
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
    [self updateGestureState:CMPLoginAccountModelGestureClose gesturePasswrd:nil];
}

- (void)gestureHelperForgetPswd:(CMPGestureHelper *)aHelper inputPassword:(NSString *)password {
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    NSString *serverID = [CMPCore sharedInstance].serverID;
    NSString *userID = [CMPCore sharedInstance].userID;
    //清空密码
    [loginDBProvider clearLoginAllPasswordWithServerID:serverID userId:userID];
    [[CMPGestureHelper shareInstance] hideGestureView];
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
    [self updateGestureState:CMPLoginAccountModelGestureClose gesturePasswrd:nil];
}

- (void)gestureHelperOtherVerify:(CMPGestureHelper *)aHelper {
    [[CMPGestureHelper shareInstance] hideGestureView];
    // 需要清空当前用户的密码
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    [[CMPCore sharedInstance].loginDBProvider updateAllAccountsUnUsedWithServerId:aServerId];
    [M3LoginManager clearHistoryPhone];
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
}

// 检查设备环境是否安全
- (void)checkEnvironment {
    // 如果当前设备越狱了，给出提示
    if ([CMPSafeUtils isJailbreak]) {
        UIAlertView *aAlertView = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"common_jailbreakAlert") delegate:nil cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles: nil];
        [aAlertView show];
    }
    // 如果当前设备已开启代理，给出提示
    if ([CMPSafeUtils checkHTTPEnable]) {
        UIAlertView *aAlertView = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"common_proxyAlert") delegate:nil cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles: nil];
        [aAlertView show];
    }
}

- (void)reloadTabBar {
    [self clearViews:^{
        
    }];
    void(^tabbarDidAppearCallBack)(void) = [_tabBarViewController.viewDidAppearCallBack copy];
    _tabBarViewController = [self tabBar];
    _tabBarViewController.viewDidAppearCallBack = tabbarDidAppearCallBack;
    self.window.rootViewController = _tabBarViewController;
    [self reloadXiaozhi];
    
    //更新h5应用后，再次检查是否需要加载引导页
    [CMPHomeAlertManager sharedInstance].hasPushedNewVersionTip = NO;
    [self showNewVersionTip];
}

- (void)reloadApp {
    [CMPCore sharedInstance].showingTopScreen = NO;
    if ([self.window.rootViewController isKindOfClass:[CMPTabBarViewController class]] ) {
        [self reloadTabBar];
    } else {
        CMPNavigationController *aNav = [[CMPNavigationController alloc] initWithRootViewController:[M3LoginManager loginViewController]];
        self.window.rootViewController = aNav;
    }
}

- (CMPTabBarViewController *)tabBar {
    if (CMP_IPAD_MODE) {
        return [[CMPPadTabBarViewController alloc] init];
    } else {
        return [[CMPPhoneTabBarViewController alloc] init];
    }
}

// 创建tabBarController，appIDs为不显示的底部菜单模块
- (void)showTabBarWithHideAppIds:(NSString *)appIDs didFinished:(void(^)(void))aDidFinished {
    
    [[CMPMigrateWebDataViewController shareInstance] evalAfterWebDataDidReady:^(id obj, NSError *error) {
           
            [self dispatchSyncToMain:^{
               
                // 强制设置webview数据
                dispatch_group_enter(self.alertGroup);
                dispatch_group_t oldAlertGroup = self.alertGroup;
                NSLog(@"enter alertGroup 1 %p",self.alertGroup);
                
                /*在这儿登录成功了才可以允许弹出被迫下线*/
                [CMPCore sharedInstance].isAlertOnShowSessionInvalid  = NO;
                
                [self popUpPrivacyProtocolPage];
                [CMPLanguageHelper checkAndSwichAvailableLanguage];
                
                [self showDeviceBindingAlert];
                [self showWeakPasswordAlert];
                [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
                    [self showXiaozhi];
                } priority:CMPHomeAlertPriorityXZ];
                [self showWiFiClockIn];
                [self showLowSystemBlankTip];
                [CMPUserNotificationSettingHelper showNotOpenUserNotificationTip];
                [[CMPCustomManager sharedInstance] checkVersionFrom:1];
                // 应该是直接创建TabBarViewcontroller
                _tabBarViewController = [self tabBar];
                __weak typeof(self) weakSelf = self;
                [_tabBarViewController setViewDidAppearCallBack:^{
                    if (aDidFinished) {
                        aDidFinished();
                    }
                    [weakSelf hideStartPageView];
                    // 应用包正在下载/正在检查更新/等待检查更新/下载失败
                    if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerDownload ||
                        [CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerCheck ||
                        [CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerInit ||
                        [CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerFail) {
                        // 等待h5下载完成后回调
                        [CMPCheckUpdateManager sharedManager].updateSuccess = [^{
                            if (oldAlertGroup == weakSelf.alertGroup) {
                                dispatch_group_leave(weakSelf.alertGroup);
                                NSLog(@"leave alertGroup 1-1 %p-%p",oldAlertGroup,weakSelf.alertGroup);
                            }
                        } copy];
                    } else {
                        if (oldAlertGroup == weakSelf.alertGroup) {
                            dispatch_group_leave(weakSelf.alertGroup);
                            NSLog(@"leave alertGroup 1-2 %p-%p",oldAlertGroup,weakSelf.alertGroup);
                        }
                    }
                    
                    if (!weakSelf.autoLockTool) {
                        weakSelf.autoLockTool = [[CMPAutoLockTool alloc] init];
                    }
                    [weakSelf.autoLockTool begin];
                }];
                self.window.rootViewController = _tabBarViewController;
                // 将startPageView显示到最前端
                [_startPageViewHelper bringToFront];
                
                [M3LoginManager clearSharedInstance];
                
                [CMPHomeAlertManager sharedInstance].hasPushedNewVersionTip = NO;
                [self showNewVersionTip];
                
                dispatch_group_notify(self.alertGroup, dispatch_get_main_queue(), ^{
                    [[CMPHomeAlertManager sharedInstance] ready];
                    NSLog(@"dispatch_group_notify alertGroup");
                    DDLogDebug(@"zl---[%s]全部完成", __FUNCTION__);
    //                [[CMPMsgQuickHandler shareInstance] begin];//ks fix -- 方案否定 换新方案，注释掉
                });
            }];
        
    //    }];
    }];
}

// 展示WiFi快捷打卡
- (void)showWiFiClockIn {
    
    __weak typeof(self) wSelf = self;
    void(^blk)(void) = ^{
        if ([CMPCore sharedInstance].serverIsLaterV7_1) {
            if (!wSelf.wifiClockInHelper) {
                wSelf.wifiClockInHelper = [[CMPWiFiClockInHelper alloc] init];
            }
            [wSelf.wifiClockInHelper showWiFiClockIn];
        }
    };
    
    [[CMPAutoSignManager shareInstance] autoSignInResult:^(NSInteger state, id _Nonnull resp, NSError * _Nonnull err) {
        if (state == 0) {
            blk();
        }
    }];
}

/**
 展示新版本指引
 */
- (void)showNewVersionTip {
    UIView *showView = ((UINavigationController *)self.tabBarViewController).view;
    if (!showView) {
        return;
    }
    BOOL isMsgPage = NO;
    if ([self.tabBarViewController.selectedViewController isKindOfClass:CMPNavigationController.class]) {
        CMPNavigationController *navi = (CMPNavigationController *)self.tabBarViewController.selectedViewController;
        if ([navi.topViewController isKindOfClass:CMPMessageListViewController.class]) {
            isMsgPage = YES;
        }
    }
    [CMPTopScreenGuideView showGuideInView:showView isMsgPage:isMsgPage];
}

/**
 展示低版本系统可能出现空白页面的提示
 */
- (void)showLowSystemBlankTip {
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        if (@available(iOS 11.0, *)) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
        } else {
            id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:SY_STRING(@"low_system_blank_tip") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:nil otherButtonTitles:@[SY_STRING(@"common_ok")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                [[CMPHomeAlertManager sharedInstance] taskDone];
            }];
            [alert setTheme:CMPTheme.new];
            [alert show];
        }
    } priority:CMPHomeAlertPrioritywLowSystemBlankTip];
}

- (void)popUpPrivacyProtocolPage {
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        BOOL isPopUpPrivacyProtocolPage = [CMPPrivacyProtocolWebViewController popUpPrivacyProtocolPageWithPresentedController:self.tabBarViewController beforePopPageBlock:nil agreeButtonActionBlock:^{
            [CMPCore.sharedInstance tagCurrentUserPopUpPrivacyProtocolPage];
            [[CMPHomeAlertManager sharedInstance] taskDone];
        } notAgreeButtonActionBlock:^{
             [[M3LoginManager sharedInstance] logout];
             [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
             [[CMPHomeAlertManager sharedInstance] taskDone];
        }];
        if (!isPopUpPrivacyProtocolPage) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
        }
    } priority:CMPHomeAlertPriorityPopUpPrivacyProtocolPage];
}

//显示小致
- (void)showXiaozhi {
    //开启语音机器人小致，暂屏蔽小致
    [CMPCore_XiaozhiBridge openSpeechRobot];
    [[CMPHomeAlertManager sharedInstance] taskDone];
    [_tabBarViewController postNotificationForXZ];
}

- (void)reloadXiaozhi {
    [CMPCore_XiaozhiBridge reloadSpeechRobot];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    NSString *sourceApplication = [options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
    if ([KWOfficeApi handleOpenURL:url sourceApplication:sourceApplication annotation:[NSNull null]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ResetKWOfficeService object:nil];
        return true;
    } else {
        [self handleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:CMPInvoiceWechatHelper.shareInstance];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%s",__func__);
    //    NSLog(@"-------%s---------%ld",__func__,(long)application.applicationState);
    // 如果当前在下载H5应用包或者是6.1sp2的版本
    if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerDownload || ![CMPCore sharedInstance].serverIsLaterV1_8_0) {
        self.bgTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            self.bgTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ApplicationDidEnterBackground object:nil];
    [[KWOfficeApi sharedInstance] setApplicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%s",__func__);
    //设置离线消息数
    [CMPCommonManager clearApplicationIconBadgeNumber];
    if (self.bgTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskIdentifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ApplicationWillEnterForeground object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s",__func__);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%s",__func__);
}


#pragma mark-
#pragma mark 推送

// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
    //后台运行时点击通知。
    if(application.applicationState != UIApplicationStateActive) {
        [self handleRemoteNotification:userInfo];
    }
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"deviceToken:%@", deviceToken);
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        NSLog(@"result:%@",result);
        [CMPCore sharedInstance].baiduRemoteNotifiInfo = result;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_DidRegisterNotifiDeviceToken object:nil];
    }];
    // 注册融云推送
    NSString *token = [NSString deviceTokenStringWithDeviceToken:deviceToken];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    [CMPCore sharedInstance].remoteNotifiToken = token;
}

// 当DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RemoteNotificationsDeviceToken"];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self handleLocalNotification:notification.userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (void)registerNotification:(NSDictionary *)launchOptions application:(UIApplication *)application {
    UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // 删除推送消息信息
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithDictionary:launchOptions];
    [aDict removeObjectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // #warning 测试 开发环境 时需要修改BPushMode为BPushModeDevelopment 需要修改Apikey为自己的Apikey
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    NSString *baiduPushKey = [CMPCommonManager baiduPushKey];
    [BPush disableLbs];//ks add -- 去掉无用的定位隐私获取
    [BPush registerChannel:aDict apiKey:baiduPushKey pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:NO];
}

- (void)showNotificationWebViewController {
    if (self.isLunchNotifiViewController) {
        self.isLunchNotifiViewController = NO;
        return;
    }
    
    if (_handleNotifiWebViewNavCtrl) {
        [_handleNotifiWebViewNavCtrl dismissViewControllerAnimated:NO completion:nil];
        _handleNotifiWebViewNavCtrl = nil;
    }
    
    CMPHandleOpenURLWebViewController *aNotifiWebViewCtrl = [[CMPHandleOpenURLWebViewController alloc] init];
    aNotifiWebViewCtrl.appId = kM3AppID_Message;
    aNotifiWebViewCtrl.version = @"1.0.0";
    aNotifiWebViewCtrl.entryName = @"handleRemoteNotifi";
    aNotifiWebViewCtrl.disableAnimated = YES;
    aNotifiWebViewCtrl.didDealloc = [^{
        [[CMPHomeAlertManager sharedInstance] taskDone];
    } copy];
    
    _handleNotifiWebViewNavCtrl = [[CMPNavigationController alloc] initWithRootViewController:aNotifiWebViewCtrl];
    
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        if (!self->_handleNotifiWebViewNavCtrl ||
            !self->_tabBarViewController ||
            !self->_tabBarViewController.selectedViewController) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
            return;
        }
        
        [self->_tabBarViewController presentViewController:self->_handleNotifiWebViewNavCtrl animated:NO completion:nil];
        if (!CMP_IPAD_MODE) {
            UINavigationController *nav = self->_tabBarViewController.selectedViewController;
            [nav popToRootViewControllerAnimated:NO];
            self->_handleNotifiWebViewNavCtrl = nil;
        }
        //这儿不taskDone，应为OA-215651 M3-iOS端：杀进程后点击离线消息穿透，穿透到详情界面弹出了底导航刷新提示
//        [[CMPHomeAlertManager sharedInstance] taskDone];
    } priority:CMPHomeAlertPriorityRemoteNotifi];
}

/**
 展示强制硬件绑定提示框
 */
- (void)showDeviceBindingAlert {
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        if ([CMPCore sharedInstance].isAlertOnShowSessionInvalid || ![CMPCore sharedInstance].devBindingForce) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
            return;
        }
        
        UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"login_bindtip") cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {//取消
                [[M3LoginManager sharedInstance] logout];
                [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
                [[CMPHomeAlertManager sharedInstance] taskDone];
            } else if (buttonIndex == 1){//确定
                [[[CMPDeviceBindingProvider alloc] init] deviceBindingSuccess:^(NSString *successMesssage) {
                    [CMPCore sharedInstance].devBindingForce = NO;
                    [self cmp_showHUDWithText:successMesssage completionBlock:^{
                        [[CMPHomeAlertManager sharedInstance] taskDone];
                    }];
                } fail:^(NSString *failMesssage) {
                    [self cmp_showHUDWithText:failMesssage completionBlock:^{
                        [[CMPHomeAlertManager sharedInstance] removeAllTask];
                        [[CMPHomeAlertManager sharedInstance] taskDone];
                        [[M3LoginManager sharedInstance] logout];
                        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
                    }];
                }];
            }
        }];
        [aAlertView show];
    } priority:CMPHomeAlertPriorityDeviceBinding];
    return;
}


/**
 展示弱口令提示框
 */
- (BOOL)showWeakPasswordAlert
{
    // 手机盾新增：手机盾是否显示弱口令提示框
    BOOL mokey_showWeak = [M3LoginManager.sharedInstance mokey_login_relevantShow];
    
    if (mokey_showWeak == NO) {
        // 如果不是手机盾模块正常走原流程
        BOOL showWeak = NO;
        if ([CMPCore sharedInstance].passwordOvertime || [CMPCore sharedInstance].passwordNotStrong) {
            if ([CMPCore sharedInstance].isAlertOnShowSessionInvalid) {
                return YES;
            }
            [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
                UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"common_weakpassword") cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                    [self modifyPassward];
                }];
                [aAlertView show];
            } priority:CMPHomeAlertPriorityWeakPwd];
            showWeak = YES;
        }
        [CMPCore sharedInstance].passwordOvertime = NO;
        [CMPCore sharedInstance].passwordNotStrong = NO;
        return showWeak;
    } else {
        // 如果是手机盾模块则不显示手势框提示
        return NO;
    }
}


// 显示修改密码
- (void)modifyPassward {
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kM3MyAccountPwdUrl]];
    if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        if ([CMPCore sharedInstance].passwordChangeForce) {
            localHref = [localHref stringByAppendingString:@"?passwordChangeForce=1&isfromnative=true"];
        }
    } else if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        localHref = [localHref stringByAppendingString:@"?useNativebanner=1"];
    }
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    aController.startPage = localHref;
    //    aController.modalPresentationStyle = UIModalPresentationPageSheet;
    aController.viewWillClose = ^{
        [[CMPHomeAlertManager sharedInstance] taskDone];
    };
    if (_tabBarViewController.navigationController) {
        [_tabBarViewController.navigationController pushViewController:aController animated:YES];
    } else {
        CMPNavigationController *navi = [[CMPNavigationController alloc]initWithRootViewController:aController];
        [_tabBarViewController presentViewController:navi animated:YES completion:nil];
    }
}

#pragma mark-
#pragma mark handle Notification

/**
 处理点击本地通知消息
 */
- (void)handleLocalNotification:(NSDictionary *)userInfo {
    NSDictionary *rcInfo = userInfo[@"rc"];
    if (rcInfo && [rcInfo isKindOfClass:[NSDictionary class]]) { // 融云消息，需要穿透
        [self handleRemoteNotification:rcInfo];
        [_tabBarViewController selectMessage];
    }
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    [CMPCore sharedInstance].remoteNotifiData = [CMPChatManager.sharedManager handleUserInfo:userInfo];
    if ([CMPCommonManager shouldOpenHandleRemoteMessageViewController]) {
        [self showNotificationWebViewController];
    }
}


#pragma -mark handleOpenURL

- (void)handleOpenURL:(NSURL *)url {
    NSString *aStr = [url absoluteString];
    aStr = [aStr urlEncoding];
    NSLog(@"%s:%@",__func__,aStr);
    if ([aStr rangeOfString:kDesktopUrl].location != NSNotFound){
        //处理从桌面一键应用进来
        aStr = [aStr replaceCharacter:kDesktopUrl withString:@""];
        NSDictionary *aDict = [aStr JSONValue];
        [_handleNotifiWebViewNavCtrl dismissViewControllerAnimated:NO completion:^{
        }];
        [CMPCore sharedInstance].openDesktopAppData = aDict;
        CMPHandleOpenURLWebViewController *aNotifiWebViewCtrl = [[CMPHandleOpenURLWebViewController alloc] init];
        aNotifiWebViewCtrl.appId = kM3AppID_Application;
        aNotifiWebViewCtrl.version = @"1.0.0";
        aNotifiWebViewCtrl.entryName = @"handleOpenDesktopApp";
        _handleNotifiWebViewNavCtrl = [[CMPNavigationController alloc] initWithRootViewController:aNotifiWebViewCtrl];
        [_tabBarViewController presentViewController:_handleNotifiWebViewNavCtrl animated:NO completion:nil];
    } else if ([url.scheme.lowercaseString isEqualToString:kSSOLoginScheme]) {
        if ([CMPSSOHelper cotainSSOParam:url]) {
            __weak __typeof(self)weakSelf = self;
            [[CMPMigrateWebDataViewController shareInstance] evalAfterWebDataDidReady:^(id obj, NSError *error) {
                // 单点登录
                weakSelf.ssoHelper = [[CMPSSOHelper alloc] init];
                [weakSelf.ssoHelper ssoWithUrl:url];
            }];
        }else if ([url.relativeString containsString:@"seeyonM3Phone://CMPSharePublish/"]){
            //处理外部分享至M3的文件和图片
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *paths = [url.relativeString stringByReplacingOccurrencesOfString:@"seeyonM3Phone://CMPSharePublish/" withString:@""];
                [CMPShareManager handleThirdAppForwardingWithPaths:paths];
            });
            
        }
    }else if ([url.scheme.lowercaseString isEqualToString:@"file"]) {
        //处理外部分享至M3的文件和图片(不走分享组件的时候)
        [CMPShareManager handleThirdAppForwardingWithOriginUrl:url];
    }else {
        if (M3LoginManager.sharedInstance.isLogin) {
            return;
        }
       
        __weak __typeof(self)weakSelf = self;
        [[CMPMigrateWebDataViewController shareInstance] evalAfterWebDataDidReady:^(id obj, NSError *error) {
            [weakSelf checkUpdate];
        }];
    }

}


- (BOOL)isLoginView {
    if ([self.window.rootViewController isKindOfClass:[CMPNavigationController class]]) {
        CMPNavigationController *naVC = (CMPNavigationController *)self.window.rootViewController;
        UIViewController *vc = naVC.topViewController;
        if ([M3LoginManager isLoginViewController:vc]) {
            return YES;
        }
    }
    return NO;
}

// 统一处理网络请求错误
- (BOOL)handleError:(NSError *)error {
    NSLog(@"%s:\n(%@)",__func__,error);
    NSLog(@"current session:%@",[CMPCore sharedInstance].jsessionId);
    NSLog(@"current new session:%@",[CMPCore sharedInstance].anewSessionAfterLogin);
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    //是登录界面时就不进行处理
    if ([self isLoginView]) {
        NSLog(@"is loginview");
        return NO;
    }
    
    CMPCore *core = [CMPCore sharedInstance];
    NSInteger errorCode = error.code;
    NSInteger serverErrorCode = [error.userInfo[@"serverErrorCode"] integerValue];
    if ([CMPFeatureSupportControl isNeedHandleSessionInvalidWithErrorCode:errorCode serverErrorCode:serverErrorCode]) {
        if ([CMPCore isLoginState]) {
            NSLog(@"not loginstate");
        }
        NSLog(@"need handle session invalid, auto login");
        [self delayHandleSessionInvalid];
        [CMPCommonManager updateReachableServer:nil];
        [self handleSessionInvalid];
        return YES;
    }
    
    //ks fix -- 20230518 此处为解决吉林客户掉线问题加的，原因。后台接口 返回的 code不是数字，而是‘被迫下线’等字符串，后台补丁解决，客户端不处理，此处不放开
    /**
     if (errorCode == 401 && error.userInfo) {
         NSString *newServerErrorCode = error.userInfo[@"newServerErrorCode"];
         NSArray *sbArr = @[@"401",@"1001",@"1002",@"1003",@"1004",@"1005",@"1006",@"1007",@"1021",@"1022",@"1023",@"1024",@"-3001",@"-3003",@"-3011",@"-3004",@"-3002",@"-3010",@"-3005",@"-3006",@"50011",@"50022"
         ];
         if (![sbArr containsObject:newServerErrorCode]) {
             //其他未识别的code都自动登录操作
             [self delayHandleSessionInvalid];
             [CMPCommonManager updateReachableServer:nil];
             [self handleSessionInvalid];
             return YES;
         }
     }
     */
    //end
    
    if (_isBeingDelayed) {
        NSLog(@"_isBeingDelayed");
        return NO;
    }
    
    NSString *errorStr = nil;
    if (errorCode == 401 ||errorCode == 1001 ||errorCode == 1002 ||errorCode == 1003 ||errorCode == 1004 ||errorCode == 1005 || errorCode == 1006 || errorCode == 1007 || errorCode == 50011 || errorCode == 50022 ||errorCode == 1010 ||errorCode == -33001 ||errorCode == 5007) {
        errorStr = error.domain;
    }
    if ((!core.isAlertOnShowSessionInvalid && ![NSString isNull:errorStr]) || errorCode == -33001) {
        NSLog(@"session invalid,logout,alert");
        [[M3LoginManager sharedInstance] logout];
        core.isAlertOnShowSessionInvalid  = YES;
        CMPAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_prompt")  message:errorStr cancelButtonTitle:SY_STRING(@"common_backLogin") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
            //加入errorCode == 1005判断，和安卓保持一致
            if (errorCode == 1005 &&
                (aLoginManager.hasSetGesturePassword
                || ([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID
                || [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID)
                 )
                 ) {
                [self OfflinestartApp];
            }else {
                [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
            }
        }];
        [aAlertView show];
        return YES;
    }
    NSLog(@"not handle error");
    return NO;
}

static BOOL autoLogining = NO;
- (void)handleSessionInvalid {
    NSLog(@"%s",__func__);
    if (autoLogining) {
        return;
    }
    autoLogining = YES;
    [[M3LoginManager sharedInstance] logout];
    __weak typeof(self) weakSelf = self;
    [self _autoLoginWithStart:^{
        NSLog(@"自动登录开始");
        [MBProgressHUD cmp_showProgressHUDWithText:SY_STRING(@"common_Connecting")];
    }  success:^{
        //[weakSelf showTabBarWithHideAppIds:nil didFinished:nil];
        [[AppDelegate shareAppDelegate].tabBarViewController reloadTabBarAndReloadWebview];
        autoLogining = NO;
        [MBProgressHUD cmp_hideProgressHUD];
        [weakSelf showXiaozhi];
        //自动登录时会先logout停止下载应用包操作，然后登录后并没有进行继续下载，需要再次check
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            
        }];
    } fail:^(NSError *error) {
        [MBProgressHUD cmp_hideProgressHUD];
        if ([weakSelf isLoginView] == NO) {
            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
        }
        autoLogining = NO;
    } ext:nil];
}

- (void)safeProtect {
    // 检查运行环境
    [self checkEnvironment];
#if CUSTOM
#else
    //提供的m3企业版本的测试包需要提示，****打ipa需要注释****
    [self checkTestVersionAndShowAlertIfNeeded];
    // 检测应用包名
    if (![CMPSafeUtils checkBundleID]) {
        exit(0);
        return;
    }
#endif
    // 开启反调试
    [[CMPSafeUtils sharedInstance] startAntiDebug];
    // 开启后台模糊
    [[CMPSafeUtils sharedInstance] startBackgroundBlur];
}

- (void)checkTestVersionAndShowAlertIfNeeded {
    if ([CMPCommonManager isM3InHouse]) {
        NSTimeInterval lastAlertTimestamp = [[NSUserDefaults standardUserDefaults] doubleForKey:@"checkTestVersionAndShowAlertIfNeededTimestamp"];
        NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timeDifference = currentTimestamp - lastAlertTimestamp;
        if (timeDifference >= 3600 * 2) {
            UIAlertView *aAlertView = [[UIAlertView alloc] initWithTitle:@"重要提示" message:@"您正在使用【测试版本】，app会记录日志信息，以及会出现某些功能无法正常使用的情况。该版本供测试和查问题使用，未经允许不能提供给其他人使用。" delegate:nil cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles: nil];
            [aAlertView show];
            [[NSUserDefaults standardUserDefaults] setDouble:currentTimestamp forKey:@"checkTestVersionAndShowAlertIfNeededTimestamp"];
            [[NSUserDefaults standardUserDefaults] synchronize]; // 同步UserDefaults
        }
    }
}

- (void)OfflinestartApp {
    
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    
    // 7.1新增功能
    // 判断面容、指纹解锁是否开启
    if (([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID ||
         [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID)) {
        if ([CMPLocalAuthenticationTools supportType] == CMPLocalAuthenticationTypeNone) {
            if (aLoginManager.hasSetGesturePassword) {
                [self showGestureVerifyView:aLoginManager.currentAccount ext:nil];
            } else {
                // 清空密码，并返回登录页
                NSString *aServerId = [CMPCore sharedInstance].serverID;
                [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:aServerId];
                [M3LoginManager clearHistoryPhone];
                [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
            }
        } else {
            [self showLocalAuthViewWithExt:nil];
        }
        return;
    }
    
    // 是否需要显示手势密码解锁
    if (aLoginManager.hasSetGesturePassword) {
        // 手机盾新增：手机盾是否显示验证弱手势
        BOOL mokey_showWeak = [M3LoginManager.sharedInstance mokey_login_relevantShow];
        if (mokey_showWeak == NO) {
            [self showGestureVerifyView:aLoginManager.currentAccount ext:nil];
            return;
        }
    }
}

#pragma mark-
#pragma mark 默认服务器

/**
 设置默认服务器
 url：服务器地址（必填，例如：https://m.seeyon.com）
 port: 服务器端口 （必填，例如：8888）
 note：备注信息（可选项）
 */
- (BOOL)initDefaultServer {
    NSString *url = @"m.seeyon.com";//需更换客户默认地址
    NSString *port = @"8080";//需更换客户默认端口
    NSString *note = @"test";//需更换客户默认备注
    NSString *aServerUrl = [CMPCore sharedInstance].serverurl;
    if ([NSString isNull:url] ||
        [NSString isNull:port] ||
        ![NSString isNull:aServerUrl]) {
        return NO;
    }
    serverEditVc = [[CMPServerEditViewController alloc] init];
    [self.window insertSubview:serverEditVc.view atIndex:-1];
    [serverEditVc saveServerWithHost:url port:port note:note fail:^(NSError *error) {
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
    }];
    return YES;
}

//ks add -- 20230512 临时解决客户掉线问题，收到掉线和离线登录时，延迟2分钟处理后面的请求error状态，哎
- (void)delayHandleSessionInvalid
{
    _isBeingDelayed = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isBeingDelayed = NO;
    });
}

-(void)vpnRenewPwd:(NSNotification *)noti
{
    [[CMPVpnManager sharedInstance] showRenewPwdAlert];
}

@end
