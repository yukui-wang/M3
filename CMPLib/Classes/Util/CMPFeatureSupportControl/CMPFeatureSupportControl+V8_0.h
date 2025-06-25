//
//  CMPFeatureSupportControl+V8_0.h
//  CMPLib
//
//  Created by 程昆 on 2020/3/4.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <CMPLib/CMPFeatureSupportControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPFeatureSupportControl (V8_0)

/// V8.0以后的URL路径中不包含 mobile_portal
/// @param version 服务器版本号
+ (BOOL)isUrlPathContainsMobilePortal:(NSString *)version;

/// V8.0以后的URL路径使用映射的新路径
/// @param version 服务器版本号
+ (BOOL)isUrlPathUseNewPath:(NSString *)version;

/// V8.0以后的融云聊天页长按菜单有多选选项,V8.0以前无
+ (BOOL)isChatViewLongTouchMenuContainsMultiSelect;

/// V8.0以后的融云聊天页新增群看板功能,V8.0以前无
+ (BOOL)isChatViewSupportGroupKanban;

/// V8.0以后的融云聊天页PluginBoard新增关联文档,人员名片,新建协同等选项,V8.0以前无
+ (BOOL)isChatViewPluginBoardSupportLightCollItems;

/// 1. V8.0以后的融云聊天页发送文件使用CMPMyFilesViewController发送,
/// 2. V8.0以前使用 SyLocalOfflineFilesListViewController 发送
+ (BOOL)isChatViewUseMyFilesOpenOfflineFiles;

/// V8.0以后的融云聊天页新增的新建协同等入口需检查是否有该权限,无权限的需要移除该新建入口
+ (BOOL)isChatViewCheckQuickNewEntryPrivilege;

/// V8.0以后通讯录下载参数拼接方式为路径拼接,V8.0以前为参数拼接方式
+ (BOOL)isOfflineDownloadRequestParamAppendByPath;

/// V8.0以后领导消息,跟踪消息等消息列表图标不再使用本地图标
+ (BOOL)isMessagListLeadershipIconEtcUseSeverImage;

/// V8.0以后点击应用聚合消息时未读数不再清零
+ (BOOL)isTapAppMessageUnreadCountResetZero;

/// V8.0以后当请求响应错误码为401,且业务错误码为1010,需自动登录
/// @param errorCode 请求响应错误码
/// @param serverErrorCode 业务错误码
+ (BOOL)isNeedHandleSessionInvalidWithErrorCode:(NSInteger )errorCode serverErrorCode:(NSInteger) serverErrorCode;

/// V8.0以后或者未设置服务器的状态导航栏返回等图标的颜色使用main-fc
+ (BOOL)isIconColorUseMainFc;

// V8.0版本，支持图片、web图片长按草
+ (BOOL)isSupportImageLongPress;
// 查看文件是否自动保存
+ (BOOL)isAutoSaveFile;
// 是否支持文件分享按钮
+ (BOOL)isShowFileShareButton;
// 是否支持文件收藏
+ (BOOL)isSupportCollect;

//V8.0以后图片浏览长按应该不需要显示原图
+ (BOOL)imageBrowserShowOriginImg;

//V8.0以后图片浏览长按应该不需要显示打印
+ (BOOL)isImageBrowserShowPrintPhoto;

//是否支持打印
+ (BOOL)isSupportPrint;

/// V8.0通讯录搜索返回字段发生变化,需要map解析
+ (BOOL)isNeedMapSearchMemberResponse;

//登陆是否区分设备
+ (BOOL)isLoginDistinguishDevice:(NSString *)version;
// 是否使用新的登录界面，V8.0版本
+ (BOOL)isUseNewLoginViewController;
//顶部导航栏工作台icon
+ (NSString *)bannerAppIcon;
//顶部导航栏一级页面高度
+ (CGFloat)bannerHeight;
//快捷菜单plist文件
+ (NSString *)quickModulePlistName;
//快捷菜单顶部显示列表
+ (NSArray *)quickModuleTopList;
//无限投屏在快捷菜单中的名字
+ (NSString *)quickMirrorStr;

//v8.0后导航栏返回按钮不显示文字
+ (BOOL)isBannarBackButtonShowText;

//v8.0后导航栏关闭按钮按钮不显示文字,显示图标
+ (BOOL)isBannarCloseButtonShowText;

//V8.0后底部导航不显示待办红点
+ (BOOL)isShowPendingAndMessage;

//V8.0转任务页参数SourceType为100,之前为61
+ (NSString *)paramSourceTypeForCovertMission;
//是否支持手势返回
+ (BOOL)allowPopGesture;

//V8.0以后APPID intelligent 消息穿透为智能问答
+ (BOOL)isShoweIntelligentQA;

//v8.0以后显示 图片/视频页面
+ (BOOL)isShowCheckAllPicsBtn;

@end

NS_ASSUME_NONNULL_END
