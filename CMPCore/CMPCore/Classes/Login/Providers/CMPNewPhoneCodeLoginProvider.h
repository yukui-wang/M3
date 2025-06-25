//
//  CMPNewPhoneLoginProvider.h
//  M3
//
//  Created by zy on 2022/2/21.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPNewPhoneCodeLoginSuccessBlock) (NSString *response,NSDictionary *userInfo);
typedef void(^CMPNewPhoneCodeLoginFailBlock) (NSError *response,NSDictionary *userInfo);

@interface CMPNewPhoneCodeLoginProvider : CMPObject


/// 是否可以使用手机号、验证码登录
/// @param success 成功回调
/// @param fail 失败回调
- (NSString *)phoneCodeLoginWithCanUserPhoneLogin:(CMPNewPhoneCodeLoginSuccessBlock)success
                                             fail:(CMPNewPhoneCodeLoginFailBlock)fail;


/// 手机号是否有效
/// @param phone 手机号
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithValidPhoneNumbe:(NSString *)phone
                                        success:(CMPNewPhoneCodeLoginSuccessBlock)success
                                           fail:(CMPNewPhoneCodeLoginFailBlock)fail;
/// 获取手机号验证码
/// @param phone 手机号
/// @param verifyCode 图形验证码
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetPhoneCode:(NSString *)phone
                                  verifyCode:(NSString *)verifyCode
                                   extParams:(NSDictionary * _Nullable)extParams
                                     success:(CMPNewPhoneCodeLoginSuccessBlock)success
                                        fail:(CMPNewPhoneCodeLoginFailBlock)fail;


/// 获取图形验证码
/// @param success 成
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetGraphCodeSuccess:(CMPNewPhoneCodeLoginSuccessBlock)success
                                               fail:(CMPNewPhoneCodeLoginFailBlock)fail;

/// 验证码校验
/// @param phone 手机号
/// @param code 验证码
/// @param success 成功
/// @param fail 失败
//- (NSString *)phoneCodeLoginWithValidatePhoneCode:(NSString *)phone
//                                             code:(NSString *)code
//                                          success:(CMPNewPhoneCodeLoginSuccessBlock)success
//                                             fail:(CMPNewPhoneCodeLoginFailBlock)fail;


/// 获取区号
/// @param success 成功
/// @param fail 失败
- (NSString *)phoneCodeLoginWithGetAreaCodeSuccess:(CMPNewPhoneCodeLoginSuccessBlock)success
                                              fail:(CMPNewPhoneCodeLoginFailBlock)fail;

@end

NS_ASSUME_NONNULL_END
