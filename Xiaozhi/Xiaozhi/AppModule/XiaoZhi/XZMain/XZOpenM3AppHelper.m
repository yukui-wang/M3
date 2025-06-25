//
//  XZOpenM3AppHelper.m
//  M3
//
//  Created by wujiansheng on 2018/1/26.
//

#import "XZOpenM3AppHelper.h"
#import "SPTools.h"
#import "XZCore.h"
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPCachedResManager.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPBannerViewController.h>
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/CMPH5AppLauncher.h>
#import <CMPLib/CMPQuickLookPreviewController.h>
#import <CMPLib/AttachmentReaderParam.h>
#import <CMPLib/CMPNavigationController.h>

#import "XZQAFileModel.h"
#import "XZMainProjectBridge.h"

@implementation XZOpenM3AppHelper

+ (BOOL)canOpenM3AppWithAppId:(NSString *)appId {
    //先判断是否是底导航的应用
    if([XZOpenM3AppHelper tabbarContainAppId:appId]) {
        return YES;
    }
    //在判断是否是全部应用的
    return  [XZOpenM3AppHelper allAPPContainAppId:appId];
}

+ (BOOL)tabbarContainAppId:(NSString *)appIds {
    NSString *appId = appIds;
    if ([appId isEqualToString:kM3AppID_Contacts] && [CMPCore sharedInstance].serverIsLaterV2_5_0) {
        appId = @"57";
    }
    NSArray *array = [[XZCore sharedInstance] tabbarIdArray];
    return [array containsObject:appId];
}

+ (BOOL)allAPPContainAppId:(NSString *)appId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:kXZ_M3APPLIST];
    return [array containsObject:appId];
}

+ (void)openM3AppWithAppId:(NSString *)appId{
    //先打开全部应用的
    if ([XZOpenM3AppHelper allAPPContainAppId:appId]) {
        if ([appId isEqualToString:kM3AppID_Contacts]) {
            //通讯录 原生应用
            if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
                NSString *url =  @"http://search.m3.cmp/v1.0.0/layout/address-index.html?cmp_orientation=auto";
                NSString* href = [XZOpenM3AppHelper urlWithUrl:url] ;
                href = [href urlCFEncoded];
                href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
                CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                aCMPBannerViewController.startPage = href;
                aCMPBannerViewController.title = @"";
                aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
                aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
                [XZOpenM3AppHelper openController:aCMPBannerViewController];
                return;
            }
            else {
                [XZOpenM3AppHelper openOfflineContacts];
                return;
            }
            
        }
        CMPCommonDBProvider *dbconn = [CMPCommonDBProvider sharedInstance];
        __block NSArray *existAppInfoList;
        [dbconn appListWithServerID:kCMP_ServerID ownerID:kCMP_OwnerID appId:appId onCompletion:^(NSArray *result) {
            existAppInfoList = [result copy];
        }];
        if (existAppInfoList.count > 0) {
            //h5应用
            [XZOpenM3AppHelper openM3AppWithDBAppInfo:[existAppInfoList lastObject]];
        }
    }
    else {
        NSString *appIdstr = appId;
        if ([appId isEqualToString:kM3AppID_Contacts] && [CMPCore sharedInstance].serverIsLaterV2_5_0) {
            appIdstr = @"57";
        }
        if([XZOpenM3AppHelper tabbarContainAppId:appIdstr]) {
            NSArray *array = [[XZCore sharedInstance] tabbarIdArray];
            NSInteger index = [array indexOfObject:appIdstr];
            UIWindow *keyWindow = [SPTools keyWindow];
            UIViewController *viewController = keyWindow.rootViewController;
            [viewController dismissViewControllerAnimated:NO completion:^{
            }];
            UITabBarController *vc = (UITabBarController *)viewController ;
            UINavigationController *nav = vc.selectedViewController;
            [nav popToRootViewControllerAnimated:NO];
            vc.selectedIndex = index;
        }
    }
}

+ (void)openOfflineContacts{
    UIViewController *aCMPBannerViewController = [XZMainProjectBridge offlineContactViewController];
    [XZOpenM3AppHelper openController:aCMPBannerViewController];
}

+ (void)openM3AppWithDBAppInfo:(CMPDBAppInfo *)aDBAppInfo {
    NSString *team = aDBAppInfo.team;
    NSString *name = aDBAppInfo.bundle_name;
    NSString *host = nil;
    if ([team isEqualToString:@"cmp"]) {
        if (![name isEqualToString:@"cmp"]) {
            host = [NSString stringWithFormat:@"%@.%@", name, team];
        }
    }
    else {
        host = [NSString stringWithFormat:@"%@.%@.cmp", name, team];
    }
    NSString *version = aDBAppInfo.version;
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
//        NSString *m3from = nil;//todo
//        if (![NSString isNull:m3from]) {
//            indexPath = [indexPath stringByAppendingFormat:@"?m3from=%@", m3from];
//        }
        if ([aDBAppInfo.appId isEqualToString:@"56"] || [aDBAppInfo.appId isEqualToString:@"58"]) {
            //我的 与 待办
            indexPath = [indexPath appendHtmlUrlParam:@"ParamHrefMark" value:@"true"];
        }
        if (!manifest) {
            indexPath = nil;
        }
        if ([NSString isNull:indexPath]) {
            return;
        }
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    aCMPBannerViewController.startPage = indexPath;
//    aCMPBannerViewController.title = name;
    aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
    [XZOpenM3AppHelper openController:aCMPBannerViewController];
}

