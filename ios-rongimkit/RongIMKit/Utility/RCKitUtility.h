//
//  RCKitUtility.h
//  iOS-IMKit
//
//  Created by xugang on 7/7/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <UIKit/UIKit.h>
#import "RCMessageModel.h"

@class RCConversationModel;

/*!
 IMKit工具类
 */
@interface RCKitUtility : NSObject

/*!
 时间转换

 @param secs    Unix时间戳（秒）
 @return        可视化的时间字符串

 @discussion 如果该时间是今天的，则返回值为"HH:mm"格式的字符串；
 如果该时间是昨天的，则返回字符串资源中Yesterday对应语言的字符串；
 如果该时间是昨天之前或者今天之后的，则返回"yyyy-MM-dd"的字符串。
 */
+ (NSString *)ConvertMessageTime:(long long)secs;

/*!
 时间转换

 @param secs    Unix时间戳（秒）
 @return        可视化的时间字符串

 @discussion 如果该时间是今天的，则返回值为"HH:mm"格式的字符串；
 如果该时间是昨天的，则返回"Yesterday HH:mm"的字符串（其中，Yesterday为字符串资源中Yesterday对应语言的字符串）；
 如果该时间是昨天之前或者今天之后的，则返回"yyyy-MM-dd HH:mm"的字符串。
 */
+ (NSString *)ConvertChatMessageTime:(long long)secs;

/*!
 获取资源包中的图片

 @param name        图片名
 @param bundleName  图片所在的Bundle名
 @return            图片
 */
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;

/*!
 获取指定颜色的图片

 @param color   颜色值
 @return        坐标为(0.0f, 0.0f, 1.0f, 1.0f)的纯色图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;


+ (UIColor *)getCMPThemeSkinColor;
/*!
 获取文字显示的尺寸

 @param text 文字
 @param font 字体
 @param constrainedSize 文字显示的容器大小

 @return 文字显示的尺寸

 @discussion 该方法在计算iOS 7以下系统显示的时候默认使用NSLineBreakByTruncatingTail模式。
 */
+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

/*!
 获取指定会话类型的消息内容的摘要

 @param messageContent  消息内容
 @param targetId  会话 Id
 @param conversationType  会话类型
 @param isAllMessage  是否获取全部摘要内容，如果设置为 NO，摘要内容长度大于 500 时可能被截取
 @return                消息内容的摘要

 @discussion SDK默认的消息有内置的处理，自定义消息会调用 RCMessageContent 中 RCMessageContentView 协议的
 conversationDigest 获取消息摘要。
*/
+ (NSString *)formatMessage:(RCMessageContent *)messageContent
                   targetId:(NSString *)targetId
           conversationType:(RCConversationType)conversationType
               isAllMessage:(BOOL)isAllMessage;

/*!
 获取消息通知时需展示的内容摘要

 @param message  消息
 @return                消息内容的摘要

 @discussion SDK默认的消息有内置的处理，自定义消息会调用 RCMessageContent 中 RCMessageContentView 协议的
 conversationDigest 获取消息摘要。
*/
+ (NSString *)formatLocalNotification:(RCMessage *)message;

/*!
 获取指定会话类型的消息内容的摘要

 @param messageContent  消息内容
 @param targetId  会话 Id
 @param conversationType  会话类型
 @return                消息内容的摘要

 @discussion SDK默认的消息有内置的处理，
 自定义消息会调用RCMessageContent中RCMessageContentView协议的conversationDigest获取消息摘要。
 @discussion 与 formatMessage:targetId:conversationType:isAllMessage 区别是，该方法在摘要内容长度大于 500 时可能被截取
 */
+ (NSString *)formatMessage:(RCMessageContent *)messageContent
                   targetId:(NSString *)targetId
           conversationType:(RCConversationType)conversationType;

/*!
 获取消息内容的摘要

 @param messageContent  消息内容
 @return                消息内容的摘要

 @discussion SDK默认的消息有内置的处理，
 自定义消息会调用RCMessageContent中RCMessageContentView协议的conversationDigest获取消息摘要。
 @discussion 与 formatMessage:targetId:conversationType:isAllMessage 区别是，该方法在摘要内容长度大于 500 时可能被截取
 */
+ (NSString *)formatMessage:(RCMessageContent *)messageContent;

/*!
 消息是否需要显示

 @param message 消息
 @return 是否需要显示
 */
+ (BOOL)isVisibleMessage:(RCMessage *)message;

/*!
 消息是否需要显示

 @param messageId 消息ID
 @param content   消息内容
 @return 是否需要显示
 */
+ (BOOL)isUnkownMessage:(long)messageId content:(RCMessageContent *)content;

/*!
 以消息的类型名为Key值在字符串资源中查找对应语言的字符串

 @param messageContent  消息内容
 @return                对应语言的字符串
 */
+ (NSString *)localizedDescription:(RCMessageContent *)messageContent;

