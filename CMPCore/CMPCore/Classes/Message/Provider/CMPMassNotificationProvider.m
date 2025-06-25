//
//  CMPMassNotificationProvider.m
//  M3
//
//  Created by 程昆 on 2019/1/17.
//

#import "CMPMassNotificationProvider.h"
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPThreadSafeMutableArray.h>
#import "CMPCommonManager.h"




NSString * const kCMPMassNotificationMessageReadUrl = @"/rest/uc/rong/littlebroadcast/confirm";

@interface CMPMassNotificationProvider()<CMPDataProviderDelegate>


@end

@implementation CMPMassNotificationProvider

- (void)readedMessage {
    
    NSString *url = [CMPCore fullUrlForPath:kCMPMassNotificationMessageReadUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    
    

}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    
}


@end
