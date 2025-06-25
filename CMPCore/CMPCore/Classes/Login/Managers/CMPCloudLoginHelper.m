//
//  CMPCloudLoginHelper.m
//  M3
//
//  Created by CRMO on 2018/9/10.
//

#import "CMPCloudLoginHelper.h"
#import "CMPCloudLoginProvider.h"
#import "CMPServerManager.h"
#import <CMPLib/GTMUtil.h>
#import <CMPLib/SvUDIDTools.h>
#import "M3LoginManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPMigrateWebDataViewController.h"
#import "CMPCheckUpdateManager.h"
#import <CMPLib/SOLocalization.h>

/** 云联网络错误 **/
NSInteger const CMPLoginErrorCloudUnreachable = 10001;
/** 云联业务错误 **/
NSInteger const CMPLoginErrorCloudException = 10002;
/** 未绑定手机号 **/
NSInteger const CMPLoginErrorPhoneUnknown = 10003;
/** 服务器信息错误 **/
NSInteger const CMPLoginErrorServerInfoException = 10003;
/** 登录错误 **/
NSInteger const CMPLoginErrorLoginException = 10004;
/** 登录错误 时提示挤下线错误**/
NSInteger const CMPLoginErrorLoginLogoutException = 10007;
/** 登录错误设备被绑定**/
NSInteger const CMPLoginErrorDeviceBindedException = -3005;

@interface CMPCloudLoginHelper()
@property (strong, nonatomic) CMPCloudLoginProvider *cloudLoginProvider;
@property (strong, nonatomic) NSMutableArray *serverManagers;
@property (copy, nonatomic) CloudLoginDidSuccess successBlock;
@property (copy, nonatomic) CloudLoginDidFail failBlock;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *verificationCode;
@property (copy, nonatomic) NSString *serverUrl;
@property (copy, nonatomic) NSString *corpID;
/* loginType新版登录新增，用于后台判断是哪个登录方式 */
@property (copy, nonatomic) NSString *loginType;
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;
@end

@implementation CMPCloudLoginHelper

#pragma mark-
#pragma mark Public

- (void)loginWithPhone:(NSString *)phone
              password:(NSString *)aPassword
      verificationCode:(NSString *)verificationCode
             loginType:(NSString *)loginType
               success:(CloudLoginDidSuccess)successBlock
                  fail:(CloudLoginDidFail)fail {
    [self p_loginWithPhone:phone password:aPassword verificationCode:verificationCode loginType:loginType success:successBlock fail:fail];
}

- (void)p_loginWithPhone:(NSString *)phone
              password:(NSString *)aPassword
      verificationCode:(NSString *)verificationCode
             loginType:(NSString *)loginType
               success:(CloudLoginDidSuccess)success
                  fail:(CloudLoginDidFail)fail {
    self.successBlock = success;
    self.failBlock = fail;
    self.phone = phone;
    self.password = aPassword;
    self.verificationCode = verificationCode;
    self.loginType = loginType;
    
    // 云联获取服务器列表
    NSString *time = _now();
    __weak __typeof(self)weakSelf = self;
    
    [self.cloudLoginProvider
     serverInfoWithMobile:phone
     time:time
     type:_type()
     success:^(CMPCloudLoginResponse *response) {
         if (!response.success) {
             NSInteger errorCode;
             NSString *errorDetail = SY_STRING(@"login_cloud_error_default");
             if (![NSString isNull:response.errorDetail]) {
                 errorDetail = response.errorDetail;
             }
             if (response.code == 2002 ||
                 response.code == 2003) {
                 errorCode = CMPLoginErrorPhoneUnknown;
             } else {
                 errorCode = CMPLoginErrorCloudException;
             }
             
             NSError *error = [NSError errorWithDomain:errorDetail code:errorCode userInfo:nil];
             if (fail) {
                 fail(error);
             }
             return;
         }
         [self dispatchAsyncToChild:^{
             // 按照顺序验证服务器
             [weakSelf _checkServers:response.data];
         }];
     }
     fail:^(NSError *error) {
         NSLog(@"zl---从云联获取数据失败：%@", error);
         NSError *aError = [NSError errorWithDomain:error.domain code:CMPLoginErrorCloudUnreachable userInfo:nil];
         if (fail) {
             fail(aError);
         }
     }];
}

