//
//  CMPMessageListViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/22.
//
//

#import "CMPMessageListViewController.h"
#import "CMPMessageListView.h"
#import "CMPMessageListCell.h"
//#import "ZLMapsViewController.h"

#import <CMPLib/MJRefresh.h>
#import "CMPMessageManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPRCTargetObject.h"

#import "CMPCommonManager.h"
#import "CMPGestureHelper.h"
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPChatManager.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPCommonTool.h>

#import "CMPSignViewController.h"
#import "CMPAggregationMessageViewController.h"
#import "CMPPrivilegeManager.h"
#import "CMPAppsDownloadProgressView.h"
#import "CMPCheckUpdateManager.h"
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPWebViewUrlUtils.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPFontProvider.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPShortcutHelper.h"
#import "CMPPCOnlineBanner.h"
#import <CMPLib/CMPSplitViewController.h>
#import "CMPOnlineDevModel.h"
#import "CMPMultiLoginManageViewController.h"
#import "CMPMessageFilterManager.h"
#import "CMPChatListViewModel.h"
#import "CMPMeetingManager.h"

#import "CMPTopScreenManager.h"
#import "CMPMessageListViewController+TopScreen.h"
#import "CMPTopScreenGuideView.h"
#import "CMPHomeAlertManager.h"

#import <CMPLib/CMPServerVersionUtils.h>

@interface CMPMessageListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CMPMessageListView *_listView;
}

 // 是否需要刷新消息列表
@property (strong, nonatomic) NSLock *needRefreshMsgLock; // needRefreshMsg锁
@property (nonatomic, retain) MSWeakTimer *refreshMsgTimer; // 刷新消息列表计算器
@property (assign, nonatomic) BOOL appsDownloadViewHidden; // 记录当前下载进度条的显示状态
//@property (assign, nonatomic) BOOL isShowNetworkTip; // 记录网络提示状态
@property (assign, nonatomic) BOOL inTopLevel; // 当前页面是否在最上层
@property (strong, nonatomic) CMPAppsDownloadProgressView *appsDownloadProgressView;
@property (strong, nonatomic) CMPPCOnlineBanner *pcOnlineBanner; // 多端在线提醒
@property (assign, nonatomic) BOOL pcOnlineBannerHidden; // 记录当前多端在线提醒显示状态
@property (strong, nonatomic) CMPOnlineDevModel *onlineDev;
@property (assign, nonatomic) BOOL unreadCountInDrag; // 气泡是否正在被拖动
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSString *selectAppId;//选中的cell的appID
@property (nonatomic,strong) CMPChatListViewModel *viewModel;

@property (nonatomic, strong) CMPTopScreenManager *topScreenManager;

@end

@implementation CMPMessageListViewController

@synthesize needRefreshMsg = _needRefreshMsg;


-(CMPChatListViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPChatListViewModel alloc] init];
    }
    return _viewModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_refreshMsgTimer invalidate];
    _refreshMsgTimer = nil;
}

- (void)cmp_didClearDetailViewController {
    if (self.selectAppId) {
        self.selectAppId = nil;
        [_listView.tableView reloadData];
    }
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    self.pcOnlineBannerHidden = YES;
    self.appsDownloadViewHidden = YES;
    [super viewDidLoad];
    self.allowRotation = NO;
    self.backBarButtonItemHidden = ![self isSecondaryPage];
    [self setTitle:SY_STRING(@"msg_msgTitle")];
    
    _listView = (CMPMessageListView *)self.mainView;
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    
    if (IS_IPHONE) {
        self.weakListView = _listView;
        //pan手势-负一屏
        [self addPanGuestureToView:_listView];
    }else{
        //平板-下拉刷新
        __weak typeof(CMPMessageListView *) wListView = _listView;
        _listView.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [[CMPMessageManager sharedManager] refreshAssociateMessage];
            [[CMPMessageManager sharedManager] refreshMessage];
            [wListView refreshQuickRouterView];
        }];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        _listView.tableView.mj_header.automaticallyChangeAlpha = YES;
    }
    
    [self.refreshMsgTimer invalidate];
    self.refreshMsgTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(refreshMsg)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:dispatch_get_main_queue()];
    [self updateRefreshMsgFlag];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidUpdate:) name:kNotificationName_MessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshing) name:kMessageDidFinishRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appsDownloadAction:) name:kNotificationName_AppsDownload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChangedAction:) name:MinStandardFontChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineDevDidChange:) name:kNotificationName_OnlineDevDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCountDragBegan) name:kNotificationName_MessageCellDragBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCountDragEnd) name:kNotificationName_MessageCellDragEnd object:nil];
    //    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(screenMirrorClicked:) name:CMPShortcutViewScreenMirroringClickedNoti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentGroupInfoChanged:) name:@"kNotificationName_departmentGroupInfoChanged" object:nil];
    
    [[CMPMessageManager sharedManager] addWaterMarkToView:_listView.tableView];
    
    //检查是否显示guide
    UIView *showView = self.rdv_tabBarController.view;
    [CMPTopScreenGuideView showGuideInView:showView isMsgPage:YES];
}

