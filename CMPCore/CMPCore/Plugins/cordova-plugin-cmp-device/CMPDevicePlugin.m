//
//  CMPDevice.m
//  CMPCore
//
//  Created by youlin on 2016/9/5.
//
//
#include <sys/types.h>
#include <sys/sysctl.h>
#import "CMPDevicePlugin.h"
#import <CordovaLib/CDV.h>
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPKeyboardStateListener.h>
#import <CMPLib/NSObject+Thread.h>

@implementation UIDevice (ModelVersion)

- (NSString*)modelVersion
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString* platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

@end

@implementation CMPDevicePlugin


- (NSString*)uniqueAppInstanceIdentifier:(UIDevice*)device
{
    return [SvUDIDTools UDID];
}

- (void)getDeviceInfo:(CDVInvokedUrlCommand*)command
{
    __weak typeof(self) weakself = self;
    [self dispatchAsyncToChild:^{
        NSDictionary* deviceProperties = [self deviceProperties];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:deviceProperties];
        [weakself.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (NSDictionary*)deviceProperties
{
    UIDevice* device = [UIDevice currentDevice];
    NSMutableDictionary* devProps = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [devProps setObject:@"Apple" forKey:@"manufacturer"];
    [devProps setObject:[device modelVersion] forKey:@"model"];
    [devProps setObject:INTERFACE_IS_PAD ? @"iPad" : @"iPhone" forKey:@"platform"];
    [devProps setObject:[device systemVersion] forKey:@"version"];
    [devProps setObject:[self uniqueAppInstanceIdentifier:device] forKey:@"uuid"];
    [devProps setObject:[[self class] cordovaVersion] forKey:@"cordova"];
    [devProps setObject:[device name] forKey:@"enbrand"];
    [devProps setObject:[device name] forKey:@"cnbrand"];
    
    NSDictionary* devReturn = [NSDictionary dictionaryWithDictionary:devProps];
    return devReturn;
}

+ (NSString*)cordovaVersion
{
    return CDV_VERSION;
}

- (void)hideSoftKeyboard:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate evalJs:@"document.activeElement.blur()"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isSoftKeyboardShow:(CDVInvokedUrlCommand*)command {
    CMPKeyboardStateListener *listner = [CMPKeyboardStateListener sharedInstance];
    NSInteger result = listner.isVisible ? 1:0;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
