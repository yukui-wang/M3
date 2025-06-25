//
//  CMPShortcutHelper.m
//  M3
//
//  Created by CRMO on 2019/4/2.
//

#import "CMPShortcutHelper.h"
#import <CMPMediator/CMPMediator.h>
#import <CMPMediator/CMPMediator+ShortcutActions.h>
#import "CMPMessageManager.h"
#import "CMPChatManager.h"
#import <CMPLib/CMPGlobleManager.h>
#import "CMPTabBarViewController.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPNavigationController.h>
#import "CMPMessageListViewController.h"
#import "CMPTabBarWebViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPMeetingManager.h"
#import "CMPTabBarProvider.h"
/** 致信AppID **/
static NSString * const kRcAppID = @"61";

@implementation CMPShortcutHelper

+ (void)showInViewController:(UIViewController *)vc {
    NSArray *shorcutItems = [[CMPMessageManager sharedManager] shortcutItemList];
    [[CMPMediator sharedInstance] CMPMediator_showShortcutInView:vc.view items:shorcutItems selectAction:^(NSUInteger index) {
        
        //ks add -- quick meeting
        NSDictionary *item = shorcutItems[index];
        NSString *appID = item[@"appID"];
        if ([appID isEqualToString:CMPMeeting_AppId]) {
            [[CMPMeetingManager shareInstance] otmBeginMeetingWithMids:nil onVC:vc from:MeetingOtmCreateFrom_Quick ext:nil completion:^(id  _Nonnull rslt, NSError * _Nonnull err, id  _Nonnull ext, NSInteger step) {
                            
            }];
            return;
        }
        //end
        
        if (CMP_IPAD_MODE) {
            [self switchTabBarItemAndPageWithShortcutItem:shorcutItems[index] inVc:vc];
        } else {
            UIViewController *aVc = vc;
            if ([aVc isKindOfClass:[RDVTabBarController class]]) {
                aVc = ((UITabBarController *)aVc).selectedViewController;
            }
            [self selectIndex:index items:shorcutItems viewController:aVc];
        }
    } closeAction:nil];
    //ks fix -- V5-43431 为了关闭快捷入口
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_willShowShortcutView" object:nil];
    //end
}

+ (void)hide {
    [[CMPMediator sharedInstance] CMPMediator_hideShortcut];
}

+ (void)selectIndex:(NSUInteger)index items:(NSArray *)items viewController:(UIViewController *)vc {
    NSDictionary *item = items[index];
    NSString *appID = item[@"appID"];
    NSString *url = item[@"url"];
    if ([appID isEqualToString:@"scan"]) {
        [[CMPMessageManager sharedManager] showScanViewWithUrl:url viewController:vc];
    } else {
//        if ([appID isEqualToString:@"61"] &&
//            CMPChatType_null == [CMPChatManager sharedManager].chatType) {
//            [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"msg_zhixinInitError")];
//            return;
//        }
        
        if ([appID isEqualToString:@"61"]) {
            if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) {
                [self cmp_showHUDWithText:SY_STRING(@"msg_zhixin_notHasPermission")];
                return;
            }
        }
        if ([appID isEqualToString:@"36"]) {//签到
            CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
            [tabBarProvider appClick:appID appName:item[@"appName"] uniqueId:@""];//没有uniqueId字段
        }
        
        [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:vc];
    }
}

#pragma mark-
#pragma mark 处理 iPad 联动跳转逻辑

/**
 同时切换页签、操作区、内容区
 
 @param item 快捷操作数据
 @param vc 跳转vc
 */
