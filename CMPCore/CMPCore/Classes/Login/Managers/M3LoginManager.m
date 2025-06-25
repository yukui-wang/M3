//
//  M3LoginManager.m
//  M3
//
//  Created by youlin on 2017/11/24.
//

#import "M3LoginManager.h"
#import <CMPLib/CMPAppListModel.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPLoginUpdateManager.h"
#import "CMPMigrateWebDataViewController.h"
#import "CMPPrivilege.h"
#import "CMPPrivilegeManager.h"
#import "AppDelegate.h"
#import "CMPBackgroundRequestsManager.h"
#import "CMPContactsManager.h"
#import "CMPChatManager.h"
#import "CMPMessageManager.h"
#import <CMPLib/CMPScheduleManager.h>
#import "CMPLoginResponse.h"
#import "CMPDeviceBindProvider.h"
#import "CMPCommonManager.h"
#import "CMPCookieTool.h"
#import "CMPCheckUpdateManager.h"
#import "CMPCloudLoginHelper.h"
#import <CMPLib/EGOCache.h>
#import "CMPLoginUpdateConfigHelper.h"
#import "CMPPartTimeHelper.h"
#import "CMPLocalAuthenticationState.h"
#import "CMPHomeAlertManager.h"
#import "CMPLoginViewController.h"
#import "CMPNewLoginViewController.h"
#import "CMPRequestBgImageUtil.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/GTMUtil.h>
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPLoginRsaTools.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/SOLocalization.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import "CMPLoginRequest.h"
#import "CMPLocationManager.h"
#import "TrustdoLoginManager.h"
#import "CMPShareManager.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPPrivacyProtocolWebViewController.h"
#import "CMPNativeToJsModelManager.h"
#import <CordovaLib/WKWebRequestCacheManager.h>
#import <CMPLib/CMPJSLocalStorageManager.h>
#import "CMPMessageFilterManager.h"
#import "CMPAttachmentHelper.h"
#import <CMPVpn/CMPVpn.h>
#import "CMPMsgQuickHandler.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import <GMObjC/GMSm3Utils.h>
#import <mach/mach_time.h>

static NSString * const kGetConfigInfoUrl = @"/rest/m3/common/getConfigInfo";
static NSString * const kHistoryPhoneCacheKey = @"historyLoginPhone";


@interface M3LoginManager()<CMPDataProviderDelegate>

@property (assign, nonatomic) BOOL hasNewColPrivilege;
@property (assign, nonatomic) BOOL hasAdressBookPrivilege;
@property (assign, nonatomic) BOOL hasIndexPrivilege;
@property (nonatomic, copy) NSString *loginRequestID;
@property (nonatomic, copy) void(^requestLoginStart)(void);
@property (nonatomic, copy) void(^requestLoginSuccess)(void);
@property (nonatomic, copy) void(^requestLoginFail)(NSError *error);
@property (nonatomic, copy) RequestAppListAndConfigSuccessBlock requestAppListAndConfigSuccess;
@property (nonatomic, copy) void(^requestAppListAndConfigFail)(NSError *error);
@property (nonatomic, copy) NSString *appListRequestID;
@property (nonatomic, copy) NSString *configInfoRequestID;
@property (nonatomic, copy) NSString *bindApplyRequestID;
@property (nonatomic, copy) NSString *logoutRequestID;
@property (nonatomic, strong) CMPLoginConfigInfoModel *loginConfigInfoModel;
@property (nonatomic, strong) CMPAppListModel *appListModel;
@property (nonatomic, strong) CMPLoginResponse *loginResponseModel;
@property (nonatomic, copy) NSString *loginResultStr;
@property (nonatomic, copy) NSString *configInfoStr;
@property (nonatomic, copy) NSString *configInfoH5CacheStr;
@property (nonatomic, retain) NSString *appListStr;
@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *loginPassword;
@property (assign, nonatomic) CMPLoginAccountModelLoginType loginType;
@property (nonatomic, strong) CMPDeviceBindProvider *deviceBindProvider;
@property (strong, nonatomic) CMPCloudLoginHelper *cloudLoginHelper;
@property (strong, nonatomic) CMPLoginUpdateConfigHelper *updateConfigHelper;
/* CMPRequestBgImageUtil */
@property (strong, nonatomic) CMPRequestBgImageUtil *requestBgUtil;

/* jsession */
@property (copy, nonatomic) NSString *jsession;
@property (assign, nonatomic) BOOL isFromAutoLogin;
@property (assign, nonatomic) __block CMPLoginModeSubType loginModeSubType;
@property (nonatomic,strong) NSMutableDictionary *loginInfoLegencyDic;

@end

@implementation M3LoginManager

#pragma mark-
#pragma mark Init

static M3LoginManager *instance = nil;

+ (M3LoginManager *)sharedInstance {
    if (instance == nil) {
        instance = [[M3LoginManager alloc] init];
    }
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _partTimeHelper = [[CMPPartTimeHelper alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged) name:kNotificationName_NetworkStatusChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:kNotificationName_UserLogout object:nil];

    }
    return self;
}

+ (void)clearSharedInstance {
    if (!instance.offlineLogin) {
        [instance clearAll];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)clearAll {
    _currentAccount = nil;
    _loginRequestID = nil;
    _requestLoginStart = nil;
    _requestLoginSuccess = nil;
    _requestLoginFail = nil;
    _appListRequestID = nil;
    _configInfoRequestID = nil;
    _bindApplyRequestID = nil;
    _loginConfigInfoModel = nil;
    _appListModel = nil;
    _loginResultStr = nil;
    _loginResponseModel = nil;
    _configInfoStr = nil;
    _appListStr = nil;
    _configInfoH5CacheStr = nil;
    _deviceBindProvider = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-
#pragma mark 通知处理

- (void)networkChanged {
    if (_offlineLogin && [CMPCommonManager reachableServer]) {
        _offlineLogin = NO;
        [self setupOther];
        [instance clearAll];
    }
}

- (void)userLogout {
    instance.offlineLogin = NO;
    [instance clearAll];
}

#pragma mark-
#pragma mark Public Api

-(void)clearOldCookieBeforeLoginWithResult:(void(^)(void))result
{
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSLog(@"ks log --- clearOldCookieBeforeLogin -- %@",cookies);
    [CMPCookieTool clearCookiesAndCache];
    cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    NSLog(@"ks log --- clearOldCookieBeforeLogin result -- %@",cookies);

    //修改清除cookie的方法
    if (@available(iOS 11.0, *)) {
        WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
        [dataStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
             for (WKWebsiteDataRecord *record  in records){
                 NSSet<NSString*>* dataTypes = record.dataTypes;
                 if([dataTypes containsObject:WKWebsiteDataTypeCookies]){
                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                           forDataRecords:@[record]
                           completionHandler:^{}];
                 }
             }
         }];
                
        uint64_t startTime = currentTimeInMillis();
        [self clearAllCookiesWithCompletion:^{
            uint64_t endTime = currentTimeInMillis();
            uint64_t elapsedTime = endTime - startTime;
            NSLog(@"clearAllCookiesWithCompletion in %llu milliseconds", elapsedTime);
            
            if (result) {
                result();
            }
        }];

    } else {
        if (result) {
            result();
        }
    }
}

