//
//  CMPServerListViewController.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerListViewController.h"
#import "CMPServerListView.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIButton+CMPButton.h>
#import "CMPServerListCell.h"
#import "CMPServerEditViewController.h"
#import <CMPLib/CMPGlobleManager.h>
#import "CMPCheckEnvironmentModel.h"
#import "CMPMigrateWebDataViewController.h"
#import "M3LoginManager.h"
#import <CMPLib/CMPAppManager.h>
#import "CMPCheckUpdateManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPServerManager.h"
#import <CMPLib/SOLocalization.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPVpn/CMPVpn.h>

@interface CMPServerListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CMPServerListView *listView;
/** 数据源，CMPServerModel数组 **/
@property (nonatomic, strong) NSMutableArray<NSArray<CMPServerModel *> *> *dataSource;
@property (nonatomic, strong) CMPServerModel *selectedModel;
/** https://m.seeyon.com:8080 **/
//@property (nonatomic, strong) NSString *serverUrl;
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;
@property (strong, nonatomic) CMPServerManager *serverManager;
@property (strong, nonatomic) NSMutableArray *headTitles;

@end

@implementation CMPServerListViewController

#pragma mark - Life circle

- (UIView *)loadingShowInView {
    return self.mainView;
}

- (void)backBarButtonAction:(id)sender {
    [_serverManager cancel];
    [super backBarButtonAction:sender];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowRotation = NO;
    [self initServerListView];
    [self setTitle:SY_STRING(@"login_server_list_title")];
    [self addRightBarButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSArray *serverList = [self.loginDBProvider listOfServer];
    NSMutableArray *normalServers = [NSMutableArray array];
    NSMutableArray *cloudServers = [NSMutableArray array];
    NSMutableArray *associateServers = [NSMutableArray array];
    self.headTitles = [NSMutableArray array];
    for (CMPServerModel *server in serverList) {
        NSString *associateServer = server.extend1;
        if (![NSString isNull:associateServer]) {
            if ([associateServer isEqualToString:@"1"]) {
                [associateServers addObject:server];
            }
            else {
                [normalServers addObject:server];
            }
        } else {
            [normalServers addObject:server];
        }
    }
    
    [self.dataSource removeAllObjects];
    if (normalServers.count > 0) {
        [self.dataSource addObject:normalServers];
        [self.headTitles addObject:SY_STRING(@"login_server_manual")];
    }
    if (cloudServers.count > 0) {
        [self.dataSource addObject:cloudServers];
        [self.headTitles addObject:SY_STRING(@"login_server_cloud")];
    }
    if (associateServers.count > 0) {
        [self.dataSource addObject:associateServers];
        [self.headTitles addObject:SY_STRING(@"login_server_ass")];
    }
    [_listView.table reloadData];
}

#pragma mark - UI

- (void)addRightBarButton {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:SY_STRING(@"login_server_add") forState:UIControlStateNormal];
    UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
    [addButton setTitleColor:themeColor forState:UIControlStateNormal];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : themeColor,
                                 NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]};
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_server_add") attributes:attributes];
    [addButton setAttributedTitle:title forState:UIControlStateNormal];
    [addButton setFrame:kBannerImageButtonFrame];
    [addButton addTarget:self action:@selector(tapAddButton) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:@[addButton]];
}

- (void)initServerListView {
    _listView = (CMPServerListView *)self.mainView;
    _listView.table.delegate = self;
    _listView.table.dataSource = self;
    __weak typeof(self) weakself = self;
    _listView.saveAction = ^{
        [weakself saveConfig];
    };
}

#pragma mark - 按钮点击事件

- (void)tapAddButton {
    CMPServerEditViewController *editVc = [[CMPServerEditViewController alloc] init];
    [self.navigationController pushViewController:editVc animated:YES];
}

- (void)saveConfig {
    if (!self.selectedModel) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:self.selectedModel.serverID];
    
    if (vpnModel.vpnUrl.length) {//vpn连接
        [self showLoadingViewWithText:@"VPN切换中"];
        __weak typeof(self) wSelf = self;
        [[CMPVpnManager sharedInstance] logoutVpnWithResult:^(id obj, id ext) {
            [wSelf hideLoadingView];
            
            [wSelf showLoadingViewWithText:@"VPN登录中"];

            [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                            
                        } success:^(id obj, id ext) {
                            [wSelf hideLoadingView];
                            [wSelf checkEnv];
                        } fail:^(id obj, id ext) {
                            [wSelf hideLoadingView];
                            [wSelf showToastWithText:obj];
                        }];
        }];

    }else{
//        if ([CMPVpnManager isVpnConnected]) {
            [[CMPVpnManager sharedInstance] logoutVpnWithResult:^(id obj, id ext) {
                                                
            }];
//        }
        [self checkEnv];
    }
}


#pragma mark - Getter & Setter

- (NSMutableArray<NSArray<CMPServerModel *> *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataSource;
}

