//
//  CMPOfflineContactViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/3.
//
//

#import "CMPOfflineContactViewController.h"
#import "CMPOfflineContactView.h"

#import "CMPOfflineContactCell.h"
#import "CMPOfflineContactTopCell.h"
#import "CMPContactsManager.h"
#import "CMPContactsResult.h"
#import <CMPLib/CMPPersonInfoUtils.h>
#import "CMPOfflineContactsUtils.h"
#import "CMPContactsSearchResultViewController.h"
#import "CMPLocalDataPlugin.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/UIImage+CMPImage.h>
#import "CMPCommonManager.h"
#import "CMPGestureHelper.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPCommonTool.h>

// icon宽度
static CGFloat const searchIconW = 20.0;
// icon与placeholder间距
static CGFloat const iconSpacing = 5.0;

@interface CMPOfflineContactViewController () <UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating,UISearchControllerDelegate>{
    CMPOfflineContactView *_contactView;
    BOOL _loadData;
    
    BOOL _showAZView;//老版本显示a-z ：yes，新版本显示最近联系人是 ：no
}
@property(nonatomic, retain)NSArray *keyList;
@property(nonatomic, retain)NSDictionary *dataDictionary;
@property(nonatomic,retain) UISearchController *searchViewController;
@property(nonatomic,retain) CMPContactsSearchResultViewController *searchResultVC;
@property(nonatomic,copy) NSString *headImgStr;// placeholder 和icon 和 间隙的整体宽度
@property (nonatomic, assign) CGFloat placeholderWidth;
@property (assign, nonatomic) BOOL isSearchMode;

@end

@implementation CMPOfflineContactViewController


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SY_RELEASE_SAFELY(_keyList);
    SY_RELEASE_SAFELY(_dataDictionary)
    SY_RELEASE_SAFELY(_searchViewController);
    SY_RELEASE_SAFELY(_searchResultVC);
    SY_RELEASE_SAFELY(_headImgStr);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _showAZView = ![[CMPCore sharedInstance] serverIsLaterV1_8_0];
    [self setTitle:SY_STRING(@"contacts")];
    
    _contactView = (CMPOfflineContactView *) self.mainView;
    _showAZView ? [self setupAZView]:[self setupFrequentView];
    _loadData = NO;
    if (_isShowBackButton) {
        self.backBarButtonItemHidden = NO;
    }
    [self setupSearchBar];
    [self addNotifications];
    _contactView.tableview.delegate = self;
    _contactView.tableview.dataSource = self;
    [_contactView.tableview setContentOffset:CGPointZero animated:NO];
    self.allowRotation = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.isSearchMode) {
        [self searchBarPlaceholderToLeft:_searchViewController.searchBar];
    } else {
        [self layoutSearchBar];
        [self searchBarPlaceholderToMiddle:_searchViewController.searchBar];
        [_contactView.tableview setContentOffset:CGPointZero animated:NO];
    }
    
    if (_showAZView) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            _contactView.spellBar.hidden = YES;
        } else {
            _contactView.spellBar.hidden = NO;
        }
    }
}

- (void)layoutSearchBar {
    UISearchBar *searchBar = _searchViewController.searchBar;
    _searchResultVC.searchBarHeight = searchBar.height;
    CGRect r = searchBar.frame;
    if (searchBar.height == 0) {
        r.size.height = 44;
    }
    r.size.width = [UIWindow mainScreenSize].width;
    searchBar.frame = r;
    searchBar.searchTextPositionAdjustment = UIOffsetMake(5, 0);
}

