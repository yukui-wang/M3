//
//  CMPServerEditViewController.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerEditViewController.h"
#import "CMPServerEditView.h"
#import "CMPCheckEnvironmentModel.h"
#import "SyScanViewController.h"
#import "CMPMigrateWebDataViewController.h"
#import "AppDelegate.h"
#import "M3LoginManager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPServerManager.h"
#import "SyQRCodeController.h"
#import "CMPLanguageHelper.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPCheckEnvResponse.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPGlobleManager.h>

#import <CMPVpn/CMPVpn.h>

@interface CMPServerEditViewController ()<SyScanViewControllerDelegate>

@property (nonatomic, strong) CMPServerEditView *serverEditView;
/** 数据库 **/
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;
@property (strong, nonatomic) CMPServerManager *serverManager;

@property (strong, nonatomic) NSString *currentPort;
@property (strong, nonatomic) NSString *currentNote;

@property (nonatomic, strong) CMPVpnEnterView *vpnEnterView;

@end

@implementation CMPServerEditViewController

#pragma mark-
#pragma mark-Life circle

- (void)dealloc
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}

- (UIView *)loadingShowInView {
    return self.mainView;
}

- (void)backBarButtonAction:(id)sender {
    [self.serverManager cancel];
    if (_serverEditView.contentChanged || _vpnEnterView.contentChanged) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:@"未保存本次修改内容，是否返回" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [super backBarButtonAction:sender];
        }];
        UIAlertAction *cacel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:delete];
        [alert addAction:cacel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [super backBarButtonAction:sender];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allowRotation = NO;
    __weak typeof(self) weakself = self;
    _serverEditView = (CMPServerEditView *)self.mainView;
    // 判断当前是编辑还是新增
    if (self.mode == CMPServerEditViewControllerModeEdit) {
        [self setTitle:SY_STRING(@"login_server_list_edit")];
        _serverEditView.canDelete = YES;
        _serverEditView.deleteAction = ^ {
            [weakself deleteServer];
        };
        if (_oldServer.host) {
            _serverEditView.host = [NSString stringWithFormat:@"%@://%@", _oldServer.scheme, _oldServer.host];
        }
        _serverEditView.port = _oldServer.port;
        _serverEditView.note = _oldServer.note;
    }
    else {
        [self setTitle:SY_STRING(@"login_server_list_add")];
        [self addScanButton];
    }
    // 绑定保存与删除事件
    _serverEditView.saveAction = ^(NSString *host, NSString *port, NSString *note) {
        [weakself saveServerWithHost:host port:port note:note];
    };
#if defined(USE_SANGFOR_VPN)
    //vpn设置按钮
    _vpnEnterView = [[CMPVpnEnterView alloc]initWithFromViewController:self];
    [self.view addSubview:_vpnEnterView];
    //修改时vpn信息
    if (_oldServer.serverID.length) {
        CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:_oldServer.serverID];
        _vpnEnterView.vpnId = vpnModel.serverID;
        _vpnEnterView.vpnUrl = vpnModel.vpnUrl;
        _vpnEnterView.vpnLoginName = vpnModel.vpnLoginName;
        _vpnEnterView.vpnLoginPwd = vpnModel.vpnLoginPwd;
        [_vpnEnterView setVpnStatus:vpnModel?YES:NO];
    }
    [self.vpnEnterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-30);
        make.height.mas_equalTo(68);
    }];
#endif
    [_serverEditView registerContentChangedAction];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.serverManager cancel];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_serverEditView dismissKeybord]; // 点击空白处隐藏键盘
}

- (void)addScanButton {
    __weak __typeof(self)weakSelf = self;
    [_serverEditView showScanButtonWithAction:^{
        [weakSelf showScan];
    }];
}

- (void)showScan {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:^{
    }];
}

/**
 跳转到登陆页面
 */
- (void)jumpToLoginView {
    [M3LoginManager jumpToLoginVCWithVC:self];
}


- (void)saveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote
{
    aHost = [aHost stringByReplacingOccurrencesOfString:@" " withString:@""];
    aPort = [aPort stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!aHost.length) {
        [self showAlertMessage:SY_STRING(@"login_server_can_not_be_null")];
        return;
    }
    if (!aPort.length) {
        [self showAlertMessage:SY_STRING(@"login_port_can_not_be_null")];
        return;
    }
        
    [self saveServerWithHost:aHost port:aPort note:aNote fail:^(NSError *error) {
    }];
}

#pragma mark-按钮点击事件

/**
 点击保存按钮
 */
