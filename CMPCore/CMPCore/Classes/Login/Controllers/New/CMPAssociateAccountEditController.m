//
//  CMPAssociateAccountViewController.m
//  M3
//
//  Created by CRMO on 2018/6/7.
//

#import "CMPAssociateAccountEditController.h"
#import "CMPAssociateAccountEditNewView.h"
#import "SyScanViewController.h"
#import "CMPServerManager.h"
#import <CMPLib/GTMUtil.h>
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPLoginResponse.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/CMPAssociateAccountModel.h>
#import <CMPLib/CMPGlobleManager.h>
#import "M3LoginManager.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPMessageManager.h"
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPLoginRsaTools.h>
#import "SyQRCodeController.h"
#import "CMPLoginRequest.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPVpn/CMPVpn.h>
@interface CMPAssociateAccountEditController ()<SyScanViewControllerDelegate, CMPDataProviderDelegate>
{
    void(^loginAssAccountRslt)(NSInteger state);
}
@property (strong, nonatomic) CMPAssociateAccountEditNewView *editView;
@property (strong, nonatomic) CMPAssociateAccountModel *accountModel;
@property (assign, nonatomic) BOOL editMode; // 0-新增 1-编辑
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *serverUrl;
@property (strong, nonatomic) NSString *serverID;
@property (strong, nonatomic) NSString *serverVersion;
@property (strong, nonatomic) NSString *updateStr;
@property (strong, nonatomic) NSString *serverContextPath;

@property (strong, nonatomic) CMPServerManager *serverManager;
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;

@property (nonatomic, strong) CMPVpnEnterView *vpnEnterView;

@end

@implementation CMPAssociateAccountEditController

- (instancetype)initWithAssAccount:(CMPAssociateAccountModel *)assAccount {
    if (self = [super init]) {
        _accountModel = assAccount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _editView = (CMPAssociateAccountEditNewView *)self.mainView;
    if (!_editView) {
        _editView = [[CMPAssociateAccountEditNewView alloc] initWithFrame:self.view.bounds];
        _editView.cmp_y = CGRectGetMaxY(self.bannerNavigationBar.frame);
        _editView.cmp_height = self.view.height - _editView.cmp_y;
        [self.view addSubview:_editView];
    }
    [self setupMainView];
    if(_editMode) {
        [self setTitle:SY_STRING(@"ass_edit_title")];
    } else {
        [self setTitle:SY_STRING(@"ass_add_title")];
    }
    
    __weak typeof(self) weakSelf = self;
    _editView.tapScanButtonAction = ^{
        [weakSelf showScan];
    };
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.editView.frame = self.view.bounds;
    _editView.cmp_y = CGRectGetMaxY(self.bannerNavigationBar.frame);
    _editView.cmp_height = self.view.height - _editView.cmp_y;
}

- (void)setupMainView {
    if (_accountModel) {
        _editMode = YES;
        _editView.deleteButton.hidden = NO;
    } else {
        _editMode = NO;
        _editView.deleteButton.hidden = YES;
    }
    self.serverContextPath = _accountModel.server.contextPath;

    _editView.hostView.text = _accountModel.server.host;
    _editView.portView.text = _accountModel.server.port;
    _editView.usernameView.text = [GTMUtil decrypt:_accountModel.loginAccount.loginName];
    _editView.passwordView.text = [GTMUtil decrypt:_accountModel.loginAccount.extend2];
    [self.editView.hostView sendActionsForControlEvents:UIControlEventEditingChanged];
    [self.editView.portView sendActionsForControlEvents:UIControlEventEditingChanged];
    [self.editView.usernameView sendActionsForControlEvents:UIControlEventEditingChanged];
    [self.editView.passwordView sendActionsForControlEvents:UIControlEventEditingChanged];
    _editView.noteView.text = _accountModel.server.note;
    
    __weak __typeof(self)weakSelf = self;
    _editView.saveAction = ^(NSString *host, NSString *port, NSString *note, NSString *username, NSString *password) {
        weakSelf.host = host;
        weakSelf.port = port;
        weakSelf.note = note;
        weakSelf.username = username;
        weakSelf.password = password;
        [weakSelf save];
    };
    
    _editView.deleteAction = ^{
        CMPAlertView *alertView =
        [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_confirm")
                                    message:SY_STRING(@"login_server_delete_message")
                          cancelButtonTitle:SY_STRING(@"common_cancel")
                          otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"common_delete"),nil]
                                   callback:^(NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           [weakSelf delete];
                                       }
                                   }];
        [alertView show];
    };
