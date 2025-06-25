//
//  CMPCore.m
//  CMPCore
//
//  Created by youlin guo on 14-10-28.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPCore.h"
#import "CMPLoginDBProvider.h"
#import "CMPDateHelper.h"
#import "CMPFontModel.h"
#import "CMPFontProvider.h"
#import "EGOCache.h"
#import "CMPH5ConfigModel.h"
#import "CMPCachedUrlParser.h"
#import "SOLocalization.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import <CMPLib/CMPURLUtils.h>
#import <CMPLib/CMPThemeManager.h>

#define kUserInfo_M3 @"kUserInfo_M3"
#define kM3CustomStartPage @"M3CustomStartPage"
#define kPushVibrationRemind @"kPushVibrationRemind"
#define kPushSoundRemind @"kPushSoundRemind"


#define kAppDownloadUrlPwd						@"0123456789ABCDEF"

NSString * const CMPCoreScreenMirroringIsOpenChangedNoti = @"CMPCoreScreenMirroringIsOpenChangedNoti";

NSString * const KURLPath_MobilePortal = @"mobile_portal";

@interface CMPCore ()
@property (nonatomic, strong) CMPH5ConfigModel *h5Config;
@end

@implementation CMPCore

@synthesize availableLanguageList = _availableLanguageList;
@synthesize languageRegion = _languageRegion;
@synthesize screenMirrorIsOpen = _screenMirrorIsOpen;


static CMPCore *_instance;

+ (CMPCore *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        _currentFont = [CMPFontModel fontModel];
        //[self databaseDidUpgradeToEncrypt];
        CMPServerModel *server = [self.loginDBProvider inUsedServer];
        self.allowRotation = [server.extend2 boolValue];
    }
    return self;
}

- (void)databaseDidUpgradeToEncrypt {
    _loginDBProvider = [[CMPLoginDBProvider alloc] init];
    [self setup];
}

- (void)setup
{
    // 1、初始化服务器信息
    self.currentServer = [_loginDBProvider inUsedServer];
    NSString *aServerId = self.currentServer.serverID;
    // 2、初始化用户信息
    CMPLoginAccountModel *aUser = [_loginDBProvider inUsedAccountWithServerID:aServerId];
    self.currentUser = aUser;
    [self updateMemberIconTime];
    //3.初始化文字字体大小设置
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",aServerId,aUser.userID,MinStandardFontKey];
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue];
    
    if (fontSize) {
        [self.currentFont setMinStandardFontSize:fontSize];
    }
    self.allowRotation = [self.currentServer.extend2 boolValue];
    [CMPCachedUrlParser clearCache];
    
    [CMPCore configLocalUiskin];
}

- (void)updateMemberIconTime
{
    // 初始化头像的时间戳
    self.memberIconTime = [[CMPDateHelper currentNumberDate] stringValue];
}

- (CMPLoginAccountModel *)currentUserFromDB
{
    [self setup];
    return self.currentUser;
}

- (NSString *)serverIdentifier
{
    if ([NSString isNull:self.serverID]) {
        return @"";
    }
    return self.serverID;
}

- (NSString *)serverID
{
    return self.currentServer.serverID;
}

- (NSString *)userID
{
    return self.currentUser.userID;
}

- (NSString *)userName
{
    return self.currentUser.name;
}

- (NSString *)accShortName {
    if (!_accShortName) {
        _accShortName = self.currentUser.extend1;
    }
    return _accShortName;
}

- (NSString *)serverVersion
{
    return self.currentServer.serverVersion;
}

- (NSString *)serverurl
{
    if (!self.currentServer.fullUrl) {
        return nil;
    }
    if ([CMPFeatureSupportControl isUrlPathContainsMobilePortal:self.serverVersion]) {
        return self.serverurlForMobilePortal;
    } else {
         return self.currentServer.fullUrl;
    }
}
+ (NSString *)serverContextPath {
    NSString *contextPath = [CMPCore sharedInstance].currentServer.contextPath;
    if ([NSString isNotNull:contextPath]) {
        return contextPath;
    }
    return KURLPath_Seeyon;
}
+ (NSString *)serverurlWithUrl:(NSString *)url
{
    return [self serverurlWithUrl:url serverVersion:self.sharedInstance.currentServer.serverVersion];
}

