//
//  CMPAppManager.m
//  CMPCore
//
//  Created by youlin on 16/5/30.
//
//

#import "CMPAppManagerPlugin.h"
#import <Foundation/Foundation.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/ZipArchive.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/AFNetworkReachabilityManager.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPTabBarProvider.h"
#import "CMPTabBarItemAttribute.h"
#import "CMPOfflineContactViewController.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPAppListModel.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPCachedResManager.h>
#import "CMPMessageManager.h"
#import "CMPMessageListViewController.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPIntercepter.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPTopScreenManager.h"

#define kPresetAppsMd5_CMP @"4d4a626595452f221662c6ff4257d666"
#define kPresetAppsMd5_M3_Login @"6e3c060124cf9e7dcf14575c53ac7bd8"
#define kPresetAppsMd5_M3_Commons @"990a5d96b99306e937d8db863dbed8f9"

@interface CMPAppManagerPlugin()<CMPDataProviderDelegate>

@property (nonatomic, copy)NSString *downloadUrl;
@property (nonatomic, strong) CMPTopScreenManager *topScreenManager;

@end

@implementation CMPAppManagerPlugin

- (NSNumber *)freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

- (void)downloadApp:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    // 需要做判断是非当前的zip已经存在了，如果存在就直接返回成功回调
    
    // 判断当前存储空间是否200M以上，如果小于200M就返回错误
    long long diskSize = [[self freeDiskSpace] longLongValue];
    if (diskSize < 200 *1024 *1024) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:5001], @"code", SY_STRING(@"common_noFreeSpace"), @"message",@"",@"detail", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    // 判断是否是公共包还是应用包
    NSString *url = [argumentsMap objectForKey:@"url"];
    NSLog(@"download app url: %@", url);
    NSString *title =[argumentsMap objectForKey:@"title"];
    NSString *donwLoadPath = [[CMPAppManager cmpAppCachePath] stringByAppendingPathComponent:title];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;//[url urlEncoding2Times];
    aDataRequest.delegate = self;
    aDataRequest.downloadDestinationPath = donwLoadPath;
    aDataRequest.requestType = kDataRequestType_FileDownload;
    NSString *callBackID = [command callbackId];
    NSDictionary *extData = [argumentsMap objectForKey:@"extData"];
    NSMutableDictionary *aDict = nil;
    if ([extData isKindOfClass:[NSDictionary class]]) {
        aDict = [NSMutableDictionary dictionaryWithDictionary:extData];
    }
    else {
        aDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [aDict setObject:callBackID forKey:@"callBackID"];
    aDataRequest.userInfo = aDict;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getAppList:(CDVInvokedUrlCommand *)command {
    NSString *appList = [UserDefaults objectForKey:[NSString stringWithFormat:@"CMPAppList_%@_%@", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID]];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:appList];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAppInfoByIdAndType:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [argumentsMap objectForKey:@"appId"];
    NSString *appType = [argumentsMap objectForKey:@"appType"];
    NSString *appList = [CMPCore sharedInstance].currentUser.appList;
    if ([NSString isNull:appId] ||
        [NSString isNull:appType] ||
        [NSString isNull:appList]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数不能为空"];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
    CMPAppList_2 *appInfo = [appListModel appInfoWithType:appType ID:appId];
    if (!appInfo) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"appInfo为空"];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[appInfo yy_modelToJSONString]];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getNavBarInfo:(CDVInvokedUrlCommand *)command {
    CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
    CMPTabBarItemAttributeList *tabBarItemAttributes = [tabBarProvider tabBarItemList];
    NSString *navBarInfo = [tabBarItemAttributes.navBarList yy_modelToJSONString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:navBarInfo];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAppList:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appList = [argumentsMap objectForKey:@"appList"];
    if (![NSString isNull:appList]) {
        [UserDefaults setObject:appList forKey:[NSString stringWithFormat:@"CMPAppList_%@_%@", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID]];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAppInfoById:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appKey = [argumentsMap objectForKey:@"id"];
    
    CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
    CMPTabBarItemAttributeList *tabBarItemAttributes = [tabBarProvider tabBarItemList];
    
    for (CMPTabBarItemAttribute *tabbar in tabBarItemAttributes.navBarList) {
        if ([tabbar.appKey isEqualToString:appKey]) {
            NSString *result = [tabbar.app JSONRepresentation];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }
    
    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
    CMPLoginConfigInfoModel_2 *config = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];

    for (CMPTabBarItemAttribute *tabbar in config.portal.expandNavBar.tabbarList) {
        if ([tabbar.appKey isEqualToString:appKey]) {
            NSString *result = [tabbar.app JSONRepresentation];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }
    
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:3002], @"code", SY_STRING(@"device_no_data"), @"message",@"",@"detail", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (CMPTopScreenManager *)topScreenManager{
    if (!_topScreenManager) {
        _topScreenManager = [CMPTopScreenManager new];
    }
    return _topScreenManager;
}

- (void)loadApp:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    [self.topScreenManager loadAppClickByParam:argumentsMap];//记录点击
    CDVPluginResult *pluginResult = [self loadAppAction:argumentsMap];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//loadApp方法
- (CDVPluginResult *)loadAppAction:(NSDictionary *)argumentsMap {
    NSString *appType = [argumentsMap objectForKey:@"appType"];
    NSString *name = [argumentsMap objectForKey:@"bundle_name"];
    if ([NSString isNull:name]) {
        name = [argumentsMap objectForKey:@"bundleName"];
    }
    NSString *entry = [argumentsMap objectForKey:@"entry"];
    NSString *parameters = [argumentsMap objectForKey:@"parameters"];
    NSInteger iOSStatusBarStyle = [[argumentsMap objectForKey:@"iOSStatusBarStyle"] integerValue];
    NSString *m3from = [argumentsMap objectForKey:@"from"];
    NSNumber *isEncode = [argumentsMap objectForKey:@"isEncode"];
        
    // 清空内容区，在内容区展示新页面，仅在 iPad 且 openWebview为YES时生效，默认值为 NO
    BOOL pushPageInDetail = [[argumentsMap objectForKey:@"pushInDetailPad"] boolValue];
    // 清空内容区域，仅在iPad 且 openWebview为YES 且 pushInDetailPad为NO时生效，默认值为 YES
    BOOL clearDetailPage = [argumentsMap objectForKey:@"clearDetailPad"] ? [[argumentsMap objectForKey:@"clearDetailPad"] boolValue] : YES;
    
    if ([entry isKindOfClass:[NSString class]] && [NSString isNull:entry]) {
        entry = @"";
    }
    
    //不拦截的跳转
    BOOL noIntercept = ![[CMPIntercepter sharedInstance] needIntercept:entry];
    if(noIntercept){
        [[NSNotificationCenter defaultCenter]postNotificationName:kNoInterceptJumpNotification object:self.viewController userInfo:@{@"url":entry}];//openInNew 新web窗口直接push
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        return pluginResult;
    }

    // 判断是否需要在新的webview打开
    BOOL isOpenNewWebview = [argumentsMap objectForKey:@"isOpenWebview"] ? false : true;
    BOOL isTailWebView = NO;
    
    // 判断是否超过多WebView阈值
    if ([CMPBannerWebViewController isWebViewMaxCount]) {
        isOpenNewWebview = NO;
        isTailWebView = YES;
    }
    
    // 判断是否为远程的h5 url地址
    if ([appType isEqualToString:@"integration_remote_url"]) {
        if (![entry isKindOfClass:[NSString class]]) {
            entry = @"";
        }
        
        // 映射到本地
        NSURL *entryURL = [NSURL URLWithString:entry];
        NSString *cachedPath = [CMPCachedUrlParser cachedPathWithUrl:entryURL];
        if (![NSString isNull:cachedPath]) {
            entry = cachedPath;
        }
        
        BOOL isEncodeUrl = isEncode ? isEncode.boolValue : YES ;
        if (isEncodeUrl) {
            entry = [entry urlCFEncoded];
        }
        
        if (![NSString isNull:m3from]) {
            entry = [entry appendHtmlUrlParam:@"m3from" value:m3from];
        }
        //ks add 发版前先注释掉
//        NSString *cmpignore = [NSString stringWithFormat:@"%@",argumentsMap[@"cmpignore"]];
        
        if (isOpenNewWebview) {
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.startPage = entry;
            aCMPBannerViewController.hideBannerNavBar = NO;
            aCMPBannerViewController.isShowBannerProgress = YES;
            aCMPBannerViewController.closeButtonHidden = NO;
//            [aCMPBannerViewController.extParamDic setObject:cmpignore forKey:@"cmpignore"];
            
            CMPBannerWebViewController *currentViewController = (CMPBannerWebViewController *)self.viewController;
            if ([currentViewController isKindOfClass:[CMPBannerWebViewController class]]) {
                [currentViewController pushVc:aCMPBannerViewController inVc:currentViewController inDetail:pushPageInDetail clearDetail:clearDetailPage animate:YES];
            } else {
                [self.viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
            }
        } else {
            CMPBannerWebViewController *aController =  (CMPBannerWebViewController *)self.viewController;
            aController.isShowBannerProgress = YES;
            aController.closeButtonHidden = NO;
            aController.isTailWebView = isTailWebView;
//            [aController.extParamDic setObject:cmpignore forKey:@"cmpignore"];
            
            // 设置显示原生头部
            [aController showNavBarforWebView:@1];
            NSURL* url = [[NSURL alloc] initWithString:entry];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [self.webViewEngine loadRequest:request];
        }
    }
    // 判断是否为本地原生app
    else if ([appType isEqualToString:@"integration_native"]) {
        NSString *downloadUrl = nil;
        if ([entry isKindOfClass:[NSDictionary class]]) {
            downloadUrl = ((NSDictionary *)entry)[@"download"];
            entry = [(NSDictionary *)entry objectForKey:@"command"];
        }
        NSArray *aList = [entry componentsSeparatedByString:@"://"];
        NSString *prefix = entry;
        if (aList.count == 2) {
            prefix = [aList objectAtIndex:0];
            parameters = [aList objectAtIndex:1];
        }
        parameters = (NSString *)
        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)parameters,
                                                                  NULL,
                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                  kCFStringEncodingUTF8));

        prefix = [NSString stringWithFormat:@"%@://%@", prefix, parameters];
        NSURL *appUrl = [NSURL URLWithString:prefix];
        if (![[UIApplication sharedApplication] openURL:appUrl]) {
            if (downloadUrl && [downloadUrl containsString:@"://"]) {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:SY_STRING(@"open_app_download_adress") message:downloadUrl cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
                    if (buttonIndex==1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    } else {
                        [self.viewController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                [alert show];
            } else {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:NULL message:[NSString stringWithFormat:SY_STRING(@"common_noAppDownloadAddress"),downloadUrl] cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:nil];
                [alert show];
            }
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            return pluginResult;
        }
    } else if ([appType isEqualToString:@"biz"]){
        NSString *appKey = [argumentsMap objectForKey:@"appKey"];
        if ([NSString isNull:appKey]) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"biz appKey not found"];
            return pluginResult;
        }
        CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:@"52"
                                                        version:@"1.0.0"
                                                       serverId:kCMP_ServerID
                                                         owerId:kCMP_OwnerID];
        if (!appInfo.path) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"appInfo not found"];
            return pluginResult;
        }
        NSString *aRootPath = [CMPCachedResManager rootPathWithHost:appInfo.url_schemes version:@"1.0.0"];
        if (aRootPath) {
            NSString *indexPath = nil;
            NSString *entry = [NSString stringWithFormat:@"layout/m3-transit-page.html?id=%@", appKey];
            indexPath = [aRootPath stringByAppendingPathComponent:entry];
            indexPath = [@"file://" stringByAppendingString:indexPath];
            
            if ([NSString isNull:indexPath]) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:SY_STRING(@"loadApp_fail")];
                return pluginResult;
            }
            
            BOOL aUseNativebanner = NO;
            // 解析url参数
            NSDictionary *urlDict = [indexPath urlPropertyValue];
            NSString *useNativeBanner = [urlDict objectForKey:@"useNativebanner"];
            aUseNativebanner = [useNativeBanner boolValue];
            NSDictionary *pageParam = @{
                @"param":argumentsMap,
                @"url":indexPath
            };
            if (isOpenNewWebview) {
                CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                aCMPBannerViewController.pageParam = pageParam;
                aCMPBannerViewController.startPage = indexPath;
                aCMPBannerViewController.hideBannerNavBar = !aUseNativebanner;
                aCMPBannerViewController.statusBarStyle = iOSStatusBarStyle;
                
                CMPBannerWebViewController *currentViewController = (CMPBannerWebViewController *)self.viewController;
                if ([currentViewController isKindOfClass:[CMPBannerWebViewController class]]) {
                    [currentViewController pushVc:aCMPBannerViewController inVc:currentViewController inDetail:pushPageInDetail clearDetail:clearDetailPage animate:YES];
                } else {
                    [self.viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
                }
            } else {
                CMPBannerWebViewController *aController =  (CMPBannerWebViewController *)self.viewController;
                // 当前webview，需要入当前page堆栈
                [aController.pageStack addObject:pageParam];
                aController.isTailWebView = isTailWebView;
                // 设置显示原生头部
                NSNumber *showNumber = aUseNativebanner ? @1 : @0;
                [aController showNavBarforWebView:showNumber];
                NSURL* url = [[NSURL alloc] initWithString:indexPath];
                NSURLRequest* request = [NSURLRequest requestWithURL:url];
                [self.webViewEngine loadRequest:request];
            }
        }
    }

    else {
        NSString *team = [argumentsMap objectForKey:@"team"];
        NSString *host = nil;
        if ([team isEqualToString:@"cmp"]) {
            if (![name isEqualToString:@"cmp"]) {
                host = [NSString stringWithFormat:@"%@.%@", name, team];
            }
        }
        else {
            host = [NSString stringWithFormat:@"%@.%@.cmp", name, team];
        }
        if (!team) {
            host = [argumentsMap objectForKey:@"urlSchemes"];
        }
        NSString *version = [argumentsMap objectForKey:@"version"];
        NSString *aRootPath = [CMPCachedResManager rootPathWithHost:host version:version];
        NSString *indexPath = nil;
        if (aRootPath) {
            NSString *aPath = aRootPath;
            NSString *manifestPath = [aPath stringByAppendingPathComponent:@"manifest.json"];
            NSString *JSONString = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *manifest = [JSONString JSONValue];
            NSString *entry = [[manifest objectForKey:@"entry"] objectForKey:@"phone"];
            indexPath = [aPath stringByAppendingPathComponent:entry];
            indexPath = [@"file://" stringByAppendingString:indexPath];
            if (![NSString isNull:m3from]) {
                indexPath = [indexPath appendHtmlUrlParam:@"m3from" value:m3from];
            }
            if (!manifest) {
                indexPath = nil;
            }
        }
        if ([NSString isNull:indexPath]) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:3001], @"code", SY_STRING(@"loadApp_fail"), @"message",@"",@"detail", nil];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            return pluginResult;
        }
        
        BOOL aUseNativebanner = NO;
        // 解析url参数
        NSDictionary *urlDict = [indexPath urlPropertyValue];
        NSString *useNativeBanner = [urlDict objectForKey:@"useNativebanner"];
        aUseNativebanner = [useNativeBanner boolValue];
        NSDictionary *pageParam = @{
            @"param":argumentsMap,
            @"url":indexPath
        };
        
        //从消息页面loadApp
        if (![self.viewController isKindOfClass:CMPBannerWebViewController.class]) {
            isOpenNewWebview = YES;
        }
        if (isOpenNewWebview) {
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.pageParam = pageParam;
            aCMPBannerViewController.startPage = indexPath;
            aCMPBannerViewController.hideBannerNavBar = !aUseNativebanner;
            aCMPBannerViewController.statusBarStyle = iOSStatusBarStyle;
            
            CMPBannerWebViewController *currentViewController = (CMPBannerWebViewController *)self.viewController;
            if ([currentViewController isKindOfClass:[CMPBannerWebViewController class]]) {
                [currentViewController pushVc:aCMPBannerViewController inVc:currentViewController inDetail:pushPageInDetail clearDetail:clearDetailPage animate:YES];
            } else {
                [self.viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
            }
        } else {
            CMPBannerWebViewController *aController =  (CMPBannerWebViewController *)self.viewController;
            // 替换栈顶
//            if (replaceTop && _pageStack.count !=0) {
//                [_pageStack removeLastObject];
//            }
            // 当前webview，需要入当前page堆栈
            [aController.pageStack addObject:pageParam];
            aController.isTailWebView = isTailWebView;
            // 设置显示原生头部
            NSNumber *showNumber = aUseNativebanner ? @1 : @0;
            [aController showNavBarforWebView:showNumber];
            NSURL* url = [[NSURL alloc] initWithString:indexPath];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [self.webViewEngine loadRequest:request];
        }
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    return pluginResult;
}

