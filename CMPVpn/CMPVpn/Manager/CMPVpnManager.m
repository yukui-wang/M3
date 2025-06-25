//
//  CMPVpnManager.m
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/11.
//

#import "CMPVpnManager.h"
#import "CMPVpnPwdModifyController.h"
#import <CMPLib/CMPConstant.h>
#if defined(__arm64__) && defined(USE_SANGFOR_VPN)

#import <SangforSDK/SFMobileSecuritySDK.h>
#import <SangforSDK/SFSecurityObject.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/KSLogManager.h>
#import <SangforSDK/SFUemSDK.h>
#import <CMPLib/CMPCore.h>

void(^cmpVpnManagerBlk)(NSInteger act,id ext);

@interface CMPVpnManager()<SFAuthResultDelegate,SFLogoutDelegate>
{
    BOOL _globelClose;
    NSString *_vpnLogPath;
    __block BOOL _isLoginFailed;
}
@property (nonatomic, copy) VpnCommonRsltBlk loginProcessBlock;
@property (nonatomic, copy) VpnCommonRsltBlk loginSuccessBlock;
@property (nonatomic, copy) VpnCommonRsltBlk loginFailedBlock;
@property (nonatomic, copy) VpnCommonRsltBlk logoutBlock;

@property (nonatomic,strong) CMPServerVpnModel *vpnConfigModel;
@property (nonatomic,strong) CMPServerVpnModel *preVpnConfigModel;

@property (nonatomic,strong) NSMutableArray *handleObjArr;
@property (nonatomic,weak) __block id subHandler;

@end

@implementation CMPVpnManager

+ (instancetype)sharedInstance{
    static CMPVpnManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPVpnManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {

        NSLog(@"ks log --- appprocess -- %s - start",__func__);
        
        _globelClose = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cmpconfig_vpn_globelclose"] boolValue];
        if (!_globelClose) {
            _vpnConfigModel = [[CMPServerVpnModel alloc] init];
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (cmpVpnManagerBlk) {
                cmpVpnManagerBlk(1,nil);
            }
                [SFMobileSecuritySDK enableDebugLog:YES];
                BOOL vpnsdkInitResult = [[SFUemSDK sharedInstance] initSDK:(SFSDKModeSupportMutable) flags:SFSDKFlagsHostApplication extra:nil];
                NSLog(@"ks log --- vpnsdkInitResult:%@",@(vpnsdkInitResult));

                [[SFUemSDK sharedInstance] setAuthResultDelegate:self];
                [[SFUemSDK sharedInstance] registerLogoutDelegate:self];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
                NSString *docPath = paths[0];
                _vpnLogPath = [docPath stringByAppendingPathComponent:@"sangforsdklogs.zip"];
                NSLog(@"vpnlogpath:%@",_vpnLogPath);
                
                [[KSLogManager shareManager] addObjLocalPath:_vpnLogPath newNameWithType:@"sangforsdklogs.zip"];
                
                [[KSLogManager shareManager] addActBeforeShareBlk:^{
                    [CMPVpnManager archieveLog:self->_vpnLogPath];
                }];
//            });
            
            
//            [self loginVpn];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_vpn_initend" object:nil];
            if (cmpVpnManagerBlk) {
                cmpVpnManagerBlk(2,nil);
            }
            
            cmpVpnManagerBlk = nil;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPwdCancel:) name:@"kNotificationName_vpnpwdcancel" object:nil];
        }
        NSLog(@"ks log --- appprocess -- %s - end",__func__);
    }
    return self;
}

-(BOOL)isGlobalClose
{
    return _globelClose;
}

-(CMPServerVpnModel *)vpnConfig
{
    return _vpnConfigModel;
}

- (void)loginVpn{
    NSString *vpnUrl = @"https://ztna.safeapp.com.cn:60201";
    NSString *vpnName = @"zy";
    NSString *vpnPwd = @"zhiyuan@123";
    
    CMPServerVpnModel *vpnConfig = [[CMPServerVpnModel alloc] init];
    vpnConfig.vpnUrl = vpnUrl;
    vpnConfig.vpnLoginName = vpnName;
    vpnConfig.vpnLoginPwd = vpnPwd;
    
    [self loginVpnWithConfig:vpnConfig process:^(id obj, id ext){
        
    } success:^(id obj, id ext) {
        
    } fail:^(id obj, id ext) {
        
    }];
}


