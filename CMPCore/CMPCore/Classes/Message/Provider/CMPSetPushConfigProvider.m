//
//  CMPSetPushConfigProvider.m
//  M3
//
//  Created by 程昆 on 2019/10/9.
//

#import "CMPSetPushConfigProvider.h"
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>

NSString * const kCMPSetPushConfigUrl = @"/rest/m3/config/user/new/message/setting";

@interface CMPSetPushConfigProvider()<CMPDataProviderDelegate>

@end

@implementation CMPSetPushConfigProvider

- (void)setPushConfigMuteSetting:(NSString *)muteSetting {
    NSString *url = [CMPCore fullUrlForPath:kCMPSetPushConfigUrl];
    NSDictionary *aParam = @{@"mute":muteSetting};
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestParam = [aParam JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    
    

}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    
}

@end