//清除WKHTTPCookieStore
- (void)clearAllCookiesWithCompletion:(void (^)(void))completion {
    dispatch_group_t group = dispatch_group_create();
    WKHTTPCookieStore *cookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
    
    
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            dispatch_group_enter(group);
            [cookieStore deleteCookie:cookie completionHandler:^{
                dispatch_group_leave(group);
            }];
        }
        
        if ([cookies count] == 0) {
            
            dispatch_group_notify(group, dispatch_get_main_queue(), completion);
        } else {
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}
// 用于获取当前时间的毫秒表示
uint64_t currentTimeInMillis(void) {
    static mach_timebase_info_data_t info;
    if (info.denom == 0) {
        mach_timebase_info(&info);
    }
    uint64_t machTime = mach_absolute_time();
    uint64_t millis = (machTime * info.numer) / (info.denom * 1000000);
    return millis;
}
- (void)requestLoginWithUserName:(NSString *)aUserName
                        password:(NSString *)aPassword
                       encrypted:(BOOL)aEncrypted
                    refreshToken:(BOOL)refreshToken
                verificationCode:(NSString *)verificationCode
                            type:(CMPLoginAccountModelLoginType)type
                    externParams:(NSDictionary *)externParams
                           start:(void(^)(void))start
                         success:(void(^)(void))success
                            fail:(void(^)(NSError *error))fail {
    [self requestLoginWithUserName:aUserName password:aPassword encrypted:aEncrypted refreshToken:refreshToken verificationCode:verificationCode type:type loginType:nil smsCode:nil externParams:externParams isFromAutoLogin:NO start:start success:success fail:fail];
}

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
                            fail:(void(^)(NSError *error))fail {
    self.appListModel = nil;
    self.loginConfigInfoModel = nil;
    self.requestLoginStart = start;
    self.requestLoginSuccess = success;
    self.requestLoginFail = fail;
    self.isFromAutoLogin = isFromAutoLogin;
    NSString *tmpUserName = aUserName.copy;
    if (!aEncrypted) {
        aUserName = [GTMUtil encrypt:aUserName];
        aPassword = [GTMUtil encrypt:aPassword];
    }
    else {
        // 兼容加密后的用户名 修改bugOA-207553 add by guoyl
        tmpUserName = [[GTMUtil decrypt:aUserName] copy];
    }
    NSString *aUDID = [SvUDIDTools UDID];
    NSString *abbreviation = [CMPDateHelper timeZoneAbbreviation];
    NSString *client = nil;
    if ([CMPFeatureSupportControl isLoginDistinguishDevice:[CMPCore sharedInstance].serverVersion]) {
        client = INTERFACE_IS_PAD ? @"ipad" : @"iphone";
    } else {
        client = @"iphone";
    }
    NSDictionary *aParam = @{@"password": aPassword ?: @"",
                             @"client": client,
                             @"deviceCode": aUDID ?: @"",
                             @"timezone":abbreviation ?: @""};
    aParam = [CMPLoginRsaTools appendRsaParam:aParam];
    NSMutableDictionary *aMutableParam = [aParam mutableCopy];
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        aMutableParam[@"name"] = aUserName;
        if (tmpUserName.justContainsNumber && CMPCore.sharedInstance.isShowPhoneLogin) {
            aMutableParam[@"login_mobliephone"] = aUserName;
            self.phone = aUserName;
        }
    }
    else {
        if (type == CMPLoginAccountModelLoginTypePhone || loginType.intValue == CMPM3LoginTypeSMS) {
            aMutableParam[@"login_mobliephone"] = aUserName;
        } else if (type == CMPLoginAccountModelLoginTypeLegacy) {
            aMutableParam[@"name"] = aUserName;
        }
    }
    if (loginType.intValue == CMPM3LoginTypeSMS  && type == CMPLoginAccountModelLoginTypeSMS) {
        NSString *phone_number = externParams[@"phone_number"];
        if (phone_number.length) {
            tmpUserName = phone_number;
            phone_number = [GTMUtil encrypt:phone_number];
            aMutableParam[@"phone_number"] = phone_number;
            self.phone = phone_number;
        }else if(tmpUserName.justContainsNumber){//如果传入的用户名是纯数字-手机号
            aMutableParam[@"phone_number"] = aUserName;
        }else if (self.currentAccount.extend5.length) {//从数据库中拿手机号
            NSString *tmpPhone = [GTMUtil decrypt:self.currentAccount.extend5];
            if (tmpPhone.justContainsNumber) {
                tmpUserName = tmpPhone;
                aMutableParam[@"phone_number"] = self.currentAccount.extend5;
            }
        }else{
            aMutableParam[@"phone_number"] = aUserName;
        }
    }

    if ([NSString isNotNull:loginType]) {
        aMutableParam[@"login_type"] = loginType;
    }
    
    if ([NSString isNotNull:verificationCode]) {
        aMutableParam[@"login.VerifyCode"] = verificationCode;
    }
    
    if ([NSString isNotNull:smsCode]) {
        aMutableParam[@"login_smsVerifyCode"] = smsCode;
    }
    
    // FIX：双因子判断--短信登录时，不要传这几个参数
    if (loginType.intValue == CMPM3LoginTypeSMS  && type == CMPLoginAccountModelLoginTypeSMS) {
        [aMutableParam removeObjectForKey:@"password"];
        [aMutableParam removeObjectForKey:@"login_type"];
        [aMutableParam removeObjectForKey:@"login_mobliephone"];
        [aMutableParam removeObjectForKey:@"name"];
    }
    
    //ks 8.2-810 新增time：时间戳。signature：签名字段
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if ((!loginType || loginType.intValue == CMPM3LoginTypeSMS)  && type == CMPLoginAccountModelLoginTypeSMS) {
            [aMutableParam removeObjectForKey:@"password"];
            [aMutableParam removeObjectForKey:@"login_type"];
            [aMutableParam removeObjectForKey:@"login_mobliephone"];
            [aMutableParam removeObjectForKey:@"name"];
            
            long long timestramp = [[NSDate date] timeIntervalSince1970];
            aMutableParam[@"time"] = @(timestramp);
            NSString *pStr;
            if (smsCode && !isFromAutoLogin) {
                pStr = smsCode;
            }else if (externParams && [externParams isKindOfClass:CMPLoginAccountModel.class]){
                NSString *token = ((CMPLoginAccountModel *)externParams).extend6;
                token = [GTMUtil decrypt:token];
                token = [GTMUtil decrypt:token];
                aMutableParam[@"token"] = token;
                pStr = token;
                
                aMutableParam[@"phone_number"] = aUserName;
                
            }else if (isFromAutoLogin) {
                NSString *token = self.currentAccount.extend6;
                token = [GTMUtil decrypt:token];
                token = [GTMUtil decrypt:token];
                aMutableParam[@"token"] = token;
                pStr = token;
            }
            NSString *signature = [self smsSignatureWithPhone:tmpUserName pStr:pStr timestramp:timestramp];
            aMutableParam[@"signature"] = signature;
        }
    }
    
    if (externParams && [externParams isKindOfClass:NSDictionary.class]) {
        [externParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![key isEqualToString:@"phone_number"]) {//phone_numer做了单独处理
                [aMutableParam setObject:obj ?: @"" forKey:key];
            }
        }];
    }
    // cancel上次登录请求
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.loginRequestID];
    
    if ([NSString isNotNull:verificationCode]) {
    }
    else {
        refreshToken = YES;
    }
    CMPLoginRequest *aLoginRquest = [[CMPLoginRequest alloc] initWithDelegate:self param:[aMutableParam JSONRepresentation]];
    if (refreshToken) {
        NSMutableDictionary *aDict = (NSMutableDictionary *)[CMPDataProvider headers];
        [aDict setObject:@"" forKey:@"Cookie"];
        aLoginRquest.headers = aDict;
    }
    
    
    BOOL isDoubleAuthLogin = NO;
    
    //双因子第二次调登录接口需要带上第一次的sessionId
    if ([externParams isKindOfClass:NSDictionary.class]) {
        id isDoubleAuthStr = [externParams objectForKey:@"isDoubleAuth"];
        if (isDoubleAuthStr && [isDoubleAuthStr isKindOfClass:NSString.class]) {
            isDoubleAuthLogin = [isDoubleAuthStr isEqualToString:@"1"];
        }else if (isDoubleAuthStr && [isDoubleAuthStr isKindOfClass:NSNumber.class]) {
            isDoubleAuthLogin = [isDoubleAuthStr isEqualToNumber:@1];
        }
    }
    if (isDoubleAuthLogin && [NSString isNotNull:self.jsession]) {
        NSMutableDictionary *aDict = (NSMutableDictionary *)[CMPDataProvider headers];
        NSString *fromatCookir = [CMPCookieTool cookieStrFromat:self.jsession];
        if (fromatCookir) {
            [aDict setObject:fromatCookir forKey:@"Cookie"];
        }
        aLoginRquest.headers = aDict;
    }
    
    self.loginRequestID = aLoginRquest.requestID;
    self.loginPassword = aPassword;
    self.loginType = type;
    if (type == CMPLoginAccountModelLoginTypePhone) {
        self.phone = aUserName;
    }else if (type == CMPLoginAccountModelLoginTypeSMS) {
        //V5-64714 这里手机验证码登录时会传手机号码过来去替换self.loginName,导致缓存到H5的loginName变为了手机号
        if ([NSString isNull:self.loginName]) {
            self.loginName = aUserName;
        }
    } else {
        self.loginName = aUserName;
    }
    
    //双因子第二次调登录方法 不清除cookie
    if (isDoubleAuthLogin || aMutableParam[@"login.VerifyCode"]) {//ks fix -- V5-36256 iOS M3输入错误验证码也可以成功登录
        [[CMPDataProvider sharedInstance] addRequest:aLoginRquest];
    }else{
        [self clearOldCookieBeforeLoginWithResult:^{
            [[CMPDataProvider sharedInstance] addRequest:aLoginRquest];
        }];
    }
    if (type == CMPLoginAccountModelLoginTypeLegacy) {
        _loginModeSubType = CMPLoginModeSubType_None;
        _loginInfoLegencyDic = nil;
        [self.loginInfoLegencyDic addEntriesFromDictionary:@{@"username":aUserName?:@"",@"password":aPassword?:@""}];
    }
}

-(NSString *)smsSignatureWithPhone:(NSString *)phone pStr:(NSString *)pStr timestramp:(long long)timestramp
{
    if (!phone || phone.length < 4) {
        return @"";
    }
    if (!pStr || pStr.length == 0) {
        return @"";
    }
    NSString *p1 = [phone substringFromIndex:phone.length-4];
    NSString *p2 = pStr;
    NSString *p3 = [SvUDIDTools UDID];
    NSString *p4 = [NSString stringWithLongLong:timestramp>0?timestramp:[NSDate date].timeIntervalSince1970];
    NSString *o = [NSString stringWithFormat:@"%@%@%@%@",p1,p2,p3,p4];
    NSString *r = [GMSm3Utils hashWithString:o];
    NSLog(@"sm3加密原串：%@",o);
    NSLog(@"sm3加密串：%@",r);
    return r;
}

- (CMPLoginAccountModel *)currentAccount {
    return [CMPCore sharedInstance].currentUser;
}