- (CMPLoginDBProvider *)loginDBProvider {
    return [CMPCore sharedInstance].loginDBProvider;
}

#pragma mark - UITableView Deleget

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 300, 16)];
    titleLabel.text = self.headTitles[section];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(titleView).mas_offset(14);
        make.top.mas_equalTo(titleView).mas_offset(12);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(16);
    }];
    return titleView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPServerModel *model = [self serverWithIndexPath:indexPath];
    NSString *note = model.note;
    if ([NSString isNull:note]) {
        return 52;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CMPServerListCellIdentifier";
    CMPServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPServerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CMPServerModel *model = [self serverWithIndexPath:indexPath];
    
    [cell setupWithModel:model];
    
    // 隐藏最后一个cell的分割线
    if (indexPath.row == (self.dataSource[indexPath.section].count - 1)) {
        [cell hideBottomLine];
    }
    
    if (model.inUsed) {
        self.selectedModel = model;
    }
    
    __weak typeof(self) weakself = self;
    
    cell.tapEditAction = ^{
        CMPServerEditViewController *vc = [[CMPServerEditViewController alloc] init];
        vc.mode = CMPServerEditViewControllerModeEdit;
        vc.oldServer = model;
        [weakself.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   self.selectedModel.inUsed = NO;
    //V5-51371
    for (NSArray *servers in self.dataSource) {
        for (int i=0; i<servers.count; i++) {
            CMPServerModel *aServer = servers[i];
            aServer.inUsed = NO;
        }
    }
    
    CMPServerModel *selectedModel = [self serverWithIndexPath:indexPath];
    selectedModel.inUsed = YES;
    self.selectedModel = selectedModel;
   
    [tableView reloadData];
}

/**
 通过IndexPath从DataSource中取出服务器model

 @param indexPath tableView对应indexPath
 @return DataSource中对应的服务器model
 */
- (CMPServerModel *)serverWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *aServers = nil;
    aServers = self.dataSource[indexPath.section];
    CMPServerModel *model = aServers[indexPath.row];
    return model;
}


#pragma mark - 保存服务器、检查更新

/**
 检查服务器信息
 */
- (void)checkEnv {
    [self showLoadingView];
    CMPNavigationController *nav = (CMPNavigationController *)self.navigationController;
    [nav updateEnablePanGesture:NO];
    
    __weak typeof(self) weakself = self;
    __weak typeof(nav) weakNav = nav;
    _serverManager = [[CMPServerManager alloc] init];
    [_serverManager checkServerWithServerModel:self.selectedModel success:^(CMPCheckEnvResponse *response, NSString *url) {
        [weakself saveServerInfo:response];
        [weakself checkUpdate];
    } fail:^(NSError *error) {
        [weakself hideLoadingView];
        [weakNav updateEnablePanGesture:YES];
        [weakself showToastWithText:error.domain];
    }];
}

/**
 检查应用包更新
 */
- (void)checkUpdate {
    __weak __typeof(self)weakself = self;
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        [weakself hideLoadingView];
        [weakself jumpToLoginView];
    }];
}

/**
 保存服务器信息到CMPServerInfo
 */
- (void)saveServerInfo:(CMPCheckEnvResponse *)aModel {
    NSString *identifier = aModel.data.identifier ? aModel.data.identifier : @"";
    NSString *serverVersion = aModel.data.version ?: @"";
   /* NSDictionary *h5CacheDic = @{@"ip" : self.selectedModel.host,
                                 @"port": self.selectedModel.port,
                                 @"model" : self.selectedModel.scheme,
                                 @"identifier" : identifier,
                                 @"updateServer" : [aModel.data.updateServer yy_modelToJSONObject],
                                 @"serverVersion" : serverVersion};
    NSString *h5CacheStr = [h5CacheDic JSONRepresentation];
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:h5CacheStr];
    */
    //OA-20989
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    NSString *aUpdateStr = [aModel.data.updateServer yy_modelToJSONString];
    CMPServerModel *server = [[CMPServerModel alloc] initWithHost:self.selectedModel.host
                                                             port:self.selectedModel.port
                                                           isSafe:self.selectedModel.isSafe
                                                           scheme:self.selectedModel.scheme
                                                             note:self.selectedModel.note
                                                           inUsed:YES
                                                         serverID:identifier
                                                    serverVersion:serverVersion
                                                     updateServer:aUpdateStr?:@""];
    [loginDBProvider addServerIfServerIdChangeWithModel:server];
    
    [loginDBProvider switchUsedServerWithUniqueID:self.selectedModel.uniqueID];
    [[CMPCore sharedInstance] setup];
}

/**
 返回到登陆页面：列表页肯定是由登录页跳转过来
 */
- (void)jumpToLoginView {
    [M3LoginManager jumpToLoginVCWithVC:self selectedModel:self.selectedModel];
    
    [self backBarButtonAction:nil];
}

@end
