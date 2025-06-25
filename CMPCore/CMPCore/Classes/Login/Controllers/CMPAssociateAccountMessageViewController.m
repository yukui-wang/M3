//
//  CMPAssociateAccountMessageViewController.m
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import "CMPAssociateAccountMessageViewController.h"
#import "CMPAssociateAccountMessageView.h"
#import "CMPAssociateAccountMessageCell.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/UIColor+Hex.h>
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import "CMPMigrateWebDataViewController.h"
#import "CMPCheckUpdateManager.h"
#import "CMPMessageManager.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPAppManager.h>
#import "CMPLocalAuthenticationState.h"
#import "CMPServerManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/SOLocalization.h>
#import "TrustdoLoginManager.h"
#import <CMPLib/GTMUtil.h>
#import <CMPVpn/CMPVpn.h>
#import "CMPMsgQuickHandler.h"
#import "CMPVerifyCodeViewController.h"

@interface CMPAssociateAccountMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CMPAssociateAccountMessageView *listView;
/** 企业列表 **/
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) CMPAssociateAccountModel *currentServer;
@property (strong, nonatomic) CMPServerManager *serverManager;
@property (copy, nonatomic) NSString *mokeyLoginName;

@end

@implementation CMPAssociateAccountMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listView = (CMPAssociateAccountMessageView *)self.mainView;
    _listView.tableView.delegate = self;
    _listView.tableView.dataSource = self;
    [self setTitle:SY_STRING(@"msg_associate")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    [self.dataSource removeAllObjects];
    CMPCore *core = [CMPCore sharedInstance];
    CMPLoginDBProvider *dbProvider = core.loginDBProvider;
    NSString *serverUniqueID = core.serverID;
    NSString *currentUserID = core.userID;
    NSArray *assServers = [dbProvider assAcountListWithServerID:serverUniqueID userID:currentUserID];
    _currentServer = [[CMPAssociateAccountModel alloc] init];
    _currentServer.serverID = core.serverID;
    _currentServer.userID = core.userID;
    _currentServer.serverUniqueID = core.currentServer.uniqueID;
    _currentServer.server = core.currentServer;
    _currentServer.loginAccount = core.currentUser;
    [self.dataSource addObjectsFromArray:assServers];
    [self.listView showNothingView:self.dataSource.count == 0];
    [self.listView.tableView reloadData];
}

#pragma mark-
#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CMPAssociateAccountMessageCellIdentifier";
    CMPAssociateAccountMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPAssociateAccountMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CMPAssociateAccountModel *assAcount = self.dataSource[indexPath.row];
    cell.name = assAcount.loginAccount.extend1;
    cell.showUnread = (assAcount.unreadCount > 0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPAssociateAccountModel *assAccount = self.dataSource[indexPath.row];
    if (assAccount == _currentServer) {
        return;
    }
    
    [self showLoadingView];
    self.bannerNavigationBar.userInteractionEnabled = NO;
    
    // 记录切换时间
    long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    _currentServer.switchTime = [NSNumber numberWithLongLong:time];
    [[CMPCore sharedInstance].loginDBProvider updateSwitchTimeWithAssAccount:_currentServer];
    
    [self switchAssAccount:assAccount];
}

