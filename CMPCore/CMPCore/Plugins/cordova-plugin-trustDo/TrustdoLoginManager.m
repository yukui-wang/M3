//
//  TrustdoLoginManager.m
//  M3
//
//  Created by wangxinxu on 2019/2/19.
//

#import "TrustdoLoginManager.h"
#import "TrustdoGetEventData.h"
#import "TrustdoGetCertAndUrl.h"
#import "TrustdoNativeCall.h"
#define MokeyLoginEventData @"MokeyLoginEventData"
#define MokeyGetCertAndUrl @"MokeyGetCertAndUrl"
#define MokeyActivateSuccess @"MokeyActivateSuccess"
#define MokeyCertExpire @"MokeyCertExpire"

@interface TrustdoLoginManager ()
/** 手机盾请求证书 **/
@property (nonatomic, strong) NSString *mokeyServerCert;
/** 手机盾请求url **/
@property (nonatomic, strong) NSString *mokeyServerUrl;
/** 手机盾KeyId **/
@property (nonatomic, strong) NSString *keyIdStr;
/** 手机盾挑战数据 **/
@property (nonatomic, strong)NSString *eventDataStr;
/** 手机盾数据字典 **/
@property (nonatomic, strong)NSMutableDictionary *saveDataDic;
/** 手机盾操作类型 **/
@property (nonatomic, strong)NSString *mokeyType;
/** 手机盾登录用户 **/
@property (nonatomic, strong) NSString *loginName;

@end

@implementation TrustdoLoginManager

static TrustdoLoginManager *_instance;

+ (TrustdoLoginManager *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _saveDataDic = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMokeyEventDataNotification:)
                                                     name:MokeyLoginEventData
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMokeyCertAndUrlNotification:)
                                                     name:MokeyGetCertAndUrl
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMokeyActivateSuccessNotification:)
                                                     name:MokeyActivateSuccess
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMokeyCertExpireNotification:)
                                                     name:MokeyCertExpire
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    #if !__has_feature(objc_arc)
        [super dealloc];
    #endif
}

#pragma mark 通知
#pragma mark 获取挑战数据的通知
- (void)getMokeyEventDataNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    _eventDataStr = [NSString stringWithFormat:@"%@", [userInfoDic objectForKey:@"eventData"]];
    [_saveDataDic setObject:_eventDataStr forKey:@"eventData"];
    if (![_eventDataStr isEqualToString:@"(null)"]) {
        // 获取证书和地址
        [[TrustdoGetCertAndUrl sharedInstance] getMokeyCertAndUrl];
    }
}

#pragma mark 获取证书和地址的通知
- (void)getMokeyCertAndUrlNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    _mokeyServerCert = [NSString stringWithFormat:@"%@", [userInfoDic objectForKey:@"cert"]];
    _mokeyServerUrl = [NSString stringWithFormat:@"%@", [userInfoDic objectForKey:@"url"]];
    
    if (![_mokeyServerCert isEqualToString:@"(null)"] && ![_mokeyServerUrl isEqualToString:@"(null)"]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"Mokey_Save_CertAndUrl"];
        [userDefaults setObject:@{@"cert":_mokeyServerCert, @"url":_mokeyServerUrl} forKey:@"Mokey_Save_CertAndUrl"];
        [userDefaults synchronize];
        
        // type：0 激活 1登录 2 重置 3修改口令 4更新证书
        NSDictionary *dic = @{@"cert":_mokeyServerCert,@"url":_mokeyServerUrl,@"keyId":_keyIdStr,@"eventData":_eventDataStr,@"type":_mokeyType};
        [[TrustdoNativeCall sharedInstance] mokeyNativeCallWithDic:dic];
        
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                    message:SY_STRING(@"login_mokey_error_nocertorurl")
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark 获取激活成功的回调
#pragma mark 进行登录操作
-(void)getMokeyActivateSuccessNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    NSLog(@"%@", userInfoDic); // code = 0;
    [self getMokeyKeyIdWithLoginName:_loginName Style:@"1"];
}

