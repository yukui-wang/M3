//
//  CMPWiFiClockInSettingResponse.h
//  M3
//
//  Created by CRMO on 2019/1/27.
//

#import "CMPBaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPWiFiClockInSettingWiFiModel : CMPObject

@property (copy, nonatomic) NSString *ssid;
@property (copy, nonatomic) NSString *bssid;

@end

@interface CMPWiFiClockInSettingResponse : CMPBaseResponse

/** 上班时间，对应服务器字段fixTime **/
@property (copy, nonatomic) NSString *clockInTime;
/** 是否需要打卡，对应服务器字段isShow **/
@property (assign, nonatomic) BOOL needClockIn;
/** 设置的WiFi，对应服务器字段wifiSetting **/
@property (strong, nonatomic) NSArray<CMPWiFiClockInSettingWiFiModel *> *wifiSettings;

/**
 判断当前连接WiFi是否合法
 
 @param connectedWiFiInfo 当前连接WiFi信息，调用[CMPWiFiUtil connectedWifiInfo]获取
 */
- (BOOL)isConnectedWiFiLegal:(NSString *)bssid;

@end

NS_ASSUME_NONNULL_END