// 是否自动登录
- (BOOL)isAutoLogin {
    NSString *aLoginName = self.currentAccount.loginName;
    NSString *aLoginPassword = self.currentAccount.loginPassword;
    NSString *aLoginPhone = self.currentAccount.extend5;
    
    if ([CMPCore sharedInstance].isByPopUpPrivacyProtocolPage) {
        if (!self.currentAccount.extraDataModel.isAlreadyShowPrivacyAgreement) {
            return NO;
        }
    }
    
    if (![CMPPrivacyProtocolWebViewController isAlreadySinglePopUpPrivacyProtocolPage]) {
          return NO;
    }
    
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        //ks add -- 8.2 810
        CMPLoginAccountModelLoginType aType = self.currentAccount.loginType;
        if (aType == CMPLoginAccountModelLoginTypeSMS) {
            NSString *token = self.currentAccount.extend6;
            if (![NSString isNull:aLoginName]
                && ![NSString isNull:token]
                && ![self _isTokenExpired]) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    
    if (![NSString isNull:aLoginName] && ![NSString isNull:aLoginPassword]) {
        return YES;
    }
    if (![NSString isNull:aLoginPhone] && ![NSString isNull:aLoginPassword]) {
        return YES;
    }
    return NO;
}

- (BOOL)isLogin {
    UIViewController *rootVc = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (!rootVc) {
        [MBProgressHUD cmp_showHUDWithText:@"keyWindow.rootVC为nil"];
        
    }
    return [rootVc isKindOfClass: CMPTabBarViewController.class];
}
// 手机盾调用
- (void)requestMokeyLoginWithUserName:(NSString *)aUserName
                             password:(NSString *)aPassword
                            encrypted:(BOOL)aEncrypted
                         refreshToken:(BOOL)refreshToken
                     verificationCode:(NSString *)verificationCode
                                 type:(CMPLoginAccountModelLoginType)type
                             accToken:(NSString *)accToken
                                start:(void(^)(void))start
                              success:(void(^)(void))success
                                 fail:(void(^)(NSError *error))fail {
    self.appListModel = nil;
    self.loginConfigInfoModel = nil;
    self.requestLoginStart = start;
    self.requestLoginSuccess = success;
    self.requestLoginFail = fail;
    if (!aEncrypted) {
        aUserName = [GTMUtil encrypt:aUserName];
        aPassword = [GTMUtil encrypt:aPassword];
    }
    NSString *aUDID = [SvUDIDTools UDID];
    NSString *abbreviation = [CMPDateHelper timeZoneAbbreviation];

    NSDictionary *aParam = @{@"password": aPassword ?: @"",
                             @"client": @"iphone",
                             @"deviceCode": aUDID ?: @"",
                             @"timezone":abbreviation ?: @""};
    aParam = [CMPLoginRsaTools appendRsaParam:aParam];
    NSMutableDictionary *aMutableParam = [aParam mutableCopy];
    if (type == CMPLoginAccountModelLoginTypePhone) {
        [aMutableParam setObject:aUserName ?: @"" forKey:@"login_mobliephone"];
    } else if (type == CMPLoginAccountModelLoginTypeLegacy) {
        [aMutableParam setObject:aUserName ?: @"" forKey:@"name"];
    } else if (type == CMPLoginAccountModelLoginTypeMokey) {
        [aMutableParam setObject:aUserName ?: @"" forKey:@"name"];
        [aMutableParam setObject:accToken ?: @"" forKey:@"accToken"];
        [aMutableParam setObject:@"mokey_m3" forKey:@"trustdo_type"];
    }
    else {
        NSLog(@"zl---%s type参数错误", __FUNCTION__);
    }
    if (![NSString isNull:verificationCode]) {
        [aMutableParam setObject:verificationCode forKey:@"login.VerifyCode"];
    }
    
    // cancel上次登录请求
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.loginRequestID];
    CMPLoginRequest *aLoginRquest = [[CMPLoginRequest alloc] initWithDelegate:self param:[aMutableParam JSONRepresentation]];
    if (refreshToken) {
        NSMutableDictionary *aDict = (NSMutableDictionary *)[CMPDataProvider headers];
        [aDict setObject:@"" forKey:@"Cookie"];
        aLoginRquest.headers = aDict;
    }
    self.loginRequestID = aLoginRquest.requestID;
    self.loginPassword = aPassword;
    self.loginType = type;
    if (type == CMPLoginAccountModelLoginTypePhone) {
        self.phone = aUserName;
    } else {
        self.loginName = aUserName;
    }
    if (aMutableParam[@"login.VerifyCode"]) {
        [[CMPDataProvider sharedInstance] addRequest:aLoginRquest];
    }else{
        [self clearOldCookieBeforeLoginWithResult:^{
            [[CMPDataProvider sharedInstance] addRequest:aLoginRquest];
        }];
    }
}

// 自动登录
- (void)autoRequestLogin:(void(^)(void))start success:(void(^)(void))success fail:(void(^)(NSError *error))fail ext:(__nullable id)extParams {
    [CMPCore sharedInstance].jsessionId = nil;
    // 离线登录
    if ([self _isOfflineLogin]) {
        [[CMPCommonManager appdelegate] delayHandleSessionInvalid];
        [self _offlineLoginSuccess:success fail:fail];
        return;
    }
    CMPLoginAccountModelLoginType aType = self.currentAccount.loginType;
    NSString *aLoginName = nil, *aLoginType = nil;
    if (aType == CMPLoginAccountModelLoginTypeLegacy) {
        aLoginName = self.currentAccount.loginName;
    } else if (aType == CMPLoginAccountModelLoginTypePhone) {
        aLoginName = self.currentAccount.extend5;
    } else if (aType == CMPLoginAccountModelLoginTypeMokey) {
        [self showLoginViewControllerWithMessage:kNotificationMessage_MokeyAutoLogin];
        return;
    }else if (aType == CMPLoginAccountModelLoginTypeSMS) {
        aLoginName = self.currentAccount.loginName;
        aLoginType = [NSString stringWithInt:CMPM3LoginTypeSMS];
    }
    NSString *aLoginPassword = self.currentAccount.loginPassword;
    
    //V5-56387 ios端双因子登录后杀进程，退出到了登录页提示当前收集号码未绑定办公账号
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:extParams?:@{}];
    if (self.currentAccount.extraDataModel.loginModeSubType == CMPLoginModeSubType_MutilVerify) {
        [ext setValue:@"1" forKey:@"isDoubleAuth"];
    }
//    if ([@"1" isEqualToString:[NSString stringWithFormat:@"%@",ext[@"ignoreDoubleAuth"]]]) {
//        [ext removeObjectForKey:@"isDoubleAuth"];
//    }
    //end
    
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:self.currentAccount.serverID];
    if (vpnModel.vpnUrl.length && ![CMPVpnManager isVpnConnected]) {//不能免密登录才使用账号密码登录
        //vpn先登录
        [self cmp_showProgressHUDWithText:@"VPN登录中"];
        __weak typeof(self) wSelf = self;

        [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                        
                    } success:^(id obj, id ext) {
                        [wSelf cmp_hideProgressHUD];
                        
                        [[M3LoginManager sharedInstance] requestLoginWithUserName:aLoginName password:aLoginPassword encrypted:YES refreshToken:YES verificationCode:nil type:aType loginType:aLoginType smsCode:nil externParams:ext isFromAutoLogin:YES
                                                                            start:^{
                            if (start) {
                                start();
                            }
                        } success:^{
                            if (success) {
                                success();
                            }
                        } fail:^(NSError *error) {
                            if ([wSelf needDeviceBind:error]) { // 高安全级别，硬件绑定
                                [wSelf showBindTipAlert];
                            }
                            if (fail) {
                                fail(error);
                            }
                        }];
                    } fail:^(id obj, id ext) {
                        [wSelf cmp_hideProgressHUD];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //修复VPN登录返回密码错误，此时一直在加载页面，没法进入或者退出
                            [wSelf cmp_showHUDWithText:obj completionBlock:^{
                                [wSelf _offlineLoginSuccess:success fail:fail];
                            }];
                        });
                    }];

    }else{
        [[M3LoginManager sharedInstance] requestLoginWithUserName:aLoginName password:aLoginPassword encrypted:YES refreshToken:YES verificationCode:nil type:aType loginType:aLoginType smsCode:nil externParams:ext isFromAutoLogin:YES
                                                            start:^{
            if (start) {
                start();
            }
        } success:^{
            if (success) {
                success();
            }
        } fail:^(NSError *error) {
            if ([self needDeviceBind:error]) { // 高安全级别，硬件绑定
                [self showBindTipAlert];
            }
            if (fail) {
                fail(error);
            }
        }];
    }
}

