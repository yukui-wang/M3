//
//  CMPMsgQuickHandler.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/9.
//

#import "CMPMsgQuickHandler.h"
#import <CMPLib/CMPCore.h>
#import "CMPHomeAlertManager.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIViewController+KSSafeArea.h>
#import "CMPCommonManager.h"
#import "CMPWindowAlertViewController.h"
#import "CMPQuickRouterAlertView.h"
//#import "M3LoginManager.h"
//#import "CMPLocalAuthenticationState.h"
//#import "CMPLocalAuthenticationTools.h"

@interface CMPMsgQuickHandler ()

@end

@implementation CMPMsgQuickHandler

+(BOOL)ifHasShowed
{
    NSString *key = [@"UDTag_MsgQuick_" stringByAppendingString:[CMPCore sharedInstance].userID];
    NSString *val = [UserDefaults objectForKey:key];
    if ([@"1" isEqualToString:val]) {
        return YES;
    }
    return NO;
}

+(void)updateActWithIfHandled:(BOOL)ifHandled
{
    NSString *val = ifHandled ? @"1" : @"0";
    NSString *key = [@"UDTag_MsgQuick_" stringByAppendingString:[CMPCore sharedInstance].userID];
    [UserDefaults setObject:val forKey:key];
    [UserDefaults synchronize];
}

+(BOOL)ifNeverTip
{
    NSString *key = [@"UDTag_MsgQuickNeverTip_" stringByAppendingString:[CMPCore sharedInstance].userID];
    NSString *val = [UserDefaults objectForKey:key];
    if ([@"1" isEqualToString:val]) {
        return YES;
    }
    return NO;
}

+(void)updateActWithIfNeverTip:(BOOL)ifNeverTip
{
    NSString *val = ifNeverTip ? @"1" : @"0";
    NSString *key = [@"UDTag_MsgQuickNeverTip_" stringByAppendingString:[CMPCore sharedInstance].userID];
    [UserDefaults setObject:val forKey:key];
    [UserDefaults synchronize];
}


static CMPMsgQuickHandler *msgQuickManager ;
static dispatch_once_t onceTokenMsgQuick;

+(instancetype)shareInstance
{
    dispatch_once(&onceTokenMsgQuick, ^{
        msgQuickManager = [[[self class] alloc] init];
        msgQuickManager.enterRoute = 9;
    });
    return msgQuickManager;
}

-(void)begin
{
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        return;
    }
    if ([CMPMsgQuickHandler ifNeverTip]) {
        return;
    }
    if ([CMPMsgQuickHandler ifHasShowed]) {
        return;
    }
    //ks fix -- V5-43553【M3快捷入口】iOS 未设置手势密码和生物识别，自动登陆后仍弹出快捷入口
    if (_enterRoute == 0) return;
//    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
//    if ([aLoginManager isAutoLogin]) {
//        BOOL canGes = aLoginManager.hasSetGesturePassword;
//        BOOL canDeviceAuth = (aLoginManager.localAuthenticationState.enableLoginFaceID || aLoginManager.localAuthenticationState.enableLoginTouchID) && [CMPLocalAuthenticationTools supportType] != CMPLocalAuthenticationTypeNone;
//        if (!canGes && !canDeviceAuth) {
//            return;
//        }
//    }
    //end
    
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        UIViewController *root = [CMPCommonManager keyWindow].rootViewController;
        if (root && [root isKindOfClass:NSClassFromString(@"RDVTabBarController")]) {
            CMPWindowAlertViewController *alertVC = [[CMPWindowAlertViewController alloc] init];
            alertVC.dismissBlk = ^(UIViewController *aVC) {
                [aVC.view removeFromSuperview];
                [aVC removeFromParentViewController];
                aVC = nil;
                [CMPMsgQuickHandler updateActWithIfHandled:YES];
                [[CMPHomeAlertManager sharedInstance] taskDone];
            };
            [root addChildViewController:alertVC];
            [root.view addSubview:alertVC.view];
            CMPQuickRouterAlertView *v= [[CMPQuickRouterAlertView alloc] init];
            v.defaultDismissTime = 0;
            [alertVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(@4);
                make.right.offset(@(-4));
                make.bottom.mas_equalTo(root.baseSafeView.mas_bottom).offset(-10);
                make.height.equalTo(@([v defaultHeight] + 10));
            }];
            [alertVC showBehind:v];
        }
    } priority:CMPHomeAlertPriorityMsgQuickAlert];
}

@end
