//
//  CMPCommonTool.h
//  CMPLib
//
//  Created by MacBook on 2019/10/10.
//  Copyright © 2019 crmo. All rights reserved.
//  这个主要用于整个项目中 依赖小但并且公用的一些方法功能，例如保存图片到相册。这些功能的代码都是一样的，抽取到这个里面可以减少重复代码
//  这是个单例。无论用何种初始化方法，都将返回一个单例对象给你

#import <Foundation/Foundation.h>
#import <CordovaLib/CDVCommandDelegate.h>
#import <AVKit/AVKit.h>
#import <CMPLib/CMPStringConst.h>


NS_ASSUME_NONNULL_BEGIN
@interface CMPCommonTool : NSObject

+ (instancetype)sharedTool;

#pragma mark - 外部方法

/// 是否安装微信
+ (BOOL)isInstalledWechat;

/// 解决iOS13取不到searchField的问题
+ (UITextField *)getSearchFieldWithSearchBar:(UISearchBar *)searchBar;

/// 解决iOS13取不到cancelButton的问题
+ (UIButton *)getCancelButtonWithSearchBar:(UISearchBar *)searchBar;

#pragma mark UIImage和字符串互转

///图片转字符串
+ (NSString *)imageToMD5Str:(UIImage *)image;


+ (NSString *)imageToMD5StringWithImage:(UIImage *)image;
// 64base字符串转图片
+ (UIImage *)base64StringToImage:(NSString *)str;

#pragma mark - 获取当前时间戳

+ (long long)getCurrentTimeStamp;

#pragma mark - ipad push适配

+ (void)pushInDetailWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc;

+ (void)pushInMasterWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc;

///
+ (void)handleCurrentSelectVC;

#pragma mark 保存图片

/// 保存图片到本地
/// @param image 图片
/// @param imgName 图片名
/// @param fromSring 图片来源
- (void)saveImageToLocalWithImage:(UIImage *)image imageData:(NSData *)imageData imgName:(NSString *)imgName from:(NSString *)fromSring fromType:(CMPFileFromType)fromType fileId:(nullable NSString *)fileId isShowSavedTips:(BOOL)isShowSavedTips;

- (NSString *)handleImageString:(NSString *)imgString;

/// 保存图片到相册，如果target有值的话，就会将存储后的回调处理交给action参数传过来的响应方法
/// @param image 图片
/// @param target 接收存储后的回调方法的接收者
/// @param action 接收回调的响应方法
- (void)savePhotoWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action;
//保存图片到相册，包括gif
- (void)savePhotoToLocalWithImagePath:(NSString *)aPath completionHandler:(nullable void(^)(BOOL success, NSError * error))completionHandler;

/// json转字典
/// @param jsonString json字符串
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/// 字典转json字符串
/// @param dict 字典
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

/// 发送插件参数为空的错误
/// @param callbackId 回调id
/// @param commandDelegate delegate
+ (void)sendPluginCallbackErrorMsgWithCallbackId:(NSString *)callbackId commandDelegate:(id<CDVCommandDelegate>)commandDelegate;

/// 获取当前显示vc的title
+ (NSString *)getCurrentShowingVCTitle;
/// 获取当前显示vc的requestUrl
+ (NSString *)getCurrentShowingVCRequestUrlString;

/// 获取当前显示的ViewController
+ (UIViewController *)getCurrentShowViewController;
+ (UIViewController *)recursiveFindCurrentShowViewControllerFromViewController:(UIViewController *)fromVC;

/// 通过类名获取一个view对应的子view。下面那个获取vc的方法同理
/// @param className 类名
/// @param inView 在哪个view中进行查找
+ (UIView *)getSubViewWithClassName:(NSString *)className inView:(UIView *)inView;

+ (UIViewController *)getSubViewControllerWithClassName:(NSString *)className  inVC:(UIViewController *)inVC;


/// 获取视频文件宽高
/// @param url 视频的url
+ (CGSize)getVideoSizeWithUrl:(NSString *)url;

/// 获取视频文件的时长 毫秒
/// @param url 视频url
+ (NSInteger)getVideoTimeByUrlString:(NSString*)url;

/// 通过url获取视频缩略图
/// @param url url
- (UIImage *)getScreenShotImageFromVideoUrl:(NSString *)url;

/// @param url 视频url
+ (UIImage *)getScreenShotImageFromVideoUrl:(NSString *)url size:(CGSize)size;


/// 压缩视频
/// utputUrl 压缩后输出视频url，将会把压缩后的视频存储到这个url所在的路径
/// @param inputURL 压缩前视频url
/// @param handler 压缩成功回调。。如果需要失败回调，后续可增加
+ (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                        completeHandler:(void (^)(NSString *outputUrl))handler;

/// 获取fileId
/// @param url url
+ (NSString *)getSourceIdWithUrl:(NSString *)url;

/// 识别图中是否有二维码
/// @param image 图片
+ (BOOL)detectQRCodeWithImage:(UIImage *)image;

/// 识别图中二维码并返回结果
/// @param image 图片
+ (NSArray<NSString *> *)scanQRCodeWithImage:(UIImage *)image;

/// 获取文件大小的格式字符串
/// @param fileSize 文件大小f
+ (NSString *)fileSizeFormat:(long long )fileSize;

/// 快捷页面防多次点击
+ (BOOL)shortCutViewAvoidMultiTapping;
+(NSMutableAttributedString *)searchResultAttributeStringInString:(NSString *)inString searchText:(NSString *)searchText;
@end

NS_ASSUME_NONNULL_END

#pragma mark - C/C++函数

/// 为了适配界面而重写的CGRectMake函数
/// @param x x
/// @param y y
/// @param width w
/// @param height h
CGRect CMPRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