- (void)loginVpnWithConfig:(CMPServerVpnModel *)config
                   process:(VpnCommonRsltBlk)processBlock
                   success:(VpnCommonRsltBlk)successBlock
                      fail:(VpnCommonRsltBlk)failedBlock
{
    NSLog(@"ks log --- appprocess -- %s \n%@_%@_%@",__func__,config.vpnUrl,config.vpnLoginName,config.vpnLoginPwd);
    
    if (_globelClose) {
        return;
    }
    if (!config || !config.vpnLoginPwd.length) {
        return;
    }
    _isLoginFailed = NO;
    [self setLanguage:CMPCore.languageCode];
    
    _vpnConfigModel  = [config yy_modelCopy];
    self.loginSuccessBlock = successBlock;
    self.loginFailedBlock = failedBlock;
    self.loginProcessBlock = processBlock;
    
    if (_vpnConfigModel.vpnSPA && _vpnConfigModel.vpnSPA.length) {
        NSDictionary *param = @{@"loginAddress":_vpnConfigModel.vpnUrl,
                                @"spaSecret":_vpnConfigModel.vpnSPA
        };
        [[SFUemSDK sharedInstance] setSPAConfig:[param JSONRepresentation] complete:^(NSString * _Nullable result, NSError * _Nullable error) {
            if (!error) {
                [[SFUemSDK sharedInstance] startPasswordAuth:[NSURL URLWithString:self->_vpnConfigModel.vpnUrl] userName:self->_vpnConfigModel.vpnLoginName password:self->_vpnConfigModel.vpnLoginPwd];
            }else{
                if (self.loginFailedBlock) {
                    NSString *message = error == nil ? result : [error localizedDescription];
                    self.loginFailedBlock(message, error);
                }
            }
        }];
    }else{
        [[SFUemSDK sharedInstance] startPasswordAuth:[NSURL URLWithString:_vpnConfigModel.vpnUrl] userName:_vpnConfigModel.vpnLoginName password:_vpnConfigModel.vpnLoginPwd];
    }
}


-(void)checkVpnConfig:(CMPServerVpnModel *)checkVpnConfig
         checkProcess:(VpnCheckRsltBlk)checkProcessBlock
         checkSuccess:(VpnCheckRsltBlk)checkSuccessBlock
            checkFail:(VpnCheckRsltBlk)checkFailedBlock
         needRollback:(CheckRollbackType)needRollback
      rollbackProcess:(VpnCommonRsltBlk)rollbackProcessBlock
      rollbackSuccess:(VpnCommonRsltBlk)rollbackSuccessBlock
         rollbackFail:(VpnCommonRsltBlk)rollbackFailedBlock
{
    NSLog(@"ks log --- appprocess -- %s \n%@_%@_%@",__func__,checkVpnConfig.vpnUrl,checkVpnConfig.vpnLoginName,checkVpnConfig.vpnLoginPwd);
    
    if (_globelClose) {
        return;
    }
    if (!checkVpnConfig || !checkVpnConfig.vpnLoginPwd.length) {
        return;
    }
    __weak typeof(self) wSelf = self;
    void(^aBlk)(void) = ^{
        [wSelf loginVpnWithConfig:checkVpnConfig process:^(id obj, id ext) {
            if (checkProcessBlock) {
                checkProcessBlock(obj,ext,self->_preVpnConfigModel);
            }
        } success:^(id obj, id ext) {
            BOOL finish = NO;
            if (checkSuccessBlock) {
                finish = checkSuccessBlock(obj,ext,self->_preVpnConfigModel);
            }
            if (finish && needRollback == CheckRollbackType_All) {
                [wSelf logoutVpnWithResult:^(id obj, id ext) {
                    [wSelf loginVpnWithConfig:self->_preVpnConfigModel process:rollbackProcessBlock success:rollbackSuccessBlock fail:rollbackFailedBlock];
                }];
            }
        } fail:^(id obj, id ext) {
            BOOL finish = NO;
            if (checkFailedBlock) {
                finish = checkFailedBlock(obj,ext,self->_preVpnConfigModel);
            }
            if (finish && needRollback) {
                [wSelf logoutVpnWithResult:^(id obj, id ext) {
                    [wSelf loginVpnWithConfig:self->_preVpnConfigModel process:rollbackProcessBlock success:rollbackSuccessBlock fail:rollbackFailedBlock];
                }];
            }
        }];
    };
    if (_vpnConfigModel && _vpnConfigModel.vpnLoginName /*&& [CMPVpnManager isVpnConnected]*/) {
        _preVpnConfigModel = [_vpnConfigModel yy_modelCopy];
        [self logoutVpnWithResult:^(id obj, id ext) {
            aBlk();
        }];
    }else{
        aBlk();
    }
}


