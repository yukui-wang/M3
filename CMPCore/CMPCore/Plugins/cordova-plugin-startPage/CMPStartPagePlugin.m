//
//  CMPStartPagePlugin.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/13.
//
//

#import "CMPStartPagePlugin.h"
#import "CMPStartPageView.h"
#import "AppDelegate.h"
#import "CMPCommonManager.h"

@implementation CMPStartPagePlugin


- (void)pluginInitialize
{
    [super pluginInitialize];
}

- (void)hideStartPage:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
