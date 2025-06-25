//
//  CMPContactsSearchResultManager.m
//  M3
//
//  Created by CRMO on 2017/11/27.
//

#import "CMPContactsSearchResultController.h"
#import "CMPContactsSearchMemberProvider.h"

#import <CMPLib/CMPOfflineContactMember.h>
#import "CMPOfflineContactCell.h"
#import <CMPLib/CMPPersonInfoUtils.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPContactsManager.h"
#import "CMPCommonManager.h"
#import <CMPLib/AFNetworkReachabilityManager.h>
#import <CMPLib/MJRefresh.h>
#import <CMPLib/SyNothingView.h>
#import <CMPLib/Masonry.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPSelectContactManager.h"
#import "CMPForwardSearchViewController.h"
typedef NS_ENUM(NSUInteger, CMPContactsSearchResultMode) {
    CMPContactsSearchResultModeOffline = 0, // 离线搜索
    CMPContactsSearchResultModeOnline = 1, // 在线搜索
    CMPContactsSearchResultModeDefault = CMPContactsSearchResultModeOffline,
};

/** 在线搜索请求间隔 **/
NSTimeInterval const kCMPContactsSearchResultRequestTimeInterval = 1;

@interface CMPContactsSearchResultController()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,CMPBaseTableViewCellDelegate>
{
    NSMutableArray *_showAllPathStateArr;
    NSInteger _cellStyleType;
}
/** 搜索模式，离线（默认）、在线 **/
@property (assign, nonatomic) CMPContactsSearchResultMode mode;
/** 离线的所有人员信息 **/
@property (strong, nonatomic) NSArray<CMPOfflineContactMember *> *allMembers;
@property (strong, nonatomic) CMPContactsSearchMemberProvider *searchMemberProvider;
/** 搜索结果 **/
@property (strong, nonatomic) NSMutableArray *searchResultArr;
/** 当前搜索关键词 **/
@property (strong, nonatomic, setter=searchWithKeyWord:) NSString *searchKeyword;
/** 是否支持在线搜索，服务器1.8.0以后版本支持 **/
@property (assign, nonatomic) BOOL supportOnlineSearch;
/** 在线搜索，当前页数 **/
@property (assign, nonatomic) NSUInteger pageNumber;
@property (strong, nonatomic) SyNothingView *nothingView;

/** 是否是多维组织搜索 **/
@property (assign, nonatomic) BOOL isScope;
/** 多维组织搜索ID，仅 isScope== true 有效 **/
@property (strong, nonatomic) NSString *businessID;

@property (assign, nonatomic) BOOL isMultipleSelect;

@end

@implementation CMPContactsSearchResultController

#pragma mark-
#pragma mark-API

- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
                      isScope:(BOOL)scope
                   businessID:(NSString *)businessID
              searchBarHeight:(CGFloat)searchBarHeight
                     delegate:(id<CMPContactsSearchResultControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.mainView = [[CMPContactsSearchResultView alloc] initWithFrame:frame
                                                             showSearchBar:showSearchBar
                                                           searchBarHeight:searchBarHeight];
        UITableView *tableView = self.mainView.tableView;
        tableView.dataSource = self;
        tableView.delegate  = self;
        tableView.hidden = YES;
        self.mainView.searchBar.delegate = self;
        self.delegate = delegate;
        self.isScope = scope;
        self.businessID = businessID;
        _showAllPathStateArr = [[NSMutableArray alloc] init];
        _cellStyleType = [CMPServerVersionUtils serverIsLaterV8_1] ? 1 : 0;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
             isMultipleSelect:(BOOL)isMultipleSelect
                      isScope:(BOOL)scope
                   businessID:(NSString *)businessID
              searchBarHeight:(CGFloat)searchBarHeight
                     delegate:(id<CMPContactsSearchResultControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.isMultipleSelect = isMultipleSelect;
        self.mainView = [[CMPContactsSearchResultView alloc] initWithFrame:frame
                                                             showSearchBar:showSearchBar
                                                           searchBarHeight:searchBarHeight
                                                          isMultipleSelect:isMultipleSelect
                                                                  delegate:delegate];
        UITableView *tableView = self.mainView.tableView;
        tableView.dataSource = self;
        tableView.delegate  = self;
        tableView.hidden = YES;
        self.mainView.searchBar.delegate = self;
        self.delegate = delegate;
        self.isScope = scope;
        self.businessID = businessID;
        _showAllPathStateArr = [[NSMutableArray alloc] init];
        _cellStyleType = [CMPServerVersionUtils serverIsLaterV8_1] ? 1 : 0;
    }
    return self;
}