- (void)logoutVpnWithResult:(VpnCommonRsltBlk)resultBlock{
    NSLog(@"ks log --- appprocess -- %s \n%@_%@_%@",__func__,_vpnConfigModel.vpnUrl,_vpnConfigModel.vpnLoginName,_vpnConfigModel.vpnLoginPwd);
    
    if (_globelClose) {
        return;
    }
    self.logoutBlock = resultBlock;
    [[SFUemSDK sharedInstance] logout];
}

- (SFAuthStatus)vpnStatus{
    if (_globelClose) {
        return 0;
    }
    SFAuthStatus status = [[SFUemSDK sharedInstance] getAuthStatus];
    return status;
}

+(BOOL)isVpnConnected{
//    if ([CMPVpnManager sharedInstance].globalClose) {
//        return NO;
//    }
//    SFAuthStatus status = [[SFMobileSecuritySDK sharedInstance] getAuthStatus];
//    return (status == SFAuthStatusAuthOk) || (status == SFAuthStatusPrimaryAuthOK);
    /**
      * 这里是自动免密认证接口，返回true表示认证成功，此时用户就可以进行资源访问了，
      * 如果返回false,表示当前不满足自动免密条件，需要用户主动调用用户名密码认证接口
      */
    return [[SFUemSDK sharedInstance] startAutoTicket];
}

+(void)openLog:(BOOL)open
{
//    if ([CMPVpnManager sharedInstance].globalClose) {
//        return;
//    }
    [SFMobileSecuritySDK enableDebugLog:open];
}

+(NSString *)archieveLog:(NSString *)logPath
{
//    if ([CMPVpnManager sharedInstance].globalClose) {
//        return @"";
//    }
    return [[SFMobileSecuritySDK sharedInstance] packLog:logPath];
}
-(NSMutableArray *)handleObjArr
{
    if (!_handleObjArr) {
        _handleObjArr = [[NSMutableArray alloc] init];
    }
    return _handleObjArr;
}
#pragma mark - SFAuthResultDelegate
/**
 认证失败
 @param msg 错误信息
 */
- (void)onAuthFailed:(BaseMessage *)msg
{
    NSLog(@"ks log --- appprocess -- %s",__func__);
    NSLog(@"AuthViewController onLoginFailed:%@", msg);
    _isLoginFailed = YES;
    BOOL needContinue = YES;
    if (_subHandler && [_subHandler respondsToSelector:NSSelectorFromString(@"onAuthFailed:")]) {
        needContinue = [_subHandler performSelector:NSSelectorFromString(@"onAuthFailed:") withObject:msg];
    }
    if (!needContinue) return;
    
    SFAuthType authType = SFAuthTypePassword;
    if(msg.errCode == SF_ERROR_CONNECT_VPN_FAILED && authType == SFAuthTypeToken) {
        NSLog(@"认证失败");
    } else {
        NSLog(@"认证失败:%@-code=%ld",msg.errStr,(long)msg.errCode);
    }
    
    if(self.loginFailedBlock){
        if(![msg.errStr containsString:@"vpn"] && ![msg.errStr containsString:@"VPN"]){
            msg.errStr = [NSString stringWithFormat:@"%@：%@",SY_STRING(@"vpn_connect_fail"),msg.errStr];
        }
        NSLog(@"vpn loginFailedBlock");
        self.loginFailedBlock(msg.errStr,msg);
        _loginFailedBlock = nil;
    }
    if (_loginProcessBlock) {
        NSLog(@"vpn loginProcessBlock set nil");
        _loginProcessBlock = nil;
    }
}
/**
 认证成功
 */
