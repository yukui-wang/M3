//
//  M3LoginManager.h
//  M3
//
//  Created by youlin on 2017/11/24.
//

#import <CMPLib/CMPObject.h>

typedef void(^RequestAppListAndConfigSuccessBlock)(NSString *applist, NSString *config, NSString *configH5Cache);
typedef void(^CMPTokenLoginSuccess)(void);
typedef void(^CMPTokenLoginFail)(NSError *error);

@class CMPPartTimeHelper;
@class CMPLocalAuthenticationState;
@class CMPServerModel;

typedef enum : NSUInteger {
    CMPM3LoginTypeAccount = 0,//账号密码0
    CMPM3LoginTypePhone,//手机1
    CMPM3LoginTypeSMS//短信验证码2
} CMPM3LoginType;

@interface M3LoginManager : CMPObject

@property (nonatomic,copy) NSString *areaCode;
@property (nonatomic, retain) CMPLoginAccountModel *currentAccount; // 当前登录账号
/** 是否是离线登录 **/
@property (assign, nonatomic) BOOL offlineLogin;
/** 兼职单位管理 **/
@property (nonatomic, readonly)CMPPartTimeHelper *partTimeHelper;
@property (strong, nonatomic) CMPLocalAuthenticationState *localAuthenticationState;
@property (nonatomic,copy) void(^ _Nullable loginProcessBlk)(NSInteger step,NSError *error, _Nullable id ext);

+ (M3LoginManager *)sharedInstance;
+ (void)clearSharedInstance;

- (void)requestLoginWithUserName:(NSString *)aUserName
                        password:(NSString *)aPassword
                       encrypted:(BOOL)aEncrypted
                    refreshToken:(BOOL)refreshToken
                verificationCode:(NSString *)verificationCode
                            type:(CMPLoginAccountModelLoginType)type
                    externParams:(NSDictionary *)externParams
                           start:(void(^)(void))start
                         success:(void(^)(void))success
                            fail:(void(^)(NSError *error))fail;

// 手机盾新增：调用方法 增加一个accToken属性
// 账号密码0，手机号登录1，短信验证码登录2
//smsCode 短信验证码
- (void)requestLoginWithUserName:(NSString *)aUserName
                        password:(NSString *)aPassword
                       encrypted:(BOOL)aEncrypted
                    refreshToken:(BOOL)refreshToken
                verificationCode:(NSString *)verificationCode
                            type:(CMPLoginAccountModelLoginType)type
                       loginType:(NSString *)loginType
                         smsCode:(NSString *)smsCode
                    externParams:(NSDictionary *)externParams
                 isFromAutoLogin:(BOOL)isFromAutoLogin
                           start:(void(^)(void))start
                         success:(void(^)(void))success
                            fail:(void(^)(NSError *error))fail;


- (void)requestMokeyLoginWithUserName:(NSString *)aUserName
                             password:(NSString *)aPassword
                            encrypted:(BOOL)aEncrypted
                         refreshToken:(BOOL)refreshToken
                     verificationCode:(NSString *)verificationCode
                                 type:(CMPLoginAccountModelLoginType)type
                             accToken:(NSString *)accToken
                                start:(void(^)(void))start
                              success:(void(^)(void))success
                                 fail:(void(^)(NSError *error))fail;


- (BOOL)isAutoLogin; // 是否自动登录
- (BOOL)isLogin; //是否已登录
- (void)autoRequestLogin:(void(^)(void))start success:(void(^)(void))success fail:(void(^)(NSError *error))fail ext:(__nullable id)extParams;// 自动登录
- (BOOL)needSetGesturePassword; // 是否需要设置手势密码
- (BOOL)hasSetGesturePassword; // 是否设置了手势密码
- (BOOL)needDeviceBind:(NSError *)error; // 是否需要硬件绑定
- (BOOL)isVerificationError:(NSError *)error; // 是否是验证码错误
- (NSString *)verificationCodeUrl:(NSError *)error; // 是否需要输入登录验证码
- (void)showBindTipAlert;
- (void)showBindTipAlertWithUserName:(NSString *)userName
                               phone:(NSString *)phone
                           serverUrl:(NSString *)serverUrl
                       serverVersion:(NSString *)serverVersion
                   serverContextPath:(NSString *)contextPath;