+ (NSString *)serverurlWithUrl:(NSString *)url serverVersion:(NSString *)serverVersion {
    if ([CMPFeatureSupportControl isUrlPathContainsMobilePortal:serverVersion]) {
        return [NSString stringWithFormat:@"%@/%@", url, KURLPath_MobilePortal];
    } else {
        return url;
    }
}

+ (NSString *)serverurlForMobilePortalWithUrl:(NSString *)url
{
    if ([NSString isNull:url]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", url, KURLPath_MobilePortal];
}

+ (NSString *)serverurlForSeeyonWithUrl:(NSString *)url
{
    if ([NSString isNull:url]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/seeyon", [self serverurlWithUrl:url]];
}

- (NSString *)serverurlForSeeyon
{
    NSString *seeyon = KURLPath_Seeyon;
    if (self.currentServer && [NSString isNotNull:self.currentServer.extend5]) {
        seeyon = self.currentServer.extend5;
    }
    return [self.serverurl stringByAppendingString:seeyon];
}

- (NSString *)serverurlForMobilePortal
{
    if (!self.currentServer.fullUrl) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", self.currentServer.fullUrl, KURLPath_MobilePortal];
}

//+ (NSString *)urlPathMapForPath:(NSString *)path {
//   return [self urlPathMapForPath:path serverVersion:self.sharedInstance.currentServer.serverVersion];
//}
//
//+ (NSString *)urlPathMapForPath:(NSString *)path serverVersion:(NSString *)serverVersion {
//    return [CMPURLUtils urlPathMatch:path serverVersion:serverVersion contextPath:KURLPath_Seeyon];
//}

+ (NSString *)fullUrlPathMapForPath:(NSString *)path {
    CMPServerModel *server = self.sharedInstance.currentServer;
    NSString *url =  [CMPURLUtils urlPathMatch:path serverVersion:server.serverVersion contextPath:server.contextPath];
    url = [[CMPCore sharedInstance].serverurl stringByAppendingString:url];
    return url;
}

+ (NSString *)fullUrlForPath:(NSString *)path {
    NSString *serverPath = [CMPCore sharedInstance].serverurlForSeeyon;
    return [serverPath stringByAppendingString:path];
}

+ (NSString *)fullUrlForPathFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list args;
    va_start(args, format);
    NSString *path = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [CMPCore fullUrlForPath:path];
}

- (NSString *)checkUpdateUrl
{
    NSDictionary *aDict = [self.currentServer.updateServer JSONValue];
    if ([aDict isKindOfClass:[NSDictionary class]]) {
        return [aDict objectForKey:@"url"];
    }
    return nil;
}

- (void)setCustomStartPageSetting:(NSString *)aStr
{
    if ([NSString isNull:aStr]) {
        aStr = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:aStr forKey:kM3CustomStartPage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)customStartPageSetting
{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:kM3CustomStartPage];
}

+ (NSString *)memberIconUrlWithId:(NSString *)aId
{
    // 如果是当前登录人员，需要每次都更新
    NSString *imageUrl = [NSString stringWithFormat:kMemberIconUrl_M3_Param,aId];
    imageUrl = [CMPCore fullUrlForPath:imageUrl];
//    NSString *aCurrentMemberId = [CMPCore sharedInstance].currentUser.userID;
//    if (aCurrentMemberId && [aId isEqualToString:aCurrentMemberId]) {
        imageUrl = [NSString stringWithFormat:@"%@&time=%@", imageUrl, [CMPCore sharedInstance].memberIconTime];
//    }
    return imageUrl;
}

+ (NSString *)rcGroupIconUrlWithGroupId:(NSString *)groupId
{
    NSString *imageUrl = [NSString stringWithFormat:kRCGroupIconUrl_M3_Param,groupId];
    imageUrl = [CMPCore fullUrlForPath:imageUrl];
    imageUrl = [NSString stringWithFormat:@"%@&time=%@", imageUrl, [CMPCore sharedInstance].memberIconTime];
    return imageUrl;
}

+ (NSString *)clinetVersion
{
    NSString *aClinetVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return aClinetVersion;
}

+ (NSString *)clinetBuildVersion
{
    NSString *aBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return aBuildVersion;
}

+ (NSString *)appDownloadUrlPwd
{
    return kAppDownloadUrlPwd;
}

//语言环境
+ (NSInteger)languageType
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    //    NSLog ( @"currentLanguage = %@" , currentLanguage);
    if ([currentLanguage isEqualToString:@"en"]) {
        // 英语
        return kLanguageType_En;
    }
    else if ([currentLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        // 繁体中文
        return kLanguageType_Zh_TW;
    }
    else if ([currentLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        // 简体中文
        return kLanguageType_Zh_C;
    }
    else {
        return kLanguageType_En;
    }
}

+ (NSString *)languageCode {
    NSString *currentLanguage;
    NSInteger languageType = [CMPCore languageType];
    switch (languageType) {
        case kLanguageType_En:
            currentLanguage = kLanguageCode_En;
            break;
        case kLanguageType_Zh_TW:
            currentLanguage = kLanguageCode_Zh_TW;
            break;
        case kLanguageType_Zh_C:
            currentLanguage = kLanguageCode_Zh_C;
            break;
        default:
            currentLanguage = kLanguageCode_En;
            break;
    }
    
    if ([self sharedInstance].isSupportSwitchLanguage) {
        SOLocalization *localization = [SOLocalization sharedLocalization];
        currentLanguage = [localization getServerLanguageKeyWithRegion:localization.region];
        currentLanguage = [currentLanguage replaceCharacter:@"_" withString:@"-"];
    }
    
    return currentLanguage;
}

//是否是中文语言环境 简体、繁体
+ (BOOL)language_ZhCN
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        // 繁体中文
        return YES;
    }
    else if ([currentLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        // 简体中文
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isLoginState
{
    NSLog(@"%s",__func__);
    if (![NSString isNull:[CMPCore sharedInstance].jsessionId]) {
        NSLog(@"session has value, ret true");
        return YES;
    };
    NSLog(@"session null, ret false");
    return NO;
}

+ (NSString *)oldServerVersion {
    NSString *serverInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kServerInfo_M3];
    NSDictionary *serverInfoDic = [serverInfo JSONValue];
    return serverInfoDic[@"serverVersion"] ?: @"";
}

- (BOOL)serverIsLaterV1_8_0 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV7_0;
}

- (BOOL)serverIsLaterV7_0_SP1 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV7_0_SP1;
}

