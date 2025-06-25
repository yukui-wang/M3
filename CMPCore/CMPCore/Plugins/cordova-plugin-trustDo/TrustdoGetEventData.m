//
//  TrustdoGetEventData.m
//  M3
//
//  Created by wangxinxu on 2019/2/19.
//

#import "TrustdoGetEventData.h"
#define MokeyLoginEventData @"MokeyLoginEventData"

@implementation TrustdoGetEventData

static TrustdoGetEventData *_instance;

+ (TrustdoGetEventData *)sharedInstance
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
        
    }
    return self;
}

#pragma mark-
#pragma mark-网络请求
#pragma mark-获取登录挑战数据
- (void)getMokeyLoginEventData
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kM3TrustdoLoginEventUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

// 获取更新证书的挑战数据
- (void)getMokeyUpdateCertEventDataWithLoginName:(NSString *)loginName; {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [[CMPCore fullUrlForPath:kM3TrustdoUpdateCertEventUrl]stringByAppendingString:loginName];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[strDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];

    // 获取挑战数据eventData
    if (strDic[@"data"] == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:SY_STRING(@"login_mokey_error_geteventdata")
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        id data = dic[@"data"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:MokeyLoginEventData
         object:data];
    }
}

@end
