//
//  CMPCore.h
//  CMPCore
//
//  Created by youlin guo on 14-10-28.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#define kLanguageType_En  1//英语及其它语言
#define kLanguageType_Zh_TW  2//繁体中文
#define kLanguageType_Zh_C  3//中文简体

#define kLanguageCode_En  @"en"//英语
#define kLanguageCode_Zh_TW  @"zh-TW"//繁体中文
#define kLanguageCode_Zh_C  @"zh-CN"//中文简体

#import <Foundation/Foundation.h>
#import "CMPConstant.h"
#import "JSON.h"
#import "YYModel.h"
#import "CMPLoginAccountModel.h"
#import "CMPServerModel.h"
#import <CMPLib/CMPFeatureSupportControlHeader.h>

#define kCMP_ServerID ([CMPCore sharedInstance].serverIdentifier)
#define kCMP_OwnerID @"cmp"
#define kServerInfo_M3 @"kServerInfo_M3"
#define CMP_SERVER_URL ([CMPCore sharedInstance].serverurl)
#define CMP_SERVER_VERSION ([CMPCore sharedInstance].serverVersion)
#define CMP_USERID ([CMPCore sharedInstance].userID)
#define KURLPath_Seeyon  @"/seeyon"

///投屏按钮是否显示改变通知
UIKIT_EXTERN NSString * const CMPCoreScreenMirroringIsOpenChangedNoti;

@class CMPLoginDBProvider;
@class CMPFontModel;
@class CMPH5ConfigModel;
@class CMPV5ProductEditionModel;

@interface CMPCore : NSObject

@property (nonatomic,strong) CMPLoginAccountModel *currentUser; // 当前用户信息
@property (nonatomic,strong) CMPServerModel *currentServer; // 当前服务器信息
@property (nonatomic,readonly) CMPFontModel *currentFont; // 当前字体信息
@property (nonatomic,readonly) CMPLoginDBProvider *loginDBProvider;
@property (nonatomic,strong,readonly) CMPH5ConfigModel *h5Config; //H5配置信息，存放在CMP包，http://cmp/v1.0.0/cmp-native-config.json

@property (nonatomic,copy,readonly)NSString *serverID; // 服务器唯一标识
@property (nonatomic,copy,readonly)NSString *userID; // 用户唯一标识
@property (nonatomic,copy,readonly)NSString *userName; // 用户名
@property (nonatomic,copy)NSString *accShortName; //单位简称
@property (nonatomic,copy,readonly)NSString *serverVersion;//当前服务器版本号

@property (nonatomic,strong)NSString *serverurl; //服务器地址 类似于http://172.20.2.20:80
@property (nonatomic,strong)NSString *serverurlForSeeyon; //服务器地,类似于http://172.20.2.20:80/seeyon
@property (nonatomic,copy)NSString *serverurlForMobilePortal; //服务器地址,一定带有mobile_portal
@property (nonatomic,copy,readonly)NSString *checkUpdateUrl; //服务器地址 类似于http://m3.seeyon.com
@property (nonatomic,strong)NSDictionary *remoteNotifiData; // 离线消息数据
@property (nonatomic,strong)NSDictionary *openDesktopAppData; // 来自打开桌面应用的的数据

@property (nonatomic,copy)NSString *pushConfig; // 推送设置
@property (nonatomic,assign)BOOL pushSoundRemind; // 消息推送声音提醒
@property (nonatomic,assign)BOOL pushVibrationRemind; // 消息推送震动提醒
@property (nonatomic,assign)BOOL pushAcceptInformation; // 新消息开关
@property (nonatomic,assign)BOOL inPushPeriod; // 是否在接收消息提醒时间段
@property (nonatomic,copy) NSString *ucConfig; // 致信设置

@property (nonatomic,copy)NSString *startReceiveTime; // 提醒时间段（开始提醒时间）
@property (nonatomic,copy)NSString *endReceiveTime; // 提醒时间段（结束提醒时间）

@property (nonatomic,copy)NSString *jsessionId;
@property (nonatomic,copy)NSString *token; // 登录token

@property (nonatomic,copy)NSString *customStartPageSetting; // 设置自定义启动页信息
@property (nonatomic,copy)NSString *contentTicket; // 集群
@property (nonatomic,copy)NSString *contentExtension; // 集群
@property (nonatomic,assign)NSInteger applicationIconBadgeNumber; // 桌面应用图标数字
@property (nonatomic,strong)NSDictionary *baiduRemoteNotifiInfo; // 百度注册消息推送信息
@property (nonatomic,copy)NSString *remoteNotifiToken; // 推送token
@property (nonatomic,assign)BOOL isAlertOnShowSessionInvalid;

