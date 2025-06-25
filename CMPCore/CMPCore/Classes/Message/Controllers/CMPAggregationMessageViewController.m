//
//  CMPaggregationMessageViewController.m
//  M3
//
//  Created by CRMO on 2018/1/8.
//

#import "CMPAggregationMessageViewController.h"
#import "CMPAggregationMessageView.h"
#import "CMPMessageListCell.h"

#import <CMPLib/MJRefresh.h>
#import "CMPMessageManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPRCTargetObject.h"

#import "CMPCommonManager.h"
#import "CMPGestureHelper.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "CMPChatManager.h"
#import <CMPLib/UIColor+Hex.h>

#import "CMPSignViewController.h"

@interface CMPAggregationMessageViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CMPAggregationMessageView *_listView;
    NSMutableArray *_dataList;
}

@end

@implementation CMPAggregationMessageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SY_RELEASE_SAFELY(_dataList);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:SY_STRING(@"msg_app")];
    
    [self setBackButton];
    
    _listView = (CMPAggregationMessageView *)self.mainView;
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    __weak UITableView *tableView = _listView.tableView;
    
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [[CMPMessageManager sharedManager] refreshMessage];
    }];
    tableView.backgroundColor = [UIColor whiteColor];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = UIColorFromRGB(0xe7e7e7);
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:kNotificationName_MessageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshing) name:kMessageDidFinishRequest object:nil];
}

- (void)loadData {
    __weak CMPAggregationMessageView *listView = _listView;
    __weak NSMutableArray *datalist = _dataList;
    [[CMPMessageManager sharedManager] messageListWithType:CMPMessageTypeAggregationApp completion:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            listView.tableView.userInteractionEnabled = NO;
            [datalist removeAllObjects];
            [datalist addObjectsFromArray:result];
            [listView.tableView reloadDataWithTotalCount:datalist.count currentCount:datalist.count];
            listView.tableView.userInteractionEnabled = YES;
        });
    }];
}

- (void)endRefreshing {
    [_listView.tableView.mj_header endRefreshing];
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
    [buttonTitle release];
    buttonTitle = nil;
    [button addTarget:self action:@selector(backBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    [self.bannerNavigationBar setLeftBarButtonItems:@[button]];
    [button release];
    button = nil;
}

- (void)backBarButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_listView.tableView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
        cell = [[[CMPMessageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    if (indexPath.row < _dataList.count) {
        [cell setupObject:[_dataList objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *list = [NSMutableArray array];
    NSString *title = SY_STRING(@"msg_delete");
    
    __weak NSMutableArray *datalist = _dataList;
    __weak UITableView *table = tableView;
    __weak CMPMessageObject *obj = [datalist objectAtIndex:indexPath.row];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < _dataList.count) {
            [[CMPMessageManager sharedManager] deleteMessageWithAppId:obj];
            [datalist removeObject:obj];
            
            if (datalist.count == 0) {
                [self loadData];
            } else {
                [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }];
    
    delete.backgroundColor =  UIColorFromRGB(0xfb464e);
    [list addObject:delete];
    
    if (obj.type != CMPMessageTypeUC) {
        if (obj.unreadCount != 0) {
            title = SY_STRING(@"msg_markRead");
            UITableViewRowAction *read = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                if (indexPath.row < _dataList.count) {
                    [[CMPMessageManager sharedManager] readMessageWithAppId:obj clearMessage:YES];
                    obj.unreadCount = 0;
                    CMPMessageListCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
                    [aCell removeUnReadCount];
                }
            }];
            read.backgroundColor = UIColorFromRGB(0xfdc213);
            [list addObject:read];
        }
    }
    BOOL istop = obj.isTop;
    title = istop ? SY_STRING(@"msg_canceltop"): SY_STRING(@"msg_top");
    UITableViewRowAction *top = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row < _dataList.count) {
            obj.isTop = !obj.isTop;
            [[CMPMessageManager sharedManager] topMessage:obj];
        }
    }];
    
    top.backgroundColor = UIColorFromRGB(0xABABAB);
    [list addObject:top];
    
    return list;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _dataList.count) {
        CMPMessageObject *obj = [_dataList objectAtIndex:indexPath.row];
        obj.unreadCount = 0;
        CMPMessageListCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
        [aCell removeUnReadCount];
        [[CMPMessageManager sharedManager] showChatView:obj viewController:self];
    }
}

@end