- (void)loadMessageApp:(CDVInvokedUrlCommand *)command{
    
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSNumber *replaceTop = [argumentsMap objectForKey:@"replaceTop"];
    BOOL isReplaceTop = replaceTop ? replaceTop.boolValue: NO;
    
    NSInteger viewControllerCount = self.viewController.navigationController.viewControllers.count;
    CMPMessageListViewController *controller = [[CMPMessageListViewController alloc] init];
    controller.backBarButtonItemHidden = NO;
    if (CMP_IPAD_MODE) {
        CMPBaseWebViewController *aViewController = (CMPBaseWebViewController *)self.viewController;
        if ([aViewController isKindOfClass:[CMPBaseWebViewController class]]) {
            [aViewController pushVc:controller inVc:self.viewController inDetail:NO clearDetail:YES animate:YES];
        }
    } else {
        [self.viewController.navigationController pushViewController:controller animated:YES];
    }
    if (isReplaceTop) {
        __weak typeof(self) weakSelf = self;
        [self dispatchAsyncToMain:^{
            NSInteger currentCount = self.viewController.navigationController.viewControllers.count;
            if (currentCount-1 != viewControllerCount) {
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      NSMutableArray *viewControllers = [weakSelf.viewController.navigationController.viewControllers mutableCopy];
                      [viewControllers removeObject:weakSelf.viewController];
                      weakSelf.viewController.navigationController.viewControllers = [viewControllers copy];
                  });
            }
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];

    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getAppEntryUrl:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [argumentsMap objectForKey:@"appId"];
//    NSString *version = [argumentsMap objectForKey:@"version"];
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    __block NSArray *existAppInfoList;
    [dbconn appListWithServerID:kCMP_ServerID
                        ownerID:kCMP_OwnerID
                          appId:appId
                   onCompletion:^(NSArray *result) {
                       existAppInfoList = [result copy];
                   }];
    NSString *aPath = nil;
    if (existAppInfoList.count > 0) {
        CMPDBAppInfo *aDBAppInfo = [existAppInfoList lastObject];
        NSString *path = [CMPAppManager documentWithPath:aDBAppInfo.path];
        NSString *manifestPath = [path stringByAppendingPathComponent:@"manifest.json"];
        NSString *JSONString = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *manifest = [JSONString JSONValue];
        aPath = [[manifest objectForKey:@"entry"] objectForKey:@"phone"];
        aPath = [NSString stringWithFormat:@"%@/%@",path,aPath];
    }
    
    CDVPluginResult *result = nil;
    
    if (![NSString isNull:aPath]) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        NSString *aStr = [NSString stringWithFormat:@"file://%@", aPath];
        [mDict setObject:aStr forKey:@"url"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mDict];
    } else {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:12025], @"code", SY_STRING(@"jsapi_error"), @"message",@"",@"detail", nil];

        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)deleteApp:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [argumentsMap objectForKey:@"appId"];
    NSString *version = [argumentsMap objectForKey:@"version"];
    [CMPAppManager deleteAppWithAppId:appId version:version aServerId:kCMP_ServerID ownerId:kCMP_OwnerID];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//  获取应用信息