- (void)fetchServerInfoWithCorpID:(NSString *)corpID phone:(NSString *)phone {
    NSLog(@"zl---[%s]开始从云联更新服务器信息", __FUNCTION__);
    NSString *time = _now();
    [self.cloudLoginProvider serverInfoWithMobile:phone
                                             time:time
                                             type:_type()
                                          success:^(CMPCloudLoginResponse *response)
    {
        if (!response.success) {
            return;
        }
        NSArray *servers = response.data;
        for (CMPCloudLoginResponseData *server in servers) {
            if ([server.corpid isEqualToString:corpID]) {
                NSString *serverAddr = server.addr_m3;
                self.corpID = corpID;
                NSLog(@"zl---[%s]从云联获取到服务器最新地址:%@", __FUNCTION__, serverAddr);
                __weak __typeof(self)weakSelf = self;
                CMPServerManager *serverManager = [[CMPServerManager alloc] init];
                [self.serverManagers addObject:serverManager];
                [serverManager
                 checkServerWithURL:serverAddr
                 success:^(CMPCheckEnvResponse *response, NSString *url) {
                     NSLog(@"zl---连接成功");
                     [weakSelf _handleCheckEnvResponse:response url:url];
                     [weakSelf.serverManagers removeObject:serverManager];
                 }
                 fail:^(NSError *error) {
                     NSLog(@"zl---连接失败：%@", error);
                     [weakSelf.serverManagers removeObject:serverManager];
                 }];
            }
        }
    } fail:^(NSError *error) {
        NSLog(@"zl---[%s],error:%@", __FUNCTION__, error);
    }];
}

#pragma mark-
#pragma mark Private

NSString* _now() {
    return [NSString stringWithInt:[[NSDate date] timeIntervalSince1970] * 1000];
}

NSString* _type() {
    return @"m3";
}

- (void)_checkServers:(NSArray *)servers {
    NSLog(@"zl---云联服务器列表：%@", servers);
    [servers enumerateObjectsUsingBlock:^(CMPCloudLoginResponseData *server, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"zl---开始尝试连接服务器：%@", server);
        NSString *serverCorpID = server.corpid;
        NSString *serverAddr = server.addr_m3;
        self.corpID = serverCorpID;
        if ([NSString isNull:serverCorpID] ||
            [NSString isNull:serverAddr]) {
            NSLog(@"zl---%s服务器地址或CorpID为空", __FUNCTION__);
            NSError *error = [NSError errorWithDomain:@"服务器地址或CorpID为空" code:CMPLoginErrorServerInfoException userInfo:nil];
            if (self.failBlock) {
                self.failBlock(error);
            }
            return;
        }
        
        // 云联返回多个M3服务器地址，逗号分隔
        NSArray *m3Addrs = [serverAddr componentsSeparatedByString:@","];
        // 一条记录返回多个地址时，同时连接所有服务器，第一个成功返回，所有失败提示失败
        __block BOOL isStop = NO;
        // 失败次数计数器，每次失败-1
        __block NSInteger failCount = m3Addrs.count;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (NSString *m3Addr in m3Addrs) {
            if (isStop) {
                break;
            }
            NSLog(@"zl---一条记录返回多个地址，开始连接%@", m3Addr);
            __weak __typeof(self)weakSelf = self;
            CMPServerManager *serverManager = [[CMPServerManager alloc] init];
            [self.serverManagers addObject:serverManager];
            
            [serverManager
             checkServerWithURL:m3Addr
             success:^(CMPCheckEnvResponse *response, NSString *url) {
                
                 // 如果已经成功了一个，其它的就不处理了
                 if (isStop) {
                     return;
                 }
                
                //如果和当前服务器id一样就不处理
                CMPCheckEnvResponseData *checkData = response.data;
                if ([checkData.identifier isEqualToString:CMPCore.sharedInstance.currentServer.serverID] && CMPCore.sharedInstance.serverIsLaterV8_0 ) {
                    failCount--;
                    if (idx == servers.count - 1 &&
                        failCount == 0) {
                        if (weakSelf.failBlock) {
                            NSError *error = [NSError errorWithDomain:@"unable to connect to server" code:10001 userInfo:nil];
                            weakSelf.failBlock(error);
                        }
                    }
                    dispatch_semaphore_signal(semaphore);
                    [weakSelf.serverManagers removeObject:serverManager];
                    
                    return;
                }
                
                 NSLog(@"zl---连接成功");
                 *stop = YES;
                 @synchronized (self) {
                     isStop = YES;
                 }
                 [weakSelf _handleCheckEnvResponse:response url:url];
                 [weakSelf _login];
                 dispatch_semaphore_signal(semaphore);
                 [weakSelf.serverManagers removeObject:serverManager];
             }
             fail:^(NSError *error) {
                 failCount--;
                 NSLog(@"zl---连接失败：%@", error);
                 if (idx == servers.count - 1 &&
                     failCount == 0) {
                     if (weakSelf.failBlock) {
                         weakSelf.failBlock(error);
                     }
                 }
                 dispatch_semaphore_signal(semaphore);
                 [weakSelf.serverManagers removeObject:serverManager];
             }];
        }
        for (int i = 0; i < m3Addrs.count; i++) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        NSLog(@"zl---一条记录返回多个地址，完成");
    }];
}

