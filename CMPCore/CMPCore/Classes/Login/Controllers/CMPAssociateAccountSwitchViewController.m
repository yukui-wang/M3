//
//  CMPAssociateAccountSwitchViewController.m
//  M3
//
//  Created by CRMO on 2018/6/19.
//

#import "CMPAssociateAccountSwitchViewController.h"
#import "CMPAssociateAccountSwitchView.h"
#import "CMPAssociateAccountSwitchCell.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/UIColor+Hex.h>
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import "CMPMigrateWebDataViewController.h"
#import "CMPCheckUpdateManager.h"
#import "CMPMessageManager.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPPartTimeHelper.h"
#import <CMPLib/CMPAppManager.h>
#import "CMPLocalAuthenticationState.h"
#import "CMPLoginConfigInfoModel.h"
#import "CMPServerManager.h"
#import <CMPLib/CMPDataProvider.h>
#import "CMPHomeAlertManager.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/Masonry.h>
#import "TrustdoLoginManager.h"
#import <CMPLib/GTMUtil.h>
#import <CMPVpn/CMPVpn.h>
#import "CMPMsgQuickHandler.h"
#import "CMPVerifyCodeViewController.h"
#import <CMPLib/CMPNavigationController.h>

@interface CMPAssociateAccountSwitchViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CMPAssociateAccountSwitchView *listView;
/** 关联企业列表 **/
@property (strong, nonatomic) NSMutableArray *assAccountList;
/** 兼职列表 **/
@property (strong, nonatomic) NSMutableArray *partTimeList;
@property (strong, nonatomic) CMPAssociateAccountModel *currentAssAccount;
@property (strong, nonatomic) CMPPartTimeModel *currentPartTime;
@property (strong, nonatomic) CMPServerManager *serverManager;
@property (strong, nonatomic) CMPPartTimeHelper *partTimeHelper;
@property (copy, nonatomic) NSString *mokeyLoginName;

@end

@implementation CMPAssociateAccountSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listView = (CMPAssociateAccountSwitchView *)self.mainView;
    _listView.tableView.delegate = self;
    _listView.tableView.dataSource = self;
    [self setTitle:SY_STRING(@"ass_switch_title")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    [self.partTimeList removeAllObjects];
    [self.assAccountList removeAllObjects];
    
    CMPLoginDBProvider *dbProvider = [CMPCore sharedInstance].loginDBProvider;
    NSString *serverID = [CMPCore sharedInstance].serverID;
    NSString *currentUserID = [CMPCore sharedInstance].userID;
    NSArray *assServers = [dbProvider assAcountListWithServerID:serverID userID:currentUserID];
    
    if (assServers.count > 0) {
        // 有关联账号本单位放到关联账号
        [self.assAccountList addObject:self.currentAssAccount];
    } else {
        // 没有关联账号本单位放到兼职
        [self.partTimeList addObject:self.currentPartTime];
    }
    
    [self.assAccountList addObjectsFromArray:assServers];
    
    NSArray *partTimes = [self.partTimeHelper partTimeList];
    [self.partTimeList addObjectsFromArray:partTimes];
    
    NSInteger sum = self.partTimeList.count + self.assAccountList.count;
    [self.listView showNothingView:sum == 0];
    [self.listView.tableView reloadData];
}

