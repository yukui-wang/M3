//
//  CMPServerListController.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerListController.h"
#import "CMPServerListNewView.h"
#import "CMPServerListNewCell.h"
#import "CMPServerEditController.h"
#import "CMPMigrateWebDataViewController.h"
#import "M3LoginManager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPServerManager.h"
#import "SyScanViewController.h"
#import "CMPServerListHeader.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIButton+CMPButton.h>
#import <CMPLib/CMPGlobleManager.h>
#import "CMPCheckEnvironmentModel.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/SOLocalization.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPVpn/CMPVpn.h>

static CGFloat const kViewMargin = 30.f;

@interface CMPServerListController ()<SyScanViewControllerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CMPServerListNewView *listView;
/** 数据源，CMPServerModel数组 **/
@property (nonatomic, strong) NSMutableArray<NSArray<CMPServerModel *> *> *dataSource;
@property (nonatomic, strong) CMPServerModel *selectedModel;
/** https://m.seeyon.com:8080 **/
//@property (nonatomic, strong) NSString *serverUrl;
@property (strong, nonatomic) CMPLoginDBProvider *loginDBProvider;
@property (strong, nonatomic) CMPServerManager *serverManager;
@property (strong, nonatomic) NSMutableArray *headTitles;

/* 取消按钮 */
@property (weak, nonatomic) UIButton *cancelBtn;
/* 设置服务器地址 label */
@property (weak, nonatomic) UILabel *titleLabel;
/* 添加按钮 */
@property (weak, nonatomic) UIButton *addServerBtn;
/* 扫一扫 按钮 */
@property (weak, nonatomic) UIButton *scanBtn;

@property (strong, nonatomic) NSIndexPath* editingIndexPath;  //当前左滑cell的index

@end

@implementation CMPServerListController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowRotation = NO;
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self setPanGesturEnabled:YES];
    
    [self configViews];
    [self initServerListView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.bannerNavigationBar.hidden = YES;
    [self setPanGesturEnabled:NO];
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

- (UIColor *)statusBarColorForiOS7 {
    return [UIColor cmp_colorWithName:@"white-bg1"];
}

- (void)configViews {
    //取消按钮
    NSString *cancelString = SY_STRING(@"common_cancel");
    CGFloat cancelBtnW = [cancelString sizeWithFontSize:[UIFont systemFontOfSize:16.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    UIButton *cancelBtn = [UIButton.alloc initWithFrame:CGRectMake(self.view.width - cancelBtnW - kViewMargin, 59.f, cancelBtnW, 22.f)];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#92a4b5"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancelBtn setImage:[[UIImage imageNamed:@"login_view_back_btn_icon"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    NSString *titleString = SY_STRING(@"login_first_login_select_server");
    CGFloat titleLabelW = [titleString sizeWithFontSize:[UIFont boldSystemFontOfSize:20.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    
    //设置服务器地址 label
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CMPRectMake(kViewMargin, 103.f, titleLabelW, 28.f)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    titleLabel.text = titleString;
    titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    //添加  按钮
    NSString *addServerBtnTitle = SY_STRING(@"login_server_add");
    CGFloat addServerBtnW = [addServerBtnTitle sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 2.f;
    UIButton *addServerBtn = [UIButton.alloc initWithFrame:CMPRectMake(self.view.width - addServerBtnW - kViewMargin, 0, addServerBtnW, 20.f)];
    addServerBtn.cmp_centerY = titleLabel.cmp_centerY;
    [addServerBtn setTitle:addServerBtnTitle forState:UIControlStateNormal];
    [addServerBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    addServerBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [addServerBtn addTarget:self action:@selector(addServerBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addServerBtn];
    self.addServerBtn = addServerBtn;
    
    //扫一扫 按钮
    UIButton *scanBtn = [UIButton.alloc initWithFrame:CMPRectMake(0, 0, 16.f, 16.f)];
    scanBtn.cmp_x = CGRectGetMinX(addServerBtn.frame) - 18.f;
    scanBtn.cmp_centerY = titleLabel.cmp_centerY;
    [scanBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"login_view_scan_qrcode_gray_icon"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
    self.scanBtn = scanBtn;
}


- (void)initServerListView {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass: CMPServerListNewView.class]) {
            [view removeFromSuperview];
        }
    }
    _listView = CMPServerListNewView.alloc.init;
    _listView.cmp_size = CGSizeMake(self.view.width - 60.f, self.view.height - 161.f);
    _listView.cmp_x = 30.f;
    _listView.cmp_y = 161.f;
    _listView.table.delegate = self;
    _listView.table.dataSource = self;
    _listView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self.view addSubview:_listView];
    
    __weak typeof(self) weakself = self;
    _listView.saveAction = ^{
        [weakself saveConfig];
    };
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(103.f);
        make.leading.mas_equalTo(kViewMargin);
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kViewMargin);
        make.top.mas_equalTo(56.f);
    }];
    
    [self.addServerBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(-kViewMargin);
    }];
    
    [self.scanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.addServerBtn.mas_leading).inset(4.f);
    }];
    
    [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(20.f);
        make.leading.mas_equalTo(30.f);
        make.trailing.mas_equalTo(-30.f);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - 按钮点击事件

/// 取消按钮 点击方法
- (void)cancelBtnClicked {
    [_serverManager cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

/// 扫码按钮 点击方法
- (void)scanBtnClicked {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

/// 添加  按钮 点击方法
- (void)addServerBtnClicked {
    CMPServerEditController *editVc = [[CMPServerEditController alloc] init];
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
    if (self.dataSource.count < 2) return 0;
    
    return 38.f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (self.dataSource.count < 2) return UIView.new;
    
    CMPServerListHeader *header = [[CMPServerListHeader alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 38.f)];
    header.titleLabel.text = self.headTitles[section];
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    CMPServerModel *model = [self serverWithIndexPath:indexPath];
//    NSString *note = model.note;
//    if ([NSString isNull:note]) {
//        return 52.f;
//    } else {
//        return 60.f;
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CMPServerListNewCellIdentifier";
    CMPServerListNewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPServerListNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    
    if(model.isMainAssAccount && !model.isCloudServer) {
        __weak typeof(self) weakself = self;
        cell.tapEditAction = ^{
            CMPServerEditController *vc = [[CMPServerEditController alloc] init];
            vc.mode = CMPServerEditControllerModeEdit;
            vc.oldServer = model;
            [weakself.navigationController pushViewController:vc animated:YES];
        };
    }
    
    if (self.dataSource.count == 1 && self.dataSource.lastObject.count == 1) {
        cell.showTopCorner = YES;
        cell.showBottomCorner = YES;
        return cell;
    }
    
    if (self.dataSource.count < 2 && indexPath.row == 0) {
        cell.showTopCorner = YES;
    }else if (indexPath.row < self.dataSource[indexPath.section].count - 1) {
        cell.showBottomCorner = NO;
        cell.showTopCorner = NO;
        cell.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
    }else {
        cell.showBottomCorner = YES;
    }
    
    
    
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


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.headTitles[indexPath.section];
    NSString *assTitle = SY_STRING(@"login_server_ass");
    if ([title isEqualToString:assTitle]) {
        return nil;
    }
    
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //这里处理删除事件
        CMPServerModel *model = [self serverWithIndexPath:indexPath];
        [tableView setEditing:NO animated:YES];
        [weakSelf deleteWithServer:model];
        
    }];
    action.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    return @[action];
    
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.editingIndexPath = indexPath;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupSlideBtnWithTableView:tableView];
//    });
}

//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
//
//    if (@available(iOS 11.0, *)) {
//        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"取消\n收藏" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            completionHandler(YES);
//        }];
//        //也可以设置图片
//        deleteAction.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
//        deleteAction.image  = [UIImage imageNamed:@"table_cell_delete_btn"];
//        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
//        return config;
//    }
//}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.editingIndexPath = nil;
}