-(void)verifyRemotePwd:(NSString *)pwd result:(void(^_Nonnull)(id respObj, NSError *err, _Nullable id ext))result {
    if (!result) {
        return;
    }
    if (!pwd) {
        result(nil,[NSError errorWithDomain:@"password null" code:-1001 userInfo:nil],nil);
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/password/retrieve/validateOldPwd/"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *p = @{@"formerpassword":[GTMUtil encrypt:pwd]};
    aDataRequest.requestParam = [p yy_modelToJSONString];
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"login.verifyRemotePwd"};
    aDataRequest.requestID = @"login.verifyRemotePwd";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

// 处理登录成功
- (void)handleLoginSuccess:(CMPDataResponse *)aResponse {
    NSLog(@"%s",__func__);
    // 存储cookie
    NSDictionary *aHeader = aResponse.responseHeaders;
//    NSString *aAccessedTimeout = [aHeader objectForKey:@"Accessed-Timeout"];
    NSString *aServerUrl = [CMPCore sharedInstance].serverurl;
    [CMPCookieTool saveCookiesWithUrl:aServerUrl responseHeaders:aHeader];
    
    NSString *aResponseStr = aResponse.responseStr;
    self.loginResultStr = aResponseStr;
    NSDictionary *responseHeader = aResponse.responseHeaders;
    NSString *aTicket = [responseHeader objectForKey:@"Content-Ticket"];
    NSString *aExtension = [responseHeader objectForKey:@"Content-Extension"];
    [CMPCore sharedInstance].contentTicket = nil;
    [CMPCore sharedInstance].contentExtension = nil;
    if (![NSString isNull:aTicket]) {
        [CMPCore sharedInstance].contentTicket = aTicket;
    }
    if (![NSString isNull:aExtension]) {
        [CMPCore sharedInstance].contentExtension = aExtension;
    }
    CMPLoginResponse *aLoginResponse = [CMPLoginResponse yy_modelWithJSON:aResponseStr];
    self.loginResponseModel = aLoginResponse;
    CMPLoginResponseCurrentMember *model = aLoginResponse.data.currentMember;
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    // 1、是否已经存在该用户，如果存在，需要读取出来，然后在更新为正在使用的用户
    CMPLoginAccountModel *aAccount = [[CMPCore sharedInstance].loginDBProvider accountWithServerID:aServerId userID:model.userId];
    if (!aAccount) {
        aAccount = [[CMPLoginAccountModel alloc] init];
        // 如果不存在需要设置gestureMode=2， 未设置手势密码
        aAccount.gestureMode = CMPLoginAccountModelGestureUninit;
    }
    // 将用户信息写入数据库
    aAccount.userID = model.userId;
    aAccount.loginPassword = self.loginPassword;
    
    if (self.loginType == CMPLoginAccountModelLoginTypePhone) {
        // 手机号
        aAccount.extend5 = self.phone;
        // 手机号登录，登录成功从服务器端获取用户名
        aAccount.loginName = [GTMUtil encrypt:model.loginName];
    } else {
        aAccount.loginName = self.loginName;
    }
    if (self.loginType == CMPLoginAccountModelLoginTypeSMS && self.phone) {
        aAccount.extend5 = self.phone;
    }
    if (self.loginType == CMPLoginAccountModelLoginTypeSMS && self.areaCode.length) {
        aAccount.extend8 = self.areaCode;
    }
    // 登录方式
    aAccount.extend4 = [NSString stringWithInt:self.loginType];
    
    // 用于关联账号
    aAccount.extend2 = self.loginPassword;
    aAccount.serverID = aServerId;
    aAccount.name = model.name;
    aAccount.loginResult = self.loginResultStr;
    
    aAccount.accountID = model.accountId;
    aAccount.departmentID = model.departmentId;
    aAccount.levelID = model.levelId;
    aAccount.postID = model.postId;
    aAccount.iconUrl = model.iconUrl;
    aAccount.extend1 = model.accShortName;
    aAccount.extend3 = model.accName;
    
    aAccount.departmentName = model.departmentName;
    aAccount.postName = model.postName;
    [CMPCore sharedInstance].jsessionId = aLoginResponse.data.ticket;
    [[CMPCore sharedInstance].loginDBProvider addAccount:aAccount inUsed:YES];
    [[CMPCore sharedInstance] setup];
    [CMPCore sharedInstance].passwordOvertime = aLoginResponse.data.config.passwordOvertime;
    [CMPCore sharedInstance].passwordNotStrong = !aLoginResponse.data.config.passwordStrong;
    [CMPCore sharedInstance].passwordChangeForce = aLoginResponse.data.config.passwordChangeForce;
    [CMPCore sharedInstance].devBindingForce = aLoginResponse.data.config.devBindingForce;
    [CMPCore sharedInstance].csrfToken = aLoginResponse.data.config.csrfToken;
    [CMPThemeManager sharedManager].uiSkin = aLoginResponse.data.config.uiSkin;//一键换肤数据
    [[CMPCore sharedInstance] updateUiskin:aLoginResponse.data.config.uiSkin];
    // 设置用户登录信息到webview
    CMPServerModel *currentServer = [CMPCore sharedInstance].currentServer;
    NSString *loginName1 = self.loginName;
    if (model.loginName.length) {
        loginName1 = [GTMUtil encrypt:model.loginName];
    }
    //self.loginName => loginName1
    [[CMPMigrateWebDataViewController shareInstance] saveLoginCache:self.loginResultStr loginName:loginName1 password:self.loginPassword serverVersion:currentServer.serverVersion];
    [CMPCore sharedInstance].anewSessionAfterLogin = aLoginResponse.data.ticket;
    [CMPCore sharedInstance].loginSuccessTime = [NSDate date];
    NSLog(@"new session:%@",[CMPCore sharedInstance].jsessionId);
    NSLog(@"new server version:%@",currentServer.serverVersion);
    NSLog(@"new user id:%@",aAccount.userID);
    NSLog(@"new user name:%@",aAccount.loginName);
    
    if (_loginModeSubType == CMPLoginModeSubType_MutilVerify) {
        CMPLoginAccountExtraDataModel *extraDataModel = [CMPLoginAccountExtraDataModel yy_modelWithJSON:aAccount.extend10];
        extraDataModel.loginModeSubType = CMPLoginModeSubType_MutilVerify;
        extraDataModel.loginInfoLegency = [self.loginInfoLegencyDic JSONRepresentation];
        NSString *extraDataModelStr = [extraDataModel yy_modelToJSONString];
        aAccount.extend10 = extraDataModelStr;
        [[CMPCore sharedInstance].loginDBProvider updateAccount:aAccount extend10:extraDataModelStr];
    }
    _loginModeSubType = CMPLoginModeSubType_None;
    _loginInfoLegencyDic = nil;
}

/**
 处理登录token
 */
- (void)handleLoginToken:(CMPDataResponse *)response {
    CMPCore *core = [CMPCore sharedInstance];
    if (!core.serverIsLaterV2_5_0) {
        return;
    }
    NSString *token = response.responseHeaders[@"ltoken"];
    NSString *expireTime = response.responseHeaders[@"ltoken_expired"];
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        //ks add -- 短信登录
        if (self.loginType == CMPLoginAccountModelLoginTypeSMS) {
            token = response.responseHeaders[@"ltk"];
            expireTime = response.responseHeaders[@"expire"];
        }
    }
    NSLog(@"zl---[%s]更新token：%@， 更新expireTime：%@", __FUNCTION__, token, expireTime);
    [core.loginDBProvider updateAccount:core.currentUser token:[GTMUtil encrypt:token] expireTime:expireTime];
    core.token = token;
    //ks fix -- V5-55931 ios端第一次使用短信登录后杀进程重新进入应用，提示无法识别令牌
    //由于logintoken时先吊用了encryptTokenUpdate，第一次flag都是false，都会清理token
    if (core.serverIsLaterV7_1) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kUserDefaultName_TokenEncryptFlag];
    }
    //end
}

// 处理登录失败
- (void)handleLoginFail:(NSError *)error {
    if (self.requestLoginFail) {
        self.requestLoginFail(error);
    }
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        CMPCore *core = [CMPCore sharedInstance];
        if (!core.serverIsLaterV2_5_0) {
            return;
        }
        //ks add -- 8.2 810
        CMPLoginAccountModelLoginType aType = self.currentAccount.loginType;
        if (aType == CMPLoginAccountModelLoginTypeSMS) {
            [core.loginDBProvider clearAccountToken:self.currentAccount];
            core.token = nil;
            core.jsessionId = nil;
            core.currentUser.extend6 = nil;
            core.currentUser.extend7 = nil;
        }
    }
}

