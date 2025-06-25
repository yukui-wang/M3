//
//  MegFaceEEManager.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MegFaceEE/MegFaceEEError.h>
#import <MegFaceEE/MegFaceEEConfig.h>
#import <MegFaceEE/MegFaceEEUserInfo.h>
#import <MegFaceEE/MegFaceEEOptions.h>
#import <MegFaceEE/MegFaceEEGlobalOptions.h>
#import <MegFaceEE/MegFaceEEGlobalConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEManager : NSObject

/**
 设置全剧配置
 
 @param globalConfig  配置信息
 @param error  错误信息
 */
+ (void)setGlobalConfig:(MegFaceEEGlobalConfig *)globalConfig error:(MegFaceEEError *_Nullable*_Nullable)error;

/**
 创建MegFaceEEManager实例
 
 @param bundlePath      资源文件路径
 @param domain          域名
 @param endpoint        端点
 @param options         配置
 @param success         成功block
 @param failed          失败block
 */
+ (void)createManagerWithBundlePath:(NSString *)bundlePath domain:(NSString *)domain endpoint:(NSString *)endpoint options:(MegFaceEEGlobalOptions *)options success:(void(^)(MegFaceEEManager * manager))success failed:(MegFaceEECommonFailed)failed;


/**
 账号登录（未登录的情况下需要进行登录）
 
 @param viewController      启动登录的界面
 @param credential          credential
 @param success             成功block
 @param options             配置
 @param failed              失败block
 */
- (void)loginWithCurrentViewController:(UIViewController *)viewController credential:(NSString *)credential options:(MegFaceEEOptions *)options success:(MegFaceEECommonSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 获取用户信息
 
 @param success             成功block
 @param failed              失败block
 */
- (void)queryUser:(void(^)(MegFaceEEUserInfo * userInfo))success failed:(MegFaceEECommonFailed)failed;

/**
 获取用户信息
 
 @param error             error
 @return                  MegFaceEEUserInfo *
 */
+ (MegFaceEEUserInfo *)getUserInfoWithDomain:(NSString *)domain error:(MegFaceEEError *_Nullable*_Nullable)error;

/**
 扫码
 
 @param viewController  启动扫码界面
 @param completion      完成回调
 @param failed          失败回调
 */
- (void)startQrcodeScannerWithCurrentViewController:(UIViewController *)viewController completion:(MegFaceEEScanCompletion)completion failed:(MegFaceEECommonFailed)failed;

/**
 校验是否是FaceEE支持的二维码
 
 @param qrCode  二维码信息
 */
- (BOOL)isFaceEEQrCode:(NSString *)qrCode;

/**
 获取二维码中domain信息
 
 @param qrCode  二维码信息
 @param error  错误信息
 */
- (NSString *)getDomainWithQrCode:(NSString *)qrCode error:(MegFaceEEError *_Nullable*_Nullable)error;

/**
 二维码认证
 
 @param viewController  启动页面
 @param qrCode          二维码内容
 @param options         认证配置
 @param success         成功block
 @param failed          失败block
 */
- (void)qrCodeVerificationWithCurrentViewController:(UIViewController *)viewController qrCode:(NSString *)qrCode options:(MegFaceEEOptions *)options toExit:(MegFaceEEScanExit _Nullable)toExit success:(MegFaceEEVerificationSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 获取通知
 
 @param success     成功block
 @parma failed      失败block
 */
- (void)getNotifications:(MegFaceEENotificationSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 通知认证
 
 @param viewController      当前页面
 @param notification        通知内容
 @param options             配置
 @param success             成功block
 @param failed              失败block
 */
-(void)notificationVerificationWithCurrentViewController:(UIViewController *)viewController notification:(MegFaceEENotification *)notification options:(MegFaceEEOptions *)options success:(MegFaceEEVerificationSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 取消通知卡片（近适用于卡片形式的通知认证）
 @param viewController      当前页面
 @param completion          卡片消失回调
 */
- (void)dismissNotificationCardWithViewController:(UIViewController *)viewController completion:(void(^)(BOOL success))completion;

/**
 获取动态令牌码
 @param domain              domain
 @param success             成功block
 @param failed              失败block
 */
+ (void)getFaceIdOTPCodeWithDomain:(NSString *)domain success:(MegFaceEEGetFaceIdOTPCompletion)success failed:(MegFaceEECommonFailed)failed;

/**
 认证方式管理
 @param viewController      当前页面
 @param success             成功block
 @param failed              失败block
 */
-(void)authenticationManagementWithCurrentViewController:(UIViewController *)viewController success:(MegFaceEECommonSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 登出
 
 @param success             成功block
 @param failed              失败block
 */
-(void)logout:(MegFaceEECommonSuccess)success failed:(MegFaceEECommonFailed)failed;

/**
 设置多语言（对所有帐号起作用）
 @prama languageType        多语言类型
 */
- (void)setLanguage:(MegFaceEELanguageType)languageType;

/**
 获取账号列表
 */
+ (NSDictionary *)getAccountList;

/**
 获取版本号
 */
+ (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
