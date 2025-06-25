//
//  XZSHForwardListViewController.m
//  M3
//
//  Created by wujiansheng on 2019/1/9.
//

#import "XZSHForwardListViewController.h"
#import "MJRefresh/MJRefresh.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"
#import "XZShortHandParam.h"
#import "XZSHForwardListView.h"
#import "XZTransWebViewController.h"
#import "XZSHForwardListObj.h"

#import "XZSHForwardListCell.h"
#import "XZSHForwardListObj.h"
#import "SPTools.h"

@interface XZSHForwardListViewController ()<UITableViewDelegate, UITableViewDataSource,CMPDataProviderDelegate> {
    XZSHForwardListView *_listView;
    NSInteger _pageNo;
    NSInteger _pageSize;
    CMPDataRequest *_forwardListRequest;
    NSMutableArray *_dataList;
}

@end

@implementation XZSHForwardListViewController

- (void)dealloc {
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_appId)
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:self.bannerViewTitle];
    self.backBarButtonItemHidden = NO;
    _listView = (XZSHForwardListView *)self.mainView;
    __weak typeof(self) weakSelf = self;
    _listView.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    _listView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf LoadMoreData];
    }];
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    [self refreshData];
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
    NSString *url = kShorthandUrl_ForwardList;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_forwardListRequest);
    _forwardListRequest = [[CMPDataRequest alloc] init];
    _forwardListRequest.requestUrl = url;
    _forwardListRequest.delegate = self;
    _forwardListRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[NSNumber numberWithLongLong:self.shId] forKey:@"id"];
    [mDict setObject:self.appId forKey:@"appId"];
    [mDict setObject:[NSNumber numberWithInteger:_pageNo] forKey:@"pageNo"];
    [mDict setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    _forwardListRequest.requestParam = [mDict JSONRepresentation];
    _forwardListRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_forwardListRequest];
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    NSLog(@"providerDidStartLoad");
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    if (_forwardListRequest == aRequest) {
        NSLog(@"aResponse = %@",aResponse.responseStr);
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
        [_dataList addObjectsFromArray:[XZSHForwardListObj objsFormDic:dataArray appID:self.appId]];
        [_listView.tableView reloadDataWithTotalCount:total currentCount:_dataList.count];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [self endRefreshing];
    NSLog(@"error = %@",error);
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row < _dataList.count) {
        XZSHForwardListObj *obj = _dataList[indexPath.row];
        NSString *identifier = obj.cellId;
        XZSHForwardListCell *cell = (XZSHForwardListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSClassFromString(obj.cellName) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        }
        if (indexPath.row < _dataList.count) {
            cell.data = _dataList[indexPath.row];
        }
        return cell;
    }
    //添加默认防止crash
    NSString *identifier = @"XZSHForwardListCellId";
    XZSHForwardListCell *cell = (XZSHForwardListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[XZSHForwardListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataList.count) {
        XZSHForwardListObj *obj = _dataList[indexPath.row];
        XZTransWebViewController *webviewController = [[XZTransWebViewController alloc] init];
        webviewController.loadUrl = obj.gotoUrl;
        webviewController.gotoParams = obj.gotoParams;
        webviewController.hideBannerNavBar = NO;
        [self.navigationController pushViewController:webviewController animated:YES];
    }
}

@end