- (void)loadAllMember {
    if (_delegate && [_delegate respondsToSelector:@selector(searchResultWillLoadData:)]) {
        [_delegate searchResultWillLoadData:self];
    }
    
    __weak typeof(self) weakself = self;
    [[CMPContactsManager defaultManager] allMembersCompletion:^(NSArray<CMPOfflineContactMember *> *allMembers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!allMembers || allMembers.count == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(searchResultFailLoadData:)]) {
                    [self.delegate searchResultFailLoadData:self];
                }
                return;
            }
            
            weakself.allMembers = allMembers;
            if (self.delegate && [self.delegate respondsToSelector:@selector(searchResultDidLoadData:)]) {
                [self.delegate searchResultDidLoadData:self];
            }
        });
    }];
}

#pragma mark-
#pragma mark-搜索

/**
 在线搜索，搜索全集团
 */
- (void)searchOnlineWithKeyword:(NSString *)searchKeyword {
    [self.searchMemberProvider cancel];
    __weak typeof(self) weakself = self;
    
    if (self.isScope) {
        [self.searchMemberProvider searchScopeWithBusinessID:self.businessID keyword:searchKeyword pageNumber:self.pageNumber success:^(CMPContactsSearchMemberResponse *aResponse) {
            [weakself _searchSuccess:aResponse];
        } fail:^(NSError *error) {
            [weakself.mainView.tableView.mj_footer endRefreshing];
        }];
    } else {
        [self.searchMemberProvider searchWithAccountID:@"-1" keyword:searchKeyword pageNumber:self.pageNumber success:^(CMPContactsSearchMemberResponse *aResponse) {
            [weakself _searchSuccess:aResponse];
        } fail:^(NSError *error) {
            [weakself.mainView.tableView.mj_footer endRefreshing];
            [weakself searchOfflineWithKeyword:searchKeyword];
        }];
    }
}

- (void)_searchSuccess:(CMPContactsSearchMemberResponse *)aResponse {
    [self dispatchAsyncToMain:^{
        [self showNothingView:NO];
        if ([aResponse.total isEqualToString:@"0"]) {
            [self showNothingView:YES];
        }
        [self reloadDataWithResponse:aResponse];
        if (self.pageNumber == 1) {
            [self scrollToTop];
        }
        self.pageNumber++;
    }];
}

/**
 离线搜索，搜索本单位
 */
- (void)searchOfflineWithKeyword:(NSString *)searchKeyword {
    if (!_allMembers ||
        [_allMembers count] == 0) {
        return;
    }
    
    [self.searchResultArr removeAllObjects];
    [self showNothingView:NO];
    NSPredicate *predicate = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        //匹配姓名和电话号码中是否包含搜索词，如添加其他条件，直接修改谓词
        predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@ OR mobilePhone CONTAINS %@ OR nameSpellHead CONTAINS[c] %@",_searchKeyword,_searchKeyword,_searchKeyword];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@ OR mobilePhone CONTAINS %@",_searchKeyword,_searchKeyword];
    }
    
    NSArray *ret = [_allMembers filteredArrayUsingPredicate:predicate];
    [self.searchResultArr addObjectsFromArray:ret];
    self.mainView.tableView.hidden = NO;
    [self.mainView.tableView reloadData];
    
    if (self.searchResultArr.count == 0) {
        [self showNothingView:YES];
    }
}

/**
 在线搜索下一页
 */
- (void)searchOnlineNextPage {
    if (self.mode != CMPContactsSearchResultModeOnline) {
        return;
    }
    [self searchOnlineWithKeyword:self.searchKeyword];
}

#pragma mark-
#pragma mark-Getter & Setter

- (void)searchWithKeyWord:(NSString *)aSearchKeyword {
    //8.0产品质量优化流程-江富祥-ZCXD-202005-00357
//    NSString *searchKeyword = [NSString isNull:aSearchKeyword]?@"":[aSearchKeyword replaceCharacter:@" " withString:@""];
    //BUG_紧急_OS+ES（VIP）_嘉里置业（中国）投资有限公司_V7.1sp1_客户为香港的客户，姓名为英语，当搜索通讯录时，很长的英语名字，如果英语名字中间有空格，就搜索不到了_BUG2021011930813
    NSString *searchKeyword = [NSString isNull:aSearchKeyword]?@"":aSearchKeyword;
    if ([NSString judgePhoneNumber:searchKeyword]) {
        searchKeyword = [searchKeyword replaceCharacter:@" " withString:@""];
    }
    
    if ([_searchKeyword isEqualToString:searchKeyword]) {
        return;
    }
    
    _searchKeyword = searchKeyword;
    
    if ([NSString isNull:searchKeyword]) {
        [self removeCellAndHideTableView];
        return;
    }
    
    [self.searchResultArr removeAllObjects];
    [_showAllPathStateArr removeAllObjects];
    
    if (self.mode == CMPContactsSearchResultModeOnline) {
        self.pageNumber = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(searchOnlineWithKeyword:)
                   withObject:searchKeyword
                   afterDelay:kCMPContactsSearchResultRequestTimeInterval];
    } else {
        [self searchOfflineWithKeyword:searchKeyword];
    }
}

