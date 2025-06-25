//
//  CMPOCRManager.m
//  M3
//
//  Created by zengbixing on 2017/12/21.
//

#import "CMPOCRManager.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"

#define kOCR_user @"seeyon"
#define kOCR_password @"cUtre27kEPRa"
#define kOCR_url @"https://imgs-sandbox.intsig.net/icr/recognize_document_v2?"

@interface CMPOCRManager()<CMPDataProviderDelegate>

@end

@implementation CMPOCRManager

+ (CMPOCRManager*)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)sendRecognizeImg:(NSData*)imgData {

    NSString *url = [NSString stringWithFormat:@"%@user=%@&password=%@",kOCR_url, kOCR_user, kOCR_password];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.bodyData = imgData;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_BodyData;
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    
    NSString *response = [aResponse responseStr];
    NSDictionary *responseDic = [response JSONValue];
    NSDictionary *data = [responseDic objectForKey:@"data"];
    
    NSLog(@"providerDidFinishLoad----");
    
    NSArray *lin = [responseDic objectForKey:@"linesText"];
    
    NSString *str = @"";
    
    for (NSInteger i = 0; i < lin.count;i++) {
        
        NSString *str1 = lin[i];
        
        str = [str stringByAppendingString:str1];
        
    }
    
    NSLog(str);
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    NSLog(@"didFailLoadWithError----");
}

@end