@property (nonatomic,copy)NSString *messageIdentifier;//v5消息请求参数
//弱口令
@property (nonatomic,assign) BOOL passwordOvertime;//密码是否超期了
@property (nonatomic,assign) BOOL passwordNotStrong;//密码强度
@property (nonatomic,assign)BOOL passwordChangeForce;// 强制修改密码
@property (nonatomic,assign) BOOL hasMyInTabBar;// 底部菜单是否My模块，如果有My模块需要屏蔽原生左上角人员头像
@property (nonatomic,assign) BOOL hasPermissionForZhixin;//是否有致信权限，已显示通讯录的”我的群组“
@property (nonatomic,assign) BOOL isZhixinServerAvailable;//致信服务是否可用
@property (nonatomic,copy) NSString *memberIconTime;  // 头像时间戳
@property (nonatomic,assign) BOOL allowRotation; // 设备横竖屏总开关，6.1sp2从application.zip的m3TabConfig.json里面的参数控制allowRotation；
/** V7.1新增字段，滑动返回手势开关 **/
@property (nonatomic,assign) BOOL allowPopGesture;
/** V7.1新增字段，区分产品线 **/
@property (nonatomic,strong) CMPV5ProductEditionModel *V5ProductEdition; // v5产品信息
/** V7.1新增字段，强制绑定设备**/
@property (nonatomic,assign)BOOL  devBindingForce;
/** V7.1新增字段，可用的语言列表**/
@property (nonatomic,strong)NSArray *availableLanguageList;
/** V7.1新增字段，服务器语言是否支持所选语言**/
@property (nonatomic,assign)BOOL isSupportCurrentLanguage;
/* 服务器关联的语言region */
@property (nonatomic,copy) NSString *languageRegion;
/** V7.1 SP1新增字段，用于pdf格式转换**/
@property (nonatomic,copy)NSString * csrfToken;
/** V7.1 SP1新增字段，打印开关**/
@property (nonatomic,assign)BOOL printIsOpen;
/** 是否多端在线 **/
@property (nonatomic,assign)BOOL isMultiOnline;
/** 是否致信端在线  只代表当前30秒在线**/
@property (nonatomic,assign)BOOL isUcOnline;
/** 多端登录静音开关是否接收消息,默认为No,不接收消息 **/
@property (nonatomic,assign)BOOL multiLoginReceivesMessageState;

/* 是否有外部分享过来的文件存储在本地 */
@property (assign,nonatomic) BOOL hasSavedFileFromOtherApps;

@property (nonatomic,copy) NSString *anewSessionAfterLogin;
@property(nonatomic,strong) NSDate *loginSuccessTime;

@property (nonatomic,assign) BOOL needHandleUrlScheme;
@property (nonatomic,copy) NSString *localstorageTag;

//是否第一次就显示验证码
@property (nonatomic,assign)BOOL firstShowValidateCode;//默认为NO

@property (nonatomic,assign) BOOL showingTopScreen;//是否正在展示负一屏
@property (nonatomic,assign) BOOL topScreenBeginShow;//开始展示负一屏（解决 红色网络问题提示栏 闪一下的问题）

@property (assign, nonatomic) BOOL hasUcMsgServerDel;//YES为支持删除远程致信消息
// 初始化
- (void)setup;

- (void)updateMemberIconTime;

+ (CMPCore *)sharedInstance;

- (CMPLoginAccountModel *)currentUserFromDB;

- (NSString *)serverIdentifier;
//人员头像
+ (NSString *)memberIconUrlWithId:(NSString *)aId;
//融云群头像
+ (NSString *)rcGroupIconUrlWithGroupId:(NSString *)groupId;

// 当前客户端版本
+ (NSString *)clinetVersion;
+ (NSString *)clinetBuildVersion;
+ (NSString *)appDownloadUrlPwd;

// 获取原H5登录设置的服务器版本号
+ (NSString *)oldServerVersion;

//语言环境
+ (NSInteger)languageType;
//语言设置的地区码en,zh_TW,zh_CN
+ (NSString *)languageCode;
//是否是中文语言环境 简体、繁体
+ (BOOL)language_ZhCN;
// 是否是登陆状态
+ (BOOL)isLoginState;
//生成一个带mobile_portal的url地址
+ (NSString *)serverContextPath;
+ (NSString *)serverurlWithUrl:(NSString *)url;
+ (NSString *)serverurlWithUrl:(NSString *)url serverVersion:(NSString *)serverVersion;
+ (NSString *)serverurlForSeeyonWithUrl:(NSString *)url;
+ (NSString *)serverurlForMobilePortalWithUrl:(NSString *)url;
//+ (NSString *)urlPathMapForPath:(NSString *)path;
//+ (NSString *)urlPathMapForPath:(NSString *)path serverVersion:(NSString *)serverVersion;
+ (NSString *)fullUrlPathMapForPath:(NSString *)path;

+ (NSString *)fullUrlForPath:(NSString *)path;
+ (NSString *)fullUrlForPathFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

- (BOOL)serverIsLaterV1_8_0;

/**
 判断服务器是否是7.0SP1及以后版本
 */
- (BOOL)serverIsLaterV7_0_SP1;

/**
 判断服务器是否是1130移动专版及以后版本
 */
- (BOOL)serverIsLaterV2_5_0;

/**
 判断服务器是否是V7.1及以后版本
 */
- (BOOL)serverIsLaterV7_1;

/**
 判断服务器是否是V7.1 SP1及以后版本
 */
- (BOOL)serverIsLaterV7_1_SP1;

/**
判断服务器是否是V8.0及以后版本
*/
- (BOOL)serverIsLaterV8_0;

/**
 是否支持多语言切换
 */
- (BOOL)isSupportSwitchLanguage;

/**
 隐私协议是否以弹出的方式展现
 */
- (BOOL)isByPopUpPrivacyProtocolPage;

//标记当前用户已弹出过隐私协议
- (void)tagCurrentUserPopUpPrivacyProtocolPage;

- (void)databaseDidUpgradeToEncrypt;

/**
 是否显示手机号快捷登录
 */
- (BOOL)isShowPhoneLogin;
/* 是否允许显示无线投屏按钮 */
@property (assign, nonatomic) BOOL screenMirrorIsOpen;
/* 是否开启sms手机验证码登录 */
@property (assign, nonatomic) BOOL canUseSMS;
/* 是否开启截屏控制 */
/* -1表示不支持截屏控制，0表示不允许截屏，1表示允许截屏屏，*/
@property (assign, nonatomic) NSInteger screenshotType;

-(void)updateUiskin:(NSDictionary *)uiskin;
+(void)configLocalUiskin;

@end
