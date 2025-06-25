//
//  CMPCloudLoginProvider.m
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import "CMPDeviceBindingProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/SvUDIDTools.h>

NSString * const CMPDeviceBindingRequestUrl = @"/rest/m3/security/device/bind";//硬件绑定

NSString * const kCMPDeviceBindingSuccessBlockKey = @"kCMPDeviceBindingSuccessBlockKey";
NSString * const kCMPDeviceBindingFailBlockKey = @"kCMPDeviceBindingFailBlockKey";

@interface CMPDeviceBindingProvider()<CMPDataProviderDelegate>

@property (strong, nonatomic) NSString *deviceBindingRequestID;

@end

@implementation CMPDeviceBindingProvider

static CMPDeviceBindingProvider *_provider;

- (void)deviceBindingSuccess:(DeviceBindingDidSuccess)success
                        fail:(DeviceBindingDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:CMPDeviceBindingRequestUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSDictionary *requestParamDic = @{@"clientName": [[UIDevice currentDevice] name],
                                      @"longClientName": [[UIDevice currentDevice] name],
                                      @"clientNum": [SvUDIDTools UDID]};
    aDataRequest.requestParam = [requestParamDic JSONRepresentation];
    aDataRequest.userInfo = @{kCMPDeviceBindingSuccessBlockKey : [success copy],
                              kCMPDeviceBindingFailBlockKey : [fail copy]};
    self.deviceBindingRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    _provider = self;
}

#pragma mark - CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.deviceBindingRequestID]) {
        DeviceBindingDidSuccess successBlock = aRequest.userInfo[kCMPDeviceBindingSuccessBlockKey];
        DeviceBindingDidFail failBlock = aRequest.userInfo[kCMPDeviceBindingFailBlockKey];
        if (successBlock) {
            NSDictionary *responseDic = [aResponse.responseStr JSONValue];
            NSInteger code = [responseDic[@"code"] integerValue];
            NSString *message = responseDic[@"message"];
            if (code == 200) {
                successBlock(message);
            }else{
                if (failBlock) {
                    failBlock(message);
                }
            }
            _provider = nil;
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:self.deviceBindingRequestID]) {
        DeviceBindingDidFail failBlock = aRequest.userInfo[kCMPDeviceBindingFailBlockKey];
        if (failBlock) {
            failBlock(@"绑定失败");
            _provider = nil;
        }
    }
}

@end