- (void)screenMirrorClicked:(NSNotification *)noti {
    
//    [self handleCurrentSelectVC];
    
}

//- (void)handleCurrentSelectVC {
//
//    UIApplication *app = UIApplication.sharedApplication;
//    UIViewController *rootVC = app.keyWindow.rootViewController;
//    if ([rootVC isKindOfClass: [RDVTabBarController class]]) {
//        RDVTabBarController *tmpVC = (RDVTabBarController *)rootVC;
//        UIViewController *vc = tmpVC.selectedViewController;
//        ZLMapsViewController *webVC = ZLMapsViewController.alloc.init;
//
//        if ([vc isKindOfClass: UINavigationController.class]) {
//            UINavigationController *tmpNav = (UINavigationController *)vc;
//            [CMPCommonTool pushInDetailWithViewController:webVC in:tmpNav.childViewControllers.firstObject];
//        }else {
//            CMPSplitViewController *tmpVc = (CMPSplitViewController *)vc;
//            [tmpVC cmp_pushPageInMasterView:webVC navigation:(UINavigationController *)tmpVc.detailNavigation];
//        }
//    }
//}

- (void)viewWillAppear:(BOOL)animated {
    if (self.topScreenShow) {
        return;
    }
    [self updateAppsDownloadViewHidden:self.appsDownloadViewHidden];
    [super viewWillAppear:animated];
    if (self.needRefreshMsg) {
        self.needRefreshMsg = NO;
        [self loadData];
    }
    [[CMPMessageManager sharedManager] refreshAssociateMessage];
    [[CMPMessageManager sharedManager] refreshMessage];
    self.inTopLevel = YES;

    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self updateAppsDownloadViewHidden:NO];
        if ([CMPCheckUpdateManager sharedManager].state == CMPCheckUpdateManagerFail) {
            [_appsDownloadProgressView showError:nil byZipAppName:nil];
        } else {
            [_appsDownloadProgressView showUpdateProgress];
        }
    }
    _listView.lockFrame = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.topScreenShow) {
        return;
    }
    [super viewDidAppear:animated];
    //竖屏状态下清空选中状态
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self cmp_didClearDetailViewController];
    }
    [_listView refreshQuickRouterView];
    [self dispatchAsyncToChild:^{
        [CMPMessageFilterManager updateFilter];
        if (!self->_dataList || self->_dataList.count==0) {
            [self loadData];
        }
        [self.viewModel checkGroupsIfContainMeByChats:self->_dataList completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            
        }];
        [CMPMeetingManager ready];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.viewModel fetchAllTopChatListWithCompletion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                NSLog(@"获取所有置顶信息:%@",ext);
            }];
        });
        
    }];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    if (self.topScreenShow) {
        return;
    }
    //修改iPhone，消息在首页因为底导航隐藏、显示导致的前后界面不一致，列表自动向上滚动，ipad无该问题
    _listView.lockFrame = INTERFACE_IS_PHONE;
    [super viewWillDisappear:animated];
    
}

- (void)viewWillLayoutSubviews {
    if (self.topScreenShow) {
        return;
    }
    [super viewWillLayoutSubviews];
    [self updateAppsDownloadViewHidden:self.appsDownloadViewHidden];
    [self updatePcOnlineBannerHidden:self.pcOnlineBannerHidden];
}

- (BOOL)isSecondaryPage {
    return self.navigationController.childViewControllers.count == 1 ? NO : YES;
}

-(void)departmentGroupInfoChanged:(NSNotification *)noti
{
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf loadData];
    });
}

