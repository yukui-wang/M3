//
//  CMPNotificationPostPlugin.m
//  CMPCore
//
//  Created by yang on 2017/2/20.
//
//

#import "CMPWebviewListenerFirePlugin.h"
#import <CMPLib/CMPObject.h>
#import <JavaScriptCore/JavaScriptCore.h>

@implementation CMPWebviewListenerFirePlugin

- (void)fire:(CDVInvokedUrlCommand*)command
{
    NSString *notiName  = (command.arguments[0])[@"type"];
    NSDictionary *obj = (command.arguments[0])[@"data"];
 
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:obj];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