+ (void)switchTabBarItemAndPageWithShortcutItem:(NSDictionary *)item
                                           inVc:(UIViewController *)vc {
    NSString *appID = item[@"appID"];

    NSString *createType = @"";
    if ([appID isEqualToString:@"1"]) {
        createType = @"freeColl";
    } else if ([appID isEqualToString:@"1_2"]) {
        createType = @"template";
        appID = @"1";
    }
    
    NSString *url = item[@"url"];
    
    // 扫一扫：特殊处理
    if ([appID isEqualToString:@"scan"]) {
        [[CMPMessageManager sharedManager] showScanViewWithUrl:url viewController:vc];
        return;
    }
    
    // 没有致信权限
//    if ([appID isEqualToString:kRcAppID] &&
//        CMPChatType_null == [CMPChatManager sharedManager].chatType) {
//        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"msg_zhixinInitError")];
//        return;
//    }
    
    if ([appID isEqualToString:kRcAppID]) {
        if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) {
            [self cmp_showHUDWithText:SY_STRING(@"msg_zhixin_notHasPermission")];
            return;
        }
    }
    
    CMPTabBarViewController *tabBar = (CMPTabBarViewController *)vc;
    NSInteger indexOfAppID = [CMPShortcutHelper indexOfTabBar:tabBar withAppId:appID];
    
    [vc cmp_clearDetailViewController];
    
    if (indexOfAppID != -1) {
        // appID对应应用在底导航，切换到对应应用
        [tabBar setSelectedIndex:indexOfAppID];
        
        if ([appID isEqualToString:kRcAppID]) {
            // 新建致信聊天，消息在底导航，不需要中间页面
            [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:vc];
        } else {
            // 清空页面，中间页面作为根页面
            CMPSplitViewController *splitVc = (CMPSplitViewController *)tabBar.selectedViewController;
            NSDictionary *params = @{@"createType" : createType};
            CMPTabBarWebViewController *bannerWebViewVc = [self tabBarWebViewWithAppID:appID params:params];
            bannerWebViewVc.titleType = CMPBannerTitleTypeLeft;
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if ((orientation == UIDeviceOrientationPortrait ||
                 orientation == UIDeviceOrientationPortraitUpsideDown)) { // splitVc.masterStackSize == 0 页签没有初始化过
                splitVc.detailNavigation.viewControllers = @[bannerWebViewVc];
                splitVc.masterStackSize = 1;
            } else {
                splitVc.masterNavigation.viewControllers = @[bannerWebViewVc];
            }
        }
    } else {
        // 切换到常用应用
        [tabBar openCommonApp];
        if ([appID isEqualToString:kRcAppID]) {
            CMPMessageListViewController *messageVc = [[CMPMessageListViewController alloc] init];
            messageVc.backBarButtonItemHidden = NO;
            
            CMPSplitViewController *splitVc = (CMPSplitViewController *)tabBar.selectedViewController;
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if ((orientation == UIDeviceOrientationPortrait ||
                orientation == UIDeviceOrientationPortraitUpsideDown) &&
                splitVc.masterStackSize != 0) { // splitVc.masterStackSize == 0 页签没有初始化过
                [splitVc.detailNavigation popToRootViewControllerAnimated:NO];
                [splitVc.detailNavigation pushViewController:messageVc animated:NO];
                splitVc.masterStackSize = 2;
            } else {
                [splitVc.masterNavigation popToRootViewControllerAnimated:NO];
                [splitVc.masterNavigation pushViewController:messageVc animated:NO];
            }
            // 新建致信聊天，消息在工作台，不需要中间页面
            [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:vc];
        } else {
            // 在首页上push中间页面
            CMPSplitViewController *splitVc = (CMPSplitViewController *)tabBar.selectedViewController;
            NSDictionary *params = @{@"createType" : createType};
            CMPBannerWebViewController *bannerWebViewVc = [self bannerWebViewWithAppID:appID params:params];
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if ((orientation == UIDeviceOrientationPortrait ||
                 orientation == UIDeviceOrientationPortraitUpsideDown)) {
                [splitVc.detailNavigation popToRootViewControllerAnimated:NO];
                [splitVc.detailNavigation pushViewController:bannerWebViewVc animated:NO];
                splitVc.masterStackSize = 2;
            } else {
                [splitVc.masterNavigation popToRootViewControllerAnimated:NO];
                [splitVc.masterNavigation pushViewController:bannerWebViewVc animated:NO];
                [splitVc clearDetailViewController];
            }
        }
    }
}

/**
 获取appID对应的应用在底导航的index
 -1 - 不在底导航
 */
+ (NSInteger)indexOfTabBar:(CMPTabBarViewController *)tabBar withAppId:(NSString *)appID {
    NSUInteger index = -1;
    for (int i = 0; i < tabBar.tabBar.items.count; ++i) {
        RDVTabBarItem *item = tabBar.tabBar.items[i];
        NSInteger tag = item.tag - CMPTabBarItemTag;
        if (tag == [appID integerValue] ||
            ([appID isEqualToString:kRcAppID] && (tag == 55))) { // 消息配置到底导航，消息 AppID为55，新建致信聊天需要切换到消息页签
            index = i;
            break;
        }
    }
    return index;
}

+ (CMPTabBarWebViewController *)tabBarWebViewWithAppID:(NSString *)appID params:(NSDictionary *)params {
    NSString *url = @"http://cmp/v/page/cmp-app-access.html";
    NSDictionary *p = @{@"appId" : appID,
                        @"openApi" : @"appCreatePage",
                        @"params" : params ?: @""};
    CMPTabBarWebViewController *viewController = [[CMPTabBarWebViewController alloc] init];
    NSString *urlStr = [url urlCFEncoded];
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
    
    viewController.startPageUrl = url;
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = NO;
    viewController.pageParam = @{@"url" : localHref,
                                 @"param" : [p JSONRepresentation]};
    return viewController;
}

+ (CMPBannerWebViewController *)bannerWebViewWithAppID:(NSString *)appID params:(NSDictionary *)params {
    NSString *url = @"http://cmp/v/page/cmp-app-access.html";
    NSDictionary *p = @{@"appId" : appID,
                        @"openApi" : @"appCreatePage",
                        @"params" : params ?: @""};
    return [CMPBannerWebViewController bannerWebViewWithUrl:url params:p];
}

@end