- (void)getAppInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [argumentsMap objectForKey:@"appId"];
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    __block NSArray *existAppInfoList;
    [dbconn appListWithServerID:kCMP_ServerID
                        ownerID:kCMP_OwnerID
                          appId:appId
                   onCompletion:^(NSArray *result) {
                       existAppInfoList = [result copy];
                   }];
    CDVPluginResult *result = nil;
    if (existAppInfoList.count > 0) {
        CMPDBAppInfo *aDBAppInfo = [existAppInfoList lastObject];
        NSString *aStr = [aDBAppInfo yy_modelToJSONString];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:aStr];
    }
    else {
          NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:12021], @"code", SY_STRING(@"common_noAppInformation"), @"message",@"",@"detail", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

// 获取下载的app 列表
- (void)getDownloadAppList:(CDVInvokedUrlCommand *)command {
    NSArray *appList = [CMPAppManager appListWithServerId:kCMP_ServerID ownerId:kCMP_OwnerID];
    NSString *jsonStr = [appList JSONRepresentation];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getJSAPIUrl:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [NSString convertToString:argumentsMap[@"appId"]];
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    __block NSArray *existAppInfoList;
    [dbconn appListWithServerID:kCMP_ServerID
                        ownerID:kCMP_OwnerID
                          appId:appId
                   onCompletion:^(NSArray *result) {
                       existAppInfoList = [result copy];
                   }];
    NSString *jsapiurl = nil;
    NSString *openAppMethod = nil;
    if (existAppInfoList.count > 0) {
        CMPDBAppInfo *aDBAppInfo = [existAppInfoList lastObject];
        NSString *aPath = [CMPAppManager documentWithPath:aDBAppInfo.path];
        NSString *manifestPath = [aPath stringByAppendingPathComponent:@"manifest.json"];
        NSString *JSONString = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *manifest = [JSONString JSONValue];
        jsapiurl = [[manifest objectForKey:@"entry"] objectForKey:@"jsapi"];
        NSString *urlSchemes = [manifest objectForKey:@"urlSchemes"];
        aPath = [CMPCachedResManager rootPathWithHost:urlSchemes version:@"v"];
        jsapiurl = [aPath stringByAppendingPathComponent:jsapiurl];
        openAppMethod = [[manifest objectForKey:@"entry"] objectForKey:@"openAppMethod"];;
    }

    CDVPluginResult *result = nil;
    if (![NSString isNull:jsapiurl] && ![NSString isNull:openAppMethod]) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        NSString *aStr = [NSString stringWithFormat:@"file://%@", jsapiurl];
        [mDict setObject:aStr forKey:@"jsapiurl"];
        [mDict setObject:openAppMethod forKey:@"openAppMethod"];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mDict];
    }
    else {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:12025], @"code", SY_STRING(@"jsapi_error"), @"message",@"",@"detail", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getPresetAppsMd5:(CDVInvokedUrlCommand *)command {
    NSDictionary *mDict = [NSDictionary dictionaryWithObjectsAndKeys:kPresetAppsMd5_CMP, @"cmp",\
                           kPresetAppsMd5_M3_Commons, @"commons", \
                           kPresetAppsMd5_M3_Login, @"login", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:mDict];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

// 检查m3应用app
- (void)checkM3AppUpdate:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *checkUrl = [argumentsMap objectForKey:@"checkUpdateUrl"];
    [self requestWithUrl:checkUrl];
}

