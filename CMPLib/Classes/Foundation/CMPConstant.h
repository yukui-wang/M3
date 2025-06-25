//
//  CMPCore.h
//  CMPCore
//
//  Created by youlin guo on 14-10-31.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#ifndef CMPCore_CMPConstant_h
#define CMPCore_CMPConstant_h

#import "CMPAdditions.h"
#import "CMPFileConstant.h"
#import "M3Constant.h"
#import "CocoaLumberjack.h"

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

//////////////////////////////////////////////////////////////
//  颜色宏
//////////////////////////////////////////////////////////////
#pragma mark Color宏
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]
#define RGBA(r,g,b,a) (r)/255.0f, (g)/255.0f, (b)/255.0f, (a)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//////////////////////////////////////////////////////////////
//  图片宏
//////////////////////////////////////////////////////////////
#pragma mark UIImage宏
#define IMAGE(name) [UIImage imageNamed:(name)]

//////////////////////////////////////////////////////////////
//  字体宏
//////////////////////////////////////////////////////////////
#pragma mark UIFont宏
#define FONTSYS(size) ([UIFont systemFontOfSize:(size)])
#define FONTBOLDSYS(size) ([UIFont boldSystemFontOfSize:(size)])

#define FONT_NAVIGATION_TITLE FONTBOLDSYS(18)
#define FONT_TITLE FONTBOLDSYS(16)
#define FONT_TIME FONTSYS(10)
#define FONT_CONTENT FONTSYS(14)
#define FONT_QUOTE FONTSYS(13)
#define FONT_PROFILE FONTSYS(16)


//////////////////////////////////////////////////////////////
//  Release宏
//////////////////////////////////////////////////////////////
#pragma mark release宏
#define SY_RELEASE(__POINTER) { [__POINTER release]; }
#define SY_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define kPageListSize 20 // 每次获取列表的条数

////////////////////////////////////////////////////////////////
//  屏幕 宏
////////////////////////////////////////////////////////////////
#define MAINSCREENFRAME         CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height );
#define MAINSCREENFRAMEFORPAD   CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width )
#define CMP_SCREEN_BOUNDS       [UIScreen mainScreen].bounds
#define CMP_SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define CMP_SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define CMP_STATUSBAR_HEIGHT    (IS_IPHONE_X_Portrait ? [UIApplication sharedApplication].statusBarFrame.size.height : 20.f)
#define CMP_TABBAR_HEIGHT       (IS_IPHONE_X_Portrait ? (49.f+34.f) : 49.f)
#define CMP_SafeBottomMargin_height       (IS_IPHONE_X_LATER ? 34.f : 0.f)

////////////////////////////////////////////////////////////////
//  Animation 宏
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//  Debug 宏
////////////////////////////////////////////////////////////////
#pragma mark NSLog宏(Debug)
#define SY_NSLOG_FRAME(_FRAME)      {NSLog(@"x:%f,y:%f,width:%f,height:%f",_FRAME.origin.x,_FRAME.origin.y,_FRAME.size.width,_FRAME.size.height);}
#define SY_NSLOG_DFRAME(_NAME,_FRAME) {NSLog(@"%@:x:%f,y:%f,width:%f,height:%f",_NAME,_FRAME.origin.x,_FRAME.origin.y,_FRAME.size.width,_FRAME.size.height);}
#define SY_NSLOG_SIZE(_SIZE)        {NSLog(@"width:%f,height:%f",_SIZE.width,_SIZE.height);}
#define SY_NSLOG_DSIZE(_NAME,_SIZE) {NSLog(@"%@:width:%f,height:%f",_NAME,_SIZE.width,_SIZE.height);}
#define SY_NSLOG_DPOINT(_NAME,_POINT) {NSLog(@"%@:x:%f,y:%f",_NAME,_POINT.x,_POINT.y);}

#define CMPFuncLog CMPLog(@"%s",__func__);

/**  自定义log ***/
#ifdef DEBUG
#define CMPLog(fmt, ...) NSLog((@"[函数名:%s]\n""[行号:%d] \n" fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define CMPLog(...);
#endif


//  多版本控制宏
#define SY_STRING(key) \
NSLocalizedString(key, nil)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONE_6             ( [[UIScreen mainScreen ] bounds].size.height == 667 )
#define IS_IPHONE_6Plus         ( [[UIScreen mainScreen ] bounds].size.height == 736 )
#define IS_IPHONE_X_UNIVERSAL   ([[UIApplication sharedApplication] statusBarFrame].size.height > 20.f ? YES:NO)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define IS_IPHONE_X_LATER (IS_IOS_11 && IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))
#define IS_IPHONE_X_Portrait              ((IS_IPHONE_X_LATER && (CMP_SCREEN_WIDTH < CMP_SCREEN_HEIGHT)) ? YES : NO)
#define IS_IPHONE_X_Landscape             ((IS_IPHONE_X_LATER && (CMP_SCREEN_WIDTH > CMP_SCREEN_HEIGHT)) ? YES : NO)