- (void)setupSearchBar
{
    _searchResultVC = [[CMPContactsSearchResultViewController alloc] init];
    _searchResultVC.allowRotation = NO;
    _searchViewController = [[UISearchController alloc] initWithSearchResultsController:_searchResultVC];
    if ([_searchViewController respondsToSelector:@selector(setObscuresBackgroundDuringPresentation:)]) {
        _searchViewController.obscuresBackgroundDuringPresentation = NO;
    }
    
    UISearchBar *searchBar = _searchViewController.searchBar;
    _searchResultVC.searchBar = searchBar;
    _searchViewController.hidesNavigationBarDuringPresentation = NO;
    _searchViewController.searchResultsUpdater = self;
    _searchViewController.delegate = self;
    
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        searchBar.placeholder = SY_STRING(@"contacts_searchkey_new");
    } else {
        searchBar.placeholder = SY_STRING(@"contacts_searchkey_old");
    }
    
    [self layoutSearchBar];
    
    _contactView.tableview.tableHeaderView = searchBar;
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.searchBarStyle =  UISearchBarStyleMinimal;
    searchBar.barStyle = UIBarStyleBlack;
    UIImage *bgImage = [UIImage imageWithName:@"searchbar_bg" inBundle:@"offlineContact"];
    UIImage *iconImage = [UIImage imageWithName:@"searchbar_icon" inBundle:@"offlineContact"];
    [searchBar setSearchFieldBackgroundImage:bgImage forState:UIControlStateNormal];
    [searchBar setImage:iconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    [self searchBarPlaceholderToMiddle:searchBar];
    
    UITextField *searchField = [CMPCommonTool getSearchFieldWithSearchBar:_searchViewController.searchBar];
    searchField.font = [UIFont systemFontOfSize:12];
    NSDictionary *attrDic = @{NSForegroundColorAttributeName : UIColorFromRGB(0xA1B0C5) ,
                              NSFontAttributeName : [UIFont systemFontOfSize:12]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:searchBar.placeholder attributes:attrDic];
    searchField.attributedPlaceholder = attrStr;
    SY_RELEASE_SAFELY(attrStr);
}


- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactsBegin) name:kContactsUpdate_Begin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactsFinish) name:kContactsUpdate_Finish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFrequentData) name:kFequestLoadFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactsFail) name:kContactsUpdate_Fail object:nil];
}

- (void)updateInfoLabel {
    OfflineStatus status = [[CMPContactsManager defaultManager] offlineStatus];
    switch (status) {
        case OfflineStatusNormal:
            [_contactView showInfoLabel:SY_STRING(@"contacts_downloading")];
            break;
        case OfflineStatusUpating:
            [_contactView showInfoLabel:SY_STRING(@"contacts_downloading")];
            break;
        case OfflineStatusFinish:
            [_contactView hideLabels];
            [_contactView.tableview setContentOffset:CGPointZero animated:NO];
            break;
        case OfflineStatusFail:
            [_contactView showErrorLabelClick:^{
                [_contactView showInfoLabel:SY_STRING(@"contacts_downloading")];
                [_contactView.tableview setContentOffset:CGPointZero animated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[CMPContactsManager defaultManager] beginUpdate];
                });
            }];
            break;
    }
}

- (void)setupAZView{
    //A-Z 界面配置
//    if ([[CMPContactsManager defaultManager] offlineStatus] != OfflineStatusUpating) {
//        _contactView.infoLabel.text = SY_STRING(@"contacts_getData");
//        [_contactView customLayoutSubviews];
//    }
    [self updateInfoLabel];
    _contactView.spellBar.selectedBlock =^(NSInteger section) {
        if (section > _keyList.count) {
            return ;
        }
        if(section == 0) {
            [_contactView.tableview setContentOffset:CGPointZero animated:NO];
        }
        else {
            [_contactView.tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                animated:NO
                                          scrollPosition:UITableViewScrollPositionTop];
        }
    };
}

- (void)setupFrequentView{
    //最近联系人 界面配置
//    if ([[CMPContactsManager defaultManager] offlineStatus] != OfflineStatusUpating) {
//        _contactView.infoLabel.hidden = YES;
//        [_contactView hideLabels];
//        [_contactView customLayoutSubviews];
//    }
    [self updateInfoLabel];
    _contactView.spellBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_loadData) {
        if (_showAZView) {
            [self loadAZData];
        }
        else {
            [self loadFrequentData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_contactView.spellBar panAnimationFinish];
}

- (void)updateContactsBegin
{
    [_contactView showInfoLabel:SY_STRING(@"contacts_downloading")];
}

- (void)updateContactsFinish
{
    __weak CMPOfflineContactView *contactView = _contactView;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_showAZView) {
            [contactView showInfoLabel:SY_STRING(@"contacts_getData")];
        }
        else {
            [contactView hideLabels];
            [contactView.tableview setContentOffset:CGPointZero animated:NO];
        }
    });
    [self loadAZData];
}

- (void)updateContactsFail
{
    [self loadAZData];
    [self updateInfoLabel];
    [_contactView.tableview setContentOffset:CGPointZero animated:NO];
}

