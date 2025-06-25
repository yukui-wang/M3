//
//  CMPWiFiUtil.h
//  CMPLib
//
//  Created by CRMO on 2019/1/14.
//  Copyright © 2019 CMPCore. All rights reserved.
//

#import "CMPObject.h"

NS_ASSUME_NONNULL_BEGIN

/** wifiInfo返回key BSSID(mac地址) **/
extern NSString * const CMPWiFiInfoKeyBSSID;
/**  wifiInfo返回key SSID（WiFi名称） **/
extern NSString * const CMPWiFiInfoKeySSID;

@interface CMPWiFiUtil : CMPObject

/**
 获取当前连接WiFi的信息
 NSDictionary *dic = [CMPWiFiUtil connectedWifiInfo];
 NSString *ssid = dic[CMPWiFiInfoKeySSID];
 NSString *bssid = dic[CMPWiFiInfoKeyBSSID];

 @return CMPWiFiInfoKeyBSSID、CMPWiFiInfoKeySSID
 */
+ (NSDictionary *)connectedWifiInfo;

@end

NS_ASSUME_NONNULL_END