- (void)onAuthSuccess:(BaseMessage *)msg
{
    NSLog(@"ks log --- appprocess -- %s",__func__);
    NSLog(@"AuthViewController onLoginSuccess:%@",msg);
    _isLoginFailed = NO;
    BOOL needContinue = YES;
    if (_subHandler && [_subHandler respondsToSelector:NSSelectorFromString(@"onAuthSuccess:")]) {
        needContinue = [_subHandler performSelector:NSSelectorFromString(@"onAuthSuccess:") withObject:msg];
    }
    if (!needContinue) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_vpnLoginSuccess" object:msg];
    if(self.loginSuccessBlock){
        NSLog(@"vpn loginSuccessBlock");
        self.loginSuccessBlock(msg,nil);
        _loginSuccessBlock = nil;
    }
    if (_loginProcessBlock) {
        NSLog(@"vpn loginProcessBlock set nil");
        _loginProcessBlock = nil;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(1) forKey:@"udcmp_vpnopen"];
    /**
     注意：单个应用省略当前步骤
     如果是被子应用拉起，登录完成后，需要拉回子应用并传递session
     */
//    if (self.launchMsg) {
//        [self launchSubApp];
//    }
}

- (void)onAuthProcess:(SFAuthType)nextAuthType message:(nonnull SFBaseMessage *)message {
    NSLog(@"ks log --- appprocess -- %s",__func__);
    NSLog(@"AuthViewController onAuthProcess:%@ message:%@",@(nextAuthType),message);
    _isLoginFailed = NO;
    BOOL needContinue = YES;
    if (_subHandler && [_subHandler respondsToSelector:NSSelectorFromString(@"onAuthProcess:message:")]) {
        needContinue = [_subHandler performSelector:NSSelectorFromString(@"onAuthProcess:message:") withObject:@(nextAuthType) withObject:message];
    }
    if (!needContinue) return;
    
    NSDictionary *msg = @{@"errCode":@(message.errCode),@"errStr":message.errStr,@"serverInfo":message.serverInfo,@"authType":@(nextAuthType)};
    if (_loginProcessBlock) {
        BOOL needTip = NO;
        if (nextAuthType == SFAuthTypeRenewPassword2
            ||nextAuthType == SFAuthTypeRand) {
            needTip = YES;
        }
        NSLog(@"vpn loginProcessBlock");
        _loginProcessBlock(msg,@(needTip));
    }else if (nextAuthType == SFAuthTypeRenewPassword2
        ||nextAuthType == SFAuthTypeRand) {
        [CMPVpnManager showAlertTipWithError:@"无法连接VPN,请联系管理员检查后台设置"];
    }
    if (nextAuthType == SFAuthTypeRenewPassword) {
        _resetPwdRuleJson = ((SFResetPswMessage *)message).resetPswMsg;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVPNNotificationName_ProcessRenewPwd object:msg];
    }
}


#pragma mark - SFLogoutDelegate
- (void)onLogout:(SFLogoutType)type message:(nonnull BaseMessage *)msg
{
    NSLog(@"ks log --- appprocess -- %s",__func__);
    _isLoginFailed = NO;
    BOOL needContinue = YES;
    if (_subHandler && [_subHandler respondsToSelector:NSSelectorFromString(@"onLogout:message:")]) {
        needContinue = [_subHandler performSelector:NSSelectorFromString(@"onLogout:message:") withObject:@(type) withObject:msg];
    }
    if (!needContinue) return;
    
    if (self.logoutBlock) {
        NSLog(@"vpn logoutBlock");
        self.logoutBlock(msg,@(type));
        _logoutBlock = nil;
    }

//    [[SFMobileSecuritySDK sharedInstance] unRegisterLogoutDelegate:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *reason = @"";
        switch (type) {
            case SFLogoutTypeUser:
                reason = @"用户注销";
                break;
            case SFLogoutTypeTicketAuthError:
                reason = @"免密失败";
                break;
            case SFLogoutTypeServerShutdown:
                reason = @"服务端注销";
                break;
            case SFLogoutTypeAuthorError:
                reason = @"授权失败";
                break;
            default:
                reason = @"未知";
                break;
        }
        NSLog(@"注销原因 : %@ code:<%ld> desc<%@>", reason, msg.errCode, msg.errStr);
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_vpnLogout" object:@{@"errCode":@(msg.errCode),@"errStr":msg.errStr,@"serverInfo":msg.serverInfo}];
    [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:@"udcmp_vpnopen"];
}