#pragma mark 获取证书过期的回调
-(void)getMokeyCertExpireNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    NSLog(@"%@", userInfoDic); // code = 811035;
    [self getMokeyKeyIdWithLoginName:_loginName Style:@"4"];
}


#pragma mark-
#pragma mark-网络请求
#pragma mark-获取KeyId
- (void)getMokeyKeyIdWithLoginName:(NSString *)loginName Style:(NSString *)style
{
    _mokeyType = style;
    _loginName = loginName;
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [[CMPCore fullUrlForPath:kM3TrustdoKeyUrl] stringByAppendingString:loginName];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    
    if (strDic == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:SY_STRING(@"login_mokey_error_getkeyid")
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[strDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        NSString *errCode = dic[@"errCode"];
        if ([NSString isNull:errCode]) {
            NSString *errMsg = SY_STRING(@"login_cloud_error_default");
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:-1001], @"code", errMsg, @"message", nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kNotificationName_MokeySDKNotification
             object:dic];
            return;
        }
        
        if ([errCode intValue] != 200) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:SY_STRING(@"login_mokey_NoBind")
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
             id data = dic[@"data"];
            _keyIdStr = [NSString stringWithFormat:@"%@", [data objectForKey:@"keyId"]];
            [_saveDataDic setObject:_keyIdStr forKey:@"keyId"];
            NSString *actStatus = [data objectForKey:@"actStatus"];
            if ([actStatus isEqualToString:@"0"]) {
                //未激活状态
                // type：0 激活 1登录 2 重置 3修改口令 4更新证书
                _mokeyType = @"0";
                _eventDataStr = @"";
                [[TrustdoGetCertAndUrl sharedInstance] getMokeyCertAndUrl];
            } else {
                // 已激活
                if ([_keyIdStr isEqualToString:@"(null)"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:SY_STRING(@"login_mokey_NoKeyId")
                                                                       delegate:self
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else {
                    if ([_mokeyType isEqualToString:@"1"]) {
                        // 获取登录挑战数据
                        [[TrustdoGetEventData sharedInstance] getMokeyLoginEventData];
                    } else if ([_mokeyType isEqualToString:@"2"]) {
                        // 重置获取证书和地址
                        [[TrustdoGetCertAndUrl sharedInstance] getMokeyCertAndUrl];
                    } else if ([_mokeyType isEqualToString:@"4"]) {
                        // 获取更新证书的挑战数据
                        [[TrustdoGetEventData sharedInstance] getMokeyUpdateCertEventDataWithLoginName:_loginName];
                    }
                }
            }
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSString *errMsg = error.domain;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:-1001], @"code", errMsg, @"message", nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificationName_MokeySDKNotification
     object:dic];
}

#pragma mark 手机盾重置
- (void)doMokeyResetWithLoginName:(NSString *)loginName EventData:(NSString *)eventData Style:(NSString *)style {
    _mokeyType = style;
    _eventDataStr = eventData;
    [_saveDataDic setObject:_eventDataStr forKey:@"eventData"];
    [self getMokeyKeyIdWithLoginName:loginName Style:_mokeyType];
}

- (BOOL)isHaveMokeyLoginPermission {
    CMPServerModel *server = CMPCore.sharedInstance.currentServer;
    NSString *serverStr = [NSString stringWithFormat:@"%@", server.updateServer];
       
    if (serverStr != nil) {
       NSData *serverData = [serverStr dataUsingEncoding:NSUTF8StringEncoding];
       NSError *err;
       NSDictionary *serverDic = [NSJSONSerialization JSONObjectWithData:serverData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
       NSString *trustdoStatus = [serverDic objectForKey:@"trustdo"];
       // 增加手机盾模块
       if ([serverDic isKindOfClass:[NSDictionary class]] && [trustdoStatus isEqualToString:@"1"] && INTERFACE_IS_PHONE) {
           return YES;
       }
    }
    return NO;
}

@end
