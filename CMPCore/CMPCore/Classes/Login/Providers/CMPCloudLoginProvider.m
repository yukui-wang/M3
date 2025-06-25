//
//  CMPCloudLoginProvider.m
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import "CMPCloudLoginProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import "CMPConstant_Ext.h"

NSString * const kCMPCloudLoginSuccessBlockKey = @"kSuccessBlockKey";
NSString * const kCMPCloudLoginFailBlockKey = @"kFailBlockKey";

@interface CMPCloudLoginProvider()<CMPDataProviderDelegate>
@property (strong, nonatomic) NSString *getServerInfoRequestID;
@end

@implementation CMPCloudLoginProvider

- (void)serverInfoWithMobile:(NSString *)mobile
                        time:(NSString *)time
                        type:(NSString *)type
                     success:(CloudLoginGetServerInfoDidSuccess)success
                        fail:(CloudLoginGetServerInfoDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = kMplusGetServerInfoUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *requestParamDic = @{@"mobile": mobile?:@"",
                                      @"time": time?:@"",
                                      @"type": type?:@""};
    aDataRequest.requestParam = [requestParamDic JSONRepresentation];
    aDataRequest.userInfo = @{kCMPCloudLoginSuccessBlockKey : [success copy],
                              kCMPCloudLoginFailBlockKey : [fail copy]};
    self.getServerInfoRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.getServerInfoRequestID]) {
        CMPCloudLoginResponse *response = [CMPCloudLoginResponse yy_modelWithJSON:aResponse.responseStr];
        CloudLoginGetServerInfoDidSuccess successBlock = aRequest.userInfo[kCMPCloudLoginSuccessBlockKey];
        if (successBlock) {
            successBlock(response);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:self.getServerInfoRequestID]) {
        CloudLoginGetServerInfoDidFail failBlock = aRequest.userInfo[kCMPCloudLoginFailBlockKey];
        if (failBlock) {
            failBlock(error);
        }
    }
}

@end