#define IOS7_Later ([UIDevice currentDevice].systemVersion.floatValue >=7.0)
#define IOS8_Later ([UIDevice currentDevice].systemVersion.floatValue >=8.0)
#define IOS9_Later ([UIDevice currentDevice].systemVersion.floatValue >=9.0)
#define IOS6_Later ([UIDevice currentDevice].systemVersion.floatValue >=6.0)
#define IOS10_Later ([UIDevice currentDevice].systemVersion.floatValue >=10.0)
#define IOS11_Later ([UIDevice currentDevice].systemVersion.floatValue >=11.0)
#define IOS7       ([UIDevice currentDevice].systemVersion.floatValue >=7.0 && [UIDevice currentDevice].systemVersion.floatValue < 8.0)

#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define CMP_IPAD_MODE (INTERFACE_IS_PAD && [CMPCore sharedInstance].serverIsLaterV7_1_SP1)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//#define InterfaceOrientationIsPortrait UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
//#define InterfaceOrientationIsLandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

#define kDeviceOrientationVal (((NSNumber *)[[UIDevice currentDevice] valueForKey:@"orientation"]).intValue)

#define InterfaceOrientationIsPortrait (CMP_IPAD_MODE ? ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width) : (kDeviceOrientationVal == UIInterfaceOrientationPortrait || kDeviceOrientationVal == UIDeviceOrientationPortraitUpsideDown || kDeviceOrientationVal == UIDeviceOrientationUnknown))
#define InterfaceOrientationIsLandscape ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)


#define UserDefaults [NSUserDefaults standardUserDefaults]
#define TYPE_CHECK(var, type) (!var || ![var isKindOfClass:[type class]]) 
#define TYPE_CHECK_RETURN(var, type) if(!var || ![var isKindOfClass:[type class]]) { \
                                        NSLog((@"%s [Line %d] Type Unsafe!!!"), __PRETTY_FUNCTION__, __LINE__);\
                                        return;}
#define TYPE_CHECK_CONTINUE(var, type) if(!var || ![var isKindOfClass:[type class]]) { \
                                        NSLog((@"%s [Line %d] Type Unsafe!!!"), __PRETTY_FUNCTION__, __LINE__);\
                                        continue;}

#define kUploadAttachmentMaxSize   1024*1024*50 //附件最大上传50M

#define k_RunKingWPSNotificationName                                    @"RunWpsAppNotifi"
#define k_RunKingExcelNotificationName                                  @"RunWpsExcelAppNotifi"
#define k_RunKingPPtNotificationName                                    @"RunWpsPPTAppNotifi"
#define k_RunKingPdfNotificationName                                    @"RunWpsPDFAppNotifi"
#define k_FinishEditKingOfficeNotificationName                          @"finishEditOffice"

#define kNotificationName_UserLogin @"kNotificationName_UserLogin"
#define kNotificationName_UserLogout @"kNotificationName_UserLogout"
#define kNotificationName_UserWillLogout @"kNotificationName_UserWillLogout"//踢下线弹提示的时候

#define kNotificationName_SessionInvalid @"kNotificationName_SessionInvalid"
#define kNotificationName_GestureWillShow @"kNotificationName_GestureWillShow"
#define kNotificationName_GestureWillHiden @"kNotificationName_GestureWillHiden"
#define kNotificationName_GestureShowLoginView @"kNotificationName_GestureShowLoginView"//手势界面显示登录页

#define kNotificationName_ShowGuidePagesView @"kNotificationName_ShowGuidePagesView" // 显示引导页通知名字
#define kNotificationName_HideGuidePagesView @"kNotificationName_HideGuidePagesView" // 隐藏引导页通知名字
#define kNotificationName_DidRegisterNotifiDeviceToken @"kNotificationName_DidRegisterNotifiDeviceToken" // 完成离线消息注册
#define kNotificationName_ChangeIcon @"com.seeyon.m3.my.changeIcon" // 选择图片成功通知
#define kNotificationName_WebviewResignKeyboard @"kNotificationName_WebviewResignKeyboard"//网页关闭键盘

// 语音机器人设置
#define kNotificationName_RobotConfigValueChanged @"kNotificationName_RobotConfigValueChanged"
#define kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch @"kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch"

//二维码扫面
#define kNotificationName_BarcodeScannerWillShow @"kNotificationName_BarcodeScannerWillShow"
#define kNotificationName_BarcodeScannerWillHide @"kNotificationName_BarcodeScannerWillHide"