-(void)messageDidUpdate:(NSNotification *)noti
{
    [self updateRefreshMsgFlag];
    id obj = noti.object;
    if (obj && [@"removeCon" isEqualToString:obj[@"action"]]) {
        NSInteger idx = ((NSNumber *)obj[@"index"]).integerValue;
        if (idx>_dataList.count-1) {
            return;
        }
        CMPMessageObject *obj = [_dataList objectAtIndex:idx];
        [_dataList removeObject:obj];

        if (_dataList.count == 0) {
            [self loadData];
        } else {
            [_listView.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        if (CMP_IPAD_MODE && [self cmp_inMasterStack]) {
            if (self.selectAppId && [obj.cId isEqualToString:self.selectAppId]) {
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    [self.cmp_splitViewController clearDetailViewController];
                }else{
                    
                }
            }
        }
        return;
    }
}

- (void)updateRefreshMsgFlag {
    self.needRefreshMsg = YES;
}

- (void)refreshMsg {
    // 刷新策略：收到新消息 且 当前ViewController可见 且 气泡没有被拖动
    if (self.needRefreshMsg &&
        [self isVisible] &&
        !self.unreadCountInDrag) {
        self.needRefreshMsg = NO;
        [self loadData];
    }
}

- (void)loadData {
    __weak CMPMessageListView *listView = _listView;
    __weak NSMutableArray *datalist = _dataList;
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToChild:^{
        [[CMPMessageManager sharedManager] messageList:^(NSArray *result) {
            [weakSelf dispatchAsyncToMain:^{
                BOOL isSame = datalist.count == result.count;
                listView.tableView.userInteractionEnabled = NO;
                [datalist removeAllObjects];
                [datalist addObjectsFromArray:result];
                [listView.tableView reloadDataWithTotalCount:datalist.count currentCount:datalist.count];
                [listView.tableView setNeedsLayout];
                [listView.tableView layoutIfNeeded];
                listView.tableView.userInteractionEnabled = YES;
                
                [weakSelf.viewModel fetchGroupsInfoByChats:datalist completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    
                }];
                
                if (!isSame) {
                    [weakSelf.viewModel handleTopChatWithLocalData:datalist];
                }
            }];
        }];
    }];
}

- (void)endRefreshing {
//    [_listView.tableView.mj_header endRefreshing];
}