// 处理检查更新后结果
- (void)_handleCheckEnvResponse:(CMPCheckEnvResponse *)aModel url:(NSString *)aUrl {
    // 根据请求的url地址判断是否安全连接
    NSString *aScheme = CMPHttpPrefix;
    BOOL isSafe = NO;
    if ([aUrl hasPrefix:CMPHttpsPrefix]) {
        aScheme = CMPHttpsPrefix;
        isSafe = YES;
    }
    
    NSString *identifier = aModel.data.identifier;
    if ([NSString isNull:identifier]) {
        return;
    }
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:aUrl];
    // 兼容端口为80、443的情况
    if (!urlComponents.port) {
        if ([urlComponents.scheme isEqualToString:@"http"]) {
            urlComponents.port = @80;
        } else if ([urlComponents.scheme isEqualToString:@"https"]) {
            urlComponents.port = @443;
        }
    }
    NSString *aHost = urlComponents.host;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    NSString *aPort = urlComponents.port;
#pragma clang diagnostic pop
    NSString *aNote = @"";
    NSString *aServerVersion = aModel.data.version;
    NSString *aUpdateDic = [aModel.data.updateServer yy_modelToJSONObject];
    NSString *aUpdateStr = [aModel.data.updateServer yy_modelToJSONString];

    CMPServerModel *newModel = [[CMPServerModel alloc] initWithHost:aHost
                                                               port:aPort
                                                             isSafe:isSafe
                                                             scheme:aScheme
                                                               note:aNote
                                                             inUsed:YES
                                                           serverID:identifier
                                                      serverVersion:aServerVersion
                                                       updateServer:aUpdateStr];
    
    // 云联返回的服务器地址，根据url判断是否存在
    // 1. 如果不存在，新增一条记录
    // 2. 如果存在，覆盖这条记录
    CMPServerModel *oldServer = [self.loginDBProvider findServerWithUniqueID:newModel.uniqueID];
    if (oldServer) {
        newModel = oldServer;
    } else {
        newModel.extend1 = @"0";
    }
    newModel.extend3 = self.corpID;
    
    // 云联同步下来的服务，如果在关联服务器里存在serverID相同的服务器，该服务器也属于关联服务器
    NSArray *aServerModelArr = [self.loginDBProvider findServersWithServerID:identifier];
    BOOL isMainServer = NO;
    for (CMPServerModel *aServerModel in aServerModelArr) {
        if (![aServerModel isMainAssAccount]) {
            isMainServer = YES;
        }
    }
    if (isMainServer) {
        newModel.extend1 = @"1";
    }
    
    [self.loginDBProvider addServerWithModel:newModel];
    [self.loginDBProvider switchUsedServerWithUniqueID:newModel.uniqueID];
    
    // 设置给webview
  /*  NSDictionary *h5CacheDic = @{@"ip" : aHost,
                                 @"port": aPort,
                                 @"model" : aScheme,
                                 @"identifier" : identifier,
                                 @"updateServer" : aUpdateDic,
                                 @"serverVersion" : aServerVersion};
    NSString *h5CacheStr = [h5CacheDic JSONRepresentation];
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:h5CacheStr];
   */
    [[CMPCore sharedInstance] setup];
    
    if ([CMPCore sharedInstance].isSupportSwitchLanguage) {
        [[SOLocalization sharedLocalization] switchRegionWithServerId:newModel.serverID inSupportRegions:
         [SOLocalization loacalSupportRegions]];
    } else {
        [[SOLocalization sharedLocalization] switchRegionWithServerId:newModel.serverID inSupportRegions:
         [SOLocalization lowerVersionLoacalSupportRegions]];
    }
}

- (void)_login {
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        [[M3LoginManager sharedInstance]
         requestLoginWithUserName:self.phone
         password:self.password
         encrypted:NO
         refreshToken:NO
         verificationCode:self.verificationCode
         type:CMPLoginAccountModelLoginTypePhone
         loginType:self.loginType
         smsCode:nil
         externParams:nil
         isFromAutoLogin:NO
         start:nil
         success:^{
             if (self.successBlock) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.successBlock();
                 });
             }
         }
         fail:^(NSError *error) {
             if (self.failBlock) {
                 self.failBlock(error);
             }
         }];
    }];
}


#pragma mark-
#pragma mark Getter

- (NSMutableArray *)serverManager {
    if (!_serverManagers) {
        _serverManagers = [NSMutableArray array];
    }
    return _serverManagers;
}

- (CMPLoginDBProvider *)loginDBProvider {
    if (!_loginDBProvider) {
        _loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    }
    return _loginDBProvider;
}

- (CMPCloudLoginProvider *)cloudLoginProvider {
    if (!_cloudLoginProvider) {
        _cloudLoginProvider = [[CMPCloudLoginProvider alloc] init];
    }
    return _cloudLoginProvider;
}

@end