- (void)switchAssAccount:(CMPAssociateAccountModel *)assAccount {
    NSLog(@"__%s__%@",__func__,assAccount.server.host);
    __weak typeof(self) weakself = self;
    
    [CMPMsgQuickHandler shareInstance].enterRoute = 2;
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:assAccount.server.serverID];
    
    if (vpnModel && vpnModel.vpnUrl.length) {

        [self showLoadingViewWithText:SY_STRING(@"vpn_connect_ing")];
        
        [[CMPVpnManager sharedInstance] checkVpnConfig:vpnModel checkProcess:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
            return YES;
        } checkSuccess:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
            
            self->_serverManager = [[CMPServerManager alloc] init];
            [self->_serverManager checkServerWithServerModel:assAccount.server success:^(CMPCheckEnvResponse *response, NSString *url) {
                NSString *canUseVpn = response.data.productEdition.canUseVPN;
                if (canUseVpn && [canUseVpn isEqualToString:@"1"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserLogout object:nil];
                    [[CMPDataProvider sharedInstance] cancelAllRequestsWithCompleteBlock:^{
                        [AppDelegate shareAppDelegate].alertGroup = nil;
                    }];
                    weakself.navigationController.viewControllers = @[weakself];
                    [weakself rdv_tabBarController].viewControllers = nil;
                    CMPCheckEnvResponse *model = (CMPCheckEnvResponse *)response;
                    [[M3LoginManager sharedInstance] requestLogout];
                    [weakself saveServerInfoWithResponse:model server:assAccount.server];
                    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
                        if ([CMPCore sharedInstance].isSupportSwitchLanguage) {
                            [[SOLocalization sharedLocalization] switchRegionWithServerId:assAccount.serverID inSupportRegions:
                             [SOLocalization loacalSupportRegions]];
                        } else {
                            [[SOLocalization sharedLocalization] switchRegionWithServerId:assAccount.serverID inSupportRegions:
                             [SOLocalization lowerVersionLoacalSupportRegions]];
                        }
                        [[CMPThemeManager sharedManager] serverDidChange];
                        [weakself loginWithAssAccount:assAccount];
                    }];
                }else{
                    [weakself hideLoadingView];
                    [weakself showToastWithText:@"当前服务不支持VPN插件，请重新配置"];
                    [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
                }
                
            } fail:^(NSError *error) {
                [weakself hideLoadingViewWithoutCount];
                self.bannerNavigationBar.userInteractionEnabled = YES;
                [weakself showAlertMessage:error.domain];
                
                [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
            }];
            
            return YES;
        } checkFail:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
            [weakself hideLoadingView];
            [weakself showToastWithText:@"VPN地址无法连接"];
            return YES;
        } needRollback:CheckRollbackType_WhenFail rollbackProcess:nil rollbackSuccess:nil rollbackFail:nil];
    }else{
        _serverManager = [[CMPServerManager alloc] init];
        [_serverManager checkServerWithServerModel:assAccount.server success:^(CMPCheckEnvResponse *response, NSString *url) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserLogout object:nil];
            [[CMPDataProvider sharedInstance] cancelAllRequestsWithCompleteBlock:^{
                [AppDelegate shareAppDelegate].alertGroup = nil;
            }];
            weakself.navigationController.viewControllers = @[weakself];
            [weakself rdv_tabBarController].viewControllers = nil;
            CMPCheckEnvResponse *model = (CMPCheckEnvResponse *)response;
            [[M3LoginManager sharedInstance] requestLogout];
            [weakself saveServerInfoWithResponse:model server:assAccount.server];
            [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
                if ([CMPCore sharedInstance].isSupportSwitchLanguage) {
                    [[SOLocalization sharedLocalization] switchRegionWithServerId:assAccount.serverID inSupportRegions:
                     [SOLocalization loacalSupportRegions]];
                } else {
                    [[SOLocalization sharedLocalization] switchRegionWithServerId:assAccount.serverID inSupportRegions:
                     [SOLocalization lowerVersionLoacalSupportRegions]];
                }
                [[CMPThemeManager sharedManager] serverDidChange];
                [weakself loginWithAssAccount:assAccount];
            }];
        } fail:^(NSError *error) {
            [weakself hideLoadingViewWithoutCount];
            self.bannerNavigationBar.userInteractionEnabled = YES;
            [weakself showAlertMessage:error.domain];
        }];
    }
}

- (void)loginWithAssAccount:(CMPAssociateAccountModel *)assAccount {
    __weak typeof(self) weakself = self;
    CMPLoginAccountModel *loginAccount = assAccount.loginAccount;
    CMPLoginAccountModelLoginType type = loginAccount.loginType;
    NSString *loginName = @"";
    if (type == CMPLoginAccountModelLoginTypePhone) {
        loginName = loginAccount.extend5;
    } else {
        loginName = loginAccount.loginName;
    }
    if (type == CMPLoginAccountModelLoginTypeMokey) {
        [self mokeyLoginWithName:[GTMUtil decrypt:loginName]];
        return;
    }
    
    NSString *password = loginAccount.extend2;
    loginAccount.loginPassword = password;
    [[CMPCore sharedInstance].loginDBProvider addAccount:loginAccount inUsed:YES];
    [[CMPCore sharedInstance] setup];
    
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:[assAccount.server.h5CacheDic JSONRepresentation]];
    
    // 7.1新增功能
    // 判断面容、指纹解锁是否开启
    if ([M3LoginManager sharedInstance].localAuthenticationState.enableLoginTouchID ||
        [M3LoginManager sharedInstance].localAuthenticationState.enableLoginFaceID) {
        [[M3LoginManager sharedInstance] clearRetryAppAndConfig];
        [[AppDelegate shareAppDelegate] showLocalAuthViewWithExt:@{@"ignoreDoubleAuth":@"1"}];
        return;
    }
    
    // 判断是否需要验证手势密码
    NSString *aGesturePassword = loginAccount.gesturePassword;
    if (![NSString isNull:aGesturePassword]) {
        [[M3LoginManager sharedInstance] clearRetryAppAndConfig];
        [CMPCore sharedInstance].currentUser.loginPassword = loginAccount.extend2;
        [[AppDelegate shareAppDelegate] showGestureVerifyView:loginAccount ext:@{@"ignoreDoubleAuth":@"1"}];
        return;
    }
    
    //ks add -- 双因子登录 0926
    CMPLoginAccountExtraDataModel *extraDataModel = loginAccount.extraDataModel;
    if (extraDataModel.loginModeSubType == CMPLoginModeSubType_MutilVerify) {
        NSString *loginInfoStr = extraDataModel.loginInfoLegency ? : @"";
        NSDictionary *loginInfoDic = [loginInfoStr JSONValue];
        if (loginInfoDic) {
            loginName = loginInfoDic[@"username"] ? : @"";
            password = loginInfoDic[@"password"] ? : @"";
        }
        type = CMPLoginAccountModelLoginTypeLegacy;
    }
    [M3LoginManager sharedInstance].loginProcessBlk = ^(NSInteger step, NSError *error, id  _Nullable ext) {
        if (!error) {
            if (step == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CMPVerifyCodeViewController *vc = [[CMPVerifyCodeViewController alloc] initWithNumber:ext ext:@{@"loginName":loginName?:@"",@"encrypted":@"1"}];
                    __weak typeof(CMPVerifyCodeViewController *) wVc = vc;
                    vc.completion = ^(BOOL success, NSError * _Nonnull err, id  _Nonnull ext) {
                        if (success) {
                            [wVc dismissViewControllerAnimated:YES completion:^{
                                [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
                                    [weakself loginSucess:YES];
                                }];
                            }];
                        }else{
                            [wVc showToastWithText:err.domain];
                        }
                    };
                    vc.cancelBlk = ^BOOL(NSError * _Nullable err, id  _Nullable ext) {
                        [weakself loginFail:err];
                        return YES;
                    };
                    [[AppDelegate shareAppDelegate].window.rootViewController presentViewController:vc animated:YES completion:nil];
                });
            }
        }else{
            [weakself loginFail:error];
        }
    };
    //end
    
    [[M3LoginManager sharedInstance] requestLoginWithUserName:loginName password:password encrypted:YES refreshToken:YES verificationCode:nil type:type loginType:@"0" smsCode:nil externParams:loginAccount isFromAutoLogin:NO start:^{
        
    } success:^{
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            [weakself loginSucess:YES];
        }];
    } fail:^(NSError *error) {
        [weakself loginFail:error];
    }];
}

