//
//  CMPNewPhoneLoginProvider.m
//  M3
//
//  Created by zy on 2022/2/21.
//

#import "CMPNewPhoneCodeLoginProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>


/// 是否可用使用手机号登录
NSString *const kCMPNewPhoneLoginCanUserPhone = @"/rest/phoneLogin/phoneCode/isCanShowPhoneLogin";
/// 获取验证码
NSString *const kCMPNewPhoneLoginGetPhoneCode = @"/rest/phoneLogin/phoneCode/getPhoneCode";
/// 获取图形验证码
NSString *const kCMPNewPhoneLoginGetGraphCode = @"/rest/authentication/captcha";
/// 输入的手机号是否可用
NSString *const kCMPNewPhoneLoginValidPhone = @"/rest/phoneLogin/phoneCode/isPhoneCanUse";
/// 获取区号
NSString *const kCMPNewPhoneLoginGetAreaCode = @"/rest/phoneLogin/phoneCode/getDistrictNum";

@interface CMPNewPhoneCodeLoginRequestObj : NSObject

@property(nonatomic, copy) CMPNewPhoneCodeLoginSuccessBlock successBlock;

@property(nonatomic, copy) CMPNewPhoneCodeLoginFailBlock failedBlock;

@property(nonatomic, retain) NSDictionary *userInfo;

@end

@implementation CMPNewPhoneCodeLoginRequestObj

- (void)dealloc {
    self.successBlock = nil;
    self.failedBlock = nil;
}

@end

@interface CMPNewPhoneCodeLoginProvider ()<CMPDataProviderDelegate>

@property (strong, nonatomic) NSString *canUserPhoneRequestID;
@property (strong, nonatomic) NSString *getPhoneCodeRequestID;
//@property (strong, nonatomic) NSString *validatePhoneCodeRequestID;
@property (strong, nonatomic) NSString *getGraphCodeRequestID;
@property (strong, nonatomic) NSString *validPhoneRequestID;
@property (strong, nonatomic) NSString *getAreaCodeRequestID;

@end

@implementation CMPNewPhoneCodeLoginProvider

/// 是否可以使用手机号、验证码登录
/// @param success 成功回调
/// @param fail 失败回调
- (NSString *)phoneCodeLoginWithCanUserPhoneLogin:(CMPNewPhoneCodeLoginSuccessBlock)success fail:(CMPNewPhoneCodeLoginFailBlock)fail {
    
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.canUserPhoneRequestID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginCanUserPhone];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
    obj.successBlock = success;
    obj.failedBlock = fail;
    obj.userInfo = nil;
    aDataRequest.userInfo = (NSDictionary *)obj;
    
    self.canUserPhoneRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}

/// 手机号是否有效
/// @param phone 手机号
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithValidPhoneNumbe:(NSString *)phone
                                        success:(CMPNewPhoneCodeLoginSuccessBlock)success
                                           fail:(CMPNewPhoneCodeLoginFailBlock)fail {
    
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.validPhoneRequestID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginValidPhone];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSDictionary *requestParamDic = @{@"phoneNumber" : phone};
    aDataRequest.requestParam = [requestParamDic JSONRepresentation];

    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
    obj.successBlock = success;
    obj.failedBlock = fail;
    obj.userInfo = nil;
    aDataRequest.userInfo = (NSDictionary *)obj;
    
    self.validPhoneRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}

/// 获取手机号验证码
/// @param phone 手机号
/// @param verifyCode 图形验证码
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetPhoneCode:(NSString *)phone
                                  verifyCode:(NSString *)verifyCode
                                   extParams:(NSDictionary * _Nullable)extParams
                               success:(CMPNewPhoneCodeLoginSuccessBlock)success
                                  fail:(CMPNewPhoneCodeLoginFailBlock)fail {
    
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.getPhoneCodeRequestID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginGetPhoneCode];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSDictionary *requestParamDic = @{@"phoneNumber" : phone, @"verifyCode" : verifyCode, @"source" : @"M3/Login"};
    if (extParams && [extParams isKindOfClass:NSDictionary.class] && extParams.allKeys.count) {
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:requestParamDic];
        [muDic addEntriesFromDictionary:extParams];
        requestParamDic = muDic;
    }
    aDataRequest.requestParam = [requestParamDic JSONRepresentation];
    
    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
    obj.successBlock = success;
    obj.failedBlock = fail;
    obj.userInfo = nil;
    aDataRequest.userInfo = (NSDictionary *)obj;
    
    self.getPhoneCodeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}