- (BOOL)serverIsLaterV2_5_0 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV7_0_SP2;
}

- (BOOL)serverIsLaterV7_1 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV7_1;
}

- (BOOL)serverIsLaterV7_1_SP1 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV7_1_SP1;
}

- (BOOL)serverIsLaterV8_0 {
    return self.currentServer.serverVersionNumber >= CMPServerVersionV8_0;
}

- (BOOL)isSupportSwitchLanguage {
    NSDictionary *updateServerDic = [self.currentServer.updateServer JSONValue];
    NSString *i18n = updateServerDic[@"i18n"];
    if ([i18n isEqualToString:@"1"] || self.serverIsLaterV7_1_SP1) {
        return YES;
    }
    return NO;
}

-(BOOL)isByPopUpPrivacyProtocolPage {
    return NO;
//    if (!self.currentServer) {
//        return YES;
//    }
//    return self.currentServer.extradDataModel.isByPopUpPrivacyProtocolPage;
}

- (void)setStartReceiveTime:(NSString *)startReceiveTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *start = [dateFormatter dateFromString:startReceiveTime];
    if (!start) {
        _startReceiveTime = @"00:00:00";
        return;
    }
    _startReceiveTime = startReceiveTime;
}

- (void)setEndReceiveTime:(NSString *)endReceiveTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *start = [dateFormatter dateFromString:endReceiveTime];
    if (!start) {
        _endReceiveTime = @"23:59:00";
        return;
    }
    _endReceiveTime = endReceiveTime;
}

- (void)setPushConfig:(NSString *)pushConfig {
    if (!pushConfig) {
        return;
    }
    [_loginDBProvider updatePushConfig:pushConfig serverID:self.serverID userID:self.userID];
}