#if defined(USE_SANGFOR_VPN)
    //vpn设置按钮
    _vpnEnterView = [[CMPVpnEnterView alloc] initWithFromViewController:self];
    [self.view addSubview:_vpnEnterView];
    
    [self.vpnEnterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-30);
        make.height.mas_equalTo(68);
    }];
#endif
    //修改时vpn信息
    if (_accountModel.serverID.length) {
        CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:_accountModel.serverID];
        if (vpnModel) {
            _vpnEnterView.vpnId = vpnModel.serverID;
            _vpnEnterView.vpnUrl = vpnModel.vpnUrl;
            _vpnEnterView.vpnLoginName = vpnModel.vpnLoginName;
            _vpnEnterView.vpnLoginPwd = vpnModel.vpnLoginPwd;
            [_vpnEnterView setVpnStatus:vpnModel?YES:NO];
        }
    }
    
    [_editView registerContentChangedAction];
}

#pragma mark - 业务逻辑

- (void)backBarButtonAction:(id)sender
{
    if (_editView.contentChanged || _vpnEnterView.contentChanged) {
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
/**
 点击保存按钮处理
 */
- (void)save {
    if (![self checkParams]) {
        return;
    }
    
    // 仅修改了备注信息，直接更新数据库
    if (_editMode) {
        if ([_accountModel.server.host.lowercaseString isEqualToString:self.host.lowercaseString] &&
            [_accountModel.server.port isEqualToString:self.port] &&
            [_accountModel.loginAccount.loginName isEqualToString:[GTMUtil encrypt:self.username]] &&
            [_accountModel.loginAccount.extend2 isEqualToString:[GTMUtil encrypt:self.password]] && !_vpnEnterView.contentChanged) {
            [self.loginDBProvider updateServerWithUniqueID:_accountModel.server.uniqueID note:self.note];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    [self showLoadingView];
    [_editView dismissKeybord];

    __weak __typeof(self)weakSelf = self;
    //保存服务器前需要判断vpn是否能连接
    NSString *vpnUrl = self.vpnEnterView.vpnUrl;
    loginAssAccountRslt = nil;
    if (vpnUrl.length) {

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
        
        CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:[CMPCore sharedInstance].serverID];
        CheckRollbackType rolltype = vpnModel.vpnUrl.length ? CheckRollbackType_WhenFail : CheckRollbackType_No;
        [[CMPVpnManager sharedInstance] checkVpnConfig:vpnConfig checkProcess:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
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
            return YES;
                } checkSuccess:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
                    [weakSelf hideLoadingView];
                    [weakSelf showLoadingView];

                    // 先检查服务器，服务器连接成功开始登录
                    // 服务器连接失败直接弹窗提示
                    [weakSelf.serverManager
                     checkServerWithHost:self.host
                     port:self.port
                     success:^(CMPCheckEnvResponse *response, NSString *url) {
                        
                         if ([NSString isNull:response.data.identifier]) {
                             [self hideLoadingViewWithoutCount];
                             [weakSelf showAlertMessage:@"Server ID is Null"];
                             [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
                             return;
                         }
                        NSString *canUseVpn = response.data.productEdition.canUseVPN;
                        if (canUseVpn && [canUseVpn isEqualToString:@"1"]) {
                            weakSelf.serverID = response.data.identifier;
                            weakSelf.serverVersion = response.data.version;
                            weakSelf.updateStr = [response.data.updateServer yy_modelToJSONString];
                            NSURLComponents *mUrl = [NSURLComponents componentsWithString:url];
                           /*-----add by raosj----- url中的80或者443端口被上一步操作替换为""，所以获取的port变为了null */
                           //2021-12-24再次修改，前缀判断问题。先判断了http，所以肯定是先走http，调换顺序先判断https
                           if (!mUrl.port) {
                               if ([url hasPrefix:CMPHttpsPrefix]){
                                   mUrl.port = [NSNumber numberWithInt:443];
                               }else if ([url hasPrefix:CMPHttpPrefix]) {
                                   mUrl.port = [NSNumber numberWithInt:80];
                               }
                           }
                           /*-----add by raosj end-----*/
                            weakSelf.serverUrl = [NSString stringWithFormat:@"%@://%@:%@", mUrl.scheme, mUrl.host, mUrl.port];
                            
                            // 不允许关联当前服务器
                            if ([response.data.identifier isEqualToString:[CMPCore sharedInstance].serverID]) {
                                [weakSelf hideLoadingViewWithoutCount];
                                [weakSelf showAlertMessage:SY_STRING(@"ass_add_err1")];
                                return;
                            }
                            
                            if (!weakSelf.editMode) { // 添加服务器，如果serverID重复，不允许新增
                                NSArray *servers = [weakSelf.loginDBProvider findServersWithServerID:response.data.identifier];
                                if (servers.count > 0) {
                                    CMPServerModel *server = [servers firstObject];
                                    [weakSelf hideLoadingViewWithoutCount];
                                    if ([server isMainAssAccount]) {
                                        [weakSelf showAlertMessage:SY_STRING(@"ass_add_err1")];
                                    } else {
                                        [weakSelf showAlertMessage:SY_STRING(@"ass_add_err2")];
                                    }
                                    return;
                                }
                            }
                            //存vpn信息
                            [CMPVpnManager saveVpnWithServerId:response.data.identifier vpnUrl:vpnUrl vpnLoginName:vpnLoginName vpnLoginPwd:CMPVpnManager.sharedInstance.vpnConfig.vpnLoginPwd vpnSPA:spa];
                            if (preVpnConfig) {
                                self->loginAssAccountRslt = ^(NSInteger state){
                                    [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
                                };
                            }
                            [weakSelf login];
                            
                        }else{
                            [weakSelf hideLoadingView];
                            [CMPVpnManager showAlertWithError:@"当前服务不支持VPN插件，\n请重新配置" sureAction:^{
                                [weakSelf.vpnEnterView vpnBtnClick:nil];
                            }];
                            [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
                        }
                     }
                     fail:^(NSError *error) {
                         [weakSelf hideLoadingViewWithoutCount];
                         [weakSelf showAlertMessage:error.domain];
                        [[CMPVpnManager sharedInstance] loginVpnWithConfig:preVpnConfig process:nil success:nil fail:nil];
                     }];
                    
                    return YES;
                    
                } checkFail:^BOOL(id obj, id ext, CMPServerVpnModel *preVpnConfig) {
                    [weakSelf hideLoadingView];
                    NSLog(@"vpn err:%@",obj);
                    [CMPVpnManager showAlertWithError:[NSString stringWithFormat:@"%@\n%@\n%@",SY_STRING(@"vpn_connect_nohand"),obj,SY_STRING(@"vpn_connect_reset")] sureAction:^{
                        [weakSelf.vpnEnterView vpnBtnClick:nil];
                    }];
                    return YES;
                } needRollback:rolltype rollbackProcess:nil rollbackSuccess:nil rollbackFail:nil];
        
    }else{
        // 先检查服务器，服务器连接成功开始登录
        // 服务器连接失败直接弹窗提示
        [self.serverManager
         checkServerWithHost:self.host
         port:self.port
         success:^(CMPCheckEnvResponse *response, NSString *url) {
            CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:response.data.identifier];
            if (vpnModel) {
                [CMPVpnManager deleteVpnByServerID:response.data.identifier];
            }
             if ([NSString isNull:response.data.identifier]) {
                 [self hideLoadingViewWithoutCount];
                 [weakSelf showAlertMessage:@"Server ID is Null"];
                 return;
             }
             weakSelf.serverID = response.data.identifier;
             weakSelf.serverVersion = response.data.version;
             weakSelf.updateStr = [response.data.updateServer yy_modelToJSONString];
             NSURLComponents *mUrl = [NSURLComponents componentsWithString:url];
            /*-----add by raosj----- url中的80或者443端口被上一步操作替换为""，所以获取的port变为了null */
            //2021-12-24再次修改，前缀判断问题。先判断了http，所以肯定是先走http，调换顺序先判断https
            if (!mUrl.port) {
                if ([url hasPrefix:CMPHttpsPrefix]){
                    mUrl.port = [NSNumber numberWithInt:443];
                }else if ([url hasPrefix:CMPHttpPrefix]) {
                    mUrl.port = [NSNumber numberWithInt:80];
                }
            }
            /*-----add by raosj end-----*/
             weakSelf.serverUrl = [NSString stringWithFormat:@"%@://%@:%@", mUrl.scheme, mUrl.host, mUrl.port];
             
             // 不允许关联当前服务器
             if ([response.data.identifier isEqualToString:[CMPCore sharedInstance].serverID]) {
                 [weakSelf hideLoadingViewWithoutCount];
                 [weakSelf showAlertMessage:SY_STRING(@"ass_add_err1")];
                 return;
             }
             
             if (!weakSelf.editMode) { // 添加服务器，如果serverID重复，不允许新增
                 NSArray *servers = [weakSelf.loginDBProvider findServersWithServerID:response.data.identifier];
                 if (servers.count > 0) {
                     CMPServerModel *server = [servers firstObject];
                     [weakSelf hideLoadingViewWithoutCount];
                     if ([server isMainAssAccount]) {
                         [weakSelf showAlertMessage:SY_STRING(@"ass_add_err1")];
                     } else {
                         [weakSelf showAlertMessage:SY_STRING(@"ass_add_err2")];
                     }
                     return;
                 }
             }
             
             [weakSelf login];
         }
         fail:^(NSError *error) {
             [weakSelf hideLoadingViewWithoutCount];
             [weakSelf showAlertMessage:error.domain];
         }];
    }
    
}

- (void)delete {
    [self showLoadingView];
    [self.loginDBProvider deleteAccount:_accountModel.loginAccount];
    [self.loginDBProvider deleteServerWithUniqueID:_accountModel.server.uniqueID];
    [self.loginDBProvider deleteAssAccount:_accountModel];
    [CMPVpnManager deleteVpnByServerID:_accountModel.serverID];
    CMPCore *core = [CMPCore sharedInstance];
    NSInteger restCount = [self.loginDBProvider countOfAssAcountWithServerID:core.serverID];
    
    if (restCount <= 1) { // 关联组只剩下一条数据了，删除关联组
        CMPAssociateAccountModel *currentAssAccount = [[CMPAssociateAccountModel alloc] init];
        currentAssAccount.serverID = core.serverID;
        currentAssAccount.userID = core.userID;
        currentAssAccount.serverUniqueID = core.currentServer.uniqueID;
        [self.loginDBProvider deleteAssAccount:currentAssAccount];
        
        // 当前服务器的关联标志设置为0
        CMPServerModel *currentServer = [self.loginDBProvider inUsedServer];
        currentServer.extend1 = @"0";
        [CMPCore sharedInstance].currentServer.extend1 = @"0";
        [self.loginDBProvider addServerWithModel:currentServer];
        [[CMPMessageManager sharedManager] deleteAssociateMessage];
    }
    [self hideLoadingViewWithoutCount];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)login {
    NSString *aUsername = [GTMUtil encrypt:self.username];
    NSString *aPassword = [GTMUtil encrypt:self.password];
    NSString *aUDID = [SvUDIDTools UDID];
    NSString *client = nil;
    if ([CMPFeatureSupportControl isLoginDistinguishDevice:self.serverVersion]) {
        client = INTERFACE_IS_PAD ? @"ipad" : @"iphone";
    } else {
        client = @"iphone";
    }
    NSString *abbreviation = [CMPDateHelper timeZoneAbbreviation];
    NSDictionary *aParam = @{@"name": aUsername,
                             @"password": aPassword,
                             @"client": client,
                             @"deviceCode": aUDID,
                             @"timezone":abbreviation,
                             @"ignoreDoubleAuth":@"1"
    };
    aParam = [CMPLoginRsaTools appendRsaParam:aParam];
    NSString *aHost = [CMPCore serverurlWithUrl:self.serverUrl serverVersion:self.serverVersion];
    CMPLoginRequest *aLoginRquest = [[CMPLoginRequest alloc] initWithDelegate:self param:[aParam JSONRepresentation] host:aHost serverVersion:self.serverVersion serverContextPath:self.serverContextPath];
    NSMutableDictionary *aDict = (NSMutableDictionary *)[CMPDataProvider headers];
    [aDict setObject:@"" forKey:@"Cookie"];
    aLoginRquest.headers = aDict;
    [[CMPDataProvider sharedInstance] addRequest:aLoginRquest];
}

/**
 登录接口返回成功处理逻辑

 @param response 登录接口返回model
 */
- (void)loginSuccess:(CMPLoginResponse *)response {
    // 1.存服务器地址
    NSString *aScheme = CMPHttpPrefix;
    BOOL isSafe = NO;
    if ([self.serverUrl hasPrefix:CMPHttpsPrefix]) {
        aScheme = CMPHttpsPrefix;
        isSafe = YES;
    }
    
    CMPServerModel *newServer = [[CMPServerModel alloc] initWithHost:[NSURLComponents componentsWithString:self.serverUrl].host
                                                               port:self.port
                                                             isSafe:isSafe
                                                             scheme:aScheme
                                                               note:self.note
                                                             inUsed:NO
                                                           serverID:self.serverID
                                                      serverVersion:self.serverVersion
                                                       updateServer:self.updateStr];
    
    
    if (_editMode) {
        [self.loginDBProvider deleteAssAccount:_accountModel];
//        if (![newServer.uniqueID isEqualToString:_accountModel.server.uniqueID]) {
            // 编辑模式下，修改了服务器地址，删除旧服务器地址
        [self.loginDBProvider deleteServerWithUniqueID:_accountModel.server.uniqueID];
//        }
    }
    
    //  如果该服务器存在，修改关联服务器标志位
    //  如果不存在，新增服务器
    newServer.extend1 = @"1";
    [self.loginDBProvider addServerWithModel:newServer];
    
    // 2.存用户信息
    [self saveUser:response];
    
    // 3.存关联表
    CMPAssociateAccountModel *newAssAccount = [self.loginDBProvider assAcountWithServerID:newServer.serverID userID:response.data.currentMember.userId];
    if (!newAssAccount) {
        newAssAccount = [[CMPAssociateAccountModel alloc] init];
    }
    newAssAccount.serverUniqueID = newServer.uniqueID;
    newAssAccount.serverID = newServer.serverID;
    newAssAccount.userID = response.data.currentMember.userId;
    
    // 更新切换时间条件：
    // 1. 新增模式
    // 2. 编辑模式，serverID、userID发生改变
    if (!_editMode ||
        ![newServer.serverID isEqualToString:_accountModel.server.serverID] ||
        ![response.data.currentMember.userId isEqualToString:_accountModel.loginAccount.userID]) {
        NSLog(@"zl---更新切换时间");
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        newAssAccount.switchTime = [NSNumber numberWithLongLong:time];
    }

    [self saveAssAccount:newAssAccount];
    [[CMPMessageManager sharedManager] insetEmptyAssociateMessage];
    
    [self hideLoadingViewWithoutCount];
    [self.navigationController popViewControllerAnimated:YES];
    [[CMPMessageManager sharedManager] startAssociateMessagePolling];
}

/**
 保存用户信息

 @param response 登录接口返回model
 */
- (void)saveUser:(CMPLoginResponse *)response {
    CMPLoginResponseCurrentMember *user = response.data.currentMember;
    NSString *aServerId = self.serverID;
    NSString *aLoginName = [GTMUtil encrypt:self.username];
    NSString *aLoginPassword = [GTMUtil encrypt:self.password];
    // 1、是否已经存在该用户，如果存在，需要读取出来，然后在更新为正在使用的用户
    CMPLoginAccountModel *aAccount = [[CMPCore sharedInstance].loginDBProvider accountWithServerID:aServerId userID:user.userId];
    if (!aAccount) {
        aAccount = [[CMPLoginAccountModel alloc] init];
        // 如果不存在需要设置gestureMode=2， 未设置手势密码
        aAccount.gestureMode = CMPLoginAccountModelGestureUninit;
    }
    // 将用户信息写入数据库
    aAccount.userID = user.userId;
    aAccount.loginPassword = aLoginPassword;
    aAccount.extend2 = aLoginPassword;
    aAccount.loginName = aLoginName;
    aAccount.serverID = aServerId;
    aAccount.name = user.name;
    aAccount.loginResult = [response yy_modelToJSONString];
    aAccount.accountID = user.accountId;
    aAccount.departmentID = user.departmentId;
    aAccount.levelID = user.levelId;
    aAccount.postID = user.postId;
    aAccount.iconUrl = user.iconUrl;
    aAccount.extend1 = user.accShortName;
    aAccount.extend3 = user.accName;
    aAccount.departmentName = user.departmentName;
    aAccount.postName = user.postName;
    [self.loginDBProvider addAccount:aAccount inUsed:YES];
}

/**
 存关联账号表

 @param newAssAccount 新关联账号model
 */
- (void)saveAssAccount:(CMPAssociateAccountModel *)newAssAccount {
    CMPAssociateAccountModel *currentAssAccount = [self.loginDBProvider assAcountWithServerID:[CMPCore sharedInstance].serverID userID:[CMPCore sharedInstance].userID];

    NSNumber *currentTime = [NSNumber numberWithInteger:(NSInteger)[NSDate timeIntervalSinceReferenceDate]];
    if (_editMode) {
        newAssAccount.createTime = _accountModel.createTime;
    } else {
        newAssAccount.createTime = currentTime;
    }
    
    if (currentAssAccount) {
        newAssAccount.groupID = currentAssAccount.groupID;
    } else {
        NSString *newGroupID = [CMPAssociateAccountModel generateGroupID];
        newAssAccount.groupID = newGroupID;
        currentAssAccount = [[CMPAssociateAccountModel alloc] init];
        currentAssAccount.serverUniqueID = [CMPCore sharedInstance].currentServer.uniqueID;
        currentAssAccount.serverID = [CMPCore sharedInstance].serverID;
        currentAssAccount.userID = [CMPCore sharedInstance].userID;
        currentAssAccount.groupID = newGroupID;
        currentAssAccount.createTime = currentTime;
        [self.loginDBProvider addAssAccount:currentAssAccount];
    }
    
    [self.loginDBProvider addAssAccount:newAssAccount];
}

/**
 检查用户输入
 */
- (BOOL)checkParams {
    if ([NSString isNull:self.host]) {
        [self showAlertMessage:SY_STRING(@"login_server_no_address")];
        return NO;
    }
    if ([NSString isNull:self.port]) {
        [self showAlertMessage:SY_STRING(@"login_server_no_port")];
        return NO;
    }
    if ([NSString isNull:self.username]) {
        [self showAlertMessage:SY_STRING(@"login_input_empty")];
        return NO;
    }
    if ([NSString isNull:self.password]) {
        [self showAlertMessage:SY_STRING(@"login_input_empty")];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_editView dismissKeybord];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    CMPLoginResponse *response = [CMPLoginResponse yy_modelWithJSON:aResponse.responseStr];
    if ([response requestSuccess]) {
        [self loginSuccess:response];
    } else {
        [self hideLoadingViewWithoutCount];
        [self showAlertMessage:response.message];
    }
    if (loginAssAccountRslt) {
        loginAssAccountRslt(1);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    if (loginAssAccountRslt) {
        loginAssAccountRslt(-1);
    }
    [self hideLoadingViewWithoutCount];
    if ([[M3LoginManager sharedInstance] needDeviceBind:error]) {
        [[M3LoginManager sharedInstance] showBindTipAlertWithUserName:self.username phone:nil serverUrl:self.serverUrl serverVersion:self.serverVersion serverContextPath:self.serverContextPath];
        return;
    }
    [self showAlertMessage:error.domain];
}

#pragma mark - 扫码

- (void)showScan {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:^{
    }];
}

- (void)scanViewController:(SyScanViewController *)scanViewController didScanFinishedWithResult:(ZXParsedResult *)aResult {
    if (aResult.type != kParsedResultTypeText) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSDictionary *aJson = [aResult.displayResult JSONValue];
    if (!aJson || ![aJson isKindOfClass:[NSDictionary class]]) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSString *host = aJson[@"host"];
    NSString *port = aJson[@"port"];
    
    if ([NSString isNull:host] || [NSString isNull:port]) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    self.editView.hostView.text = host;
    self.editView.portView.text = port;
    [self.editView.hostView sendActionsForControlEvents:UIControlEventEditingChanged];
    [self.editView.portView sendActionsForControlEvents:UIControlEventEditingChanged];
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma mark Getter & Setter

- (CMPServerManager *)serverManager {
    if (!_serverManager) {
        _serverManager = [[CMPServerManager alloc] init];
    }
    return _serverManager;
}

- (CMPLoginDBProvider *)loginDBProvider {
    return [CMPCore sharedInstance].loginDBProvider;
}

@end