- (void)setupBannerButtons {
    if (CMP_IPAD_MODE) {
        return;
    }
    
    self.bannerNavigationBar.rightViewsMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 5.0f;
    NSMutableArray *items = [NSMutableArray array];
    
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    if (configInfo.portal.isShowCommonApp && !self.isSecondaryPage) {
        UIButton *appButton = [UIButton buttonWithImageName:[CMPFeatureSupportControl bannerAppIcon] frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
        [appButton addTarget:self action:@selector(pushCommonAppView) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:appButton];
    }
    
    UIButton *searchButton = [UIButton buttonWithImageName:@"banner_search" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [searchButton addTarget:self action:@selector(pushSearchView) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:searchButton];
    
    // V7.1新增功能，如果快捷菜单配置在底导航，不展示加号
    if (!configInfo.tabBar.hasShortCut ||
        self.isSecondaryPage) {
        UIButton *quickButton = [UIButton buttonWithImageName:@"msg_shape" frame:kBannerIconButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
        [quickButton addTarget:self action:@selector(quickButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:quickButton];
    }
    
    [self.bannerNavigationBar setRightBarButtonItems:items];
}

- (void)pushSearchView {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr;
    
    //有致信插件
    BOOL zhixin = [CMPMessageManager sharedManager].hasZhiXinPermissionAndServerAvailable;
    //全文检索
    BOOL index = [CMPPrivilegeManager getCurrentUserPrivilege].hasIndexPlugin;
    if ([CMPServerVersionUtils serverIsLaterV8_3]) {
        if (zhixin) {
            aStr = kM3FullSearchUrl_180;
            aStr = [aStr stringByAppendingFormat:@"?messageSearch=true"];
        }else{
            if (index) {
                aStr = kM3FullSearchUrl_830;//(单独的全文检索)
            } else {
                aStr = kM3AllSearchUrl_180;
            }
        }
    }else 
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        if (index) {
            aStr = kM3FullSearchUrl_180;
        } else {
            aStr = kM3AllSearchUrl_180;
        }
    } else {
        aStr = kM3AllSearchUrl;
    }
    
    aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = NO;
    aCMPBannerViewController.statusBarStyle = 0;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
}

- (void)topScreenPushSearchView {
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr;
    
    //全文检索
    BOOL index = [CMPPrivilegeManager getCurrentUserPrivilege].hasIndexPlugin;
    
    if ([CMPServerVersionUtils serverIsLaterV8_3]) {
        if (index) {
            aStr = kM3FullSearchUrl_830;//(单独的全文检索)
        } else {
            aStr = kM3AllSearchUrl_180;
        }
    }else
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        if (index) {
            aStr = kM3FullSearchUrl_180;
        } else {
            aStr = kM3AllSearchUrl_180;
        }
    } else {
        aStr = kM3AllSearchUrl;
    }
    
    aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = NO;
    aCMPBannerViewController.statusBarStyle = 0;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
}
/**
 打开常用应用
 */
- (void)pushCommonAppView {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = kM3CommonAppUrl;
    aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aCMPBannerViewController.hideBannerNavBar = NO;
    aCMPBannerViewController.backBarButtonItemHidden = NO;
    aCMPBannerViewController.statusBarStyle = 0;
    [self.navigationController pushViewController:aCMPBannerViewController animated:YES];
}

- (void)quickButtonAction {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    self.allowRotation = NO;
    UIViewController *viewcontroller = [self rdv_tabBarController];
    [CMPShortcutHelper showInViewController:viewcontroller?:self];
}

- (void)setBackButton {
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count < 1) {
        return;
    }
    
    UIViewController *lastViewController = viewControllers[0];
    NSString *title = lastViewController.title;
    
    if (!title) {
        title = SY_STRING(@"common_back");
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [button setImage:[[UIImage imageNamed:@"banner_return"] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor] forState:UIControlStateNormal];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [CMPThemeManager sharedManager].iconColor};
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:title
                                                                      attributes:attributeDic];
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    buttonTitle = nil;
    [button addTarget:self action:@selector(backBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    [self.bannerNavigationBar setLeftBarButtonItems:@[button]];
    button = nil;
}

- (void)backBarButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.viewLoaded) {
        __weak CMPMessageListView *listView = _listView;
        __weak typeof(self) weakSelf = self;
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [weakSelf updateAppsDownloadViewHidden:self.appsDownloadViewHidden];
            [listView.tableView reloadData];
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (CMPBannerTitleType)bannerTitleType {
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        if (self.isSecondaryPage) {
            return CMPBannerTitleTypeCenter;
        }
        return CMPBannerTitleTypeLeft;
    } else {
        return CMPBannerTitleTypeCenter;
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CMPMessageListCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CMPMessageListCellIdentifier";
    CMPMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPMessageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row < _dataList.count) {
        CMPMessageObject *obj = [_dataList objectAtIndex:indexPath.row];
        [cell setupObject:obj];
        if (self.selectAppId && [obj.cId isEqualToString:self.selectAppId]) {
            [cell setBkViewColor:[[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.2]];
        }
        cell.dragAction = ^{
            [[CMPMessageManager sharedManager] markUnreadWithMessage:obj isMarkUnread:NO];
            if (obj.type == CMPMessageTypeAggregationApp) {
                [[CMPMessageManager sharedManager] readAppMessage];
            } else {
                [[CMPMessageManager sharedManager] readMessageWithAppId:obj clearMessage:YES];
            }
            obj.unreadCount = 0;
        };
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        return NO;
    }
    if (indexPath.row < _dataList.count) {
        CMPMessageObject *obj = [_dataList objectAtIndex:indexPath.row];
        if (obj.type == CMPMessageTypeAssociate) { // 关联消息不能编辑
            return NO;
        }
    } else {
        return NO;
    }

    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_listView.tableView setEditing:NO animated:NO];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                           editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *list = [NSMutableArray array];
    NSString *title = SY_STRING(@"msg_remove");
   
    __weak NSMutableArray *datalist = _dataList;
    __weak UITableView *table = tableView;
    
    __weak CMPMessageObject *obj = nil;
    __weak typeof(self) weakSelf = self;
    if (indexPath.row < _dataList.count) {
        obj = [_dataList objectAtIndex:indexPath.row];
    } else {
        return nil;
    }

    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < datalist.count) {
            if (obj.type == CMPMessageTypeAggregationApp) {
                [[CMPMessageManager sharedManager] deleteAppMessage];
            } else {
                [weakSelf.viewModel deleteChatByCid:obj.cId completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                    
                }];
                [[CMPMessageManager sharedManager] deleteMessageWithAppId:obj];
            }

            [datalist removeObject:obj];

            if (datalist.count == 0) {
                [weakSelf loadData];
            } else {
                [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if (CMP_IPAD_MODE && [self cmp_inMasterStack]) {
                if (self.selectAppId && [obj.cId isEqualToString:self.selectAppId]) {
                    [self.cmp_splitViewController clearDetailViewController];
                }
            }
        }
    }];
    
    delete.backgroundColor = [UIColor cmp_colorWithName:@"app-bgc4"];
    if (obj.type != CMPMessageTypeMassNotification) {
        [list addObject:delete];
    }
    
    title = SY_STRING(@"msg_mark_unread");
    UITableViewRowAction *markUnreadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.viewModel signChatToUnreadByCid:obj.cId isUnread:YES completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            if (!error) {
//                [self.dbProvider topMessage:obj];
            }else if (error.code == -1111||error.code == -1001){
                [[CMPMessageManager sharedManager] markUnreadWithMessage:obj isMarkUnread:YES];
                //ks fix -- 客户bug BUG_重要_V8.0sp2_OS（标准）_国务院国有资产监督管理委员会石化机关服务中心_M3标为未读后重影_BUG2023120581646
//                [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                //end
            }else{
                
            }
        }];
    }];
    
    markUnreadAction.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    if ((obj.type != CMPMessageTypeAssociate && obj.type != CMPMessageTypeMassNotification && obj.type != CMPMessageTypeFileAssistant) && (obj.unreadCount == 0 /*|| obj.isNoDisturb*/) && !obj.extradDataModel.isMarkUnread) {
        [list addObject:markUnreadAction];
    }
    