- (BOOL)needDeviceBind:(NSError *)error {
    NSString *str = error.userInfo[@"responseString"];
    NSDictionary *strDic = [str JSONValue];
    NSInteger code = [strDic[@"code"] integerValue];
    if (code == -3010) { // 高安全级别，硬件绑定
        return YES;
    } else if (code == 500) { // 兼容6.1
        NSString *message = strDic[@"message"];
        if (![NSString isNull:message]) {
            NSDictionary *messageDic = [message JSONValue];
            if (messageDic && [messageDic isKindOfClass:[NSDictionary class]]) {
                code = [messageDic[@"code"] integerValue];
                if (code == -3010) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isVerificationError:(NSError *)error {
    NSString *str = error.userInfo[@"responseString"];
    NSDictionary *strDic = [str JSONValue];
    NSInteger code = [strDic[@"code"] integerValue];
    if (code == 9) {
        return YES;
    }
    return NO;
}

- (NSString *)verificationCodeUrl:(NSError *)error {
    NSDictionary *userInfo = error.userInfo;
    if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
        NSString *responseString = userInfo[@"responseString"];
        if (![NSString isNull:responseString]) {
            NSDictionary *responseDic = [responseString JSONValue];
            if (responseDic && [responseDic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = responseDic[@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    NSString *verificationUrl = data[@"verify_code_url"];
                    return verificationUrl;
                }
            }
        }
    }
    return nil;
}

- (void)requestAppListAndConfigSuccess:(RequestAppListAndConfigSuccessBlock)success fail:(void(^)(NSError *error))fail {
    _requestAppListAndConfigSuccess = [success copy];
    _requestAppListAndConfigFail = [fail copy];
    [self requestAppList];
    [self requestConfigInfo];
}

- (void)requestAppList {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlPathMapForPath:@"/api/mobile/app/list"];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    self.appListRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)hanldeRequestAppList:(CMPDataResponse *)aResponse {
    NSString *aResultStr = aResponse.responseStr;
    if ([NSString isNull:aResultStr]) {
        return;
    }
    self.appListStr = aResultStr;
    [UserDefaults setObject:aResultStr forKey:[NSString stringWithFormat:@"CMPAppList_%@_%@", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID]];
    CMPObject *model = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        model = [CMPAppListModel_2 yy_modelWithJSON:aResultStr];
    } else {
        model = [CMPAppListModel yy_modelWithJSON:aResultStr];
    }
    // 根据结果判断是否有新建协同权限
    _hasNewColPrivilege = [self hasNewColPrivilege:model];
    self.appListModel = model;
    CMPLoginUpdateManager *upadateManager = [[CMPLoginUpdateManager alloc] init];
    // 把App list缓存到H5
    [upadateManager createTables];
    if ([self.appListModel isKindOfClass:[CMPAppListModel class]]) {
        [upadateManager insertApps:self.appListModel];
    }
}

/**
 判断是否有新建协同权限
 */
- (BOOL)hasNewColPrivilege:(CMPAppListModel *)model {
    if ([model isKindOfClass:[CMPAppListModel class]]) {
        for (CMPAppListData *obj in model.data) {
            if ([obj.bundleName isEqualToString:@"newcoll"] &&
                [obj.isShow isEqualToString:@"1"]) {
                return YES;
            }
        }
    } else if ([model isKindOfClass:[CMPAppListModel_2 class]]) {
        for (CMPAppListData_2 *appListData in model.data) {
            for (CMPAppList_2 *appList in appListData.appList) {
                if ([appList.bundleName isEqualToString:@"newcoll"] &&
                    [appList.isShow isEqualToString:@"1"]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

// 获取配置信息
- (void)requestConfigInfo {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kGetConfigInfoUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    self.configInfoRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)handleRequestConfigInfo:(CMPDataResponse *)aResponse {
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:aResponse.responseStr];
        _hasAdressBookPrivilege = model.config.hasAddressBook;
        _hasIndexPrivilege = model.config.hasIndexPlugin;
        NSString *h5CacheStr = [model getH5CacheStr];
        self.configInfoStr = aResponse.responseStr;
        self.configInfoH5CacheStr = h5CacheStr;
        CMPCore.sharedInstance.screenMirrorIsOpen = [model.config.allow_ScreenCast isEqualToString:@"enable"];
        CMPCore.sharedInstance.hasUcMsgServerDel = model.hasUcMsgServerDel;
    } else {
        CMPLoginConfigInfoModel *model = [CMPLoginConfigInfoModel yy_modelWithJSON:aResponse.responseStr];
        _hasAdressBookPrivilege = model.data.hasAddressBook;
        _hasIndexPrivilege = model.data.hasIndexPlugin;
        self.configInfoStr = aResponse.responseStr;
        self.configInfoH5CacheStr = aResponse.responseStr;
        CMPCore.sharedInstance.screenMirrorIsOpen = [model.data.allow_ScreenCast isEqualToString:@"enable"];
    }
}

- (void)setupOther {
    // 更新兼职单位
    [[M3LoginManager sharedInstance] refreshPartTime];
    // 开始注册离线消息推送
    [[CMPBackgroundRequestsManager sharedManager] registerRemoteNotification];
    // 获取启动页面设置信息
    [[CMPBackgroundRequestsManager sharedManager] requestCustomStartPage];
    // 离线通讯录开启更新
    [[CMPContactsManager defaultManager] beginUpdate];
    // 初始化致信
    [[CMPChatManager sharedManager] begin];
    // 消息中心
    [[CMPMessageManager sharedManager] begin];
    // 启动日程同步
    [[CMPScheduleManager sharedManager] startSync];
    //该请求需要设置token,所以在设置token以后再请求
    [[CMPBackgroundRequestsManager sharedManager].requestBgImageUtil requestBackgroundWithStart:^{
        
    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
        
    } success:^(CMPLoginViewStyle * _Nonnull style) {
        
    } fail:^(NSError * _Nonnull error) {
        
    }];
    // 初始化分享权限
    [[CMPShareManager sharedManager] requestShareAuthData];
    NSString *account = [NSString stringWithFormat:@"%@-%@",kCMP_ServerID, CMP_USERID];
    account = account.sha1; // 加密
//    [CMPCommonManager reportMtaWithAccount:account];
     [CMPCommonManager reportUAppWithAccount:account];
}

/**
 保存权限信息
 */
- (void)savePrivilege {
    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    pr.hasColNew = _hasNewColPrivilege;
    pr.hasAddressBook = _hasAdressBookPrivilege;
    pr.hasIndexPlugin = _hasIndexPrivilege;
    [CMPPrivilegeManager setCurrentUserPrivilegeWithConfig:pr];
}

- (void)handleAppListAndLoginConfigRequest {
    if (!self.appListStr || !self.configInfoStr) {
        return;
    }
    if (_requestAppListAndConfigSuccess) {
        _requestAppListAndConfigSuccess(self.appListStr, self.configInfoStr, self.configInfoH5CacheStr);
        _requestAppListAndConfigSuccess = nil;
    }
}

- (void)handleAppListAndLoginConfig {
    CMPLoginResponse *aLoginResponse = _loginResponseModel;
    CMPLoginResponseCurrentMember *model = aLoginResponse.data.currentMember;
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    // 1、是否已经存在该用户，如果存在，需要读取出来，然后在更新为正在使用的用户
    CMPLoginAccountModel *aAccount = [[CMPCore sharedInstance].loginDBProvider accountWithServerID:aServerId userID:model.userId];
    aAccount.appList = self.appListStr;
    
    CMPCore *core = [CMPCore sharedInstance];
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:self.configInfoStr];
        core.printIsOpen = model.config.printIsOpen;
        core.screenMirrorIsOpen = [model.config.allow_ScreenCast isEqualToString:@"enable"];
        //设置地图key
        CMPLocationManager.shareLocationManager.mapKey = model.config.mapKey;
    } else {
        CMPLoginConfigInfoModel *model = [CMPLoginConfigInfoModel yy_modelWithJSON:self.configInfoStr];
        core.printIsOpen = model.data.printIsOpen;
    }
    aAccount.configInfo = self.configInfoStr;
    [core.loginDBProvider addAccount:aAccount inUsed:YES];
    core.currentUser = aAccount;
    [core setup];
    
    // 更新服务器首页
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:aAccount.configInfo];
        NSString *defaultAppKey = newConfig.portal.indexAppKey;
        [CMPTabBarViewController setHomeTabBar:defaultAppKey];
        if (newConfig.config.canLocation) {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways||
                status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [AppDelegate shareAppDelegate].hasCalledUpdateOnlineLngLat = YES;//标记位置已上报
                [self.updateConfigHelper reportLoginLocation];//如果已同意则直接调用
            }
        }
    }
    
    [self savePrivilege];
    [self setupOther];
    // 设置config信息到webview
    [[CMPMigrateWebDataViewController shareInstance] saveConfigInfo:self.configInfoH5CacheStr];
    [self.updateConfigHelper allUpdateDone];
    
    if (self.requestLoginSuccess) {
        self.requestLoginSuccess();
    }
}

- (void)requestLogout {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlPathMapForPath:@"/api/verification/logout"];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPLoginResponse *loginResponse = [CMPLoginResponse yy_modelWithJSON:[CMPCore sharedInstance].currentUser.loginResult];
    NSDictionary *aParamDict = @{@"userId" : [CMPCore sharedInstance].userID,
                                 @"statisticId" : loginResponse.data.statisticId ?: @"",
                                 @"clientType" : ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @(2) : @(1))};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    self.logoutRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    
    CMPCore *core = [CMPCore sharedInstance];
    if ([CMPServerVersionUtils serverIsLaterV8_2_810] && self.currentAccount.loginType == CMPLoginAccountModelLoginTypeSMS) {
        
    }else{
        [core.loginDBProvider clearAccountToken:core.currentUser];
    }
    core.token = nil;
    core.jsessionId = nil;
    [self clearOldCookieBeforeLoginWithResult:nil];
    [[CMPNativeToJsModelManager shareManager] clearData];
    [[WKWebRequestCacheManager shareInstance] clear];
    [CMPJSLocalStorageManager clear];
    [[CMPMigrateWebDataViewController shareInstance] logoutWithResult:nil];
    [CMPCore sharedInstance].showingTopScreen = NO;//重置负一屏状态
}

- (void)logout {
    [CMPCore sharedInstance].isAlertOnShowSessionInvalid = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserLogout object:nil];
    [[CMPCheckUpdateManager sharedManager] stopDownload];
    [[CMPDataProvider sharedInstance] cancelAllRequestsWithCompleteBlock:^{
        //OA-186059 ios登录m3后一直没弹出智能消息弹框，导致小智图标一直显示不出来
        [AppDelegate shareAppDelegate].alertGroup = nil;
    }];
    [[CMPHomeAlertManager sharedInstance] removeAllTask];
    CMPCore *core = [CMPCore sharedInstance];
    // 1130版本token登录，掉线清除token
    [core.loginDBProvider clearAccountToken:core.currentUser];
    core.token = nil;
    [self clearOldCookieBeforeLoginWithResult:nil];
    core.jsessionId = nil;
    
    [[CMPNativeToJsModelManager shareManager] clearData];
    [[WKWebRequestCacheManager shareInstance] clear];
    [CMPJSLocalStorageManager clear];
    //重新登录需要再次上传位置信息
    [AppDelegate shareAppDelegate].hasCalledUpdateOnlineLngLat = NO;
    [CMPCore sharedInstance].showingTopScreen = NO;//重置负一屏状态
    [[CMPMigrateWebDataViewController shareInstance] logoutWithResult:nil];
    [CMPMessageFilterManager freeFilter];
    [CMPAttachmentHelper free];
    _loginModeSubType = CMPLoginModeSubType_None;
    _loginInfoLegencyDic = nil;
}

- (void)showLoginViewControllerWithMessage:(NSString *)message {
    [self showLoginViewControllerWithMessage:message error:nil];
}

- (void)showLoginViewControllerWithMessage:(NSString *)message error:(NSError *)error {
    [self showLoginViewControllerWithMessage:message error:error username:nil password:nil];
}

- (void)showLoginViewControllerWithMessage:(NSString *)message
                                     error:(NSError *)error
                                  username:(NSString *)username
                                  password:(NSString *)password {
    [self showLoginViewControllerWithMessage:message error:error username:username password:password isAutoLogin:NO];
}

