//
//  CMPAppDelegate.m
//  CMPLib
//
//  Created by youlin on 2017/5/14.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "CMPAppDelegate.h"

@implementation CMPAppDelegate

@synthesize allowRotation = _allowRotation;

+ (CMPAppDelegate *)shareAppDelegate
{
    return nil;
}

//返回：是否要跳转到登陆页面  //统一处理原生弹出提示
- (BOOL)handleError:(NSError *)error
{
    return NO;
}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
//- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
//#else
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
//#endif
{
    if ([self.rotationAllowed isEqualToString:@"YES"]) {
        return UIInterfaceOrientationMaskLandscape;
    } else if ([self.rotationAllowed isEqualToString:@"NO"])  {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)setAllowRotation:(BOOL)allowRotation {
    _allowRotation = allowRotation;
}

- (BOOL)allowRotation {
    // 无论那个服务器版本，ipad、phone要支持横屏，必须根据deviceAllowRotation参数控制
    if (![CMPCore sharedInstance].allowRotation) {
        return NO;
    }
    if (INTERFACE_IS_PAD) {
        // 如果总开关开启，ipad端所有页面都支持横竖屏，V7.1SP1 IPad左右栏布局专版
        return YES;
    }
    else {
        // 如果是iPhone，根据设置参数控制是否支持横竖屏，
        // 比如：H5 url地址带cmp_orientation=auto，js主动设置参数、原生界面天然支持（附件、图片查看）
        return _allowRotation;
    }
}

- (CMPScreenShotView *)screenshotView
{
    if (!_screenshotView) {
        _screenshotView = [[CMPScreenShotView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
        [self.window insertSubview:_screenshotView atIndex:0];
        _screenshotView.hidden = YES;
    }
    return _screenshotView;
}

@end