//    if (obj.type != CMPMessageTypeUC) {
//        if (obj.unreadCount != 0) {
//            title = SY_STRING(@"msg_markRead");
//            UITableViewRowAction *read = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//                if (indexPath.row < datalist.count) {
//                    if (obj.type == CMPMessageTypeAggregationApp) {
//                        [[CMPMessageManager sharedManager] readAppMessage];
//                    } else {
//                        [[CMPMessageManager sharedManager] readMessageWithAppId:obj clearMessage:YES];
//                    }
//                    obj.unreadCount = 0;
//                }
//            }];
//            read.backgroundColor = UIColorFromRGB(0xfdc213);
//            [list addObject:read];
//        }
//    }
    
    
    BOOL istop = obj.isTop;
    title = istop ? SY_STRING(@"msg_canceltop"): SY_STRING(@"msg_top");
    UITableViewRowAction *top = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < datalist.count) {
            obj.isTop = !obj.isTop;
            [[CMPMessageManager sharedManager] topMessage:obj];
        }
    }];
    
    top.backgroundColor = [UIColor cmp_colorWithName:@"gray-bgc1"];
    [list addObject:top];
    
    return list;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < _dataList.count) {
        CMPMessageObject *obj = [_dataList objectAtIndex:indexPath.row];
        if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
            [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
            CMPMessageListCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
            [aCell setSelected:NO];
            return;
        }
        
        self.inTopLevel = NO;
        [[CMPMessageManager sharedManager] showChatView:obj viewController:self];
        [[CMPMessageManager sharedManager] markUnreadWithMessage:obj isMarkUnread:NO];
        if (obj.type == CMPMessageTypeRC) {
            [self.viewModel signChatToUnreadByCid:obj.cId isUnread:NO completion:nil];
        }
        CMPMessageListCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
        if (obj.type != CMPMessageTypeAggregationApp &&
            obj.type != CMPMessageTypeAssociate) {
            obj.unreadCount = 0;
            [aCell removeUnReadCount];
        }
        if (CMP_IPAD_MODE) {
            self.selectAppId = obj.cId;
            [_listView.tableView reloadData];
        }
    }
}

#pragma mark - CMPQuickModuleViewDelegate

- (void)cmpQuickModuleViewDidCancel {
    self.allowRotation = NO;
}

- (void)cmpQuickModuleViewDidSelectedUrl:(NSString *)url {
    self.allowRotation = NO;
    [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:self];
}

- (void)cmpQuickModuleViewDidSelectedScanUrl:(NSString *)url{
    self.allowRotation = NO;
    [[CMPMessageManager sharedManager] showScanViewWithUrl:url viewController:self];
}

- (NSArray*)getListData {
	return _dataList;
}

#pragma mark-
#pragma mark Getter & Setter