- (void)showLoginViewControllerWithMessage:(NSString *)message
                                     error:(NSError *)error
                                  username:(NSString *)username
                                  password:(NSString *)password
                               isAutoLogin:(BOOL) isAutoLogin {
    [[CMPCheckUpdateManager sharedManager] stopDownload];
    [CMPCore sharedInstance].jsessionId = nil;
    [[AppDelegate shareAppDelegate] clearViews:^{
        [CMPCore sharedInstance].remoteNotifiData = nil;
        [[CMPHomeAlertManager sharedInstance] removeAllTask];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserLogout object:nil];
        CMPLoginViewController *aLoginViewController = (CMPLoginViewController *)[M3LoginManager loginViewController];
        aLoginViewController.errorMessage = message;
        aLoginViewController.error = error;
        aLoginViewController.defaultUsername = username;
        aLoginViewController.defaultPassword = password;
        CMPNavigationController *aNav = [[CMPNavigationController alloc] initWithRootViewController:aLoginViewController];
        [AppDelegate shareAppDelegate].window.rootViewController = aNav;
        [CMPCore sharedInstance].showingTopScreen = NO;//重置负一屏状态
    }];
}

#pragma mark-
#pragma mark 离线登录

/**
 判断是否满足离线登录逻辑
 1. 服务器版本号大于1.8.0
 2. 服务器不可达
 3. 2.5.0之前判断cookie过期，2.5.0之后判断token过期
 4.3.5.0之后token为空,ssession不为空
 */
- (BOOL)_isOfflineLogin {
    BOOL result = NO;
    CMPCore *core = [CMPCore sharedInstance];
    if (core.serverIsLaterV1_8_0 &&
        ![CMPCommonManager reachableServer]) {
        if (core.serverIsLaterV2_5_0) {
            NSString *jsessionId = [CMPCookieTool JSESSIONIDForUrl:core.serverurl];
            if (![self _isTokenExpired] || ([NSString isNull:CMPCore.sharedInstance.token] && [NSString isNotNull:jsessionId])) {
                result = YES;
            }
        } else {
            if (![CMPCookieTool isCookieExpired]) {
                result = YES;
            }
        }
    }
    
    return result;
}

/**
 离线登录
 */
- (void)_offlineLoginSuccess:(CMPTokenLoginSuccess)success
                        fail:(CMPTokenLoginFail)fail {
    DDLogDebug(@"zl---离线登录-----");
    [CMPCore sharedInstance].loginSuccessTime = [NSDate date];
    // 检查应用包是否下载完成
    if (![[CMPCheckUpdateManager sharedManager] isDownloadAllApp]) {
        if (fail) {
            fail(nil);
            return;
        }
    }
    
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        NSString *token = [CMPCore sharedInstance].currentUser.extend6;
        [CMPCore sharedInstance].token = [GTMUtil decrypt:token];
        [self setupOther];
        _offlineLogin = YES;
        if (success) {
            success();
        }
    } else {
        if ([CMPCookieTool restoreCookies]) {
            [self setupOther];
            _offlineLogin = YES;
            if (success) {
                success();
            }
        } else {
            DDLogError(@"zl---restoreCookies失败");
            if (fail) {
                fail(nil);
            }
        }
    }
    
    [self _restoreJsessionId];
    [self _fetchServerInfoFromCloud];
}

/**
 离线登录，手机号登录，从云联更新服务器信息
 */
- (void)_fetchServerInfoFromCloud {
    DDLogDebug(@"zl---从云联更新服务器信息");
    CMPLoginAccountModel *loginAccount = [CMPCore sharedInstance].currentUser;
    CMPLoginAccountModelLoginType loginType = [loginAccount loginType];
    if (loginType == CMPLoginAccountModelLoginTypePhone) {
        self.cloudLoginHelper = [[CMPCloudLoginHelper alloc] init];
        NSString *corpID = [CMPCore sharedInstance].currentServer.extend3;
        NSString *phone = [GTMUtil decrypt:loginAccount.extend5];
        [self.cloudLoginHelper fetchServerInfoWithCorpID:corpID phone:phone];
    }
}

#pragma mark-
#pragma mark token登录

- (void)encryptTokenUpdate {
    BOOL flag = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultName_TokenEncryptFlag] boolValue];
    if (!flag) {
        [[CMPCore sharedInstance].loginDBProvider clearAllTokens];
        [CMPCore sharedInstance].token = nil;
        [CMPCore sharedInstance].currentUser.extend6 = nil;
        [CMPCore sharedInstance].currentUser.extend7 = nil;
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kUserDefaultName_TokenEncryptFlag];
    }
}

- (void)loginWithTokenStart:(void(^)(void))start success:(CMPTokenLoginSuccess)success
                         fail:(CMPTokenLoginFail)fail ext:(__nullable id)extParams {
    // V7.1版本token加密，处理低版本升级上来token没有加密问题，将所有token清空
    [self encryptTokenUpdate];
    
    // 离线登录
    if ([self _isOfflineLogin]) {
        CMPLoginAccountModelLoginType aType = self.currentAccount.loginType;
        if (aType == CMPLoginAccountModelLoginTypeMokey) {
            [self showLoginViewControllerWithMessage:nil];
            return;
        }
        [self _offlineLoginSuccess:success fail:fail];
        return;
    }
    
    // token过期，走原自动登录逻辑
    if ([self _isTokenExpired]) {
        NSLog(@"zl---[%s]Token过期", __FUNCTION__);
        if ([CMPCommonManager reachableServer]) {
            [self autoRequestLogin:start success:success fail:fail ext:extParams];
        } else {
            // 连接不上服务器，直接返回登录页
            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:SY_STRING(@"Common_Server_CannotConnect")];
        }
        return;
    }
    
    CMPLoginAccountModelLoginType aType = self.currentAccount.loginType;
    if (aType == CMPLoginAccountModelLoginTypeSMS && [CMPServerVersionUtils serverIsLaterV8_2_810]) {
        [self autoRequestLogin:start success:success fail:fail ext:extParams];
        return;
    }
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:self.currentAccount.serverID];
    if (vpnModel.vpnUrl.length && ![CMPVpnManager isVpnConnected]) {
        //vpn先登录
        [self cmp_showProgressHUDWithText:@"VPN登录中"];
        __weak typeof(self) wSelf = self;

        [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                        
                    } success:^(id obj, id ext) {
                        [wSelf cmp_hideProgressHUD];
                        [wSelf goMainPageWith:success];
                    } fail:^(id obj, id ext) {
                        [wSelf cmp_showHUDWithText:obj];
                    }];
    }else{
        [self goMainPageWith:success];
    }
}

// token没有过期，直接到首页，异步更新配置
- (void)goMainPageWith:(CMPTokenLoginSuccess)success{
    CMPCore *core = [CMPCore sharedInstance];
    NSString *token = core.currentUser.extend6;
    core.token = [GTMUtil decrypt:token];
    CMPLoginResponse *loginResponse = [CMPLoginResponse yy_modelWithJSON:core.currentUser.loginResult];
    core.passwordOvertime = loginResponse.data.config.passwordOvertime;
    core.passwordNotStrong = !loginResponse.data.config.passwordStrong;
    core.passwordChangeForce = loginResponse.data.config.passwordChangeForce;
    core.devBindingForce = loginResponse.data.config.devBindingForce;
    [self _restoreJsessionId];
    [self setupOther];
    
    AppDelegate *appDelegate = [AppDelegate shareAppDelegate];
    dispatch_group_enter(appDelegate.alertGroup);
    dispatch_group_t oldAlertGroup = appDelegate.alertGroup;
    NSLog(@"enter alertGroup 2 %p",appDelegate.alertGroup);
    
    if (success) {
        success();
    }
    [self retryAppAndConfig:^(NSDictionary *dic) {
        if (oldAlertGroup == appDelegate.alertGroup) {
            dispatch_group_leave(appDelegate.alertGroup);
            NSLog(@"leave alertGroup 2 %p-%p",oldAlertGroup,appDelegate.alertGroup);
        }
    }];
}

- (void)setTokenExpire {
    CMPLoginAccountModel *account = [[CMPCore sharedInstance].loginDBProvider inUsedAccountWithServerID:[CMPCore sharedInstance].serverID];
    //ks add -- 短信登录
    //ks fix -- V5-53858,8.2有短信token登录后 切换兼职单位 不清除token，不然自动登录不了
    BOOL del = YES;
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (self.loginType == CMPLoginAccountModelLoginTypeSMS) {
            del = NO;
        }
    }
    if (del) {
        [[CMPCore sharedInstance].loginDBProvider updateAccount:account token:account.extend6 expireTime:@""];
    }
    [CMPCore sharedInstance].currentUser = account;
}

- (NSDictionary *)appAndConfigSyncStatus {
    BOOL appListSyncDone = self.updateConfigHelper.appListSyncDone;
    BOOL configInfoSyncDone = self.updateConfigHelper.configInfoSyncDone;
    BOOL userInfoSyncDone = self.updateConfigHelper.userInfoSyncDone;
    NSDictionary *dic = @{@"appList": [NSNumber numberWithBool:appListSyncDone], @"configInfo": [NSNumber numberWithBool:configInfoSyncDone], @"userInfo": [NSNumber numberWithBool:userInfoSyncDone]};
    return dic;
}

- (void)clearRetryAppAndConfig{
    [self.updateConfigHelper allUpdateReLoad];
}

