//
//  CMPAutoLockTool.m
//  M3
//
//  Created by CRMO on 2019/3/15.
//

#import "CMPAutoLockTool.h"
#import "M3LoginManager.h"
#import "CMPLocalAuthenticationTools.h"
#import <CMPLib/CMPCore.h>
#import "CMPLocalAuthenticationState.h"
#import "CMPGestureHelper.h"
#import "CMPLocalAuthenticationHelper.h"
#import "AppDelegate.h"
#import <CMPLib/CMPLoginAccountModel.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/NSObject+CMPHUDView.h>

/** 自动锁定时间间隔,单位秒 **/
static int const kAutoLockTime = 5 * 60;

@interface CMPAutoLockTool()
@property (strong, nonatomic) NSDate *beginTime;
@end

@implementation CMPAutoLockTool

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)begin {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:kNotificationName_ApplicationDidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:kNotificationName_ApplicationWillEnterForeground object:nil];
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterBackground {
    self.beginTime = [NSDate date];
}

- (void)enterForeground {
    // 自动锁定展示规则：
    // 1. 用户登录状态
    // 2. 开启了手势密码、指纹解锁
    // 3. 手势密码、指纹解锁当前没有展示
    // 4. 休眠时间大于用户设置时间
    
    if (![self loginState]) {
        DDLogDebug(@"zl---[%s]当前不是登录状态", __FUNCTION__);
        return;
    }
    
    if (![self enableGesture] &&
        ![self enableLocalAuthentication]) {
        DDLogDebug(@"zl---[%s]没有开启手势密码，指纹解锁", __FUNCTION__);
        return;
    }
    
    if ([self isGestureViewShowed] ||
        [self isLocalAuthenticationViewShowed]) {
        DDLogDebug(@"zl---[%s]手势密码、指纹解锁已经展示", __FUNCTION__);
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:self.beginTime];
    if (time > kAutoLockTime) {
        if (([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID ||
             [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID) &&
            [CMPLocalAuthenticationTools supportType] != CMPLocalAuthenticationTypeNone) {
            CMPLocalAuthenticationHelper *helper = [[CMPLocalAuthenticationHelper alloc] init];
            
            helper.tapGestureView = ^{
                [self showGestureView];
            };
            
            __weak __typeof(self)weakSelf = self;
            [helper authWithCompletion:^(BOOL result, NSError *error) {
                if (!result) {
                    if ([CMPLocalAuthenticationTools isLocked]) {
                        M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
                        if (aLoginManager.hasSetGesturePassword) {
                            [weakSelf showGestureView];
                        } else {
                            // 清空密码，并返回登录页
                            NSString *aServerId = [CMPCore sharedInstance].serverID;
                            [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerId:aServerId];
                            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
                        }
                        [helper hide];
                        NSString *typeStr = @"";
                        CMPLocalAuthenticationType authType = [CMPLocalAuthenticationTools supportType];
                        if (authType == CMPLocalAuthenticationTypeFaceID) {
                            typeStr = @"面部";
                        }else if (authType == CMPLocalAuthenticationTypeTouchID) {
                            typeStr = @"指纹";
                        }
                        [[UIViewController currentViewController] cmp_showHUDToBottomWithText:[typeStr stringByAppendingString:@"解锁失败，请稍后重试"]];
                    }
                } else {
                    [helper hide];
                }
            }];
        } else {
            [self showGestureView];
        }
    }
}

- (void)showGestureView {
    CMPGestureHelper *helper = [CMPGestureHelper shareInstance];
    NSString *aImgUrl = [CMPCore memberIconUrlWithId:[CMPCore sharedInstance].userID];
    CMPLoginAccountModel *account = [CMPCore sharedInstance].currentUser;
    NSDictionary *aDic = @{@"autoHide" : @YES ,
                           @"gespassword" : account.gesturePassword,
                           @"imgUrl" : aImgUrl,
                           @"loginName" : account.loginName,
                           @"username" : account.name,
                           @"userpassword" : account.loginPassword
                           };
    [helper showGestureViewWithDelegate:[AppDelegate shareAppDelegate] from:FROM_BACKGROUND object:aDic ext:nil];
}

/**
 获取登陆状态
 */
- (BOOL)loginState {
    NSString *jesession = [CMPCore sharedInstance].jsessionId;
    if (![NSString isNull:jesession] && jesession.length > 0) {
        return YES;
    }
    return NO;
}

/**
 是否开启了手势密码
 */
- (BOOL)enableGesture {
    return [M3LoginManager sharedInstance].hasSetGesturePassword;
}

/**
 是否开启了指纹解锁
 */
- (BOOL)enableLocalAuthentication {
    if (([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID ||
         [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID) &&
        [CMPLocalAuthenticationTools supportType] != CMPLocalAuthenticationTypeNone) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isGestureViewShowed {
    return [CMPGestureHelper shareInstance].currentGestureView;
}

- (BOOL)isLocalAuthenticationViewShowed {
    return [CMPLocalAuthenticationHelper isLocalAuthenticationShow];
}

@end