- (void)saveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote fail:(void(^)(NSError *))afail {
    _currentNote = aNote;
    _currentPort = aPort;
    
    //保存服务器前需要判断vpn是否能连接
    NSString *vpnUrl = self.vpnEnterView.vpnUrl;
    if (vpnUrl.length) {
//        if ([CMPVpnManager isVpnConnected]) {
            [[CMPVpnManager sharedInstance] logoutVpnWithResult:^(id obj, id ext) {
                                                
            }];
//        }
        NSString *vpnLoginName = self.vpnEnterView.vpnLoginName;
        NSString *vpnLoginPwd = self.vpnEnterView.vpnLoginPwd;
        [self showLoadingViewWithText:SY_STRING(@"vpn_connect_ing")];
        __weak __typeof(self) weakSelf = self;
        CMPServerVpnModel *vpnConfig = [[CMPServerVpnModel alloc] init];
        vpnConfig.vpnUrl = vpnUrl;
        vpnConfig.vpnLoginName = vpnLoginName;
        vpnConfig.vpnLoginPwd = vpnLoginPwd;
        NSString *spa = self.vpnEnterView.vpnSPA;
        vpnConfig.vpnSPA = spa;
        
        [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnConfig
                                                   process:^(id obj, id ext) {
            if (obj && [obj isKindOfClass:NSDictionary.class]) {
                BOOL needTip = [ext boolValue];
                if (needTip) {
                    [weakSelf hideLoadingView];
                    NSLog(@"vpn err:%@",obj[@"errStr"]);
                    [CMPVpnManager showAlertWithError:[NSString stringWithFormat:@"%@\n%@\n%@",SY_STRING(@"vpn_connect_nohand"),obj[@"errStr"],SY_STRING(@"vpn_connect_reset")] sureAction:^{
                        [weakSelf.vpnEnterView vpnBtnClick:nil];
                    }];
                }
                NSInteger authType = ((NSNumber *)obj[@"authType"]).integerValue;
                if (authType == 18) {
                    [weakSelf hideLoadingView];
                    if(obj[@"status"] && [obj[@"status"] isKindOfClass:NSNumber.class]){
                        NSInteger status = ((NSNumber *)obj[@"status"]).integerValue;
                        if (status == 200) {
                            //如果有修改密码 需要更新，存储数据库也是
                            weakSelf.vpnEnterView.vpnLoginPwd = CMPVpnManager.sharedInstance.vpnConfig.vpnLoginPwd;
                        }
                    }
                }
            }
                    } success:^(id obj, id ext) {
                        [weakSelf hideLoadingView];
                        [weakSelf showLoadingView];

                        [weakSelf.serverManager checkServerWithHost:aHost port:aPort success:^(CMPCheckEnvResponse *response, NSString *url) {
                            NSString *canUseVpn = response.data.productEdition.canUseVPN;
                            if (canUseVpn && [canUseVpn isEqualToString:@"1"]) {
                                [weakSelf handleCheckEnvResponse:response url:url];
                                //存vpn信息
                                [CMPVpnManager saveVpnWithServerId:response.data.identifier vpnUrl:vpnUrl vpnLoginName:vpnLoginName vpnLoginPwd:CMPVpnManager.sharedInstance.vpnConfig.vpnLoginPwd vpnSPA:spa];
                            }else{
                                [weakSelf hideLoadingView];
                                [CMPVpnManager showAlertWithError:@"当前服务不支持VPN插件，\n请重新配置" sureAction:^{
                                    [weakSelf.vpnEnterView vpnBtnClick:nil];
                                }];
                                [[CMPVpnManager sharedInstance] logoutVpnWithResult:nil];
                            }
                            
                         } fail:^(NSError *error) {
                             [weakSelf hideLoadingView];
                             [weakSelf showToastWithText:error.domain];
                             [[CMPVpnManager sharedInstance] logoutVpnWithResult:nil];
                            if (afail) {afail(error);}
                         }];
                    } fail:^(id obj, id ext) {
                        [weakSelf hideLoadingView];
                        NSLog(@"vpn err:%@",obj);
                        [CMPVpnManager showAlertWithError:[NSString stringWithFormat:@"%@\n%@\n%@",SY_STRING(@"vpn_connect_nohand"),obj,SY_STRING(@"vpn_connect_reset")] sureAction:^{
                            [weakSelf.vpnEnterView vpnBtnClick:nil];
                        }];
                    }];
    }else{
        [self showLoadingView];
//        if ([CMPVpnManager isVpnConnected]) {
            [[CMPVpnManager sharedInstance] logoutVpnWithResult:^(id obj, id ext) {
                                                
            }];
//        }
        __weak __typeof(self)weakSelf = self;
        [self.serverManager checkServerWithHost:aHost port:aPort success:^(CMPCheckEnvResponse *response, NSString *url) {
             [weakSelf handleCheckEnvResponse:response url:url];
            CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:response.data.identifier];
            if (vpnModel) {
                [CMPVpnManager deleteVpnByServerID:response.data.identifier];
            }
        } fail:^(NSError *error) {
            [weakSelf hideLoadingView];
            [weakSelf showToastWithText:error.domain];
            if (afail) {afail(error);}
        }];
    }
}

/**
 点击删除按钮
 */