- (void)retryAppAndConfigFor8_0:(void (^)(NSDictionary *dic))doneBlock {
    DDLogDebug(@"zl---[%s]开始重试", __FUNCTION__);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    
    if (!self.updateConfigHelper.appListSyncDone) {
        [self.updateConfigHelper updateAppList:^(BOOL success) {
            dispatch_group_leave(group);
            DDLogDebug(@"zl---[%s]updateAppList完成：%d", __FUNCTION__, success);
        }];
    } else {
        dispatch_group_leave(group);
    }
    if (!self.updateConfigHelper.configInfoSyncDone) {
        [self.updateConfigHelper updateConfigInfo:^(BOOL success) {
            dispatch_group_leave(group);
            DDLogDebug(@"zl---[%s]updateConfigInfo完成：%d", __FUNCTION__, success);
        }];
    } else {
        dispatch_group_leave(group);
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSDictionary *dic = [self appAndConfigSyncStatus];
        DDLogDebug(@"zl---[%s]全部完成：%@", __FUNCTION__, dic);
        if (doneBlock) {
            doneBlock(dic);
        }
    });
}

- (void)retryAppAndConfig:(void (^)(NSDictionary *dic))doneBlock {
    DDLogDebug(@"zl---[%s]开始重试", __FUNCTION__);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    
    if (!self.updateConfigHelper.appListSyncDone) {
        [self.updateConfigHelper updateAppList:^(BOOL success) {
            dispatch_group_leave(group);
            DDLogDebug(@"zl---[%s]updateAppList完成：%d", __FUNCTION__, success);
        }];
    } else {
        dispatch_group_leave(group);
    }
    if (!self.updateConfigHelper.userInfoSyncDone) {
        [self.updateConfigHelper updateUserInfo:^(BOOL success) {
            dispatch_group_leave(group);
            DDLogDebug(@"zl---[%s]updateUserInfo完成：%d", __FUNCTION__, success);
        }];
    } else {
        dispatch_group_leave(group);
    }
    if (!self.updateConfigHelper.configInfoSyncDone) {
        [self.updateConfigHelper updateConfigInfo:^(BOOL success) {
            dispatch_group_leave(group);
            DDLogDebug(@"zl---[%s]updateConfigInfo完成：%d", __FUNCTION__, success);
        }];
    } else {
        dispatch_group_leave(group);
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSDictionary *dic = [self appAndConfigSyncStatus];
        DDLogDebug(@"zl---[%s]全部完成：%@", __FUNCTION__, dic);
        if (doneBlock) {
            doneBlock(dic);
        }
    });
}

- (void)refreshAppList:(void (^)(BOOL success))doneBlock {
    [self.updateConfigHelper updateAppList:^(BOOL success) {
        if (doneBlock) {
            doneBlock(success);
        }
        DDLogDebug(@"zl---[%s]refreshAppList完成：%d", __FUNCTION__, success);
    }];
}

- (BOOL)_isTokenExpired {
    BOOL result = NO;
    NSString *tokenExpiredTime = [CMPCore sharedInstance].currentUser.extend7;
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        tokenExpiredTime = [GTMUtil decrypt:tokenExpiredTime];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 1000;
        if (now > tokenExpiredTime.longLongValue) {
            result = YES;
        }
    }else{
        NSTimeInterval now = ([[NSDate date] timeIntervalSince1970] - 60 * 60 * 12) * 1000;
        if ([tokenExpiredTime longLongValue] < now) {
            result = YES;
        }
    }
    
    return result;
}

- (void)_restoreJsessionId {
    CMPLoginResponse *aLoginResponse = [CMPLoginResponse yy_modelWithJSON:[CMPCore sharedInstance].currentUser.loginResult];
    [CMPCore sharedInstance].jsessionId = aLoginResponse.data.ticket;
    [CMPCore sharedInstance].anewSessionAfterLogin = [CMPCore sharedInstance].jsessionId;
}

- (CMPLoginUpdateConfigHelper *)updateConfigHelper {
    if (!_updateConfigHelper) {
        _updateConfigHelper = [[CMPLoginUpdateConfigHelper alloc] init];
    }
    return _updateConfigHelper;
}

#pragma mark-
#pragma mark 手机盾模块判断是否使用弱手势和密码的提示
-(BOOL)mokey_login_relevantShow {
    // 如果为手机盾模块不进行展示验证弱手势和密码提示框
    BOOL mokey_showWeak; // YES是手机盾模块展示  NO不是
    CMPLoginAccountModelLoginType loginType = [CMPCore sharedInstance].currentUser.loginType;
    if (loginType == CMPLoginAccountModelLoginTypeMokey) {
        if (TrustdoLoginManager.sharedInstance.isHaveMokeyLoginPermission) {
             mokey_showWeak = YES;
        } else {
             mokey_showWeak = NO;
        }
    } else {
        mokey_showWeak = NO;
    }
    return mokey_showWeak;
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider
                     request:(CMPDataRequest *)aRequest {
    NSString *aRequestId = aRequest.requestID;
    if ([self.loginRequestID isEqualToString:aRequestId]) {
        if (self.requestLoginStart) {
            self.requestLoginStart();
        }
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSString *aRequestId = aRequest.requestID;
    if ([self.loginRequestID isEqualToString:aRequestId]) {
        if (aResponse.responseStatusCode != 200) {
            CMPBaseResponse *resp = [CMPBaseResponse yy_modelWithJSON:aResponse.responseStr];
            NSError *error = [NSError errorWithDomain:resp.message?:SY_STRING(@"login_fail") code:aResponse.responseStatusCode userInfo:@{NSLocalizedDescriptionKey:resp.message?:@"unknown reason",@"responseString":aResponse.responseStr?:@""}];
            [self handleLoginFail:error];
            return;
        }
        
        //ks fix 不要只判断code 200，还要判断下具体参数，不然网络被拦截修改，也直接进去了
        CMPLoginResponse *aLoginResponse = [CMPLoginResponse yy_modelWithJSON:aResponse.responseStr];
        if (!aLoginResponse.code) {
            NSError *error = [NSError errorWithDomain:aLoginResponse.message?:@"unknown reason" code:aResponse.responseStatusCode userInfo:@{NSLocalizedDescriptionKey:aLoginResponse.message?:@"unknown reason"}];
            [self handleLoginFail:error];
            return;
        }
        NSInteger insideCode = aLoginResponse.code.integerValue;
        if (insideCode != 200) {
            //V5-32729【ios】用户移动端未授权时，登录提示"登录失败"，需要提示"用户未授权"
            NSError *error = [NSError errorWithDomain:aLoginResponse.message?:@"unknown reason" code:insideCode userInfo:@{NSLocalizedDescriptionKey:aLoginResponse.message?:@"unknown reason",@"responseString":aResponse.responseStr?:@""}];//ks fix -- V5-35302 移动端登录，启动锁定保护，超过限制次数未弹出验证码 (后端有修改过状态码，所以都走200成功回调了)
            [self handleLoginFail:error];
            return;
        }
        //ks add -- 8.2 sp1 双因子
        if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
            NSString *aResponseStr = aResponse.responseStr;
            if (aResponseStr) {
                NSDictionary *respDic = [aResponseStr JSONValue];
                if (respDic && [respDic isKindOfClass:NSDictionary.class] && respDic[@"data"]) {
                    NSString *subType = [NSString stringWithFormat:@"%@",respDic[@"data"][@"isDoubleAuth"]];
                    if ([@"1" isEqualToString:subType]) {
                        
                        //双因子验证码登录记录一下第一次返回的jsessionid
                        NSDictionary *headers = aResponse.responseHeaders;
                        NSString *cookie = headers[@"Set-Cookie"];
                        if (cookie.length) {
                            self.jsession = cookie.copy;
                            NSString *aServerUrl = [CMPCore sharedInstance].serverurl;
                            [CMPCookieTool saveCookiesWithUrl:aServerUrl responseHeaders:headers];
                        }
                        
                        _loginModeSubType = CMPLoginModeSubType_MutilVerify;
                        if (_loginProcessBlk) {
                            NSString *phone = respDic[@"data"][@"telNumber"];
                            if (phone && [phone isKindOfClass:NSString.class] && phone.length) {
                                _loginProcessBlk(1,nil,phone);
                            } else {
                                _loginProcessBlk(0,[NSError errorWithDomain:@"telNumber is null" code:-1001 userInfo:nil],phone);
                            }
                            _loginProcessBlk = nil;
                            return;
                        }
                        //弥补
                        [self clearCurrentUserLoginPassword];
                        [self showLoginViewControllerWithMessage:nil];
                        return;
                    }
                }
            }
        }
        //end
        if (!aLoginResponse.data || !aLoginResponse.data.currentMember) {
            CMPBaseResponse *resp = [CMPBaseResponse yy_modelWithJSON:aResponse.responseStr];
            NSError *error = [NSError errorWithDomain:resp.message?:SY_STRING(@"login_fail") code:aResponse.responseStatusCode userInfo:@{NSLocalizedDescriptionKey:resp.message?:@"unknown reason"}];
            [self handleLoginFail:error];
            return;
        }

        [self handleLoginSuccess:aResponse];
        [self handleLoginToken:aResponse];
        [CMPMsgQuickHandler updateActWithIfHandled:NO];
        // 如果是V8.0获取applist、config异步
        if ([CMPCore sharedInstance].serverIsLaterV8_0 && self.isFromAutoLogin) {
            [self clearRetryAppAndConfig];
            AppDelegate *appDelegate = [AppDelegate shareAppDelegate];
            dispatch_group_enter(appDelegate.alertGroup);
            dispatch_group_t oldAlertGroup = appDelegate.alertGroup;
            NSLog(@"enter alertGroup 2 %p",appDelegate.alertGroup);
            [self retryAppAndConfigFor8_0:^(NSDictionary *dic) {
                if (oldAlertGroup == appDelegate.alertGroup) {
                    dispatch_group_leave(appDelegate.alertGroup);
                    NSLog(@"leave alertGroup 2 %p-%p",oldAlertGroup,appDelegate.alertGroup);
                }
            }];
            [self setupOther];
            if (self.requestLoginSuccess) {
                self.requestLoginSuccess();
            }
            return;
        }
        __weak __typeof(self)weakSelf = self;
        [self
         requestAppListAndConfigSuccess:^(NSString *applist, NSString *config, NSString *configH5Cache) {
            [weakSelf handleAppListAndLoginConfig];
        }
         fail:^(NSError *error) {
            [weakSelf handleLoginFail:error];
        }];
    }
    else if ([self.appListRequestID isEqualToString:aRequestId]) {
        [self hanldeRequestAppList:aResponse];
        [self handleAppListAndLoginConfigRequest];
    }
    else if ([self.configInfoRequestID isEqualToString:aRequestId]) {
        [self handleRequestConfigInfo:aResponse];
        [self handleAppListAndLoginConfigRequest];
    }
    else if ([self.logoutRequestID isEqualToString:aRequestId]) {
        NSLog(@"登出------");
    }
    else if ([@"login.verifyRemotePwd" isEqualToString:aRequestId]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
        if (!completionBlk) {
            return;
        }
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        if (responseObj) {
            NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
            if ([code isEqualToString:@"200"]) {
                id respData = responseObj[@"data"];
                completionBlk(respData,nil,responseObj);
            }else{
                NSString *msg = [NSString stringWithFormat:@"%@",responseObj[@"message"]];
                NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
                completionBlk(nil,err,responseObj);
            }
        }else{
            NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }
    else {
        NSLog(@"");
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithOriginalError:(NSError *)error errorMsg:(NSError *)erroeMsg {
    id requestParam = aRequest.requestParam;
    if ([requestParam isKindOfClass:NSString.class] && ![requestParam containsString:@"login.VerifyCode"]) {
        //保存sessionID
        NSDictionary *userInfo = error.userInfo;
        NSHTTPURLResponse *response = userInfo[@"com.alamofire.serialization.response.error.response"];
        NSDictionary *headers = response.allHeaderFields;
        NSString *cookie = headers[@"Set-Cookie"];
        if (cookie.length) {
            self.jsession = cookie.copy;
        }
    }
    
    NSString *aRequestId = aRequest.requestID;
    if ([self.loginRequestID isEqualToString:aRequestId]) {
        [self handleLoginFail:erroeMsg];
    }
    else if ([self.appListRequestID isEqualToString:aRequestId] ||
             [self.configInfoRequestID isEqualToString:aRequestId]) {
        if (_requestAppListAndConfigFail) {
            _requestAppListAndConfigFail(erroeMsg);
            _requestAppListAndConfigFail = nil;
        }
    }
    else if ([self.logoutRequestID isEqualToString:aRequestId]) {
    }
}

/**
 提示硬件绑定
 */
- (void)showBindTipAlert {
    CMPLoginAccountModelLoginType loginType = self.loginType;
    NSString *loginName = nil;
    NSString *phone = nil;
    if (loginType == CMPLoginAccountModelLoginTypePhone) {
        phone = self.phone;
    } else if (loginType == CMPLoginAccountModelLoginTypeLegacy) {
        loginName = self.loginName;
        if ([CMPFeatureSupportControl isUseNewLoginViewController]) {
            NSString *tempPhone = [GTMUtil decrypt:loginName];
            if (tempPhone.justContainsNumber && tempPhone.length >0 &&  CMPCore.sharedInstance.isShowPhoneLogin) {
                phone = self.loginName;//8.0手机号和用户名没分开，统一传给server
            }
        }
    } else if (loginType == CMPLoginAccountModelLoginTypeMokey) {
        loginName = self.loginName;
    }
    CMPServerModel *serverModel = CMPCore.sharedInstance.currentServer;
    [self showBindTipAlertWithUserName:loginName phone:phone serverUrl:serverModel.fullUrl serverVersion:CMP_SERVER_VERSION serverContextPath:serverModel.contextPath];
}

- (void)showBindTipAlertWithUserName:(NSString *)userName
                               phone:(NSString *)phone
                           serverUrl:(NSString *)serverUrl
                       serverVersion:(NSString *)serverVersion
                   serverContextPath:(NSString *)contextPath {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SY_STRING(@"login_bindtip") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:SY_STRING(@"commom_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            CMPDeviceBindRequest *request = [[CMPDeviceBindRequest alloc] initWithLoginName:userName phone:phone serverUrl:serverUrl serverVersion:serverVersion serverContextPath:contextPath];
            self.deviceBindProvider = [[CMPDeviceBindProvider alloc] init];
            [self.deviceBindProvider request:request
                                       start:nil
                                     success:^(CMPBaseResponse *response, NSDictionary *responseHeaders) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CMPDeviceBindResponse *model = (CMPDeviceBindResponse *)response;
                    [weakSelf cmp_showHUDWithText:model.data.resultMessage];
                });
            }
                                        fail:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf cmp_showHUDWithText:error.domain];
                });
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
    });
}