- (NSString *)ucConfig {
    return [_loginDBProvider ucConfigWithServerID:self.serverID userID:self.userID];
}

- (void)setUcConfig:(NSString *)ucConfig {
    if (!ucConfig) {
        return;
    }
    [_loginDBProvider updateUcConfig:ucConfig serverID:self.serverID userID:self.userID];
}

- (NSString *)pushConfig {
    return [_loginDBProvider pushConfigWithServerID:self.serverID userID:self.userID];
}

- (BOOL)inPushPeriod {
    return [CMPDateHelper isNowInPeriodWithStart:_startReceiveTime end:_endReceiveTime];
}

- (CMPH5ConfigModel *)h5Config {
    if (!_h5Config) {
        NSURL *configURL = [NSURL URLWithString:@"http://cmp/v1.0.0/cmp-native-config.json"];
        NSString *path = [CMPCachedUrlParser cachedPathWithUrl:configURL];
        NSError *error = nil;
        NSURL *pathURL = [NSURL URLWithString:path];
        NSString *json = [NSString stringWithContentsOfURL:pathURL encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            CMPH5ConfigModel *h5Config = [CMPH5ConfigModel yy_modelWithJSON:json];
            _h5Config = h5Config;
        }
    }
    return _h5Config;
}

- (NSArray *)availableLanguageList {
    if (!_availableLanguageList) {
        _availableLanguageList = [[NSArray alloc] init];
        NSArray *availableLanguageList = self.currentServer.extradDataModel.availableLanguageList;
        if (availableLanguageList) {
            _availableLanguageList = [availableLanguageList copy];
        }
    }
    return _availableLanguageList;
}

