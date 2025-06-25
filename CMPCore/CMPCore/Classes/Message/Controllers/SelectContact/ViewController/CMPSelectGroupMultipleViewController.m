//
//  CMPSelectGroupMultipleViewController.m
//  M3
//
//  Created by Shoujian Rao on 2023/9/4.
//

#import "CMPSelectGroupMultipleViewController.h"
#import "CMPSelectMultipleBottomView.h"
#import "CMPSelectGroupMultipleView.h"
#import "CMPForwardSearchViewController.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPMessageManager.h"
#import "CMPSelContactListCell.h"
#import "CustomCircleSearchBar.h"

#import "CMPSelectMultipleDataProvider.h"
#import <CMPLib/MJRefresh.h>
#import "CMPSelectContactManager.h"
#import <CMPLib/CMPCommonTool.h>
#define kSearchBarHeight 40
@interface CMPSelectGroupMultipleViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) CMPSelectMultipleBottomView *bottomView;
@property (strong, nonatomic) UIButton *cancelBtn;

@property (strong, nonatomic) CMPSelectGroupMultipleView *listView;
@property (nonatomic, strong) UISearchController *searchViewController;
@property (nonatomic, strong) CMPForwardSearchViewController *searchResultVC;

@property (nonatomic, assign) CGFloat placeholderWidth;

@property (nonatomic, assign) BOOL searchBarPlaceMiddle;//旋转时seacrhbar

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *searchDataList;
@property (nonatomic, strong) CustomCircleSearchBar *searchBar;

@property (nonatomic, strong) CMPSelectMultipleDataProvider *dataProvider;
@property (nonatomic, assign) NSInteger pageNo;

@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, assign) BOOL searchMode;

@property (nonatomic, assign) BOOL layoutOnce;

@end

@implementation CMPSelectGroupMultipleViewController


- (void)dealloc{
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"群组列表"];
    [self createSubView];
    
    self.pageNo = 1;
    [self getAllGroups];
    
    UIView *tableBackgroundView = [[UIView alloc] initWithFrame:_listView.tableView.bounds];
    tableBackgroundView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    _listView.tableView.backgroundView = tableBackgroundView;
    
    __weak typeof(self) weakSelf = self;
    _listView.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.pageNo = 1;
        if (weakSelf.searchMode) {
            [weakSelf searchGroup:weakSelf.searchBar.text];
        }else{
            [weakSelf getAllGroups];
        }
    }];
    
    _listView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.pageNo++;
        if (weakSelf.searchMode) {
            [weakSelf searchGroup:weakSelf.searchBar.text];
        }else{
            [weakSelf getAllGroups];
        }
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bottomSelectContact:) name:kNotificationName_SelectContactChanged object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_layoutOnce) {//V5-57056 致信转发多选：ios端转发多选选人界面，选项较多时最后1个选项选不到。修改为第一次进入显示布局重新计算。
        _layoutOnce = YES;
        [self layoutBottomViewByKeyboardHeight:0];
    }
}

#pragma mark - loadData
- (void)getAllGroups{
    __weak typeof(self) weakSelf = self;
    [self.dataProvider getGroupByPageNo:self.pageNo completion:^(NSArray *arr, NSError *err) {
        [weakSelf.listView.tableView.mj_header endRefreshing];
        [weakSelf.listView.tableView.mj_footer endRefreshing];
        
        if (weakSelf.pageNo == 1) {
            [weakSelf.dataList removeAllObjects];
        }
        [weakSelf.dataList addObjectsFromArray:arr];
        
        weakSelf.listView.tableView.mj_footer.hidden = arr.count<20;
        
        weakSelf.searchMode = NO;
        
        [weakSelf.listView.tableView reloadData];
        
        if (weakSelf.dataList.count) {
            weakSelf.listView.tableView.tableFooterView = nil;
        }else{
            weakSelf.listView.tableView.tableFooterView = weakSelf.placeholderView;
        }
    }];
}

- (void)searchGroup:(NSString *)key{
    if (key.length<=0) {
        [self.listView.tableView.mj_header endRefreshing];
        [self.listView.tableView.mj_footer endRefreshing];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.dataProvider searchGroupByKeyword:key pageNo:self.pageNo completion:^(NSArray *arr, NSError *err) {
        [weakSelf.listView.tableView.mj_header endRefreshing];
        [weakSelf.listView.tableView.mj_footer endRefreshing];
        
        if (weakSelf.pageNo == 1) {
            [weakSelf.searchDataList removeAllObjects];
        }
        [weakSelf.searchDataList addObjectsFromArray:arr];
        
        weakSelf.listView.tableView.mj_footer.hidden = arr.count<20;
        
        weakSelf.searchMode = YES;
        
        [weakSelf.listView.tableView reloadData];
        
        if (weakSelf.searchDataList.count) {
            weakSelf.listView.tableView.tableFooterView = nil;
        }else{
            weakSelf.listView.tableView.tableFooterView = weakSelf.placeholderView;
        }
    }];
}

