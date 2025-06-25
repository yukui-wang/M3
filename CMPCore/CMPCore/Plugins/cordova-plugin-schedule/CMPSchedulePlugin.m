//
//  CMPSchedulePlugin.m
//  CMPCore
//
//  Created by yang on 2017/2/21.
//
//

#import "CMPSchedulePlugin.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPScheduleManager.h>
#import <EventKit/EventKit.h>
#import <CMPLib/CMPDevicePermissionHelper.h>

@interface CMPSchedulePlugin ()<CMPDataProviderDelegate>
{
    
}

@end

@implementation CMPSchedulePlugin

- (void)writeConfig:(CDVInvokedUrlCommand*)command
{
    NSDictionary *config = command.arguments[0][@"data"];
    NSLog(@"%s--%@",__func__,config);
    //此处开启日程同步
    EKEventStore *_eventStore = [[[EKEventStore alloc] init] autorelease];
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            NSLog(@"requestAccessToEntityType result:%@:%@",@(granted),error);
            CDVPluginResult *pluginResult = nil;
            if (error) {
                NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:58001],@"code",SY_STRING(@"Calendar_LoadFail"),@"message",@"",@"detail", nil];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else {
                if (granted) {
                    [[CMPScheduleManager sharedManager] writeConfig:config];
                    if ([[config objectForKey:@"immediateSync"] boolValue]) {
                        [[CMPScheduleManager sharedManager] forceSync];
                    }
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }else {
                    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:58002],@"code",SY_STRING(@"Calendar_NoAccess"),@"message",@"",@"detail", nil];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    //权限设置弹框
                    NSString *app_Name = [[NSBundle mainBundle]
                                           objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    NSString *message = [NSString stringWithFormat:SY_STRING(@"Calendar_Permisson_Setting"),app_Name];
                    [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"Calendar_Unavailable_title") messsage:message];
                }
            }
            
        }];
    }else{
        NSLog(@"no method requestAccessToEntityType");
    }
}

- (void)readConfig:(CDVInvokedUrlCommand*)command
{
    NSDictionary *data = [[CMPScheduleManager sharedManager] readConfig];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:data];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dealloc
{
    [super dealloc];
}

@end
