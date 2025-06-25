//
//  CMPServerEditViewController.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerEditController.h"
#import "CMPServerEditNewView.h"
#import "CMPCheckEnvironmentModel.h"
#import "SyScanViewController.h"
#import "CMPMigrateWebDataViewController.h"
#import "AppDelegate.h"
#import "M3LoginManager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPServerManager.h"
#import "SyQRCodeController.h"
#import "CMPLanguageHelper.h"
#import "CMPCheckEnvResponse.h"

#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/SOLocalization.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/Masonry.h>

#import <CMPVpn/CMPVpn.h>
static CGFloat const kViewMargin = 35.f;


@interface CMPServerEditController ()<SyScanViewControllerDelegate>

@property (nonatomic, strong) CMPServerEditNewView *serverEditView;
/** 数据库 **/
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;
@property (strong, nonatomic) CMPServerManager *serverManager;

@property (strong, nonatomic) NSString *currentPort;
@property (strong, nonatomic) NSString *currentNote;

/* 取消按钮 */
@property (weak, nonatomic) UIButton *cancelBtn;
/* 设置服务器地址 label */
@property (weak, nonatomic) UILabel *titleLabel;
/* 添加按钮 */
@property (weak, nonatomic) UIButton *addServerBtn;
/* 扫一扫 按钮 */
@property (weak, nonatomic) UIButton *scanBtn;

@property (nonatomic, strong) CMPVpnEnterView *vpnEnterView;

@end

@implementation CMPServerEditController

#pragma mark - Life circle

- (void)dealloc
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allowRotation = NO;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass: CMPServerEditNewView.class]) {
            [view removeFromSuperview];
        }
    }
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    __weak typeof(self) weakself = self;
    if (!_serverEditView) {
        _serverEditView = [CMPServerEditNewView.alloc initWithFrame:self.view.bounds];
        [self.view addSubview:_serverEditView];
    }
    
    // 判断当前是编辑还是新增
    if (self.mode == CMPServerEditControllerModeEdit) {
        [self setTitle:SY_STRING(@"login_first_login_edit_server")];
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
    }
    // 绑定保存与删除事件
    _serverEditView.saveAction = ^(NSString *host, NSString *port, NSString *note) {
        [weakself saveServerWithHost:host port:port note:note];
    };
    
    CMPNavigationController *nav = (CMPNavigationController *)self.navigationController;
    [nav updateEnablePanGesture:YES];
    [self configViews];
    
    [_serverEditView registerContentChangedAction];
}

