//
//  CMPPermissionPlugin.m
//  M3
//
//  Created by 程昆 on 2019/3/1.
//

#import "CMPPermissionPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPPermissionPlugin ()<CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,copy) NSString *hasPermissionCallbackId;

@property (nonatomic,strong) NSMutableDictionary *systemSupportOptionsDic;

@end

@implementation CMPPermissionPlugin

- (CLLocationManager *)locationManager{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    NSDictionary *arguments = [command.arguments lastObject];
    NSString *module = arguments[@"module"];
    NSDictionary *infoDic = nil;
    if ([module isEqualToString:@"wifi"]) {
        infoDic = @{
                     @"code" : @"200",
                     @"message" : @"",
                     @"detail" : @"",
                   };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else if ([module isEqualToString:@"location"]){
        if(![CLLocationManager locationServicesEnabled]){
            infoDic = @{
                        @"code" : @"5003",
                        @"message" : @{
                                         @"permission" : @"location",
                                         @"name" : @"",
                                         @"hint" : @"请打开定位开关"
                                      },
                        @"detail" : @"",
                        };
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }else{
            CLAuthorizationStatus status =  [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways ) {
                infoDic = @{
                            @"code" : @"200",
                            @"message" : @"",
                            @"detail" : @"",
                            };
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else if (status == kCLAuthorizationStatusDenied){
                infoDic = @{
                            @"code" : @"5003",
                            @"message" : @{
                                    @"permission" : @"location",
                                    @"name" : UIApplicationOpenSettingsURLString,
                                    @"hint" : @"请打开允许获得定位权限开关"
                                    },
                            @"detail" : @"",
                            };
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            } else if (status == kCLAuthorizationStatusNotDetermined ){
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                    self.locationManager.delegate = self;
                    self.hasPermissionCallbackId = command.callbackId;
                }
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSDictionary *infoDic = nil;
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        infoDic = @{
                    @"code" : @"200",
                    @"message" : @"",
                    @"detail" : @"",
                    };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.hasPermissionCallbackId];
    } else if (status == kCLAuthorizationStatusDenied){
        infoDic = @{
                    @"code" : @"5003",
                    @"message" : @{
                            @"permission" : @"location",
                            @"name" : UIApplicationOpenSettingsURLString,
                            @"hint" : @"请打开允许获得定位权限开关"
                            },
                    @"detail" : @"",
                    };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[infoDic JSONRepresentation]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.hasPermissionCallbackId];
    }
}

- (void)getSystemSupportOptions:(CDVInvokedUrlCommand *)command {
    NSDictionary *arguments = [command.arguments lastObject];
    NSString *option = arguments[@"option"];
    CDVPluginResult *pluginResult = nil;
    if ([NSString isNull:option]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.systemSupportOptionsDic];
    } else {
        NSNumber *boolValue = _systemSupportOptionsDic[option];
        if (boolValue) {
            NSDictionary *resultDic = [NSDictionary dictionaryWithObject:boolValue forKey:option];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSDictionary *)systemSupportOptionsDic {
    if (!_systemSupportOptionsDic) {
        _systemSupportOptionsDic = [NSMutableDictionary dictionary];
        _systemSupportOptionsDic[@"darkMode"] = @(CMPThemeManager.sharedManager.isSupportUserInterfaceStyleDark);
    }
    return _systemSupportOptionsDic;
}

@end