- (NSMutableArray *)searchResultArr {
    if (!_searchResultArr) {
        _searchResultArr = [NSMutableArray array];
    }
    return _searchResultArr;
}

- (CMPContactsSearchMemberProvider *)searchMemberProvider {
    if (!_searchMemberProvider) {
        _searchMemberProvider = [[CMPContactsSearchMemberProvider alloc] init];
    }
    return _searchMemberProvider;
}

/**
 是否支持在搜索
 判断逻辑：1.8.0之后默认支持在线搜索，1.8.0之前服务器从服务端取config，如果有对应补丁包支持在线搜索。
 */
- (BOOL)supportOnlineSearch {
    _supportOnlineSearch = NO;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        _supportOnlineSearch = YES;
    } else {
        CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
        NSString *configStr = currentUser.configInfo;
        CMPLoginConfigInfoModel *configInfoModel = [CMPLoginConfigInfoModel yy_modelWithJSON:configStr];
        _supportOnlineSearch = configInfoModel.data.hasAddressBookIndex;
    }
    return _supportOnlineSearch;
}

- (CMPContactsSearchResultMode)mode {
    BOOL reachableServer = [CMPCommonManager reachableServer];
    
    // 多维组织搜索只支持在线搜索
    if ((reachableServer && self.supportOnlineSearch) ||
        _isScope) {
        _mode = CMPContactsSearchResultModeOnline;
        if (!self.mainView.tableView.mj_footer) {
            self.mainView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchOnlineNextPage)];
        }
    } else {
        _mode = CMPContactsSearchResultModeOffline;
        self.mainView.tableView.mj_footer = nil;
    }
    return _mode;
}

#pragma mark-
#pragma mark-UI

- (void)removeCellAndHideTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchResultArr removeAllObjects];
        [self.mainView.tableView reloadData];
        [self.mainView.tableView setNeedsLayout];
        [self.mainView.tableView layoutIfNeeded];
        self.mainView.tableView.hidden = YES;
    });
}

- (void)reloadDataWithResponse:(CMPContactsSearchMemberResponse *)aResponse {
    NSArray<CMPContactsSearchMemberResponseChildren *> *children = aResponse.children;
    for (CMPContactsSearchMemberResponseChildren *child in children) {
        CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
        member.name = child.n;
        member.postName = child.pN ?: child.p;
        member.orgID = child.i ?: child.orgID;
        if (child.dfn.length) {
            member.parentDepts = [child.dfn componentsSeparatedByString:@"/"];
        }
        [self.searchResultArr addObject:member];
    }
    
    self.mainView.tableView.hidden = NO;
    [self.mainView layoutSubviews];
    [self.mainView.tableView reloadData];
    [self endRefreshWithCurrentCount:self.searchResultArr.count
                          totalCount:[aResponse.total integerValue]];
}

- (void)endRefreshWithCurrentCount:(NSInteger)currentCount totalCount:(NSInteger)totalCount {
    if (currentCount >= totalCount) {
        [self.mainView.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.mainView.tableView.mj_footer endRefreshing];
    }
    
    if (self.searchResultArr.count == 0) {
        self.mainView.tableView.hidden = YES;
    }
}

- (void)scrollToTop {
    if ([self.mainView.tableView visibleCells].count > 0) {
        [self.mainView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:NO];
    }
}

- (void)showNothingView:(BOOL)show {
    if (show) {
        if (!_nothingView) {
            CGRect tableViewFrame = self.mainView.tableView.frame;
            CGRect nothingViewFrame = CGRectMake(CGRectGetMinX(tableViewFrame), CGRectGetMinY(tableViewFrame), CGRectGetWidth(tableViewFrame), CGRectGetHeight(tableViewFrame) - 50);
            _nothingView = [[SyNothingView alloc] initWithFrame:nothingViewFrame];
        }
        [_nothingView removeFromSuperview];
        [self.mainView addSubview:_nothingView];
        [_nothingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mainView.tableView);
        }];
    }
    else {
        [_nothingView removeFromSuperview];
    }
}

