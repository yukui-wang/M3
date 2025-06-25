//
//  CMPCloudLoginHelper.h
//  M3
//
//  Created by CRMO on 2018/9/10.
//

#import <CMPLib/CMPObject.h>

/** 云联网络错误 **/
extern NSInteger const CMPLoginErrorCloudUnreachable;
/** 云联业务错误 **/
extern NSInteger const CMPLoginErrorCloudException;
/** 未绑定手机号 **/
extern NSInteger const CMPLoginErrorPhoneUnknown;
/** 服务器信息错误 **/
extern NSInteger const CMPLoginErrorServerInfoException;
/** 登录错误 **/
extern NSInteger const CMPLoginErrorLoginException;
/** 登录错误 设备已被绑定 **/
extern NSInteger const CMPLoginErrorDeviceBindedException;

typedef void(^CloudLoginDidSuccess)(void);
typedef void(^CloudLoginDidFail)(NSError * _Nonnull error);

@interface CMPCloudLoginHelper : CMPObject

/**
 云联手机号登录

 @param phone 手机号
 @param aPassword 密码
 @param verificationCode 验证码
 @param success 成功回调
 @param fail 失败回调
 */
- (void)loginWithPhone:(NSString * _Nonnull)phone
              password:(NSString * _Nonnull)aPassword
      verificationCode:(NSString * _Nullable)verificationCode
             loginType:(NSString * _Nullable)loginType
               success:(CloudLoginDidSuccess _Nullable)success
                  fail:(CloudLoginDidFail _Nullable)fail;

/**
 从云联更新服务器信息
 离线登录时触发

 @param corpID 云联服务器ID
 */
- (void)fetchServerInfoWithCorpID:(NSString * _Nonnull)corpID phone:(NSString *_Nonnull)phone;

@end
