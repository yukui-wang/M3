//
//  CMPPrivilegePlugin.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import "CMPPrivilegePlugin.h"
#import "CMPPrivilegeManager.h"

/** 新建协同权限 **/
static NSString * const CMPPrivilegePluginNewcoll = @"newcoll";

@implementation CMPPrivilegePlugin

- (void)writePrivilege:(CDVInvokedUrlCommand *)command
{
    NSDictionary *vals = [command.arguments lastObject][@"values"];
    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    pr.hasColNew = [vals[@"hasColNew"] boolValue];
    pr.hasAddressBook = [vals[@"hasAddressBook"] boolValue];
    [CMPPrivilegeManager setCurrentUserPrivilegeWithConfig:pr];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getAuthorityByKey:(CDVInvokedUrlCommand *)command {
    NSString *key = [command.arguments lastObject][@"key"];
    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    if ([key isEqualToString:CMPPrivilegePluginNewcoll]) {
        CDVPluginResult *result = nil;
        if(pr.hasColNew) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
