//
//  CMPWiFiClockInProvider.m
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import "CMPWiFiClockInProvider.h"
#import <CMPLib/CMPWiFiUtil.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/SvUDIDTools.h>

static NSString * const kCMPWiFiClockInUrl = @"/rest/attendance/fastPunchCard";
static NSString * const kCMPWiFiClockInSettingUrl = @"/rest/m3/common/fastPunchSetting";

@interface CMPWiFiClockInProvider()<CMPDataProviderDelegate>
@property (copy, nonatomic) NSString *clockInSettingRequestID;
@property (copy, nonatomic) NSString *clockInRequestID;
@end

@implementation CMPWiFiClockInProvider

- (void)requestClockInSettingSuccess:(CMPWiFiClockInProviderRequestSettingSuccess)success
                                fail:(CMPWiFiClockInProviderRequestSettingFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPWiFiClockInSettingUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"success" : [success copy],
                              @"fail" : [fail copy]};
    self.clockInSettingRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)clockInWithSSID:(NSString *)ssid
                  bssid:(NSString *)bssid
            clockInTime:(NSString *)clockInTime
                success:(CMPWiFiClockInProviderClockInSuccess)success
                   fail:(CMPWiFiClockInProviderClockInFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPWiFiClockInUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"success" : [success copy],
                              @"fail" : [fail copy]};
    NSString *aUDID = [SvUDIDTools UDID];
    aDataRequest.requestParam = [@{@"fixTime" : clockInTime ?: @"",
                                  @"ssid" : ssid ?: @"",
                                  @"mac" : bssid ?: @"",
                                  @"deviceId" : aUDID ?: @"",
                                  } JSONRepresentation];
    self.clockInRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.clockInRequestID]) {
        CMPWiFiClockInProviderClockInSuccess block = aRequest.userInfo[@"success"];
        CMPWiFiClockInResponse *response = [CMPWiFiClockInResponse yy_modelWithJSON:aResponse.responseStr];
        if (block) {
            block(response);
        }
    } else if ([aRequest.requestID isEqualToString:self.clockInSettingRequestID]) {
        CMPWiFiClockInProviderRequestSettingSuccess block = aRequest.userInfo[@"success"];
        CMPWiFiClockInSettingResponse *response = [CMPWiFiClockInSettingResponse yy_modelWithJSON:aResponse.responseStr];
        if (block) {
            block(response);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:self.clockInRequestID]) {
        CMPWiFiClockInProviderClockInFail block = aRequest.userInfo[@"fail"];
        if (block) {
            block(error);
        }
    } else if ([aRequest.requestID isEqualToString:self.clockInSettingRequestID]) {
        CMPWiFiClockInProviderRequestSettingFail block = aRequest.userInfo[@"fail"];
        if (block) {
            block(error);
        }
    }
}

@end
