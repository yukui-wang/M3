//
//  CMPCommonManager.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/25.
//
//

#import <Foundation/Foundation.h>
#import <CMPLib/AFNetworkReachabilityManager.h>

@class CMPDBAppInfo;
@class AppDelegate;

#define kMacro_UserHeadIcon @"current_user_header"
#define kMacro_UserHeadIconBoarderWidth 1

@interface CMPCommonManager : NSObject

//获取AppDelegate
+ (AppDelegate *)appdelegate;
//获取AppDelegate Window
+ (UIWindow *)keyWindow;
//开始监听网络状态
+ (void)startMonitoringForNetwork;
//用户登录
+ (void)userLogin;
// 清空桌面图标的数字
+ (void)clearApplicationIconBadgeNumber;
// 更新应用图标的数字
+ (void)updateApplicationIconBadgeNumber;
//appdelegate添加通知
+ (void)addNotificationListener;
//注销键盘事件
+ (void)resignKeyBoardInView:(UIView *)view;
//获取启动页背景图
+ (UIImage *)getStartPageBackgroundImage;
//获取启动页横屏背景图
+ (UIImage *)getStartPageLandscapeBackgroundImage;
//获取启动页横屏背景图
+ (NSString *)getStartPageLandBackgroundPath;
//获取启动页logo
+ (UIImage *)getStartPageLogoImage;
//创建启动页文件夹
+ (void)createStartPageDirPath;
//获取启动页背景图路径
+ (NSString *)getStartPageBackgroundPath;
//获取启动页logo路径
+ (NSString *)getStartPageLogoPath;
//获取人员头像图片（new）（如果本地有就从本地拿，如果没有就从服务器拿）
+(void)getUserHeadImageComplete:(void(^)(UIImage *image))complete cache:(BOOL)aCache;
//更新头像信息
+ (void)updateMemberIconInfo;
//更新头像信息
+ (void)updateMemberIconInfoWithUserId:(NSString *)userId;
// 是否显示小致
+ (void)showRobot:(BOOL)aShow;
//是否可以打开离线消息
+ (BOOL)shouldOpenHandleRemoteMessageViewController;

/**
 初始化第三方分析模块
 Bugly、MTA
 */
+ (void)initAnalysisModule;

+ (void)removeCurrentUserFaceCache; // 删除当前人员头像缓存
+ (void)removeUserFaceCacheWithUserId:(NSString *)userId;
+ (NSString *)baiduPushKey; // 获取百度推送的key
+ (NSString *)lbsAPIKey; // 获取高德地图key
+ (NSString *)lbsGoogleAPIKey; //获取谷歌地图key
+ (NSString *)lbsWebAPIKey; // 获取高德地图web api key
+ (NSString *)pushMsgClientProtocolType; //获取离线消息推送那些，传给服务器端
+ (NSString *)checkCMPShellUpdateUrl:(NSString *)aUrl; // 获取检查客户端更新壳的url地址
+ (NSString *)prefixAppID; // 获取Prefix AppID
+ (NSString *)leboHpPlayAppID; //获取乐播投屏AppID
+ (NSString *)leboHpPlayAppKey; //获取乐播投屏AppKey

// 当前网络是否可用wifi、3G、4G
+ (BOOL)reachableNetwork;
// 当前网络状态
+ (NSInteger)networkReachabilityStatus;
// 是否可以连接服务器
+ (BOOL)reachableServer;
+ (void)updateReachableServer:(NSError *)aError;
// 获取设备网络类型
+ (NSString *)networkType;
// 获取网络状态
+ (NSDictionary *)networkStatusInfo;
// 是否是企业版本
+ (BOOL)isM3InHouse;
//上报mta用户账号
//+ (void)reportMtaWithAccount:(NSString *)aAccount;
//上报U-APP用户账号
+ (void)reportUAppWithAccount:(NSString *)aAccount;
//隐私协议url
+ (NSString *)privacyAgreementUrl;
+(void)outputAppStartLoadTimeCostWithDes:(NSString *)des;
+(BOOL)isSeeyonRobotByUid:(NSString *)uid;

@end