#pragma mark-
#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.assAccountList.count;
    } else {
        return self.partTimeList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.assAccountList.count > 0) {
            return 60;
        }
        return 49;
    } else {
        return 49;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CMPAssociateAccountSwitchCellIdentifier";
    CMPAssociateAccountSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPAssociateAccountSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell showBottomLine];
    
    if (indexPath.section == 0) {
        CMPAssociateAccountModel *assAcount = self.assAccountList[indexPath.row];
        if (assAcount == self.currentAssAccount) {
            cell.name = [self.partTimeHelper currentAccountShortName];
            cell.showCheck = YES;
        } else {
            cell.name = assAcount.loginAccount.extend1;
            cell.showCheck = NO;
        }
        cell.server = assAcount.server.fullUrl;
        if (assAcount == self.assAccountList.lastObject) {
            [cell hideBottomLine];
        }
    } else if (indexPath.section == 1) {
        CMPPartTimeModel *partTime = self.partTimeList[indexPath.row];
        cell.name = partTime.accountShortName;
        cell.showCheck = (partTime.accountID == [CMPCore sharedInstance].currentUser.accountID);
        if (partTime == self.partTimeList.lastObject) {
            [cell hideBottomLine];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.bannerNavigationBar.userInteractionEnabled = NO;
    
    if (indexPath.section == 0) {
        CMPAssociateAccountModel *assAccount = self.assAccountList[indexPath.row];
        if (assAccount == self.currentAssAccount) {
            self.bannerNavigationBar.userInteractionEnabled = YES;
            return;
        }
        [self showLoadingView];
        // 记录切换时间
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        self.currentAssAccount.switchTime = [NSNumber numberWithLongLong:time];
        [[CMPCore sharedInstance].loginDBProvider updateSwitchTimeWithAssAccount:self.currentAssAccount];
        [self switchAssAccount:assAccount];
    } else if (indexPath.section == 1) {
        CMPPartTimeModel *partTime = self.partTimeList[indexPath.row];
        if (partTime.accountID == [CMPCore sharedInstance].currentUser.accountID) {
            self.bannerNavigationBar.userInteractionEnabled = YES;
            return;
        }
        [[CMPHomeAlertManager sharedInstance] removeAllTask];
        [self showLoadingView];
        [self switchPartTime:partTime];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.assAccountList.count > 0) {
            return 32;
        }
        return 0;
    } else {
        if (self.partTimeList.count > 0) {
            return 32;
        }
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 300, 16)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(titleView).offset(14);
        make.top.equalTo(titleView).offset(12);
        make.size.equalTo(CGSizeMake(300, 16));
    }];

    if (section == 0) {
        if (self.assAccountList.count > 0) {
            titleLabel.text = SY_STRING(@"ass_switch_ass_title");
            return titleView;
        }
        return nil;
    } else {
        if (self.partTimeList.count > 0) {
            titleLabel.text = SY_STRING(@"ass_switch_parttime_title");
            return titleView;
        }
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark-
#pragma mark Private Method

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
            [weakself hideLoadingView];
            [weakself showLoadingView];
            self->_serverManager = [[CMPServerManager alloc] init];
            [self->_serverManager checkServerWithServerModel:assAccount.server success:^(CMPCheckEnvResponse *response, NSString *url) {
                NSString *canUseVpn = response.data.productEdition.canUseVPN;
                if (canUseVpn && [canUseVpn isEqualToString:@"1"]) {
                    [weakself hideLoadingView];
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
    if ([NSString isNull:password]) {
        //密码被清了，显示登陆页
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
        return;
    }
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
        [CMPCore sharedInstance].currentUser.loginPassword = password;
        [CMPCore sharedInstance].currentUser.userID = loginAccount.userID;
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
    //OA-20989
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    [loginDBProvider addServerIfServerIdChangeWithModel:server];

    [loginDBProvider switchUsedServerWithUniqueID:server.uniqueID];
    [[CMPCore sharedInstance] setup];
}

- (void)switchPartTime:(CMPPartTimeModel *)partTime {
    [self.partTimeHelper
     switchPartTime:partTime
     completion:^(CMPPartTimeModel *aPartTime, NSError *error) {
         if (error) {
             [self hideLoadingViewWithoutCount];
             self.bannerNavigationBar.userInteractionEnabled = YES;
             [self showAlertMessage:error.domain];
             return;
         }
         
         self.navigationController.viewControllers = @[self];
         [self rdv_tabBarController].viewControllers = nil;
         
         [[M3LoginManager sharedInstance]
          requestAppListAndConfigSuccess:^(NSString *applist, NSString *config, NSString *configH5Cache){
              NSString *aServerId = [CMPCore sharedInstance].serverID;
             CMPLoginAccountModel *preAccount = [[CMPCore sharedInstance].loginDBProvider inUsedAccountWithServerID:aServerId];
              CMPLoginAccountModel *aAccount = [[CMPCore sharedInstance].loginDBProvider inUsedAccountWithServerID:aServerId];
              // 将用户信息写入数据库
              aAccount.appList = applist;
              aAccount.configInfo = config;
              aAccount.accountID = aPartTime.accountID;
              aAccount.departmentID = aPartTime.departmentID;
              aAccount.postID = aPartTime.postID;
              aAccount.levelID = aPartTime.levelID;
              
              [[CMPCore sharedInstance].loginDBProvider addAccount:aAccount inUsed:YES];
              [[CMPCore sharedInstance] setup];
              
              [[M3LoginManager sharedInstance] savePrivilege];
              [[M3LoginManager sharedInstance] setupOther];
              [[CMPMigrateWebDataViewController shareInstance] updateAccountID:aAccount.accountID accountName:aPartTime.accountName shortName:aPartTime.accountShortName accountCode:aPartTime.accountCode configInfo:configH5Cache currentInfo:aPartTime preInfo:preAccount];
             
              // 更新服务器首页
              if ([CMPCore sharedInstance].serverIsLaterV7_1) {
                  CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:config];
                  NSString *defaultAppKey = newConfig.portal.indexAppKey;
                  [CMPTabBarViewController setHomeTabBar:defaultAppKey];
              }
              
//              [[CMPMigrateWebDataViewController shareInstance] saveConfigInfo:configH5Cache];
              [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
          }
          fail:^(NSError *error) {
              [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
          }];
     }];
}

#pragma mark-
#pragma mark Getter && Setter

- (NSMutableArray *)assAccountList {
    if (!_assAccountList) {
        _assAccountList = [NSMutableArray array];
    }
    return _assAccountList;
}

- (NSMutableArray *)partTimeList {
    if (!_partTimeList) {
        _partTimeList = [NSMutableArray array];
    }
    return _partTimeList;
}

- (CMPPartTimeHelper *)partTimeHelper {
    if (!_partTimeHelper) {
        _partTimeHelper = [M3LoginManager sharedInstance].partTimeHelper;
    }
    return _partTimeHelper;
}

- (CMPAssociateAccountModel *)currentAssAccount {
    if (!_currentAssAccount) {
        CMPCore *core = [CMPCore sharedInstance];
        _currentAssAccount = [[CMPAssociateAccountModel alloc] init];
        _currentAssAccount.serverID = core.serverID;
        _currentAssAccount.userID = core.userID;
        _currentAssAccount.serverUniqueID = core.currentServer.uniqueID;
        _currentAssAccount.server = core.currentServer;
        _currentAssAccount.loginAccount = core.currentUser;
    }
    return _currentAssAccount;
}

- (CMPPartTimeModel *)currentPartTime {
    if (!_currentPartTime) {
        CMPCore *core = [CMPCore sharedInstance];
        _currentPartTime = [[CMPPartTimeModel alloc] init];
        _currentPartTime.serverID = core.serverID;
        _currentPartTime.userID = core.userID;
        _currentPartTime.accountID = core.currentUser.accountID;
        _currentPartTime.accountName = core.currentUser.extend3;
        _currentPartTime.accountShortName = [self.partTimeHelper currentAccountShortName];
    }
    return _currentPartTime;
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


@end
