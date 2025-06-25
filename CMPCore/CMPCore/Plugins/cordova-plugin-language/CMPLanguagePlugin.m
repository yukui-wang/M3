//
//  CMPLanguagePlugin.m
//  M3
//
//  Created by 程昆 on 2019/6/11.
//

#import "CMPLanguagePlugin.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDataProvider.h>
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import "CMPLanguageHelper.h"

@implementation CMPLanguagePlugin

- (void)set:(CDVInvokedUrlCommand *)command {
    NSDictionary *arguments = [command.arguments lastObject];
    NSString *language = arguments[@"value"];
    SOLocalization *localization =[SOLocalization sharedLocalization];
    language = [localization getRegionWithServerLanguageKey:language];
    [localization setRegion:language serverId:[CMPCore sharedInstance].serverID];
    
    __block CDVPluginResult *result = nil;
    
    if (!language) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not support the language"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_ChangeLanguage" object:language];

    [CMPLanguageHelper refreshDataAndInterfaceDidSuccess:^{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } fail:^(NSError *error) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.domain];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)getList:(CDVInvokedUrlCommand *)command {
    NSArray *list = [CMPLanguageHelper availableLanguageList];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[list JSONRepresentation]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