- (void)deleteServer
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SY_STRING(@"common_confirm") message:SY_STRING(@"login_server_delete_message") preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakself = self;
    UIAlertAction *delete = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself deleteServer:weakself.oldServer];
        //删除对应的vpn信息
        [CMPVpnManager deleteVpnByServerID:weakself.oldServer.serverID];
        // 刷新一下内存缓存
        [[CMPCore sharedInstance] setup];
        [self jumpToLoginView];
    }];
    UIAlertAction *cacel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:delete];
    [alert addAction:cacel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteServer:(CMPServerModel *)server {
    NSArray *servers = [self.loginDBProvider findServersWithServerID:server.serverID];
    if (servers.count == 1) {
        [self.loginDBProvider deleteAssAccountAndServerForServerID:server.serverID];
    }
    
    [self.loginDBProvider deleteServerWithUniqueID:server.uniqueID];
}

// 处理检查更新后结果
- (void)handleCheckEnvResponse:(CMPCheckEnvResponse *)aModel url:(NSString *)aUrl
{
    // 根据请求的url地址判断是否安全连接
    NSString *aScheme = CMPHttpPrefix;
    BOOL isSafe = NO;
    if ([aUrl hasPrefix:CMPHttpsPrefix]) {
        aScheme = CMPHttpsPrefix;
        isSafe = YES;
    }
    
    NSString *identifier = aModel.data.identifier;
    if ([NSString isNull:identifier]) {
        [self hideLoadingView];
        [self showToastWithText:@"Server ID is Null"];
        return;
    }
    
    // 关联服务器与云联添加服务器不允许新增
    NSArray *aServerModelArr = [self.loginDBProvider findServersWithServerID:identifier];
    for (CMPServerModel *aServerModel in aServerModelArr) {
        if (![aServerModel isMainAssAccount]) {
            [self hideLoadingView];
            [self showToastWithText:SY_STRING(@"ass_add_err2")];
            return;
        }
//        if ([aServerModel isCloudServer]) {
//            [self hideLoadingView];
//            [self showToastWithText:SY_STRING(@"ass_add_err3")];
//            return;
//        }
    }
    
    // 设置给webview
    NSString *aHost = [NSURLComponents componentsWithString:aUrl].host;
    NSString *aPort = _currentPort;//_serverEditView.portView.text;
    NSString *aNote = _currentNote; //_serverEditView.noteView.text;
    NSString *aServerVersion = aModel.data.version;
   // NSString *aUpdateDic = [aModel.data.updateServer yy_modelToJSONObject];
    NSString *aUpdateStr = [aModel.data.updateServer yy_modelToJSONString];
 /* NSDictionary *h5CacheDic = @{@"ip" : aHost ?: @"",
                                 @"port": aPort ?: @"",
                                 @"model" : aScheme ?: @"",
                                 @"identifier" : identifier ?: @"",
                                 @"updateServer" : aUpdateDic ?: @"",
                                 @"serverVersion" : aServerVersion ?: @""};
    NSString *h5CacheStr = [h5CacheDic JSONRepresentation];
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:h5CacheStr];
*/
    // 保存到本地
    CMPServerModel *newModel = [[CMPServerModel alloc] initWithHost:aHost
                                                               port:aPort
                                                             isSafe:isSafe
                                                             scheme:aScheme
                                                               note:aNote
                                                             inUsed:YES
                                                           serverID:identifier
                                                      serverVersion:aServerVersion
                                                       updateServer:aUpdateStr];
    CMPServerModel *oldServer = [CMPCore.sharedInstance.loginDBProvider findServerWithUniqueID:newModel.uniqueID];
    newModel.extend10 = oldServer.extend10;
    
    [self.loginDBProvider addServerWithModel:newModel];
    if (self.mode == CMPServerEditViewControllerModeEdit && ![newModel.uniqueID isEqualToString:_oldServer.uniqueID]) {
        // 编辑模式下，修改了服务器地址，删除旧服务器地址
        [self deleteServer:_oldServer];
    }
    [self.loginDBProvider switchUsedServerWithUniqueID:newModel.uniqueID];
    [[CMPCore sharedInstance] setup];

    __weak __typeof(self)weakSelf = self;
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        [weakSelf hideLoadingView];
        [weakSelf jumpToLoginView];
    }];
}

#pragma mark-
#pragma mark SyScanViewControllerDelegate

- (void)scanViewController:(SyScanViewController *)scanViewController didScanFinishedWithResult:(ZXParsedResult *)aResult {
    if (aResult.type != kParsedResultTypeText) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NSDictionary *aJson = [aResult.displayResult JSONValue];
    if (!aJson || ![aJson isKindOfClass:[NSDictionary class]]) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSString *host = aJson[@"host"];
    NSString *port = aJson[@"port"];
    
    if ([NSString isNull:host] || [NSString isNull:port]) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    self.serverEditView.host = host;
    self.serverEditView.port = port;
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanViewControllerScanFailed:(SyScanViewController *)scanViewController {
    
}
- (void)scanViewControllerDidCanceled:(SyScanViewController *)scanViewController {
    
}


#pragma mark-Getter&Setter

- (CMPLoginDBProvider *)loginDBProvider {
    return [CMPCore sharedInstance].loginDBProvider;
}

- (CMPServerManager *)serverManager {
    if (!_serverManager) {
        _serverManager = [[CMPServerManager alloc] init];
    }
    return _serverManager;
}

@end
