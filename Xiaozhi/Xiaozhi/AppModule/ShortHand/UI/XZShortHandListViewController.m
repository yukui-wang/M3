//
//  XZShortHandListViewController.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandListViewController.h"
#import "XZShortHandListView.h"
#import "MJRefresh/MJRefresh.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"
#import "XZShortHandParam.h"
#import "XZShortHandListCell.h"
#import "SPTools.h"
#import "XZShortHandObj.h"
#import "XZShortHandDetailViewController.h"
#import "XZShortHandCreateViewController.h"
#import "CMPGlobleManager.h"

#import "XZSHForwardView.h"
#import "XZSHForwardListViewController.h"

@interface XZShortHandListViewController ()<UITableViewDelegate, UITableViewDataSource,CMPDataProviderDelegate> {
    XZShortHandListView *_listView;
    NSInteger _pageNo;
    NSInteger _pageSize;
    NSMutableArray *_dataList;
    CMPDataRequest *_dataRequest;
    CMPDataRequest *_deleteRequest;
}

@end

@implementation XZShortHandListViewController

- (void)dealloc {
    SY_RELEASE_SAFELY(_dataList);
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_dataRequest);
    SY_RELEASE_SAFELY(_deleteRequest);
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"全部速记"];
    self.backBarButtonItemHidden = NO;
    
    _listView = (XZShortHandListView *)self.mainView;
    __weak typeof(self) weakSelf = self;
    _listView.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    _listView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf LoadMoreData];
    }];
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    [_listView.createBtn addTarget:self action:@selector(showCreateView) forControlEvents:UIControlEventTouchUpInside];
    [self refreshData];
}

- (void)setupBannerButtons {
    self.bannerNavigationBar.rightViewsMargin = 0.0f;
    self.bannerNavigationBar.rightMargin = 4.0f;
    UIButton *searchButton = [UIButton buttonWithImageName:@"CMPBannerButton.bundle/ic_banner_search.png" frame:CGRectMake(0, 0, 42, 45) buttonImageAlignment:kButtonImageAlignment_Center];
    UIEdgeInsets insets = searchButton.imageEdgeInsets;
    searchButton.imageEdgeInsets = UIEdgeInsetsMake(insets.top, insets.left + 2, insets.bottom, insets.right - 2);
    [searchButton addTarget:self action:@selector(showSearchView) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:searchButton, nil]];
}



- (void)refreshData {
    _pageNo = 1;
    _pageSize = 20;
    [self requestData];
}

- (void)LoadMoreData {
    _pageSize = 20;
    _pageNo ++;
    [self requestData];
}

- (void)endRefreshing {
    [_listView.tableView.mj_header endRefreshing];
    [_listView.tableView.mj_footer endRefreshing];
}

- (void)requestData {
    NSString *url = kShorthandUrl_List;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_dataRequest);
    _dataRequest = [[CMPDataRequest alloc] init];
    _dataRequest.requestUrl = url;
    _dataRequest.delegate = self;
    _dataRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[NSNumber numberWithInteger:_pageNo] forKey:@"pageNo"];
    [mDict setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    _dataRequest.requestParam = [mDict JSONRepresentation];
    _dataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_dataRequest];
}

- (void)requestDelete:(long long)shId {
    NSString *url = kShorthandUrl_Delete;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_deleteRequest);
    _deleteRequest = [[CMPDataRequest alloc] init];
    _deleteRequest.requestUrl = url;
    _deleteRequest.delegate = self;
    _deleteRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[NSNumber numberWithLongLong:shId] forKey:@"id"];
    _deleteRequest.requestParam = [mDict JSONRepresentation];
    _deleteRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_deleteRequest];
}
- (void)showForwardView:(XZShortHandObj *)data {
    [XZSHForwardView showInView:self.view pushController:self data:data];
}

- (void)showForwardListBlock:(XZShortHandObj *)data appId:(NSString *)appId title:(NSString *)title {
    XZSHForwardListViewController *vc = [[XZSHForwardListViewController alloc] init];
    vc.shId = data.shId;
    vc.appId = appId;
    vc.bannerViewTitle = title;
    [self.navigationController pushViewController:vc animated:YES];
    SY_RELEASE_SAFELY(vc)
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    if (_dataRequest == aRequest) {
        NSLog(@"datalist = %@",aResponse.responseStr);
        if (_pageNo == 1 ) {
            [_dataList removeAllObjects];
        }
        if (!_dataList) {
            _dataList = [[NSMutableArray alloc] init];
        }
        NSDictionary *dic = [aResponse.responseStr JSONValue];
        NSDictionary *data = [SPTools dicValue:dic forKey:@"data"];
        NSInteger total = [SPTools integerValue:data forKey:@"total"];
        NSArray *dataArray = [SPTools arrayValue:data forKey:@"data"];
        for (NSDictionary *item in dataArray) {
            XZShortHandObj *obj = [[[XZShortHandObj alloc] initWithDic:item] autorelease];
            [_dataList addObject:obj];
        }
        [_listView.tableView reloadDataWithTotalCount:total currentCount:_dataList.count];
    }
    else if (_deleteRequest == aRequest) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"删除成功"];
        [self refreshData];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [self endRefreshing];
    if (_dataRequest == aRequest) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"获取数据失败"];

    }
    else if (_deleteRequest == aRequest) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"删除失败"];
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *identifier = @"XZShortHandListCellIn";
    XZShortHandListCell *cell = (XZShortHandListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[XZShortHandListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    if (indexPath.row < _dataList.count) {
        cell.data = _dataList[indexPath.row];
        __weak typeof(self) weakSelf = self;
        cell.forwardBlock = ^(XZShortHandObj * _Nonnull data) {
            [weakSelf showForwardView:data];
        };
        cell.deleteBlock = ^(XZShortHandObj * _Nonnull data) {
            [weakSelf requestDelete:data.shId];
        };
        cell.showForwardListBlock = ^(XZShortHandObj *data, NSString *appId, NSString *title) {
            [weakSelf showForwardListBlock:data appId:appId title:title];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataList.count) {
        __weak typeof(self) weakSelf = self;
        XZShortHandDetailViewController *vc = [[XZShortHandDetailViewController alloc] init];
        vc.data =_dataList[indexPath.row];
        vc.updateSucessBlock = ^{
            [weakSelf refreshData];
        };
        vc.deleteSucessBlock = ^{
            [weakSelf refreshData];
        };
        [self.navigationController pushViewController:vc animated:YES];
        SY_RELEASE_SAFELY(vc);
    }
}

- (void)showSearchView {
    
}

- (void)showCreateView {
    __weak typeof(self) weakSelf = self;
    XZShortHandCreateViewController *vc = [[XZShortHandCreateViewController alloc] init];
    vc.createSucessBlock = ^{
        [weakSelf refreshData];
    };
    [self.navigationController pushViewController:vc animated:YES];
    SY_RELEASE_SAFELY(vc);
}



@end

