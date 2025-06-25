//
//  TrustdoGetCertAndUrl.m
//  M3
//
//  Created by wangxinxu on 2019/2/20.
//

#import "TrustdoGetCertAndUrl.h"
#define MokeyGetCertAndUrl @"MokeyGetCertAndUrl"

@interface TrustdoGetCertAndUrl ()
/** 手机盾请求证书 **/
@property (nonatomic, strong) NSString *mokeyServerCert;
/** 手机盾请求url **/
@property (nonatomic, strong) NSString *mokeyServerUrl;
@end

@implementation TrustdoGetCertAndUrl

static TrustdoGetCertAndUrl *_instance;

+ (TrustdoGetCertAndUrl *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        //        [self mokeySetup];
    }
    return self;
}

#pragma mark-
#pragma mark-网络请求
#pragma mark-获取初始化使用的地址和证书
- (void)getMokeyCertAndUrl
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kM3TrustdoServerInfoUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

// 获取手机盾的证书和地址
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    if (!strDic ||
        ![strDic isKindOfClass:[NSDictionary class]]) {
        [self showMokeyErrorAlert];
        return;
    }
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[strDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:MokeyGetCertAndUrl
     object:dic];
}

-(void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [self showMokeyErrorAlert];
}

- (void)showMokeyErrorAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SY_STRING(@"common_prompt")
                                                        message:SY_STRING(@"login_mokey_error_getInfo")
                                                       delegate:self
                                              cancelButtonTitle:SY_STRING(@"common_ok")
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