/// 获取图形验证码
/// @param success 成
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetGraphCodeSuccess:(CMPNewPhoneCodeLoginSuccessBlock)success
                                               fail:(CMPNewPhoneCodeLoginFailBlock)fail {
    
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.getGraphCodeRequestID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginGetGraphCode];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
    obj.successBlock = success;
    obj.failedBlock = fail;
    obj.userInfo = nil;
    aDataRequest.userInfo = (NSDictionary *)obj;
    
    self.getGraphCodeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}


/// 获取区号
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetAreaCodeSuccess:(CMPNewPhoneCodeLoginSuccessBlock)success
                                              fail:(CMPNewPhoneCodeLoginFailBlock)fail {
    
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.getAreaCodeRequestID];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginGetAreaCode];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    
    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
    obj.successBlock = success;
    obj.failedBlock = fail;
    obj.userInfo = nil;
    aDataRequest.userInfo = (NSDictionary *)obj;
    
    self.getAreaCodeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    return aDataRequest.requestID;
}

//- (NSString *)phoneCodeLoginWithValidatePhoneCode:(NSString *)phone
//                                             code:(NSString *)code
//                                          success:(CMPNewPhoneCodeLoginSuccessBlock)success
//                                             fail:(CMPNewPhoneCodeLoginFailBlock)fail {
//
//    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.validatePhoneCodeRequestID];
//
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPNewPhoneLoginValidatePhoneCode];
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = kRequestMethodType_POST;
//    aDataRequest.requestType = kDataRequestType_Url;
//    aDataRequest.headers = [CMPDataProvider headers];
//    NSDictionary *requestParamDic = @{@"phoneNumber" : phone,
//                                      @"smsVerifyCode": code};
//    aDataRequest.requestParam = [requestParamDic JSONRepresentation];
//
//    CMPNewPhoneCodeLoginRequestObj *obj = [[CMPNewPhoneCodeLoginRequestObj alloc] init];
//    obj.successBlock = success;
//    obj.failedBlock = fail;
//    obj.userInfo = nil;
//    aDataRequest.userInfo = (NSDictionary *)obj;
//
//    self.validatePhoneCodeRequestID = aDataRequest.requestID;
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
//    return aDataRequest.requestID;
//}

#pragma mark - CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.getPhoneCodeRequestID]) {
        self.getPhoneCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.canUserPhoneRequestID]) {
        self.canUserPhoneRequestID = nil;
//    } else if ([aRequest.requestID isEqualToString:self.validatePhoneCodeRequestID]) {
//        self.validatePhoneCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.getGraphCodeRequestID]) {
        self.getGraphCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.validPhoneRequestID]) {
        self.validPhoneRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.getAreaCodeRequestID]) {
        self.getAreaCodeRequestID = nil;
    }
    CMPNewPhoneCodeLoginRequestObj *obj = (CMPNewPhoneCodeLoginRequestObj *)aRequest.userInfo;
    NSString *responseStr = [NSString stringFromHtmlStr:aResponse.responseStr];
    if (obj.successBlock) {
        obj.successBlock(responseStr,obj.userInfo);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:self.getPhoneCodeRequestID]) {
        self.getPhoneCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.canUserPhoneRequestID]) {
        self.canUserPhoneRequestID = nil;
//    } else if ([aRequest.requestID isEqualToString:self.validatePhoneCodeRequestID]) {
//        self.validatePhoneCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.getGraphCodeRequestID]) {
        self.getGraphCodeRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.validPhoneRequestID]) {
        self.validPhoneRequestID = nil;
    } else if ([aRequest.requestID isEqualToString:self.getAreaCodeRequestID]) {
        self.getAreaCodeRequestID = nil;
    }
    CMPNewPhoneCodeLoginRequestObj *obj = (CMPNewPhoneCodeLoginRequestObj *)aRequest.userInfo;
    if (obj.failedBlock) {
        obj.failedBlock(error, obj.userInfo);
    }
}

@end
