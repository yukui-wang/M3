//
//  CMPBadgeNumberlugin.m
//  CMPCore
//
//  Created by wujiansheng on 2016/11/10.
//
//

#import "CMPBadgeNumberlugin.h"
#import <CMPLib/CMPCore.h>

@implementation CMPBadgeNumberlugin
- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand*)command
{
    NSDictionary *parameter = [[command arguments] lastObject];
    NSString *badgeNumber = [parameter objectForKey:@"badgeNumber"];
    NSInteger number = 0;
    if ([badgeNumber isKindOfClass:[NSString class]] || [badgeNumber isKindOfClass:[NSNumber class]]) {
        number = [badgeNumber integerValue];
    }
//    [CMPCore sharedInstance].applicationIconBadgeNumber = number;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number]; // 不要每次设置，影响性能
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