-(void)resetPwdCancel:(NSNotification *)noti
{
    NSDictionary *msg = @{@"errCode":@(40053),@"errStr":@"vpn修改密码取消",@"serverInfo":@"vpn修改密码取消",@"authType":@(SFAuthTypeRenewPassword),@"status":@(100)};
    if (_loginProcessBlock) {
        NSLog(@"vpn loginProcessBlock");
        _loginProcessBlock(msg,@(NO));
    }
}


-(BOOL)updatePwd:(NSString *)newPwd
{
    if (_vpnConfigModel && newPwd && newPwd.length) {
        _vpnConfigModel.vpnLoginPwd = newPwd;
        return YES;
    }
    return NO;
}

-(VpnCommonRsltBlk)loginProcessBlock
{
    if (_loginProcessBlock) return _loginProcessBlock;
    return nil;
}

-(BOOL)setLanguage:(NSString *)language
{
    if (!language ||!language.length) return NO;
    BOOL suc = [[SFMobileSecuritySDK sharedInstance] setSDKOption:SFSDKOptionLanguage value:([language isEqualToString:@"en"]?@"en_US":language)];
    return suc;
}

-(void)showRenewPwdAlert
{
    if (_isLoginFailed) return;//V5-57546
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CMPVpnManager showSureAlertWithMessage:SY_STRING(@"vpn_modifypwd_firsttip") sureTitle:SY_STRING(@"vpn_modifypwd_gomodify") sureAction:^{
            CMPVpnPwdModifyController *ac = [[CMPVpnPwdModifyController alloc] init];
            self->_subHandler = ac;
            UIViewController *vc = [CMPVpnManager findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
            [vc presentViewController:ac animated:YES completion:^{
                    
            }];
        } cancelAction:^{
            [self resetPwdCancel:nil];
        }];
    });
    
}

#pragma mark - vpn db
+ (void)saveVpnWithServerId:(NSString *)serverID vpnUrl:(NSString *)vpnUrl vpnLoginName:(NSString *)vpnLoginName vpnLoginPwd:(NSString *)vpnLoginPwd vpnSPA:(NSString *)spa {
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    CMPServerVpnModel *vpnModel = CMPServerVpnModel.new;
    vpnModel.serverID = serverID;
    vpnModel.vpnUrl = vpnUrl;
    vpnModel.vpnLoginName = vpnLoginName;
    vpnModel.vpnLoginPwd = vpnLoginPwd;
    vpnModel.vpnSPA = spa ? : @"";
    BOOL flag = [loginDBProvider addVpnInfoWith:vpnModel];
    NSLog(@"saveVpnWithServerId flag = %d",flag);
}

+ (void)deleteVpnByServerID:(NSString *)serverID{
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    BOOL flag = [loginDBProvider deleteServerVpnWithServerID:serverID];
    NSLog(@"deleteVpnByServerID flag = %d",flag);
}

+ (CMPServerVpnModel *)getVpnModelByServerID:(NSString *)serverID{
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    CMPServerVpnModel *vpn = [loginDBProvider getVpnInfoByServerID:serverID];
    return vpn;
}

+ (void)showSureAlertWithMessage:(NSString *)message
                       sureTitle:(NSString *)sureTitle
                      sureAction:(void(^)(void))sureBlock
                      cancelAction:(void(^)(void))cancelBlock{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    [cancel setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:sureTitle?:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }];
    [ac addAction:cancel];
    [ac addAction:sure];
    
    UIViewController *vc = [self findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
    [vc presentViewController:ac animated:YES completion:^{
            
    }];
}

+ (void)showAlertTipWithError:(NSString *)errStr {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:errStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:cancel];
    
    UIViewController *vc = [self findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
    [vc presentViewController:ac animated:YES completion:^{
            
    }];
}

+ (void)showAlertWithError:(NSString *)errStr sureAction:(void(^)(void))sureBlock {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:errStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }];
    [ac addAction:cancel];
    [ac addAction:sure];
    
    UIViewController *vc = [self findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
    [vc presentViewController:ac animated:YES completion:^{
            
    }];
}

+ (void)showToastWithError:(NSString *)errStr sureAction:(void(^)(void))sureBlock {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:errStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }];
    [ac addAction:cancel];
    [ac addAction:sure];
    
    UIViewController *vc = [self findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
    [vc presentViewController:ac animated:YES completion:^{
            
    }];
}

