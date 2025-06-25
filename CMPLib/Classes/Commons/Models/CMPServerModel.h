//
//  CMPServerModel.h
//  M3
//
//  Created by CRMO on 2017/11/1.
//

#import <Foundation/Foundation.h>

#define CMPHttpPrefix  @"http" // http前缀
#define CMPHttpsPrefix  @"https" // https前缀

@class CMPServerExtradDataModel;

@interface CMPServerModel : NSObject

/** 唯一的ID **/
@property (nonatomic, strong) NSString *uniqueID;
/** 服务器ID **/
@property (nonatomic, strong) NSString *serverID;
/** 服务器地址 **/
@property (nonatomic, strong) NSString *host;
/** 端口 **/
@property (nonatomic, strong) NSString *port;
/** 模式：HTTP/HTTPS **/
@property (nonatomic, assign) BOOL isSafe;
/** HTTP/HTTPS **/
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *fullUrl;
/** 备注 **/
@property (nonatomic, strong) NSString *note;
/** 正在使用 **/
@property (nonatomic, assign) BOOL inUsed;
/** 服务器版本号 **/
@property (nonatomic, strong) NSString *serverVersion;
/** 服务器版本号,用于版本号比较 **/
@property (assign, nonatomic) NSUInteger serverVersionNumber;
/** 更新服务器信息 **/
@property (nonatomic, strong) NSString *updateServer;

@property (strong, nonatomic) NSString *extend1; // "1"-属于关联服务器 "2"-通过云联添加
@property (strong, nonatomic) NSString *extend2; // 是否支持横竖屏
@property (strong, nonatomic) NSString *extend3; // 云联ID
@property (strong, nonatomic) NSString *extend4; // getAppList缓存
@property (strong, nonatomic) NSString *extend5; //path  多租户port后面那一截 如“/seeyon”
@property (strong, nonatomic) NSString *extend6; //orgCode 多租户组织码
@property (strong, nonatomic) NSString *extend7;
@property (strong, nonatomic) NSString *extend8;
@property (strong, nonatomic) NSString *extend9;
@property (strong, nonatomic) NSString *extend10; //储存附加信息

//储存在extend10中
@property (strong, nonatomic) CMPServerExtradDataModel *extradDataModel;

- (instancetype)initWithHost:(NSString *)host
                        port:(NSString *)port
                      isSafe:(BOOL)isSafe
                      scheme:(NSString *)aScheme
                        note:(NSString *)note
                      inUsed:(BOOL)inUsed
                    serverID:(NSString *)serverID
               serverVersion:(NSString *)aServerVersion
                updateServer:(NSString *)aUpdateServer;

- (BOOL)isEqualWithHost:(NSString *)host
                   port:(NSString *)port
                 isSafe:(BOOL)isSafe;

/**
 是否是关联账号的主账号
 根据server model 的extend1判断，
 extend1为1说明服务器是关联添加，不是主账号；extend1为0或者nil说明服务器是手动添加，是主账号
 
 @return 是否是关联主账号
 */
- (BOOL)isMainAssAccount;

/**
 是否是通过云联中心添加
 */
- (BOOL)isCloudServer;
/**
多租户参数设置：orgCode —组织码（extend6） path —多租户port后面那一截 如“/seeyon”（extend5）
*/
- (void)setupOrgCode:(NSString *)orgCode path:(NSString *)path;
/**
多租户组织码
*/
- (NSString *)orgCode;
- (NSString *)contextPath;
/*服务器信息到H5缓存Local Storage*/
- (NSDictionary *)h5CacheDic;
@end

@interface CMPServerExtradDataModel : NSObject

/** 隐私协议是否采用弹出的方式**/
@property (nonatomic,assign)BOOL isByPopUpPrivacyProtocolPage;

/** 可用的语言列表**/
@property (nonatomic,strong)NSArray *availableLanguageList;
/* 语言region */
@property (copy, nonatomic) NSString *languageRegion;
/* 是否显示手机号快捷登录 */
@property (copy, nonatomic) NSString *isShowPhoneLogin;
/* 是否允许显示无线投屏按钮 */
@property (assign, nonatomic) BOOL screenMirrorIsOpen;
/* 是否开启sms手机验证码登录 */
@property (assign, nonatomic) BOOL canUseSMS;
/* 是否开启截屏控制 */
/* -1表示不支持截屏控制，0表示不允许截屏，1表示允许截屏屏，*/
@property (assign, nonatomic) NSInteger screenshotType;
/* 致信服务是否可用 */
@property (assign, nonatomic) BOOL isZhixinServerAvailable;
/** 换肤信息**/
@property (nonatomic,strong)NSDictionary *uiSkin;


@end

@interface CMPServerVpnModel : NSObject

@property (nonatomic, copy) NSString *serverID;
@property (nonatomic, copy) NSString *vpnUrl;
@property (nonatomic, copy) NSString *vpnLoginName;
@property (nonatomic, copy) NSString *vpnLoginPwd;
@property (nonatomic, copy) NSString *vpnSPA;

@end
