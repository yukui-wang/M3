//
//  CMPLoginUpdateConfigProvider.m
//  M3
//
//  Created by CRMO on 2018/9/27.
//

#import "CMPLoginUpdateConfigProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPCore.h>

static NSString * const kConfigInfoURL = @"/rest/m3/common/getConfigInfo";
static NSString * const kUserInfoURL = @"/rest/m3/login/getCurrentUser";
static NSString * const kCustomNavBarIndex = @"/rest/m3/navbar/customNavBarIndex";
static NSString * const kReportLoginLocation = @"/rest/m3/individual/updateOnlineLngLat";
static NSString * const kSuccessBlockKey = @"kSuccessBlockKey";
static NSString * const kFailBlockKey = @"kFailBlockKey";

@interface CMPLoginUpdateConfigProvider()<CMPDataProviderDelegate>
@property (copy, nonatomic) NSString *configInfoRequestID;
@property (copy, nonatomic) NSString *appListRequestID;
@property (copy, nonatomic) NSString *userInfoRequestID;
@property (copy, nonatomic) NSString *customNavBarIndexRequestID;
@property (copy, nonatomic) NSString *reportLoginLocationRequestID;
@end

@implementation CMPLoginUpdateConfigProvider

- (void)requestConfigInfoSuccess:(CMPRequestConfigInfoDidSuccess)success
                            fail:(CMPRequestConfigInfoDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kConfigInfoURL];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    self.configInfoRequestID = aDataRequest.requestID;
    aDataRequest.userInfo = @{kSuccessBlockKey : [success copy],
                              kFailBlockKey : [fail copy]};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)requestAppListSuccess:(CMPRequestAppListDidSuccess)success
                         fail:(CMPRequestAppListDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlPathMapForPath:@"/api/mobile/app/list"];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    self.appListRequestID = aDataRequest.requestID;
    aDataRequest.userInfo = @{kSuccessBlockKey : [success copy],
                              kFailBlockKey : [fail copy]};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)requestUserInfoSuccess:(CMPRequestUserInfoDidSuccess)success
                          fail:(CMPRequestUserInfoDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kUserInfoURL];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    
    NSDictionary *param = @{@"deviceCode" : [SvUDIDTools UDID] ?: @"",
                            @"userAgentFrom" : @"iphone",
                            @"pd" : [CMPCore sharedInstance].currentUser.loginPassword ?: @""
                            };
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [param JSONRepresentation];
    aDataRequest.requestType = kDataRequestType_Url;
    self.userInfoRequestID = aDataRequest.requestID;
    aDataRequest.userInfo = @{kSuccessBlockKey : [success copy],
                              kFailBlockKey : [fail copy]};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)updateCustomNavBarIndexWithPortalID:(NSString *)portalID
                                     appKey:(NSString *)appkey
                                    success:(CMPCustomNavBarIndexSuccess)success
                                       fail:(CMPCustomNavBarIndexFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCustomNavBarIndex];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    self.customNavBarIndexRequestID = aDataRequest.requestID;
    aDataRequest.userInfo = @{kSuccessBlockKey : [success copy],
                              kFailBlockKey : [fail copy]};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:_configInfoRequestID]) {
        id model = nil;
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:aResponse.responseStr];
        } else {
            model = [CMPLoginConfigInfoModel yy_modelWithJSON:aResponse.responseStr];
        }
        if ([model isKindOfClass:CMPLoginConfigInfoModel_2.class]) {
            CMPLoginConfigInfoModel_2 *m = model;
            CMPCore.sharedInstance.hasUcMsgServerDel = m.hasUcMsgServerDel;
        }
        
        CMPRequestConfigInfoDidSuccess block = aRequest.userInfo[kSuccessBlockKey];
        if (block) {
            block(model,aResponse.responseStr);
        }
    } else if ([aRequest.requestID isEqualToString:_appListRequestID]) {
        NSString *aResultStr = aResponse.responseStr;
        CMPObject *model = nil;
        if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
            model = [CMPAppListModel_2 yy_modelWithJSON:aResultStr];
        } else {
            model = [CMPAppListModel yy_modelWithJSON:aResultStr];
        }
        CMPRequestAppListDidSuccess block = aRequest.userInfo[kSuccessBlockKey];
        if (block) {
            block(model, aResultStr);
        }
    } else if ([aRequest.requestID isEqualToString:_userInfoRequestID]) {
        NSString *aResultStr = aResponse.responseStr;
        CMPRequestUserInfoDidSuccess block = aRequest.userInfo[kSuccessBlockKey];
        if (block) {
            block(aResultStr);
        }
    } else if ([aRequest.requestID isEqualToString:_customNavBarIndexRequestID]) {
        CMPCustomNavBarModel *model = [CMPCustomNavBarModel yy_modelWithJSON:aResponse.responseStr];
        CMPCustomNavBarIndexSuccess block = aRequest.userInfo[kSuccessBlockKey];
        if (block) {
            block(model);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:_configInfoRequestID]) {
        CMPRequestConfigInfoDidFail block = aRequest.userInfo[kFailBlockKey];
        if (block) {
            block(error);
        }
    } else if ([aRequest.requestID isEqualToString:_appListRequestID]) {
        CMPRequestAppListDidFail block = aRequest.userInfo[kFailBlockKey];
        if (block) {
            block(error);
        }
    } else if ([aRequest.requestID isEqualToString:_userInfoRequestID]) {
        CMPRequestUserInfoDidFail block = aRequest.userInfo[kFailBlockKey];
        if (block) {
            block(error);
        }
    } else if ([aRequest.requestID isEqualToString:_customNavBarIndexRequestID]) {
        CMPCustomNavBarIndexFail block = aRequest.userInfo[kSuccessBlockKey];
        if (block) {
            block(error);
        }
    }
}

- (void)reportLoginLocationWithProvice:(NSString *)provice
                                  city:(NSString *)city
                             rectangle:(NSString *)rectangle {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kReportLoginLocation];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    self.reportLoginLocationRequestID = aDataRequest.requestID;
    NSDictionary *param = @{@"province" : provice ?: @"",
                            @"city" : city ?: @"",
                            @"rectangle" : rectangle ?: @""
                            };
    aDataRequest.requestParam = [param JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

@end
