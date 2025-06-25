//
//  CMPFaceManager.h
//  CMPCore
//
//  Created by Shoujian Rao on 2023/9/20.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_SIMULATOR
    // 在模拟器环境下
#else
#import <MegFaceEE/MegFaceEE.h>
#endif

#import "CMPFaceErrorModel.h"

//type=1认证流程 type=2注册人脸流程
typedef void(^DetectCompletion)(NSInteger statusCode, NSString *message,NSString *qrCodeId,NSInteger type);

typedef void(^ResultCompletion)(BOOL success, CMPFaceErrorModel *errModel);
@interface CMPFaceManager : NSObject
+ (instancetype)sharedInstance;


- (void)faceEECheckWithDict:(NSDictionary *)dict inVC:(UIViewController *)vc detectCompletion:(DetectCompletion)detectCompletion;

//本地判断是否为人脸二维码
- (BOOL)isFaceEEQrCode:(NSString *)qrCode;

- (void)verifyQrCode:(NSString *)qrCode inVC:(UIViewController *)vc completion:(ResultCompletion)completion;

//- (void)clearConfig;

- (void)confirmRegisterFaceInVC:(UIViewController *)vc confirmBlock:(void(^)(void))confirmBlock cancelBlock:(void(^)(void))cancelBlock;
@end