#pragma mark - UITable

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.searchMode?self.searchDataList.count:self.dataList.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataArr = self.searchMode?self.searchDataList:self.dataList;
    NSDictionary *dict = dataArr[indexPath.row];
    
    static NSString *cellIde = @"cellIdeMultiple";
    CMPSelContactListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[CMPSelContactListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIde];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
    obj.serverId = [CMPCore sharedInstance].serverID;
    obj.memberId = [NSString stringWithFormat:@"rcgroup_%@",dict[@"i"]] ;
    obj.downloadUrl = [CMPCore rcGroupIconUrlWithGroupId:dict[@"i"]];
    
    cell.faceView.memberIcon = obj;
    cell.userNameLabel.text = dict[@"n"];
    NSAttributedString *attstr = [CMPCommonTool searchResultAttributeStringInString:dict[@"n"] searchText:_searchBar.text];
    [cell.userNameLabel setAttributedText:attstr];
    
    //设置多选按钮
    [cell setSelectImageConfig];
    //选中状态
    cell.selectCell = [[CMPSelectContactManager sharedInstance].selectedCidArr containsObject:dict[@"i"]];
    //管理员图标
    [cell setAdminImageConfig:[dict[@"ci"] isEqualToString:[CMPCore sharedInstance].userID]];
    //部门群标识
    if([dict[@"groupType"] isEqualToString:@"DEPARTMENT"]){//DEPARTMENT\ORDINARY
        [cell setDepartment:@"部门群"];
    }else{
        [cell setDepartment:nil];
    }
    
    if (indexPath.row == dataArr.count - 1) {
        cell.separatorImageView.hidden = YES;
    } else {
        cell.separatorImageView.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.searchBar resignFirstResponder];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:CMPSelContactListCell.class]) {
        CMPSelContactListCell *listCell = (CMPSelContactListCell *)cell;
        listCell.selectCell = !listCell.selectCell;
        
        NSArray *dataArr = self.searchMode?self.searchDataList:self.dataList;
        NSDictionary *dict = dataArr[indexPath.row];
        
        NSString *cid = dict[@"i"];
        NSString *name = dict[@"n"];
        NSInteger type = 1;//RC融云消息
        NSInteger subType = 3;//群
        [self.searchBar resignFirstResponder];
        
        if(listCell.selectCell){
            BOOL canSelect = [[CMPSelectContactManager sharedInstance] addSelectContact:cid
                                                                                   name:name
                                                                                   type:type
                                                                                subType:subType];
            
            if (!canSelect) {
                listCell.selectCell = NO;
            }
        }else{
            [[CMPSelectContactManager sharedInstance] delSelectContact:cid];
        }
    }
}
//底部取消人员后通知
- (void)bottomSelectContact:(NSNotification *)notify{
    [self.searchBar resignFirstResponder];
    [_listView.tableView reloadData];
    [_bottomView refreshData];
    [self layoutBottomViewByKeyboardHeight:0];
}

#pragma mark - view

- (void)createSubView {
    //列表
    _listView = (CMPSelectGroupMultipleView *)self.mainView;
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    _listView.tableView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    
    // 无数据占位图
    self.placeholderView = [[UIView alloc] initWithFrame:_listView.tableView.bounds];
    self.placeholderView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (_listView.tableView.bounds.size.height-30)/2, _listView.tableView.bounds.size.width, 30)];
    label.text = SY_STRING(@"common_nodata");
    label.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    label.textAlignment = NSTextAlignmentCenter;
    [self.placeholderView addSubview:label];
    
    //header视图
    UIView *listHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _listView.tableView.bounds.size.width, kSearchBarHeight)];
    _listView.tableView.tableHeaderView = listHeaderView;
    //搜索框
    CustomCircleSearchBar *search = [[CustomCircleSearchBar alloc]initWithPlaceholder:@"搜索" size:CGSizeMake(self.view.bounds.size.width, kSearchBarHeight)];
    search.delegate = self;
    [listHeaderView addSubview:search];
    _searchBar = search;
    search.showsCancelButton = NO;
    
    //取消按钮
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancelBtn setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    [listHeaderView addSubview:_cancelBtn];
    
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kSearchBarHeight);
    _cancelBtn.frame = CGRectMake(self.view.bounds.size.width, 0, 60, kSearchBarHeight);
    
    //底部共用组件
    _bottomView = [[CMPSelectMultipleBottomView alloc]init];
    _bottomView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [CMPSelectMultipleBottomView defaultHeight]);
    [self.view addSubview:_bottomView];
    _bottomView.viewController = self;//关联VC
    [_bottomView refreshData];
    
    //其他操作
    __weak typeof(self) weakSelf = self;
    _bottomView.confirmBtnBlcok = ^{
        [weakSelf.searchBar resignFirstResponder];
    };
    
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kSearchBarHeight);
    _cancelBtn.frame = CGRectMake(self.view.bounds.size.width, 0, 60, kSearchBarHeight);
    [self layoutBottomViewByKeyboardHeight:0];
}

