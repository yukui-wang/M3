//
//  CMPFaceDataProvider.h
//  M3
//
//  Created by Shoujian Rao on 2023/9/20.
//

#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccess)(NSInteger statusCode, NSDictionary*_Nullable responseObject, NSString *_Nullable errorHint);
typedef void(^RequestFailure)(NSInteger statusCode, NSError*_Nullable error);

typedef void(^CompletionBlock)(NSDictionary * _Nullable respData,NSError * _Nullable error);

@interface CMPFaceDataProvider : CMPDataProvider<CMPDataProviderDelegate>


- (void)faceIdConfigCompletion:(CompletionBlock)completionBlock;
- (void)bizAndQrCodeByUserName:(NSString *)userName biz_no:(NSString *)biz_no completion:(CompletionBlock)completionBlock;
- (void)credentialBy:(NSString *)userName isSkip:(BOOL)isSkip completion:(CompletionBlock)completionBlock;
/**
 {
     "qrCodeId":"f13f341g",
     "status": 1
 }
 识别成功传递 status = 1，识别失败传递 -1
 */
-(void)scanQrcode:(NSString *)qrCodeId status:(NSInteger)status completion:(CompletionBlock)completionBlock;

//获取credential
//- (void)credentialWithUserName:(NSString *)userName skipVerification:(BOOL)skipVerification success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;


/*
 type
指定本次认证模式：
“web_login_with_username”         本次认证为带用户名的 web 认证请求
“web_login_without_username”    本次认证为不带用户名的 web 认证请求
 */
//发起认证（创建认证请求并获取 token）
//- (void)createBizInfoWithmessage:(NSDictionary *)message success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

//请求创建认证二维码
//- (void)createQrCodeWithBizInfoToken:(NSString *)bizInfoToken bizNo:(NSString *)bizNo  success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

//查询验证结果
- (void)getResultWith:(NSString *)bizNo bizInfoToken:(NSString *)bizInfoToken completion:(CompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