+ (UIViewController*)findViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [self findViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self findViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self findViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

+(void)setManagerBlk:(void(^)(NSInteger,id))blk
{
    cmpVpnManagerBlk = blk;
}

@end






#else //非64位

@implementation CMPVpnManager
+ (instancetype)sharedInstance{
    static CMPVpnManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPVpnManager alloc] init];
    });
    return instance;
}

- (void)loginVpnWithConfig:(CMPServerVpnModel *)config
                   success:(VpnCommonRsltBlk)successBlock
                      fail:(VpnCommonRsltBlk)failedBlock{
    
}

- (void)logoutVpnWithResult:(VpnCommonRsltBlk)resultBlock{
    
}

+(void)saveVpnWithServerId:(NSString *)serverID vpnUrl:(NSString *)vpnUrl vpnLoginName:(NSString *)vpnLoginName vpnLoginPwd:(NSString *)vpnLoginPwd{
    
}
+(void)deleteVpnByServerID:(NSString *)serverID{
    
}
+(CMPServerVpnModel *)getVpnModelByServerID:(NSString *)serverID{
    return nil;
}

+(BOOL)isVpnConnected{
    return NO;
}

+ (void)showAlertTipWithError:(NSString *)errStr {
}

+ (void)showAlertWithError:(NSString *)errStr sureAction:(void(^)(void))sureBlock {
    
}

+(void)openLog:(BOOL)open
{
    
}

+(NSString *)archieveLog:(NSString *)logPath
{
    return @"";
}


-(BOOL)isGlobalClose
{
    return NO;
}

-(id)vpnConfig
{
    return nil;
}

+(void)setManagerBlk:(void(^)(NSInteger,id))blk
{
    
}

-(BOOL)setLanguage:(NSString *)language
{
    return NO;
}

-(BOOL)updatePwd:(NSString *)newPwd
{
    return NO;
}

-(void)showRenewPwdAlert
{
    [CMPVpnManager showSureAlertWithMessage:SY_STRING(@"vpn_modifypwd_firsttip") sureTitle:SY_STRING(@"vpn_modifypwd_gomodify") sureAction:^{
        CMPVpnPwdModifyController *ac = [[CMPVpnPwdModifyController alloc] init];
        UIViewController *vc = [CMPVpnManager findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
        [vc presentViewController:ac animated:YES completion:^{
                
        }];
    } cancelAction:^{
        
    }];
}


+ (void)showSureAlertWithMessage:(NSString *)message
                       sureTitle:(NSString *)sureTitle
                      sureAction:(void(^)(void))sureBlock
                      cancelAction:(void(^)(void))cancelBlock{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    [cancel setValue:[UIColor grayColor] forKey:@"_titleTextColor"];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:sureTitle?:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureBlock) {
            sureBlock();
        }
    }];
    [ac addAction:cancel];
    [ac addAction:sure];
    
    UIViewController *vc = [self findViewController:[[UIApplication sharedApplication]keyWindow].rootViewController];
    [vc presentViewController:ac animated:YES completion:^{
            
    }];
}

+ (UIViewController*)findViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [self findViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self findViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0) {
            return [self findViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}
- (void)loginVpnWithConfig:(CMPServerVpnModel *)config process:(__strong VpnCommonRsltBlk)processBlock success:(__strong VpnCommonRsltBlk)successBlock fail:(__strong VpnCommonRsltBlk)failedBlock {
}

+ (void)saveVpnWithServerId:(NSString *)serverID vpnUrl:(NSString *)vpnUrl vpnLoginName:(NSString *)vpnLoginName vpnLoginPwd:(NSString *)vpnLoginPwd vpnSPA:(NSString *)spa {
}

- (VpnCommonRsltBlk)loginProcessBlock {
    return nil;
}

- (void)checkVpnConfig:(CMPServerVpnModel *)checkVpnConfig checkProcess:(__strong VpnCheckRsltBlk)checkProcessBlock checkSuccess:(__strong VpnCheckRsltBlk)checkSuccessBlock checkFail:(__strong VpnCheckRsltBlk)checkFailedBlock needRollback:(CheckRollbackType)needRollback rollbackProcess:(__strong VpnCommonRsltBlk)rollbackProcessBlock rollbackSuccess:(__strong VpnCommonRsltBlk)rollbackSuccessBlock rollbackFail:(__strong VpnCommonRsltBlk)rollbackFailedBlock {
}


@end

#endif
