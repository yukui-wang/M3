//
//  CMPGuidePagesViewHelper.m
//  M3
//
//  Created by youlin on 2017/11/23.
//

#import "CMPGuidePagesViewHelper.h"
#import "AppDelegate.h"
#import "CMPGuidePagesViewController.h"

NSString * const kIsShowedGuidePage = @"kIsShowGuidePage";
NSString * const kM3VersionKey = @"m3version";
NSString * const kM3NotAgreePrivacyKey = @"kM3NotAgreePrivacyKey";

@interface CMPGuidePagesViewHelper ()

@property (nonatomic,strong)UIWindow *window;
@property (nonatomic,copy)GuidePagesViewDismissBlock dismissBlock;

@end

@implementation CMPGuidePagesViewHelper

+ (BOOL)needShowGuidePagesView
{
    NSString *aOldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kM3VersionKey];
    NSString *aCurrentVersion = [CMPCore clinetVersion];

    if (!aOldVersion) {
        return YES;
    }
    
    if ([aOldVersion compare:aCurrentVersion] == NSOrderedAscending) {
        return YES;
    }
    
    BOOL isNotAgreePrivacy = [[[NSUserDefaults standardUserDefaults] objectForKey:kM3NotAgreePrivacyKey] boolValue];
    if (isNotAgreePrivacy) {
        return YES;
    }
    
    return NO;
    
//    NSNumber *isShowedGuidePage = [[NSUserDefaults standardUserDefaults] objectForKey:kIsShowedGuidePage];
//    if (!isShowedGuidePage) {
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kIsShowedGuidePage];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return YES;
//    }
//    return NO;
}

- (void)showGuidePagesView:(NSArray *)imagePathArray dismissComplete:(GuidePagesViewDismissBlock)complete
{
    self.dismissBlock = complete;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.hidden = NO;
    CMPGuidePagesViewController *guidePagesViewController = [[CMPGuidePagesViewController alloc] initWithGuidePagesViewHelper:self];
    self.window.rootViewController = guidePagesViewController;
    
    // 发通知当前引导页显示
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ShowGuidePagesView object:nil];
}


- (void)hideGuidePagesView
{
    self.window.hidden = YES;
    self.window = nil;
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    self.dismissBlock = nil;
}

#pragma mark CMPGuidePagesViewDelegate
- (void)guidePagesView:(CMPGuidePagesView *)welcomeView buttonTag:(NSInteger)tag
{
    [UIView animateWithDuration:0.7 animations:^{
//        _guidePagesView.alpha = 0.01;
//        _guidePagesView.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
        self.window.rootViewController.view.alpha = 0.01;
        self.window.rootViewController.view.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
    } completion:^(BOOL finished) {
        [self hideGuidePagesView];
        // 发通知当前引导页关闭
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_HideGuidePagesView object:nil];
    }];
}

@end