- (void)savePrivilege;
- (void)setupOther;

/**
 注销账户，主要是注销离线消息推送
 */
- (void)requestLogout;

/**
 退出登录，清理cookie、清理token、清理jsessionId，停止应用包下载，取消所有请求
 */
- (void)logout;

/**
 跳转到登录页
 
 @param message 需要提示的弹窗的文字内容
 */
- (void)showLoginViewControllerWithMessage:(NSString *)message;

/**
 跳转到登录页
 
 @param message 需要提示的弹窗的文字内容
 @param error 错误信息
 */
- (void)showLoginViewControllerWithMessage:(NSString *)message error:(NSError *)error;

/**
 跳转到登录页
 
 @param message 需要提示的弹窗的文字内容
 @param error 错误信息
 @param username 用户名
 @param password 密码
 */
- (void)showLoginViewControllerWithMessage:(NSString *)message
                                     error:(NSError *)error
                                  username:(NSString *)username
                                  password:(NSString *)password;

- (void)requestAppListAndConfigSuccess:(RequestAppListAndConfigSuccessBlock)success fail:(void(^)(NSError *error))fail;

/**
 通过手机号获取保存的密码，密文
 */
- (NSString *)passwordWithPhone:(NSString *)phone;

/**
 保存登录过的手机号，明文
 */
+ (void)saveHistoryPhone:(NSString *)phone;

/**
 获取上次登录的手机号，明文
 */
+ (NSString *)historyPhone;

/**
 清空手机号登录记录
 */
+ (void)clearHistoryPhone;

#pragma mark-
#pragma mark token登录

- (void)loginWithTokenStart:(void(^)(void))start success:(CMPTokenLoginSuccess)success
                       fail:(CMPTokenLoginFail)fail ext:(__nullable id)extParams;

/**
 手动将token置为过期
 */
- (void)setTokenExpire;

/**
 获取Applist、ConfigInfo更新状态
 
 @return @{@"appList": @YES,@"configInfo": @YES,@"userInfo": @YES}
 */
- (NSDictionary *)appAndConfigSyncStatus;

/**
 重试从服务端获取AppList、ConfigInfo、userInfo
 如果都成功就不用重试
 doneBlock 成功回调 @{@"appList": @YES,@"configInfo": @YES,@"userInfo": @YES}
 */
- (void)retryAppAndConfig:(void (^)(NSDictionary *dic))doneBlock;

/**
 刷新AppList
 
 @param doneBlock 成功回调
 */
- (void)refreshAppList:(void (^)(BOOL success))doneBlock;

/**
 更新兼职单位
 */
- (void)refreshPartTime;

/**
 重置Applist、ConfigInfo、userInfo更新状态
 */
- (void)clearRetryAppAndConfig;

/// 跳转到登录vc  从editVC跳转
/// @param vc vc
+ (void)jumpToLoginVCWithVC:(UIViewController *)vc;

/// 跳转到登录vc  从server list vc跳转
/// @param vc vc
+ (void)jumpToLoginVCWithVC:(UIViewController *)vc selectedModel:(CMPServerModel *)selectedModel;
+ (UIViewController *)loginViewController;
+ (BOOL)isLoginViewController:(UIViewController *)controller;

#pragma mark-
#pragma mark 手机盾模块判断是否使用弱手势和密码的提示
- (BOOL)mokey_login_relevantShow;

///
///校验服务器用户密码
-(void)verifyRemotePwd:(NSString *)pwd result:(void(^_Nonnull)(id respObj, NSError *err, _Nullable id ext))result;

- (void)clearCurrentUserLoginPassword;

@end