// 检查V5应用app
- (void)checkV5AppUpdate:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *checkUrl = [argumentsMap objectForKey:@"checkUpdateUrl"];
    [self requestWithUrl:checkUrl];
}

- (void)loadInExplorer:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *urlStr = [argumentsMap objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] openURL:url]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getMD5ByIDs:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSArray *appIDs = [argumentsMap objectForKey:@"appIDs"];
    
    if (!appIDs ||
        ![appIDs isKindOfClass:[NSArray class]] ||
        appIDs.count == 0) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:12018], @"code", @"参数错误", @"message",@"",@"detail", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
    
    for (NSString *appID in appIDs) {
        __block NSArray *existAppInfoList;
        [dbconn appListWithServerID:kCMP_ServerID
                            ownerID:kCMP_OwnerID
                              appId:appID
                       onCompletion:^(NSArray *result) {
                           existAppInfoList = [result copy];
                       }];
        
        if (existAppInfoList.count > 0) {
            CMPDBAppInfo *aDBAppInfo = [existAppInfoList lastObject];
            NSDictionary *dic = @{@"appID" : aDBAppInfo.appId ?: @"",
                                  @"md5" : aDBAppInfo.extend1 ?: @"",
                                  @"path" : aDBAppInfo.url_schemes ?: @""};
            [result addObject:dic];
        } else {
            NSDictionary *dic = @{@"appID" : appID,
                                  @"md5" : @"",
                                  @"path" : @""};
            [result addObject:dic];
        }
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[result yy_modelToJSONString]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getLocalResourceUrl:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *str = [argumentsMap objectForKey:@"url"];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:str]];
    CDVPluginResult *pluginResult = nil;
    if ([NSString isNull:localHref]) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:12018], @"code", SY_STRING(@"wrong_local_resource_path"), @"message",@"",@"detail", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    else {
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:localHref, @"localUrl", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openThirdNative:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *urlScheme = argumentsMap[@"appEnter"];
    if (!urlScheme || urlScheme.length==0) {
        urlScheme = argumentsMap[@"iosAppEntry"];
    }
    if (urlScheme && urlScheme.length>0) {
        NSDictionary *paramDict = argumentsMap[@"params"];
        NSString *paramStr = nil;
        // 兼容quanshiappios
        if ([urlScheme isEqualToString:@"quanshiappios"]) {
             paramStr = [NSMutableString string];
            NSArray *keys = paramDict.allKeys;
            if(keys.count > 1){
                for(int i = 0; i < keys.count; i++){
                    NSString *key = keys[i];
                    NSString *value = paramDict[key];
                    if(0 == i){
                        paramStr = [paramStr stringByAppendingFormat:@"%@=%@",key,value];
                    }else{
                        paramStr = [paramStr stringByAppendingFormat:@"&%@=%@",key,value];
                    }
                }
            }
            else if(1 == keys.count){
                paramStr = paramDict.allValues[0];
            }
        }
        else {
            paramStr = [paramDict JSONRepresentation];
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@://%@",urlScheme, paramStr];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *appURL = [NSURL URLWithString:urlStr];
        if([[UIApplication sharedApplication] openURL:appURL]){
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            NSString *downloadUrl = argumentsMap[@"iosDownloadUrl"];
            if (downloadUrl && [downloadUrl containsString:@"://"]) {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:SY_STRING(@"open_app_download_adress") message:downloadUrl cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
                    if (buttonIndex==1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    }
                }];
                [alert show];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:NULL message:[NSString stringWithFormat:SY_STRING(@"common_noAppDownloadAddress"),downloadUrl] cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:nil];
                [alert show];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"iosDownloadUrl is null or incorrect"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }
    else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"appEntry is null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showAddressBook:(CDVInvokedUrlCommand *)command {
    CMPOfflineContactViewController *vc = [[CMPOfflineContactViewController alloc] init];
    vc.isShowBackButton = YES;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (void)getAppIconUrlByAppId:(CDVInvokedUrlCommand *)command {
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *appId = [argumentsMap objectForKey:@"appId"];
    CMPMessageObject *message = [[CMPMessageManager sharedManager] messageWithAppID:appId];
    NSString *iconUrl = message.iconUrl;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:iconUrl];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getMessageAppCount:(CDVInvokedUrlCommand *)command {
    [[CMPMessageManager sharedManager] totalUnreadCount:^(NSInteger count) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:count];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


- (NSString *)requestWithUrl:(NSString *)url {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"get";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = @"";
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    CMPDataResponse *fileResponce = (CMPDataResponse *)aResponse;
    NSLog(@"下载文件储存路径：%@",fileResponce.downloadDestinationPath);
    NSString *aZipApp = fileResponce.downloadDestinationPath;
    NSString *md5 = [aRequest.userInfo objectForKey:@"md5"];
    NSError *error = [CMPAppManager storeAppWithZipPath:aZipApp md5:md5];
	[CMPAppManager resetAppsMap];
    NSString *aCallBackId = [aRequest.userInfo objectForKey:@"callBackID"];
    CDVPluginResult *result = nil;
    if (error) {
        NSNumber *errorCode = [NSNumber numberWithInteger:error.code];
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:errorCode, @"code", error.domain, @"message", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    }
    else {
        NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"pos", fileResponce.downloadDestinationPath, @"path", nil];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    }
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:aCallBackId];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSString *aCallBackId = [aRequest.userInfo objectForKey:@"callBackID"];
    NSNumber *errorCode = [NSNumber numberWithInteger:1];
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:errorCode, @"code", error.domain, @"message", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:aCallBackId];
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt {
    float aProgress = [[aExt objectForKey:@"progress"] floatValue];
    if (aProgress < 1) {
        NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
        NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
        NSMutableDictionary *aResult = [NSMutableDictionary dictionaryWithDictionary:aExt];
        [aResult setObject:aDict forKey:@"extData"];
        [aResult setObject:[NSNumber numberWithFloat:aProgress] forKey:@"pos"];
        [aResult removeObjectForKey:@"progress"];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aResult];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
    }
}

#pragma mark-
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001 && buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
    }
}

@end