- (BOOL)needSetGesturePassword {
    if (self.currentAccount.gestureMode == CMPLoginAccountModelGestureUninit) {
        return YES;
    }
    return NO;
}

- (BOOL)hasSetGesturePassword {
    CMPLoginAccountModelGesture aGestureMode = self.currentAccount.gestureMode;
    NSString *aGesturePassword = self.currentAccount.gesturePassword;
    [[CMPMigrateWebDataViewController shareInstance] saveGestureState:aGestureMode];
    if ([self isAutoLogin] && aGestureMode == CMPLoginAccountModelGestureOpen && ![NSString isNull:aGesturePassword]) {
        return YES;
    }
    return NO;
}

- (NSString *)passwordWithPhone:(NSString *)phone {
    return [[CMPCore sharedInstance].loginDBProvider passwordWithPhone:phone];
}

/**
 保存登录过的手机号，明文
 */
+ (void)saveHistoryPhone:(NSString *)phone {
    [[EGOCache globalCache] setObject:phone forKey:kHistoryPhoneCacheKey];
}

/**
 获取上次登录的手机号，明文
 */
+ (NSString *)historyPhone {
    return (NSString *)[[EGOCache globalCache] objectForKey:kHistoryPhoneCacheKey];
}

+ (void)clearHistoryPhone {
    [[EGOCache globalCache] removeCacheForKey:kHistoryPhoneCacheKey];
}

#pragma mark-
#pragma mark 兼职单位

- (void)refreshPartTime {
    [_partTimeHelper refreshPartTimeList];
}

/// 跳转到登录vc  从editVC跳转
/// @param vc vc
- (CMPLocalAuthenticationState *)localAuthenticationState {
    if (!_localAuthenticationState) {
        _localAuthenticationState = [[CMPLocalAuthenticationState alloc] init];
    }
    return _localAuthenticationState;
}

/// 跳转到登录vc  从server list vc跳转
/// @param vc vc
+ (void)jumpToLoginVCWithVC:(UIViewController *)vc {
    [M3LoginManager jumpToLoginVCWithVC:vc selectedModel:nil];
}

+ (void)jumpToLoginVCWithVC:(UIViewController *)vc selectedModel:(CMPServerModel *)selectedModel {
    NSString *aServerID = selectedModel.serverID;
    if ([NSString isNull:aServerID]) {
        aServerID = kCMP_ServerID;
    }
    if ([CMPCore sharedInstance].isSupportSwitchLanguage) {
        [[SOLocalization sharedLocalization] switchRegionWithServerId:aServerID inSupportRegions:
         [SOLocalization loacalSupportRegions]];
    } else {
        [[SOLocalization sharedLocalization] switchRegionWithServerId:aServerID inSupportRegions:
         [SOLocalization lowerVersionLoacalSupportRegions]];
    }
    [[CMPThemeManager sharedManager] serverDidChange];
    if ([M3LoginManager isLoginViewController:vc.navigationController.viewControllers[0]]) {
        NSMutableArray *viewControllers = [NSMutableArray array];
        viewControllers = [vc.navigationController.viewControllers mutableCopy];
        viewControllers[0] = [M3LoginManager loginViewController];
        vc.navigationController.viewControllers = viewControllers;
        [vc.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [CMPCore sharedInstance].showingTopScreen = NO;
    CMPNavigationController *aNav = [[CMPNavigationController alloc] initWithRootViewController:[M3LoginManager loginViewController]];
    [AppDelegate shareAppDelegate].window.rootViewController = aNav;
}

+ (UIViewController *)loginViewController
{
    if (![CMPFeatureSupportControl isUseNewLoginViewController]) {
        return [[CMPLoginViewController alloc] init];
    }
    return [[CMPNewLoginViewController alloc] init];
}

+ (BOOL)isLoginViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[CMPLoginViewController class]] ||
         [controller isKindOfClass:[CMPNewLoginViewController class]]) {
        return YES;
    }
    return NO;
}

-(NSMutableDictionary *)loginInfoLegencyDic
{
    if (!_loginInfoLegencyDic) {
        _loginInfoLegencyDic = [[NSMutableDictionary alloc] init];
    }
    return _loginInfoLegencyDic;
}

- (void)clearCurrentUserLoginPassword
{
    NSString *serId = [CMPCore sharedInstance].currentServer.serverID;
    NSString *userId = [CMPCore sharedInstance].currentUser.userID;
    [[CMPCore sharedInstance].loginDBProvider clearLoginPasswordWithServerID:serId userId:userId];
}
@end