- (void)setAvailableLanguageList:(NSArray *)availableLanguageList {
    _availableLanguageList = availableLanguageList;
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.availableLanguageList = [availableLanguageList copy];
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

-(void)updateUiskin:(NSDictionary *)uiskin {
//    if (!uiskin || ![uiskin isKindOfClass:NSDictionary.class]) return;
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.uiSkin = uiskin;
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

+(void)configLocalUiskin {
    [CMPThemeManager sharedManager].uiSkin = nil;
    [CMPThemeManager sharedManager].skinThemeColor = nil;
    [CMPThemeManager sharedManager].brandColor2 = nil;
    [CMPThemeManager sharedManager].brandColor7 = nil;
    if ([CMPCore sharedInstance].currentServer) {
        CMPServerExtradDataModel *serverExtraModel = [CMPCore sharedInstance].currentServer.extradDataModel;
        if (serverExtraModel.uiSkin) {
            [CMPThemeManager sharedManager].uiSkin = serverExtraModel.uiSkin;
        }
    }
}

- (NSString *)languageRegion {
    NSString *languageRegion = self.currentServer.extradDataModel.languageRegion;
    if (languageRegion) {
        _languageRegion = [languageRegion copy];
    }else {
        NSArray<CMPServerModel *> *serverModels = [self.loginDBProvider findServersWithServerID:self.currentServer.serverID];
           __block NSString *anotherLanguageRegion = nil;
        if (serverModels.count > 1) {
               [serverModels enumerateObjectsUsingBlock:^(CMPServerModel * _Nonnull serverModel, NSUInteger idx, BOOL * _Nonnull stop) {
                   NSString *languageRegion = serverModel.extradDataModel.languageRegion;
                   if (![self.currentServer.uniqueID isEqualToString:serverModel.uniqueID] && [NSString isNotNull:languageRegion]) {
                       anotherLanguageRegion = languageRegion;
                       *stop = YES;
                   }
               }];
        }
        if (anotherLanguageRegion) {
            _languageRegion = [anotherLanguageRegion copy];
        } else {
            _languageRegion = nil;
        }
    }
    return _languageRegion;
}

- (void)setLanguageRegion:(NSString *)languageRegion {
     _languageRegion = [languageRegion copy];
     NSArray<CMPServerModel *> *serverModels = [self.loginDBProvider findServersWithServerID:self.currentServer.serverID];
     [serverModels enumerateObjectsUsingBlock:^(CMPServerModel * _Nonnull serverModel, NSUInteger idx, BOOL * _Nonnull stop) {
          CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:serverModel.extend10];
          serverExtradDataModel.languageRegion = [languageRegion copy];
          serverModel.extend10 = [serverExtradDataModel yy_modelToJSONString];
          [self.loginDBProvider updateServerWithUniqueID:serverModel.uniqueID extraDataString:serverModel.extend10];
     }];
    
}

- (BOOL)isShowPhoneLogin {
    return self.currentServer.extradDataModel.isShowPhoneLogin.boolValue;
}

/// 投屏组件按钮是否显示配置
/// @param screenMirrorIsOpen 是否显示
- (void)setScreenMirrorIsOpen:(BOOL)screenMirrorIsOpen {
    _screenMirrorIsOpen = screenMirrorIsOpen;
    
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.screenMirrorIsOpen = screenMirrorIsOpen;
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

- (BOOL)screenMirrorIsOpen {
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    return serverExtradDataModel.screenMirrorIsOpen;
}

/* 是否开启sms手机验证码登录 */
- (BOOL)canUseSMS {
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    return serverExtradDataModel.canUseSMS;
}

- (void)setCanUseSMS:(BOOL)canUseSMS {
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.canUseSMS = canUseSMS;
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

- (NSInteger)screenshotType{
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    if (!serverExtradDataModel) {//如果删除了服务器信息，则返回-1
        return -1;
    }
    return serverExtradDataModel.screenshotType;
}

- (void)setScreenshotType:(NSInteger)screenshotType{
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.screenshotType = screenshotType;
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

/* 致信服务是否可用 */
-(BOOL)isZhixinServerAvailable {
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    return serverExtradDataModel.isZhixinServerAvailable;
}

- (void)setIsZhixinServerAvailable:(BOOL)isZhixinServerAvailable {
    CMPServerExtradDataModel *serverExtradDataModel = [CMPServerExtradDataModel yy_modelWithJSON:self.currentServer.extend10];
    serverExtradDataModel.isZhixinServerAvailable = isZhixinServerAvailable;
    self.currentServer.extend10 = [serverExtradDataModel yy_modelToJSONString];
    [self.loginDBProvider updateServerWithUniqueID:self.currentServer.uniqueID extraDataString:self.currentServer.extend10];
}

//标记当前用户已弹出过隐私协议
- (void)tagCurrentUserPopUpPrivacyProtocolPage {
    CMPLoginDBProvider *loginDBProvider = self.loginDBProvider;
    CMPLoginAccountModel *loginAccountModel = self.currentUser;
    CMPLoginAccountExtraDataModel *extraDataModel = [CMPLoginAccountExtraDataModel yy_modelWithJSON:loginAccountModel.extend10];
    extraDataModel.isAlreadyShowPrivacyAgreement = YES;
    NSString *extraDataModelStr = [extraDataModel yy_modelToJSONString];
    loginAccountModel.extend10 = extraDataModelStr;
    [loginDBProvider updateAccount:loginAccountModel extend10:extraDataModelStr];
}

- (void)setNeedHandleUrlScheme:(BOOL)needHandleUrlScheme
{
    NSString *serid = [CMPCore sharedInstance].serverIdentifier;
    if (!serid) {
        return;
    }
//    NSString *mid = [CMPCore sharedInstance].userID;
//    if (!mid) return;
//    NSString *key = [@"kstag_newurlscheme_" stringByAppendingFormat:@"%@%@",serid,mid];
    NSString *key = [@"kstag_newurlscheme_" stringByAppendingFormat:@"%@",serid];
    [UserDefaults setObject:@(needHandleUrlScheme) forKey:key];
    [UserDefaults synchronize];
}

-(BOOL)needHandleUrlScheme
{
    NSString *serid = [CMPCore sharedInstance].serverIdentifier;
    if (!serid) {
        return NO;
    }
//    NSString *mid = [CMPCore sharedInstance].userID;
//    if (!mid) return NO;
//    NSString *key = [@"kstag_newurlscheme_" stringByAppendingFormat:@"%@%@",serid,mid];
    NSString *key = [@"kstag_newurlscheme_" stringByAppendingFormat:@"%@",serid];
    NSNumber *val = [UserDefaults objectForKey:key];
    if (val) {
        return val.boolValue;
    }
    return NO;
}

@end