- (BOOL)needRefreshMsg {
    if (self.topScreenShow) {
        return NO;
    }else{
        [self.needRefreshMsgLock lock];
        BOOL result = _needRefreshMsg;
        [self.needRefreshMsgLock unlock];
        return result;
    }
}

- (void)setNeedRefreshMsg:(BOOL)needRefreshMsg {
    [self.needRefreshMsgLock lock];
    _needRefreshMsg = needRefreshMsg;
    [self.needRefreshMsgLock unlock];
}

- (NSLock *)needRefreshMsgLock {
    if (!_needRefreshMsgLock) {
        _needRefreshMsgLock = [[NSLock alloc] init];
    }
    return _needRefreshMsgLock;
}

#pragma -mark 字体大小改变

- (void)fontChangedAction:(NSNotification *)aNotification {
    [_listView.tableView reloadData];
}

#pragma -mark 显示应用包下载进度条
- (void)appsDownloadAction:(NSNotification *)aNotification {
    if ([CMPCheckUpdateManager sharedManager].firstDownloadDone) return;
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        if (!weakSelf.inTopLevel) {
            return;
        }
        NSDictionary *aValue = aNotification.object;
        NSString *state = [aValue objectForKey:@"state"];
        if ([state isEqualToString:@"start"]) {
            [weakSelf updateAppsDownloadViewHidden:NO];
            [weakSelf.appsDownloadProgressView showUpdateProgress];
        }
        else if ([state isEqualToString:@"progress"]) {
            CGFloat aProgress = [[aValue objectForKey:@"value"] floatValue]*100;
            if (!weakSelf.appsDownloadProgressView) {
                [weakSelf updateAppsDownloadViewHidden:NO];
            }
            [weakSelf.appsDownloadProgressView updateProgress:aProgress];
        }
        else if ([state isEqualToString:@"success"] ) {
            [weakSelf.appsDownloadProgressView updateProgress:100];
            [weakSelf updateAppsDownloadViewHidden:YES];
        }
        else if ([state isEqualToString:@"fail"]) {
            NSString *zipAppName = aValue[@"zipAppName"];
            if (!weakSelf.appsDownloadProgressView) {
                [weakSelf updateAppsDownloadViewHidden:NO];
            }
            [weakSelf.appsDownloadProgressView showError:nil byZipAppName:zipAppName];
        }
    }];
}

- (void)updateAppsDownloadViewHidden:(BOOL)aHidden {
    if (self.topScreenShow) {
        return;
    }
//    if (self.isShowNetworkTip) {
//        aHidden = YES;
//    }
    self.appsDownloadViewHidden = aHidden;
    if (!aHidden) {
        CGRect f = [super mainFrame];
        if (!_appsDownloadProgressView) {
            _appsDownloadProgressView = [[CMPAppsDownloadProgressView alloc] init];
            [self.view addSubview:_appsDownloadProgressView];
        }
        _appsDownloadProgressView.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, 40);
    }
    else {
        if (_appsDownloadProgressView) {
            [_appsDownloadProgressView removeFromSuperview];
            _appsDownloadProgressView = nil;
        }
    }
    self.mainView.frame = [self mainFrame];
    [self bringXZIconToFront];
}

- (void)bringXZIconToFront {
    //小致图标会被遮住
    UIView *view = [self.view viewWithTag:kViewTag_XiaozIcon];
    if (view) {
        [self.view bringSubviewToFront:view];
    }
}

- (void)backBarButtonAction:(id)sender {
    if (CMP_IPAD_MODE) {
        [self cmp_clearDetailViewController];
    }
    [super backBarButtonAction:sender];
}

#pragma -mark 重新是否显示网络提示

- (BOOL)canShowNetworkTip {
    return YES;
}

- (void)didUpdateNetworkTip:(BOOL)isShow {
    [self updateAppsDownloadViewHidden:self.appsDownloadViewHidden];
}

- (void)willUpdateNetworkTip:(BOOL)isShow {
   // self.isShowNetworkTip = isShow;
    
    // 网络提示展示的时候，多端在线不展示
    if (isShow) {
        [self updatePcOnlineBannerHidden:YES];
    } else {
        [self updatePcOnlineBannerHidden:self.pcOnlineBannerHidden];
    }
}

#pragma -mark 处理气泡拖动效果

/**
 气泡开始拖动
 */
- (void)unreadCountDragBegan {
    self.unreadCountInDrag = YES;
}

/**
 气泡结束拖动
 */