#pragma mark-
#pragma mark-UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<self.searchResultArr.count) {
        id value = [self.searchResultArr objectAtIndex:indexPath.row];
        NSInteger styleType = _cellStyleType;
        if ([_showAllPathStateArr containsObject:[NSString stringWithInt:indexPath.row]]) {
            styleType = 2;
        }
        return styleType == 0? [CMPOfflineContactCell cellHeight] : [CMPOfflineContactCell cellHeightWithModel:value styleType:styleType];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"CMPContactsSearchResultManagerCellIdentifier";
    CMPOfflineContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[CMPOfflineContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    
    
    
    if (indexPath.row<self.searchResultArr.count) {
        id value = [self.searchResultArr objectAtIndex:indexPath.row];
        NSInteger styleType = _cellStyleType;
        if ([_showAllPathStateArr containsObject:[NSString stringWithInt:indexPath.row]]) {
            styleType = 2;
        }
        [cell setStyleType:styleType];//ks add 需要先设置
        cell.indexPath = indexPath;
        cell.searchText = _searchKeyword;
        [cell setupDataWithMember:value];
        [cell addLineWithSearchRow:indexPath.row RowCount:self.searchResultArr.count];
        
        
        if(self.isMultipleSelect){//多选
            [cell setSelectImageConfig];
            CMPOfflineContactMember *value = [self.searchResultArr objectAtIndex:indexPath.row];
            cell.selectCell = [[CMPSelectContactManager sharedInstance].selectedCidArr containsObject:value.orgID];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.searchResultArr.count) {
        if(self.isMultipleSelect){//多选
            //老搜索页面直接隐藏键盘
            [self.mainView unFocusTextView];
            if([self.delegate isKindOfClass:CMPForwardSearchViewController.class]){
                CMPForwardSearchViewController *vc = (CMPForwardSearchViewController *)self.delegate;
                [vc.searchBar resignFirstResponder];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:CMPOfflineContactCell.class]) {
                CMPOfflineContactCell *listCell = (CMPOfflineContactCell *)cell;
                listCell.selectCell = !listCell.selectCell;
                if (self.searchResultArr.count>indexPath.row) {
                    CMPOfflineContactMember *value = [self.searchResultArr objectAtIndex:indexPath.row];
                    if(listCell.selectCell){
                        BOOL canSelect = [[CMPSelectContactManager sharedInstance] addSelectContact:value.orgID
                                                                              name:value.name
                                                                              type:1
                                                                           subType:1];
                        if(!canSelect){
                            listCell.selectCell = NO;
                        }
                    }else{
                        [[CMPSelectContactManager sharedInstance] delSelectContact:value.orgID];
                    }
                }
            }            
            return;
        }
        if (self.searchResultArr.count>indexPath.row) {
            CMPOfflineContactMember *value = [self.searchResultArr objectAtIndex:indexPath.row];
            if (_delegate && [_delegate respondsToSelector:@selector(searchResultDidSelectMember:)]) {
                /*用于点击搜索结果的列表，如致信转发搜索等*/
                [_delegate searchResultDidSelectMember:value];
            }
            else {
                /*默认显示人员卡片*/
                [CMPPersonInfoUtils showPersonInfoView:value.orgID
                                                  from:@"contacts"
                                            enableChat:YES
                                  parentViewController:[UIViewController currentViewController]
                                         allowRotation:YES];
            }
        }
    }
}

#pragma mark-
#pragma mark-load faceview

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
//        [self loadFaceImagesForOnscreenRows];
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self loadFaceImagesForOnscreenRows];
//}
//
//- (void)loadFaceImagesForOnscreenRows {
//    NSArray *visiblePaths = [self.mainView.tableView indexPathsForVisibleRows];
//    for (NSIndexPath *indexPath in visiblePaths) {
//        UITableViewCell *aCell = [self.mainView.tableView cellForRowAtIndexPath:indexPath];
//        if ([aCell isKindOfClass:[CMPOfflineContactCell class]]) {
//            CMPOfflineContactCell *cell = (CMPOfflineContactCell *)aCell;
//            [cell loadFaceImage];
//        }
//    }
//}

#pragma mark-
#pragma mark-UISearchBarDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(searchResultWillBeginDragging:)]) {
        [_delegate searchResultWillBeginDragging:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchKeyword = searchText;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.mainView removeObserver];
    [self.mainView removeFromSuperview];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (CMP_IPAD_MODE && UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        [[UIViewController currentViewController].cmp_splitViewController clearDetailViewController];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(searchResultDidCacel:)]) {
        [_delegate searchResultDidCacel:self];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (_delegate && [_delegate respondsToSelector:@selector(searchResultDidSearch:)]) {
        [_delegate searchResultDidSearch:self];
    }
}


#pragma mark-
#pragma mark-CMPBaseTableviewcellDelegate

-(void)cmpBaseTableViewCell:(CMPBaseTableViewCell *)cell didTapAct:(NSInteger)action ext:(id)ext
{
    switch (action) {
        case 1://显示全路径
        {
            [_showAllPathStateArr addObject:[NSString stringWithInt:cell.indexPath.row]];
            [self.mainView.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
            
        default:
            break;
    }
}

@end
