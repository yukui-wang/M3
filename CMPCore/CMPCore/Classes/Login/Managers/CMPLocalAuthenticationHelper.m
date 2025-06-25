//
//  CMPLocalAuthenticationHelper.m
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import "CMPLocalAuthenticationHelper.h"
#import "CMPLocalAuthenticationViewController.h"
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPLoginDBProvider.h>

static int const kLocalAuthenticationWindowTag = 100001;

@interface CMPLocalAuthenticationHelper()
@property (strong, nonatomic) UIWindow *window;
@end

@implementation CMPLocalAuthenticationHelper

- (void)authWithCompletion:(void(^)(BOOL result, NSError *error))completion {
    self.window = [[UIWindow alloc] init];
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.tag = kLocalAuthenticationWindowTag;
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    CMPLocalAuthenticationViewController *vc = [[CMPLocalAuthenticationViewController alloc] init];
    self.window.rootViewController = vc;
    self.window.hidden = NO;
    
    __weak __typeof(self)weakSelf = self;
    vc.authDidFinish = completion;
    vc.tapGestureView = ^{
        if (weakSelf.tapGestureView) {
            weakSelf.tapGestureView();
        }
        [weakSelf hide];
    };
    vc.tapLoginView = ^{
        // 清空当前用户的密码
        NSString *aServerId = [CMPCore sharedInstance].serverID;
        [[CMPCore sharedInstance].loginDBProvider updateAllAccountsUnUsedWithServerId:aServerId];
        [M3LoginManager clearHistoryPhone];
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
        [weakSelf hide];
    };
}

- (void)hide {
    self.window.hidden = YES;
    self.window = nil;
}

+ (BOOL)isLocalAuthenticationShow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *w in windows) {
        if (w.tag == kLocalAuthenticationWindowTag) {
            return YES;
        }
    }
    return NO;
}

@end
