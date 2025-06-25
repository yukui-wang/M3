//
//  CMPUserNotificationSettingHelper.m
//  M3
//
//  Created by 程昆 on 2020/7/2.
//

#import "CMPUserNotificationSettingHelper.h"
#import <CMPLib/CMPCustomAlertView.h>
#import "CMPHomeAlertManager.h"

@implementation CMPUserNotificationSettingHelper

+ (void)showNotOpenUserNotificationTip {
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    BOOL isUserNotificationEnable = !(UIUserNotificationTypeNone == setting.types);
    
    NSString *showNotOpenUserNotificationTipFlag = kUserDefaultName_showNotOpenUserNotificationTipFlag;
    NSDate *saveDate = [[NSUserDefaults standardUserDefaults] objectForKey:showNotOpenUserNotificationTipFlag];
    BOOL isToday = saveDate ? [[NSCalendar currentCalendar] isDateInToday:saveDate] : NO;
    
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        if (isUserNotificationEnable || isToday) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
            return;
        }
        
        id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:SY_STRING(@"user_notification_not_open_tip") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:SY_STRING(@"user_notification_ignore") otherButtonTitles:@[SY_STRING(@"common_goto_setting")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
               if (buttonIndex == 1) {
                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
               } else {
                   NSDate *saveDate = [NSDate date];
                   [[NSUserDefaults standardUserDefaults] setObject:saveDate forKey:showNotOpenUserNotificationTipFlag];
                   [[NSUserDefaults standardUserDefaults] synchronize];
               }
            [[CMPHomeAlertManager sharedInstance] taskDone];
        }];
        [alert setTheme:CMPTheme.new];
        [alert show];
    } priority:CMPHomeAlertPrioritywNotOpenUserNotification];
}

@end