- (void)configViews {
    //取消按钮
    NSString *cancelString = SY_STRING(@"common_cancel");
    CGFloat cancelBtnW = [cancelString sizeWithFontSize:[UIFont systemFontOfSize:16.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    UIButton *cancelBtn = [UIButton.alloc initWithFrame:CGRectMake(self.view.width - cancelBtnW - kViewMargin, 59.f, cancelBtnW, 22.f)];
    [cancelBtn setImage:[[UIImage imageNamed:@"login_view_back_btn_icon"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#92a4b5"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    NSString *titleString = SY_STRING(@"login_server_list_add");
    // 判断当前是编辑还是新增
    if (self.mode == CMPServerEditControllerModeEdit) {
        titleString = SY_STRING(@"login_first_login_edit_server");
    }
    CGFloat titleLabelW = [titleString sizeWithFontSize:[UIFont boldSystemFontOfSize:20.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    
    //设置服务器地址 label
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CMPRectMake(kViewMargin, 103.f, titleLabelW, 28.f)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    titleLabel.text = titleString;
    titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    //添加  按钮
    NSString *addServerBtnTitle = SY_STRING(@"login_scan_button");
    CGFloat addServerBtnW = [addServerBtnTitle sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 2.f;
    UIButton *addServerBtn = [UIButton.alloc initWithFrame:CMPRectMake(self.view.width - addServerBtnW - kViewMargin, 0, addServerBtnW, 20.f)];
    addServerBtn.cmp_centerY = titleLabel.cmp_centerY;
    [addServerBtn setTitle:addServerBtnTitle forState:UIControlStateNormal];
    [addServerBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    addServerBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [addServerBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addServerBtn];
    self.addServerBtn = addServerBtn;
    
    //扫一扫 按钮
    UIButton *scanBtn = [UIButton.alloc initWithFrame:CMPRectMake(0, 0, 16.f, 16.f)];
    scanBtn.cmp_x = CGRectGetMinX(addServerBtn.frame) - 18.f;
    scanBtn.cmp_centerY = titleLabel.cmp_centerY;
    [scanBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"login_view_scan_qrcode_blue_icon"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
    self.scanBtn = scanBtn;
    
    if ((addServerBtnW + titleLabelW) > (self.view.width - 2.f*kViewMargin - 26.f) && !CMP_IPAD_MODE) {
        titleLabel.numberOfLines = 0;
        titleLabel.cmp_width -= 10.f;
        titleLabel.cmp_height += 20.f;
    }
    
    _serverEditView.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.view.width, self.view.height - CGRectGetMaxY(titleLabel.frame));
#if defined(USE_SANGFOR_VPN)
    //vpn设置按钮
    _vpnEnterView = [[CMPVpnEnterView alloc]initWithFromViewController:self];
    [self.view addSubview:_vpnEnterView];
    //修改时vpn信息
    if (_oldServer.serverID.length) {
        CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:_oldServer.serverID];
        if (vpnModel) {
            _vpnEnterView.vpnId = vpnModel.serverID;
            _vpnEnterView.vpnUrl = vpnModel.vpnUrl;
            _vpnEnterView.vpnLoginName = vpnModel.vpnLoginName;
            _vpnEnterView.vpnLoginPwd = vpnModel.vpnLoginPwd;
            _vpnEnterView.vpnSPA = vpnModel.vpnSPA;
            [_vpnEnterView setVpnStatus:vpnModel?YES:NO];
        }
    }
#endif
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    //添加  按钮
    NSString *addServerBtnTitle = SY_STRING(@"login_scan_button");
    CGFloat addServerBtnW = [addServerBtnTitle sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 2.f;
    NSString *titleString = SY_STRING(@"login_server_list_add");
    // 判断当前是编辑还是新增
    if (self.mode == CMPServerEditControllerModeEdit) {
        titleString = SY_STRING(@"login_first_login_edit_server");
    }
    CGFloat titleLabelW = [titleString sizeWithFontSize:[UIFont boldSystemFontOfSize:20.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(103.f);
        
        make.left.mas_equalTo(kViewMargin);
        if ((addServerBtnW + titleLabelW) > (self.view.width - 2.f*kViewMargin - 26.f) && !CMP_IPAD_MODE) {
            make.width.mas_equalTo(titleLabelW - 10.f);
            make.height.mas_equalTo(50.f);
        }
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kViewMargin);
        make.top.mas_equalTo(56.f);
    }];
    
    
    [self.addServerBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-kViewMargin);
    }];
    
    
    
    [self.scanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.addServerBtn);
        make.right.mas_equalTo(self.addServerBtn.mas_left).inset(4.f);
    }];
    
    [self.serverEditView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.vpnEnterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-30);
        make.height.mas_equalTo(68);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.host) {
        self.serverEditView.host = self.host;
    }
    if (self.host) {
        self.serverEditView.port = self.port;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.serverManager cancel];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_serverEditView dismissKeybord]; // 点击空白处隐藏键盘
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

#pragma mark - 按钮点击事件
/// 取消按钮 点击方法
- (void)cancelBtnClicked {
    [_serverManager cancel];
    if (_serverEditView.contentChanged || _vpnEnterView.contentChanged) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:@"未保存本次修改内容，是否返回" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakself = self;
        UIAlertAction *delete = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cacel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:delete];
        [alert addAction:cacel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/// 扫码按钮 点击方法
- (void)scanBtnClicked {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:^{
        
    }];
}

- (void)autoSaveServerWithHost:(NSString *)aHost port:(NSString *)aPort note:(NSString *)aNote fail:(void(^)(NSError *))fail
{
    if (!_serverEditView) {
        _serverEditView = [CMPServerEditNewView.alloc initWithFrame:self.view.bounds];
        [self.view addSubview:_serverEditView];
    }
    _serverEditView.hostView.text = aHost;
    _serverEditView.portView.text = aPort;
    _serverEditView.noteView.text = aNote;
    
    [self saveServerWithHost:aHost port:aPort note:aNote fail:fail];
}

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
        __weak __typeof(self)weakSelf = self;
        
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
        
    }else{ //没有vpn的保存逻辑
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
    }
    
    // 设置给webview
    NSString *aHost = [NSURLComponents componentsWithString:aUrl].host;
    NSString *aPort = _currentPort;
    NSString *aNote = _currentNote; 
    NSString *aServerVersion = aModel.data.version;
    NSString *aUpdateStr = [aModel.data.updateServer yy_modelToJSONString];
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
    
    [self.loginDBProvider addServerWithModel:newModel];
    

    if (self.mode == CMPServerEditControllerModeEdit && ![newModel.uniqueID isEqualToString:_oldServer.uniqueID]) {
        // 编辑模式下，修改了服务器地址，删除旧服务器地址
        [self deleteServer:_oldServer];
    }
    [self.loginDBProvider switchUsedServerWithUniqueID:newModel.uniqueID];
    [[CMPCore sharedInstance] setup];
    
    // 设置服务器信息到H5缓存Local Storage
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:newModel.h5CacheDic.JSONRepresentation];

    __weak __typeof(self)weakSelf = self;
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        [weakSelf hideLoadingView];
        [weakSelf jumpToLoginView];
    }];
}


#pragma mark - SyScanViewControllerDelegate

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


#pragma mark - Getter&Setter

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
