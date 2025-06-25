//
//  CMPShareManager.h
//  M3
//
//  Created by MacBook on 2019/10/24.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPStringConst.h>

@class CMPShareFileModel,CMPFileManagementRecord;

NS_ASSUME_NONNULL_BEGIN

@interface CMPShareManager : NSObject

/* 分享权限数据 */
@property (strong, nonatomic, readonly) NSDictionary *shareAuthData;


+ (instancetype)sharedManager;
/// 筛选分享入口
/// @param appId 分享过来的appid
/// @param keys 要进行筛选的入口数组
+ (NSArray *)filterShareTypeWithAppId:(NSString *)appId keys:(NSArray *)keys;

///显示内部分享view
- (void)showShareViewWithList:(nullable CMPShareFileModel *)shareFileModel mfr:(nullable CMPFileManagementRecord *)mfr pushVC:(UIViewController *)pushVC;

///显示外部分享到M3 view
- (void)showShareToInnerViewWithFilePaths:(NSArray *)filePaths fromVC:(UIViewController *)fromVC;

///显示投屏提示view
- (void)showScreenMirrorTipsView;

/// 显示分享到外部的授权弹框
- (void)showShareToAppsAuthViewWithArgu:(NSDictionary *)argu ClickedResult:(void(^)(NSString *result))clickedResult;

///关闭弹框
- (void)hideViewWithAnimation:(BOOL)animation;

#pragma mark 请求分享权限数据
- (void)requestShareAuthData;

#pragma mark - 分享相关
/// 注册分享id
- (void)initShareSDK;
/// 分享到QQ
/// @param filePath 文件路径
- (void)shareToQQWithFilePath:(NSString *)filePath;
/// 分享到微信
/// @param filePath 文件路径
- (void)shareToWechatWithFilePath:(NSString *)filePath;
/// 分享到致信
/// @param filePath 文件路径
- (void)shareToUcWithFilePaths:(NSArray *)filePaths commandDelegate:(nullable id)commandDelegate callbackId:(nullable NSString *)callbackId showVc:(UIViewController *)showVc;
/// 用系统分享打开
/// @param filePath 文件路径
- (void)shareToOtherWithFilePath:(NSString *)filePath showVc:(UIViewController *)showVc;
/// 分享到企业微信
/// @param filePath 文件路径
- (void)shareToWWechatWithFilePath:(NSString *)filePath;

/// 分享到钉钉
/// @param filePath 文件路径
- (void)shareToDingtalkWithFilePath:(NSString *)filePath;

/// 弹出无线投屏提示框
- (void)shareToOpenScreenMirroring;

/// 下载文件
/// @param filePath 文件路径
- (void)shareToDownloadWithFilePath:(NSString *)filePath from:(NSString *)from fromType:(CMPFileFromType)fromType fileId:(NSString *)fileId origin:(nullable NSString *)origin;

/// 打印
/// @param filePath 文件路径
/// @param webview webview
- (void)shareToPrintFileWithPath:(NSString *)filePath webview:(UIView *)webview;

/// 收藏文件
/// @param filePath 文件路径
/// @param fileId 文件id
- (void)shareToCollectWithFilePath:(NSString *)filePath fileId:(NSString *)fileId isUc:(BOOL)isUc;


#pragma mark - 外部分享相关

/// 处理外部分享至M3的文件和图片
/// @param path 文件\图片 路径
+ (void)handleThirdAppForwardingWithPaths:(NSString *)paths;
+ (void)handleThirdAppForwardingWithOriginUrl:(NSURL *)url;
+ (NSString *)getNewPath:(NSString *)path;
+ (NSString *)copyData:(NSData *)data withPath:(NSString *)path;

#pragma mark -- 通用分享（需求来自于v8稠州银行项目）
- (void)ksCommonShare:(NSDictionary *)params ext:(__nullable id)ext result:(void(^)(NSInteger step,NSDictionary *actInfo, NSError *err, __nullable id ext))result;

@end

NS_ASSUME_NONNULL_END