+ (void)openController:(UIViewController *)aCMPBannerViewController {
    UIViewController *viewController = [SPTools currentViewController];
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        viewController = [(UITabBarController *)viewController selectedViewController];
    }
    if (viewController.navigationController) {
        [viewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
    }
    else if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)viewController pushViewController:aCMPBannerViewController animated:YES];
    }
    else {
        [viewController presentViewController:aCMPBannerViewController animated:YES completion:^{
        }];
    }
}

+ (NSString *)urlWithUrl:(NSString *)url {
//    if ([[CMPCore sharedInstance] serverIsLaterV7_0_SP1]) {
//        url = [url appendHtmlUrlParam:@"useNativebanner" value:@"1"];
//    }
//    url = [url appendHtmlUrlParam:@"cmp_orientation" value:@"auto"];
    return [XZOpenM3AppHelper urlWithUrl:url autoOrientation:NO];
}

+ (NSString *)urlWithUrl:(NSString *)url autoOrientation:(BOOL)autoOrientation {
    NSString *urlS = url;
    if ([[CMPCore sharedInstance] serverIsLaterV7_0_SP1]) {
        urlS = [urlS appendHtmlUrlParam:@"useNativebanner" value:@"1"];
    }
    if (INTERFACE_IS_PAD || autoOrientation) {
        urlS = [urlS appendHtmlUrlParam:@"cmp_orientation" value:@"auto"];
    }
    return urlS;
}

+ (void)showWebviewWithUrl:(NSString *)url {
    [XZOpenM3AppHelper showWebviewWithUrl:url autoOrientation:NO];
}

+ (void)showWebviewWithUrl:(NSString *)url autoOrientation:(BOOL)autoOrientation {
    [XZOpenM3AppHelper showWebviewWithUrl:url handleUrl:YES autoOrientation:autoOrientation];
}

+ (void)showWebviewWithUrl:(NSString *)url handleUrl:(BOOL)handleUrl autoOrientation:(BOOL)autoOrientation {
    NSString* href = handleUrl ? [XZOpenM3AppHelper urlWithUrl:url autoOrientation:autoOrientation] :url;
    href = [href urlCFEncoded];
    href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    aCMPBannerViewController.startPage = href;
    aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:aCMPBannerViewController];
    [[SPTools currentViewController] presentViewController:nav animated:YES completion:^{
    }];
}

+ (void)pushWebviewWithUrl:(NSString *)url nav:(UINavigationController *)nav {
    NSString* href = [XZOpenM3AppHelper urlWithUrl:url];
    href = [href urlCFEncoded];
    href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    aCMPBannerViewController.startPage = href;
    aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:aCMPBannerViewController animated:YES];
}

//url = nil 跳转中转界面
+ (void)openH5AppWithParams:(NSDictionary *)params
                        url:(NSString *)url
               inController:(UIViewController *)controller {
    if (url) {
        NSString* href = [XZOpenM3AppHelper urlWithUrl:url];
        href = [href urlCFEncoded];
        href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];

        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = href;
        aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
        aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
        CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:aCMPBannerViewController];
        [[SPTools currentViewController] presentViewController:nav animated:YES completion:^{
        }];
    }
    else {
        [CMPH5AppLauncher launchH5AppWithParam:params inController:controller];
    }
}

+ (void)showQAFile:(XZQAFileModel *)model {
    
    AttachmentReaderParam *param = [[AttachmentReaderParam alloc] init];
    param.url = [XZCore fullUrlForPathFormat:kDownloadAttUrl, model.fileId];
    param.origin = [XZCore serverurl];
    param.fileId = model.fileId;
    param.fileName = model.filename;
//    param.fileType = model.type;
    param.fileSize = [NSString stringWithLongLong:model.fileSize];
    param.lastModified = model.lastModified;
    param.autoSave = YES;
    
    CMPQuickLookPreviewController *aViewController = [[CMPQuickLookPreviewController alloc] init];
    aViewController.attReaderParam = param;
    CMPNavigationController *navi = [[CMPNavigationController alloc] initWithRootViewController:aViewController];
    [[SPTools currentViewController] presentViewController:navi animated:YES completion:nil];
}


@end