- (void)unreadCountDragEnd {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.unreadCountInDrag = NO;
    });
}

#pragma -mark PC在线提醒

- (void)onlineDevDidChange:(NSNotification *)notification {
    CMPOnlineDevModel *model = notification.userInfo[@"onlineDev"];
    self.onlineDev = model;
    if (self.topScreenShow || [CMPCore sharedInstance].topScreenBeginShow) {
        return;
    }
    if (!model.isMultiOnline) {
        // 其它端全部不在线，隐藏banner
        [self updatePcOnlineBannerHidden:YES];
    } else {
        [self updatePcOnlineBannerHidden:NO];
        [self.pcOnlineBanner updateTipMessageWithOnlineModel:self.onlineDev muteState:![CMPCore sharedInstance].multiLoginReceivesMessageState];
    }
}

- (CGRect)mainFrame {
    CGRect f = [super mainFrame];
    if (!_pcOnlineBannerHidden || !_appsDownloadViewHidden) {
        f.origin.y += 40;
        f.size.height -= 40;
    }
    return f;
}

- (void)updatePcOnlineBannerHidden:(BOOL)aHidden {
    if (self.topScreenShow) {
        return;
    }
    // 下载提示展示时，多端在线不展示
    if (!self.appsDownloadViewHidden) {
        aHidden = YES;
    }
    _pcOnlineBannerHidden = aHidden;
    if (!aHidden) {
        CGRect f = [super mainFrame];
        self.pcOnlineBanner.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, 40);
    } else {
        if (_pcOnlineBanner) {
            [_pcOnlineBanner removeFromSuperview];
            _pcOnlineBanner = nil;
            if (!self.appsDownloadViewHidden) {
                [self updateAppsDownloadViewHidden:self.appsDownloadViewHidden];
            }
        }
    }
    self.mainView.frame = [self mainFrame];
}

- (void)updatePcOnlineBannerFrameByHidden:(BOOL)aHidden {
    
}

- (CMPPCOnlineBanner *)pcOnlineBanner {
    if (!_pcOnlineBanner) {
        _pcOnlineBanner = [[CMPPCOnlineBanner alloc] init];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPcOnlineBanner)];
        [_pcOnlineBanner addGestureRecognizer:tapRecognizer];
        [self.view addSubview:_pcOnlineBanner];
        [self bringXZIconToFront];
    }
    return _pcOnlineBanner;
}

//- (void)tapPcOnlineBanner {
//    if (!self.onlineDev.pcOnline && !self.onlineDev.ucOnline) {
//        return;
//    }
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    __weak typeof(self) weakSelf = self;
//    if (self.onlineDev.pcOnline) {
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:SY_STRING(@"mu_login_exit_web") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf cmp_showProgressHUDInView:weakSelf.view];
//            [[CMPMessageManager sharedManager] logoutDeviceType:1 completion:^(NSError *error) {
//                [weakSelf cmp_hideProgressHUD];
//                [weakSelf cmp_showSuccessHUDInView:weakSelf.view];
//                [[CMPMessageManager sharedManager] refreshMessage];
//            }];
//        }];
//        [alertController addAction:action1];
//    }
//
//    if (self.onlineDev.ucOnline) {
//        UIAlertAction *action2 = [UIAlertAction actionWithTitle:SY_STRING(@"mu_login_exit_zhixin")  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf cmp_showProgressHUDInView:weakSelf.view];
//            [[CMPMessageManager sharedManager] logoutDeviceType:4 completion:^(NSError *error) {
//                [weakSelf cmp_hideProgressHUD];
//                [weakSelf cmp_showSuccessHUDInView:weakSelf.view];
//                [[CMPMessageManager sharedManager] refreshMessage];
//            }];
//        }];
//        [alertController addAction:action2];
//    }
//
//    UIAlertAction *action3 = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction:action3];
//    alertController.popoverPresentationController.sourceView = self.view;
//    alertController.popoverPresentationController.sourceRect = CGRectMake(self.view.cmp_width / 2, 64 + 40, 1, 1);
//    [self presentViewController:alertController animated:YES completion:nil];
//}

- (void)tapPcOnlineBanner {
    if (!self.onlineDev.isMultiOnline) {
        return;
    }
    
    CMPMultiLoginManageViewController *controller = [[CMPMultiLoginManageViewController alloc] initWithOnlineDevModel:self.onlineDev presentViewController:self];
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
    
}

@end

