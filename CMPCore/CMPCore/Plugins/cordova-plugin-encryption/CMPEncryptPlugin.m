//
//  CMPEncryptPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/10/13.
//
//

#import "CMPEncryptPlugin.h"
#import <CMPLib/GTMUtil.h>
#import <CMPLib/NSString+CMPString.h>

@implementation CMPEncryptPlugin
//  加密
- (void)encryptM3Login:(CDVInvokedUrlCommand*)command
{
    NSDictionary *parameter = [[command arguments] lastObject];
    NSArray *values =  [parameter objectForKey:@"value"];
    NSMutableArray *aResult = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *aStr in values) {
        NSString *v = @"";
        if (![NSString isNull:aStr]) {
           v = [GTMUtil encrypt:aStr];
        }
        [aResult addObject:v];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aResult];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