//判断是否显示左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.headTitles[indexPath.section];
    NSString *assTitle = SY_STRING(@"login_server_ass");
    if ([title isEqualToString:assTitle]) return NO;
    
    
    return YES;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


// 设置左滑菜单按钮的样式
- (void)setupSlideBtnWithTableView:(UITableView *)tableView
{
    UIView *view = nil;
    // 判断系统是否是iOS11及以上版本
    if (@available(iOS 11.0, *)) {
//        view = [CMPCommonTool getSubViewWithClassName:@"UISwipeActionPullView" inView:tableView];
        
    } else {
        // iOS11以下做法
        CMPServerListNewCell *cell = [tableView cellForRowAtIndexPath:self.editingIndexPath];
        view = [CMPCommonTool getSubViewWithClassName:@"UITableViewCellDeleteConfirmationView" inView:cell];
        
    }
    
    [self setupRowActionView:view];
}



// 设置背景图片
- (void)setupRowActionView:(UIView *)rowActionView
{
    UIView *remarkContentView = rowActionView.subviews[0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_cell_delete_btn"]];
    imageView.cmp_size = CGSizeMake(40.f, 40.f);
    imageView.contentMode = UIViewContentModeCenter;
    imageView.center = CGPointMake(remarkContentView.width/2.f, remarkContentView.height/2.f);
    imageView.backgroundColor = [UIColor cmp_colorWithName:@"app-bgc4"];
    [imageView cmp_setRoundView];
    [remarkContentView addSubview:imageView];
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

/**
 点击删除按钮
 */
- (void)deleteWithServer:(CMPServerModel *)model
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SY_STRING(@"common_confirm") message:SY_STRING(@"login_server_delete_message") preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakself = self;
    UIAlertAction *delete = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself deleteServer:model];
        //删除对应的vpn信息
        [CMPVpnManager deleteVpnByServerID:model.serverID];
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
    
    NSArray *allAccount  = self.loginDBProvider.allAccount;
    for (CMPLoginAccountModel *account in allAccount) {
        if ([account.serverID isEqualToString:server.serverID]) {
            [self.loginDBProvider deleteAccount:account];
        }
    }
}

#pragma mark - 保存服务器、检查更新

/**
 检查服务器信息
 */
- (void)checkEnv {
    [self showLoadingView];
    CMPNavigationController *nav = (CMPNavigationController *)self.navigationController;
    [nav updateEnablePanGesture:YES];
    
    __weak typeof(self) weakself = self;
    _serverManager = [[CMPServerManager alloc] init];
    [_serverManager checkServerWithServerModel:self.selectedModel success:^(CMPCheckEnvResponse *response, NSString *url) {
        [weakself saveServerInfo:response];
        [weakself checkUpdate];
    } fail:^(NSError *error) {
        [weakself hideLoadingView];
        [nav updateEnablePanGesture:YES];
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
    
    [self cancelBtnClicked];
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
    
    CMPServerEditController *editVc = [[CMPServerEditController alloc] init];
//    [editVc saveServerWithHost:host port:port note:nil];
    editVc.host = host;
    editVc.port = port;
    __weak typeof(self) weakSelf = self;
    [scanViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf.navigationController pushViewController:editVc animated:YES];
    }];
}

@end
