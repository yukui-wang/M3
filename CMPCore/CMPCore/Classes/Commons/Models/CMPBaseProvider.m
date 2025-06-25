//
//  CMPBaseProvider.m
//  M3
//
//  Created by CRMO on 2017/11/20.
//

#import "CMPBaseProvider.h"

@interface CMPBaseProvider()
{
    CMPBaseRequest *request;
}
@end

@implementation CMPBaseProvider

- (void)request:(CMPBaseRequest *)aRequest
          start:(void(^)(void))start
        success:(void(^)(CMPBaseResponse *response, NSDictionary *responseHeader))success
           fail:(void(^)(NSError *error))fail {
    self.requestStart = start;
    self.requestSuccess = success;
    self.requestFail = fail;
    request = aRequest;
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [aRequest requestUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = [aRequest requestMethod];
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [aRequest yy_modelToJSONString];
    aDataRequest.requestType = [aRequest requestType];
    aDataRequest.httpShouldHandleCookies = [aRequest handleCookie];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)cacelRequest {
    self.requestStart = nil;
    self.requestSuccess = nil;
    self.requestFail = nil;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}

- (Class)classOfResponse {
//    NSString *requestClassName = NSStringFromClass([request class]);
//    NSString *prefix = [requestClassName substringToIndex:(requestClassName.length - 7)];
//    NSString *responseClassName = [prefix stringByAppendingString:@"Response"];
//    Class responseClass = NSClassFromString(responseClassName);
    return nil;
}

#pragma mark-
#pragma mark-CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider
                     request:(CMPDataRequest *)aRequest {
    if (self.requestStart) {
        self.requestStart();
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    CMPBaseResponse *model = [[self classOfResponse] yy_modelWithJSON:aResponse.responseStr];
    if (!model) {
        if (self.requestFail) {
            NSError *error = [NSError errorWithDomain:SY_STRING(@"Common_Server_DataError") code:-1 userInfo:nil];
            self.requestFail(error);
        }
        return;
    }
    if (self.requestSuccess) {
        self.requestSuccess(model, aResponse.responseHeaders);
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if (self.requestFail) {
        self.requestFail(error);
    }
}

@end
