//
//  CMPWiFiClockInSettingResponse.m
//  M3
//
//  Created by CRMO on 2019/1/27.
//

#import "CMPWiFiClockInSettingResponse.h"

@implementation CMPWiFiClockInSettingWiFiModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ssid" : @"ssid",
             @"bssid" : @"mac"
             };
}

@end

@implementation CMPWiFiClockInSettingResponse

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"clockInTime" : @"data.fastPunchSet.fixTime",
             @"needClockIn" : @"data.fastPunchSet.isShow",
             @"wifiSettings" : @"data.fastPunchSet.wifiSetting"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"wifiSettings" : [CMPWiFiClockInSettingWiFiModel class]};
}

- (BOOL)isConnectedWiFiLegal:(NSString *)bssid {
    if ([NSString isNull:bssid]) {
        return NO;
    }
    
    for (CMPWiFiClockInSettingWiFiModel *wifi in self.wifiSettings) {
        if ([wifi.bssid isEqualToString:bssid]) {
            return YES;
        }
    }
    
    return NO;
}

@end
