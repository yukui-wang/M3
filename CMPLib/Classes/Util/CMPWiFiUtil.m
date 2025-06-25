//
//  CMPWiFiUtil.m
//  CMPLib
//
//  Created by CRMO on 2019/1/14.
//  Copyright © 2019 CMPCore. All rights reserved.
//

#import "CMPWiFiUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NSString * const CMPWiFiInfoKeyBSSID = @"BSSID";
NSString * const CMPWiFiInfoKeySSID = @"SSID";

@implementation CMPWiFiUtil

+ (NSDictionary *)connectedWifiInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifname in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
    }
    if (!info) {
        return nil;
    }
    
    NSMutableDictionary *mucopyInfo = [info mutableCopy];
    [mucopyInfo setObject:[info[CMPWiFiInfoKeyBSSID] formatWifiBssid] forKey:CMPWiFiInfoKeyBSSID];
    
    return [mucopyInfo copy];
}

@end
