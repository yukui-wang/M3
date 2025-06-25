//
//  CMPWebViewMsgListener.m
//  CMPCore
//
//  Created by yang on 2017/2/20.
//
//

#import "CMPWebviewListenerAddPlugin.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPObject.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <CMPLib/NSString+CMPString.h>

@interface CMPWebviewListenerAddPlugin ()

@end

@implementation CMPWebviewListenerAddPlugin

- (void)add:(CDVInvokedUrlCommand*)command
{
    NSString *notiName  = (command.arguments[0])[@"type"];
    if ([NSString isNull:notiName]) {
        NSLog(@"收到空的监听事件！");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notiName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiRecive:) name:notiName object:nil];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)notiRecive:(NSNotification *)noti
{
    NSString *value = @"''";
    NSString *aName = noti.name;
    id aObject = noti.object;
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
        value = [userInfo JSONRepresentation];
    } else {
        if ([aObject isKindOfClass:[NSString class]]) {
            value = [aObject replaceCharacter:@"'" withString:@"&apos;"];
            value = [aObject replaceCharacter:@"\n" withString:@" "];
            value = [NSString stringWithFormat:@"'%@'", aObject];
        } else if ([aObject isKindOfClass:[NSDictionary class]]) {
            value = [aObject JSONRepresentation];
        }
    }
    
    NSString *aStr = [NSString stringWithFormat:@"cmp.event.trigger('%@','document',%@)", aName, value];
    [self.commandDelegate evalJs:aStr];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