- (void)layoutBottomViewByKeyboardHeight:(CGFloat)keyboardHeight{
    CGRect frame = self.mainFrame;
    CGFloat botH = [CMPSelectMultipleBottomView defaultHeight];
    if (keyboardHeight>0) {
        frame.size.height = frame.size.height - keyboardHeight - botH;
        _listView.frame = frame;
        
        _bottomView.frame = CGRectMake(0, CGRectGetMaxY(_listView.frame), CGRectGetWidth(_listView.frame), botH);
    }else{
        frame.size.height = frame.size.height - botH - CMP_SafeBottomMargin_height;
        _listView.frame = frame;
        
        _bottomView.frame = CGRectMake(0, CGRectGetMaxY(_listView.frame), CGRectGetWidth(_listView.frame), botH + CMP_SafeBottomMargin_height);
    }
    [_bottomView customLayoutSubviews];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardRect = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    if (![[CMPSelectContactManager sharedInstance].sendView isContentFieldEditing]) {
        //留言输入的时候不改变底部控件位置 V5-57027
        [self layoutBottomViewByKeyboardHeight:keyboardHeight];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self layoutBottomViewByKeyboardHeight:0];
}
#pragma mark - action

- (void)cancelBtnAction{
    [_searchBar resignFirstResponder];
    
    [self hideCancelBtn];
    
    
    if (_searchBar.text.length) {
        self.pageNo = 1;
        [self getAllGroups];
        _searchBar.text = @"";
    }
    
}

- (void)hideCancelBtn{
    CGFloat searchW = self.view.bounds.size.width;
    _searchBar.frame = CGRectMake(0, 0, searchW, kSearchBarHeight);
//    _searchBar.textfield.frame = CGRectMake(14, (kSearchBarHeight-30)/2, searchW - 28, 30);
    _cancelBtn.frame = CGRectMake(searchW, 0, 60, kSearchBarHeight);
    
    [_searchBar.textfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(searchW-28);
//        make.top.mas_equalTo((kSearchBarHeight-30)/2);
        make.left.mas_equalTo(14);
        make.centerY.offset(0);
        make.height.equalTo(30);
    }];
}

- (void)showCancelBtn{
    CGFloat searchW = self.view.bounds.size.width-50;
    _cancelBtn.frame = CGRectMake(searchW-10, 0, 60, kSearchBarHeight);
    _searchBar.frame = CGRectMake(0, 0, searchW, kSearchBarHeight);
//    _searchBar.textfield.frame = CGRectMake(14, (kSearchBarHeight-30)/2, searchW - 28, 30);
    
    [_searchBar.textfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(searchW-28);
        make.left.mas_equalTo(14);
        make.centerY.offset(0);
        make.height.equalTo(30);
    }];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self showCancelBtn];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if (searchBar.text.length) {
        return YES;
    }
    [self hideCancelBtn];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //停止编辑时检测如果清空，则重新请求
    [searchBar resignFirstResponder];
    if ([searchBar.text isEqual:@""] && ![self.searchBar.lastSearchText isEqual:searchBar.text]) {
        self.pageNo = 1;
        [self getAllGroups];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //从有数据变为空，则查询一次全部
    if ([searchBar.text isEqual:@""] && ![self.searchBar.lastSearchText isEqual:searchBar.text]) {
        self.pageNo = 1;
        [self getAllGroups];
    }else{
        NSString *text = searchBar.text;
        if (text.length) {
            self.pageNo = 1;
            [self searchGroup:text];
        }
    }
}

//点击搜索查询
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *text = searchBar.text;
    if (text.length) {
        self.pageNo = 1;
        [self searchGroup:text];
    }
}

#pragma mark - lazy
- (CMPSelectMultipleDataProvider *)dataProvider{
    if (!_dataProvider) {
        _dataProvider = [CMPSelectMultipleDataProvider new];
    }
    return _dataProvider;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

- (NSMutableArray *)searchDataList{
    if (!_searchDataList) {
        _searchDataList = [NSMutableArray new];
    }
    return _searchDataList;
}

@end