/*!
 获取消息对应的本地消息Dictionary

 @param message 消息实体
 @return 本地通知的Dictionary
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCMessage *)message;

/*!
 获取消息对应的本地消息Dictionary（已废弃，请勿使用）

 @param conversationType    会话类型
 @param fromUserId          发送者的用户ID
 @param targetId            消息的目标会话ID
 @param messageContent      消息内容
 @return                    本地通知的Dictionary

 @warning **已废弃，请勿使用。**
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType
                                         fromUserId:(NSString *)fromUserId
                                           targetId:(NSString *)targetId
                                     messageContent:(RCMessageContent *)messageContent
    __deprecated_msg("已废弃，请勿使用。");

/*!
 获取消息对应的本地消息Dictionary

 @param conversationType    会话类型
 @param fromUserId          发送者的用户ID
 @param targetId            消息的目标会话ID
 @param objectName          消息的类型名
 @return                    本地通知的Dictionary
 */
+ (NSDictionary *)getNotificationUserInfoDictionary:(RCConversationType)conversationType
                                         fromUserId:(NSString *)fromUserId
                                           targetId:(NSString *)targetId
                                         objectName:(NSString *)objectName;

/*!
 获取文件消息中消息类型对应的图片名称

 @param fileType    文件类型
 @return            图片名称
 */
+ (NSString *)getFileTypeIcon:(NSString *)fileType;

/*!
 获取文件大小的字符串，单位是k

 @param byteSize    文件大小，单位是byte
 @return 文件大小的字符串
 */
+ (NSString *)getReadableStringForFileSize:(long long)byteSize;

/*!
 获取会话默认的占位头像

 @param model 会话数据模型
 @return 默认的占位头像
 */
+ (UIImage *)defaultConversationHeaderImage:(RCConversationModel *)model;

/*!
 获取聚合显示的会话标题

 @param conversationType 聚合显示的会话类型
 @return 显示的标题
 */
+ (NSString *)defaultTitleForCollectionConversation:(RCConversationType)conversationType;

/*!
 获取会话模型对应的未读数

 @param model 会话数据模型
 @return 未读消息数
 */
+ (int)getConversationUnreadCount:(RCConversationModel *)model;

/*!
 会话模型是否包含未读的@消息

 @param model 会话数据模型
 @return 是否包含未读的@消息
 */
+ (BOOL)getConversationUnreadMentionedStatus:(RCConversationModel *)model;

/*!
 同步会话多端阅读状态

 @param conversation 会话

 @discussion 会根据已经设置的RCIM的enabledReadReceiptConversationTypeList属性进行过滤、同步。
 */
+ (void)syncConversationReadStatusIfEnabled:(RCConversation *)conversation;

/*!
 获取汉字对应的拼音首字母

 @param hanZi 汉字

 @return 拼音首字母
 */
+ (NSString *)getPinYinUpperFirstLetters:(NSString *)hanZi;

/*!
 在SFSafariViewController或WebViewController中打开URL

 @param url             URL
 @param viewController  基于哪个页面弹出新的页面
 */
+ (void)openURLInSafariViewOrWebView:(NSString *)url base:(UIViewController *)viewController;

/**
 检查url是否以http或https开头，如果不是，为其头部追加http://

 @param url url

 @return 以http或者https开头的url
 */
+ (NSString *)checkOrAppendHttpForUrl:(NSString *)url;

/*!
 验证手机号
 */
+ (BOOL)validateCellPhoneNumber:(NSString *)cellNum;

/*!
 验证邮箱
 */
+ (BOOL)validateEmail:(NSString *)email;

/**
获取 keyWindow

@return UIWindow
*/
+ (UIWindow *)getKeyWindow;

/**
 获取 AppDelegate window 的 safeAreaInsets

 @return AppDelegate window 的 safeAreaInsets
 */
+ (UIEdgeInsets)getWindowSafeAreaInsets;

/**
 修正iOS系统图片的图片方向

 @param image 需要修正的图片
 @return 修正后的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)image;

/**
判断当前设备是否是 iPad
*/
+ (BOOL)currentDeviceIsIPad;

/**
在 controller 弹出弹窗

@param title title
@param message message
@param style 弹窗的风格
@param actions UIAlertAction 的数组
@param controller 用哪个页面弹出
*/
+ (void)showAlertController:(NSString *)title
                    message:(NSString *)message
             preferredStyle:(UIAlertControllerStyle)style
                    actions:(NSArray<UIAlertAction *> *)actions
           inViewController:(UIViewController *)controller;

/**
动态颜色设置

 @param lightColor  亮色
 @param darkColor  暗色
 @return 修正后的图片
*/
+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

/**
根据图片消息的 imageUrl 判断图片是否加载
*/
+ (BOOL)hasLoadedImage:(NSString *)imageUrl;

/**
根据图片消息的 imageUrl 获取已下载的图片 data

 @param imageUrl  图片消息的 imageUrl
 @return 图片 data
*/
+ (NSData *)getImageDataForURLString:(NSString *)imageUrl;

/**
 ks fix for rc update 计算文本所占时图大小，融云原有方法计算，如果有空格会计算不准确
 */
+ (CGSize)getTextDrawingSizeWithText:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

@end