/**
 保存服务器信息到CMPServerInfo
 */
- (void)saveServerInfoWithResponse:(CMPCheckEnvResponse *)response server:(CMPServerModel *)server {
   /* NSString *identifier = response.data.identifier ? response.data.identifier : @"";
    NSDictionary *h5CacheDic = @{@"ip" : server.host,
                                 @"port": server.port,
                                 @"model" : server.scheme,
                                 @"identifier" : identifier,
                                 @"updateServer" : [response.data.updateServer yy_modelToJSONObject],
                                 @"serverVersion" : server.serverVersion};
    NSString *h5CacheStr = [h5CacheDic JSONRepresentation];
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:h5CacheStr];
    */
    [[CMPCore sharedInstance].loginDBProvider switchUsedServerWithUniqueID:server.uniqueID];
    [[CMPCore sharedInstance] setup];
}

#pragma mark-
#pragma mark Getter && Setter

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)mokeyLoginWithName:(NSString *)aLoginName {
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(getMokeyLoginSuccessNotification:)
                                                name:kNotificationName_MokeyLoginSuccess
                                              object:nil];
             
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMokeySDKNotification:)
                                                 name:kNotificationName_MokeySDKNotification
                                               object:nil];
    self.mokeyLoginName = aLoginName;
    [[TrustdoLoginManager sharedInstance] getMokeyKeyIdWithLoginName:aLoginName Style:@"1"];
}

- (void)getMokeyLoginSuccessNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    __weak typeof(self) weakself = self;
    [[M3LoginManager sharedInstance] requestMokeyLoginWithUserName:self.mokeyLoginName password:@"" encrypted:NO refreshToken:NO verificationCode:@"" type:CMPLoginAccountModelLoginTypeMokey accToken:userInfoDic[@"message"] start:^{
    } success:^{
        [weakself loginSucess:NO];
    } fail:^(NSError *error) {
        [weakself loginFail:error];
    }];
}
///手机盾SDK返回的数据回调
- (void)getMokeySDKNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    NSString *messageStr = userInfoDic[@"message"];
    [self showToastWithText:messageStr];
}

//手机盾不显示手势密码
- (void)loginSucess:(BOOL)showGesture {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [CMPAppManager resetAppsMap];
    [self hideLoadingViewWithoutCount];
    // 需要判断是否需要设置手势密码
    if (showGesture && [[M3LoginManager sharedInstance] needSetGesturePassword]) {
        [[AppDelegate shareAppDelegate] showSetGesturePwdView];
    } else {
        [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
        
    }
}

- (void)loginFail:(NSError *)error {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self hideLoadingViewWithoutCount];
    if ([[M3LoginManager sharedInstance] needDeviceBind:error]) {
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
        [[M3LoginManager sharedInstance] showBindTipAlert];
        return;
    }
    [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
}

@end
