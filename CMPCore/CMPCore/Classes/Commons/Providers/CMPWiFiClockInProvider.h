//
//  CMPWiFiClockInProvider.h
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import <CMPLib/CMPObject.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPWiFiClockInResponse.h"
#import "CMPWiFiClockInSettingResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPWiFiClockInProviderClockInSuccess)(CMPWiFiClockInResponse *);
typedef void(^CMPWiFiClockInProviderClockInFail)(NSError *);

typedef void(^CMPWiFiClockInProviderRequestSettingSuccess)(CMPWiFiClockInSettingResponse *);
typedef void(^CMPWiFiClockInProviderRequestSettingFail)(NSError *);

@interface CMPWiFiClockInProvider : CMPObject

/**
 获取WiFi打卡相关配置信息

 @param success 成功回调
 @param fail 失败回调
 */
- (void)requestClockInSettingSuccess:(CMPWiFiClockInProviderRequestSettingSuccess)success
                                fail:(CMPWiFiClockInProviderRequestSettingFail)fail;

/**
 打卡

 @param success 成功回调
 @param fail 失败回调
 */
- (void)clockInWithSSID:(NSString *)ssid
                  bssid:(NSString *)bssid
                clockInTime:(NSString *)clockInTime
                success:(CMPWiFiClockInProviderClockInSuccess)success
                   fail:(CMPWiFiClockInProviderClockInFail)fail;

@end

NS_ASSUME_NONNULL_END