//录音
#define kNotificationName_AudioRecorderWillRecording @"kNotificationName_AudioRecorderWillRecording"
#define kNotificationName_AudioRecorderWillStop @"kNotificationName_AudioRecorderWillStop"

//播放语音
#define kNotificationName_AudioPlayerWillPlay @"kNotificationName_AudioPlayerWillPlay"
#define kNotificationName_AudioPlayerWillStop @"kNotificationName_AudioPlayerWillStop"

//新建联系人 人员保存到本地
#define kNotificationName_ABNewPersonViewWillShow @"kNotificationName_ABNewPersonViewWillShow"
#define kNotificationName_ABNewPersonViewWillHide @"kNotificationName_ABNewPersonViewWillHide"

//语音输入
#define kNotificationName_SpeechInputWillInput @"kNotificationName_SpeechInputWillInput"
#define kNotificationName_SpeechInputWillStop @"kNotificationName_SpeechInputWillStop"

//拍照相册 统一不好区分
#define kNotificationName_CameraWillShow @"kNotificationName_CameraWillShow"
#define kNotificationName_CameraWillHide @"kNotificationName_CameraWillHide"

//红包界面显示
#define kNotificationName_RedPacketWillShow @"kNotificationName_RedPacketWillShow"
#define kNotificationName_RedPacketWillHide @"kNotificationName_RedPacketWillHide"

//快捷方式
#define kNotificationName_QuickModuleWillShow @"kNotificationName_QuickModuleWillShow"
#define kNotificationName_QuickModuleWillHide @"kNotificationName_QuickModuleWillHide"

//第三方打开的alert
#define kNotificationName_ThirdAppMenuWillShow @"kNotificationName_ThirdAppMenuWillShow"
#define kNotificationName_ThirdAppMenuWillHide @"kNotificationName_ThirdAppMenuWillHide"
//alert show
#define kNotificationName_AlertWillShow @"kNotificationName_AlertWillShow"
#define kNotificationName_AlertWillHide @"kNotificationName_AlertWillHide"

//发短信界面
#define kNotificationName_SMSViewWillShow @"kNotificationName_SMSViewWillShow"
#define kNotificationName_SMSViewWillHide @"kNotificationName_SMSViewWillHide"

/*语音插件 开始：隐藏小致   结束：重新显示小致*/
#define kNotificationName_SpeechPluginOn @"kNotificationName_SpeechPluginOn"
#define kNotificationName_SpeechPluginOff @"kNotificationName_SpeechPluginOff"

#define kNotificationName_TabbarSelectedViewControllerChanged @"kNotificationName_TabbarSelectedViewControllerChanged"


/*融云需关闭小致，以修复 OA-161007（致信）开着小致的时候致信语音发不出去，一直提示时间过短*/
#define kNotificationName_RCChatWillShow @"kNotificationName_RCChatWillShow"
#define kNotificationName_RCChatWillHide @"kNotificationName_RCChatWillHide"

// 融云通知
#define kNotificationName_ClearRCGroupMsg @"kNotificationName_ClearRCGroupMsg" // 清除融云群消息
#define kNotificationName_ChangeGroupName @"kNotificationName_ChangeGroupName" // 群名更新通知
#define kNotificationName_AcceptInformationChange @"kNotificationName_AcceptInformationChange" // 新消息开关
#define kNotificationName_PermissionForZhixinChange @"kNotificationName_PermissionForZhixinChange"//致信权限
#define kNotificationName_MessageUpdate @"kNotificationName_MessageUpdate" // 消息刷新

#define kNotificationName_NetworkAvailable @"NotificationName_NetworkAvailable"
#define kNotificationName_NetworkNotAvalable @"NotificationName_NetworkNotAvalable"
#define kNotificationName_NetworkStatusChange @"CMPNetworkStatusChange"
#define kNotificationName_AppsDownload @"kNotificationName_AppsDownload"

#define kRongCloudReceiveMessage  @"kRongCloudReceiveMessage"

#define kNotificationName_ApplicationDidEnterBackground @"notificationName_ApplicationDidEnterBackground"
#define kNotificationName_ApplicationWillEnterForeground @"notificationName_ApplicationWillEnterForeground"
#define kNotificationName_ApplicationWillResignActive @"notificationName_ApplicationWillResignActive"
#define kNotificationName_ApplicationDidBecomeActive @"notificationName_ApplicationDidBecomeActive"