- (void)loadAZData
{
    //加载A-Z 数据
    if (!_contactView || !_showAZView) {
        return;
    }
    _loadData = YES;
    __weak CMPOfflineContactViewController* weakSelf = self;
    __weak CMPOfflineContactView *contactView = _contactView;
    [[CMPContactsManager defaultManager] allMemberInAz:^(CMPContactsResult *result) {
        if (!result.sucessfull) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 禁用tableview
            contactView.tableview.userInteractionEnabled = NO;
            weakSelf.dataDictionary = result.dataDic;
            weakSelf.keyList = result.keyList;
            
            NSMutableArray *array = [NSMutableArray arrayWithObject:@"search"];
            [array addObjectsFromArray:weakSelf.keyList];
            
//            if ([[CMPContactsManager defaultManager] offlineStatus] == OfflineStatusFinish) {
//                [contactView hideLabels];
//                [contactView.tableview setContentOffset:CGPointZero animated:NO];
//            }
            [self updateInfoLabel];
            [contactView.tableview reloadData];
            contactView.spellBar.indexArray = array;
            contactView.tableview.userInteractionEnabled = YES;
        });
    }];
}

- (void)loadFrequentData
{
     //加载最近联系人 数据
    if (!_contactView) {
        return;
    }
    _loadData = YES;
    __weak CMPOfflineContactViewController* weakSelf = self;
    __weak CMPOfflineContactView *contactView = _contactView;
    [[CMPContactsManager defaultManager] allFrequentContact:^(CMPContactsResult *result) {
        if (!result.sucessfull) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            contactView.tableview.userInteractionEnabled = NO;
            weakSelf.dataDictionary = result.dataDic;
            weakSelf.keyList = result.keyList;
            [contactView.tableview setContentOffset:CGPointZero animated:NO];
            [contactView.tableview reloadData];
            contactView.tableview.userInteractionEnabled = YES;
        });
    }];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //检索符合条件的数据，更新搜索结果vc
    _searchResultVC.searchKeyword = searchController.searchBar.text;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.isSearchMode = YES;
    [self searchBarPlaceholderToLeft:_searchViewController.searchBar];
    [_contactView hideTableView];
    [self rdv_tabBarController].tabBar.hidden = YES;
    
    // 调整SearchBar位置
    CGFloat height = [UIView staticStatusBarHeight];
    UIView *view = [searchController.searchBar superview];
    if (view.superview == searchController.view ) {
        CGRect f = view.frame;
        f.origin.y = height;
        view.frame = f;
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.isSearchMode = NO;
    self.allowRotation = NO;
    [_contactView showTableView];
    if (!self.isShowBackButton) { // tabbar上显示的通讯录
        [self rdv_tabBarController].tabBar.hidden = NO;
    }
    [_contactView customLayoutSubviews];
    [_contactView.tableview setContentOffset:CGPointZero animated:NO];
    [self layoutSearchBar];
    [self searchBarPlaceholderToMiddle:_searchViewController.searchBar];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //搜索
    return _showAZView ? _keyList.count +1 : (_loadData ? 2:1);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // a----z
    if (section ==0) {
        return 1;
    }
    
    if (section-1 < _keyList.count) {
        NSArray *list =  [_dataDictionary objectForKey:[_keyList objectAtIndex:section-1]];
        if (!_showAZView && list.count == 0) {
            //暂无数据
            return 1;
        }
        return list.count;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        // a----z
        return _showAZView ? 24 : 34;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        // a----z
        NSString *key = [_keyList objectAtIndex:section-1];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contactView.width, _showAZView ? 24 : 34)];
        view.backgroundColor = _showAZView ? UIColorFromRGB(0xf4f4f4):[UIColor whiteColor];
        UILabel * label = [[UILabel alloc]init];
        label.frame = _showAZView ?CGRectMake(14, 0, _contactView.width-28, 24):CGRectMake(14, 14, _contactView.width-28, 20);
        label.text = key;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = _showAZView ? [UIColor blackColor]:UIColorFromRGB(0xa1b0c5);
        label.font = FONTSYS(14);
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        [label release];
        label = nil;
        return [view autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( !_showAZView&& section == 0 ) {
        // a----z
        return 10;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ( !_showAZView&& section == 0 ) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contactView.width, 24)];
        view.backgroundColor = UIColorFromRGB(0xf4f4f4);
        return [view autorelease];
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [CMPOfflineContactTopCell cellHeight];
    }
    return [CMPOfflineContactCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *identifier = @"topidentifier";
        CMPOfflineContactTopCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[CMPOfflineContactTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            _showAZView ? [cell setupAZView]:[cell setupFrequentView];
            
            [cell.orgButton addTarget:self action:@selector(showOrgView) forControlEvents:UIControlEventTouchUpInside];
            [cell.teamButton addTarget:self action:@selector(showTeamView) forControlEvents:UIControlEventTouchUpInside];
            [cell.groupButton addTarget:self action:@selector(showGroupChatView) forControlEvents:UIControlEventTouchUpInside];
            [cell.contactsButton addTarget:self action:@selector(showContactsView) forControlEvents:UIControlEventTouchUpInside];
            [cell.relatedButton addTarget:self action:@selector(showRelatedView) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    if (!_showAZView) {
        NSString *key = [_keyList objectAtIndex:0];
        NSArray *list =  [_dataDictionary objectForKey:key];
        if (list.count == 0) {
            NSString *identifier = @"nthingIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
                cell.textLabel.text = SY_STRING(@"common_nodata");
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }
    NSString *identifier = @"CMPOfflineContactCellIdentifier";
    CMPOfflineContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[CMPOfflineContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    if (indexPath.section-1 < _keyList.count) {
        NSString *key = [_keyList objectAtIndex:indexPath.section-1];
        NSArray *list =  [_dataDictionary objectForKey:key];
        if (indexPath.row<list.count) {
            id value = [list objectAtIndex:indexPath.row];
            [cell setupDataWithMember:value];            
            [cell addLineWithRow:indexPath.row RowCount:list.count];
        }
    }
    //加载头像
    if (tableView.dragging == NO && tableView.decelerating == NO) {
        if ([cell respondsToSelector:@selector(loadFaceImage)]) {
            [cell performSelector:@selector(loadFaceImage)];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section-1 < _keyList.count) {
        NSString *key = [_keyList objectAtIndex:indexPath.section-1];
        NSArray *list =  [_dataDictionary objectForKey:key];
        if (indexPath.row<list.count) {
            CMPOfflineContactMember *value = [list objectAtIndex:indexPath.row];
            [CMPPersonInfoUtils showPersonInfoView:value.orgID from:@"contacts" enableChat:YES parentViewController:self allowRotation:YES];
        }
    }
}


#pragma mark load faceview begin
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate) {
//        [self loadFaceImagesForOnscreenRows];
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self loadFaceImagesForOnscreenRows];
//}
//
//- (void)loadFaceImagesForOnscreenRows
//{
//    NSArray *visiblePaths = [_contactView.tableview indexPathsForVisibleRows];
//    for (NSIndexPath *indexPath in visiblePaths) {
//        UITableViewCell *aCell = [_contactView.tableview cellForRowAtIndexPath:indexPath];
//        if ([aCell isKindOfClass:[CMPOfflineContactCell class]]) {
//            CMPOfflineContactCell *cell = (CMPOfflineContactCell *)aCell;
//            [cell loadFaceImage];
//        }
//    }
//}
#pragma mark load faceview end

#pragma mark-
#pragma mark UISearchControllerDelegate

- (void)showOrgView
{
    [CMPOfflineContactsUtils showOrganizationView:self];
}

- (void)showTeamView
{
    [CMPOfflineContactsUtils showProjectTeamView:self];
}

- (void)showGroupChatView
{
    [CMPOfflineContactsUtils showGroupChatView:self];
}

- (void)showContactsView
{
    [CMPOfflineContactsUtils showFrequentContactsView:self];
}

- (void)showRelatedView
{
    [CMPOfflineContactsUtils showRelatedView:self];
}

#pragma mark-
#pragma mark 重载父类方法

- (BOOL)canShowNetworkTip {
    return NO;
}

#pragma mark-
#pragma mark 私有方法

/**
 将searchBar的文字、图标居中显示
 */
- (void)searchBarPlaceholderToMiddle:(UISearchBar *)searchBar {
    if (@available(iOS 11.0, *)) {
        [searchBar setPositionAdjustment:UIOffsetMake((searchBar.width - self.placeholderWidth - 16) / 2, 0) forSearchBarIcon:UISearchBarIconSearch];
    }
}

/**
 将searchBar的文字、图标靠左显示
 */
- (void)searchBarPlaceholderToLeft:(UISearchBar *)searchBar {
    if (@available(iOS 11.0, *)) {
        [searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}

- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [_searchViewController.searchBar.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
        _placeholderWidth = size.width + iconSpacing + searchIconW;
    }
    return _placeholderWidth;
}

@end
