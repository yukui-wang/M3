//
//  CMPLauguageProvider.m
//  M3
//
//  Created by 程昆 on 2019/6/17.
//

#import "CMPLauguageProvider.h"
#import <CMPLib/CMPDataProvider.h>

NSString * const CMPLauguageRequestUrl = @"/rest/m3/common/locales";//获取服务器语言列表

NSString * const kCMPLauguageSuccessBlockKey = @"kCMPLauguageSuccessBlockKey";
NSString * const kCMPLauguageFailBlockKey = @"kCMPLauguageFailBlockKey";

@interface CMPLauguageProvider()<CMPDataProviderDelegate>

@property (strong, nonatomic) NSString *deviceBindingRequestID;

@end

@implementation CMPLauguageProvider

static CMPLauguageProvider *_provider;

- (void)getLanguageListSuccess:(GetLauguageListDidSuccess)success
                        fail:(GetLauguageListDidFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:CMPLauguageRequestUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.userInfo = @{kCMPLauguageSuccessBlockKey : [success copy],
                              kCMPLauguageFailBlockKey : [fail copy]};
    self.deviceBindingRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    _provider = self;
}

#pragma mark - CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.deviceBindingRequestID]) {
        GetLauguageListDidSuccess successBlock = aRequest.userInfo[kCMPLauguageSuccessBlockKey];
        GetLauguageListDidFail failBlock = aRequest.userInfo[kCMPLauguageFailBlockKey];
        if (successBlock) {
            NSDictionary *responseDic = [aResponse.responseStr JSONValue];
            NSInteger code = [responseDic[@"code"] integerValue];
            NSString *message = responseDic[@"message"];
            NSArray *lists = responseDic[@"data"];
            if (code == 200) {
                if (lists && [lists isKindOfClass:[NSArray class]]) {
                     successBlock([lists copy],message);
                }
            }else{
                if (failBlock) {
                    
                    if (message) {
                        NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
                        failBlock(error);
                    }
                    
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
        GetLauguageListDidFail failBlock = aRequest.userInfo[kCMPLauguageFailBlockKey];
        if (failBlock) {
            failBlock(error);
            _provider = nil;
        }
    }
}

@end