//tabbar 显示了，通知消息去设置消息tabbar红点
#define kNotificationName_TabbarViewControllerDidAppear @"kNotificationName_TabbarViewControllerDidAppear"
// 消息模块数据库变更，需要刷新UI
#define kNotificationName_DBMessageDidUpdate @"kNotificationName_DBMessageDidUpdate"

/** ConfigInfo更新成功通知 **/
#define kNotificationName_ConfigInfoDidUpdate @"kNotificationName_ConfigInfoDidUpdate"
/** AppList更新成功通知 **/
#define kNotificationName_AppListDidUpdate @"kNotificationName_AppListDidUpdate"
/** 人员信息更新成功 **/
#define kNotificationName_UserInfoDidUpdate @"kNotificationName_UserInfoDidUpdate"
//底导航子视图 界面显示了。目前仅智能消息用到了
#define kNotificationName_TabbarChildViewControllerDidAppear @"kNotificationName_TabbarChildViewControllerDidAppear"
/** 重设WPS服务 **/
#define kNotificationName_ResetKWOfficeService @"kNotificationName_ResetKWOfficeService"

////////////////////////////////////////////////////////////////
//  NSUserDefault Keys
////////////////////////////////////////////////////////////////

/** 升级标志位。V7.1版本token加密，处理低版本升级上来token没有加密问题，将所有token清空 **/
#define kUserDefaultName_TokenEncryptFlag @"kUserDefaultName_TokenEncryptFlag"

/** 展示新版本操作引导标志位 首次进入m3出现该提示**/
#define kUserDefaultName_showNewVersionTipFlag [NSString stringWithFormat:@"kUserDefaultName_showNewVersionTipFlag_%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,[CMPCore sharedInstance].currentUser.accountID]
#define kUserDefaultName_showNewVersionTipFlag_M3VersionKey @"kUserDefaultName_showNewVersionTipFlag_M3VersionKey"

/** 展示提示用户打开推送开关标志位  未打开推送开关每天出现一次该提示**/
#define kUserDefaultName_showNotOpenUserNotificationTipFlag [NSString stringWithFormat:@"kUserDefaultName_showNotOpenUserNotificationTipFlag%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,[CMPCore sharedInstance].currentUser.accountID]

/** 升级标志位 V7.1版本数据库加密加密，处理低版本升级上来数据库没有加密问题 **/
#define kUserDefaultName_DatabaseEncryptFlag @"kUserDefaultName_DatabaseEncryptFlag"

/** 是否同意过隐私协议标志位 **/
#define kUserDefaultName_SinglePopUpPrivacyProtocolPageFlag @"kUserDefaultName_SinglePopUpPrivacyProtocolPageFlag"

/** splitViewController 堆栈变更，横竖屏切换，第一次点击该页签时会触发，收到通知时view的frame是最新的 **/
#define kNotificationName_CMPSplitViewControllerDidUpdateStack @"kNotificationName_CMPSplitViewControllerDidUpdateStack"

/** 在线设备变更 **/
#define kNotificationName_OnlineDevDidChange @"kNotificationName_OnlineDevDidChange"

/** 消息气泡开始拖动 **/
#define kNotificationName_MessageCellDragBegan @"kNotificationName_MessageCellDragBegan"
/** 消息气泡结束拖动 **/
#define kNotificationName_MessageCellDragEnd @"kNotificationName_MessageCellDragEnd"

/** 升级标志位 V7.1_SP1版本数据库老用户标记为已经弹出过隐私协议框 **/
#define kUserDefaultName_DatabaseOldAccountAlreadyPopuUppPrivacypPage @"kUserDefaultName_DatabaseOldAccountAlreadyPopuUppPrivacypPage"

/** 音视频服务到期标志位 存储当天提示服务到期日期 **/
#define kUserDefaultName_RemindVideoExpireDay @"kUserDefaultName_RemindVideoExpireDay"

/* *******************************手机盾相关*********************************** */
// 手机盾相关通知
#define kNotificationName_MokeyLoginSuccess @"kNotificationName_MokeyLoginSuccess"
#define kNotificationName_MokeySDKNotification @"kNotificationName_MokeySDKNotification"
#define kNotificationName_MokeyGetUseState @"kNotificationName_MokeyGetUseState"

#define kNotificationMessage_MokeyAutoLogin @"kNotificationMessage_MokeyAutoLogin"
/* *******************************手机盾相关*********************************** */


//小致界面打开与关闭
#define kNotificationName_XiaozViewShow @"kNotificationName_XiaozViewShow"
#define kNotificationName_XiaozViewHide @"kNotificationName_XiaozViewHide"

#define kViewTag_XiaozIcon 123450

#define kRCUserId_AtAll @"userid_atall"
#define kUserId_ZXRobot @"2580014621208301249"
#define kAccountId_Seeyon @"670869647114347"

#endif
