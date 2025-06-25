//
//  RCUserListViewController.m
//  RongExtensionKit
//
//  Created by 杜立召 on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "CMPRCUserListViewController.h"
#import "CMPRCUserListTableViewCell.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIViewController+KSSafeArea.h>
#import <CMPLib/Masonry.h>

@interface CMPRCUserListViewController ()<UISearchResultsUpdating,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_tempOtherArr;
    NSMutableDictionary *allUsers;
    NSMutableArray *allKeys;
    UILabel *_confirmLb;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) UISearchBar *searchBar;//搜索框

//@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic,assign) NSInteger curChooseState;//当前的选择状态

@property (nonatomic,strong) NSMutableArray *selectedUserArr;
@property (nonatomic,strong) NSMutableArray *selectedUserIdArr;

@end

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation CMPRCUserListViewController{
    NSMutableArray *_searchResultArr;//搜索结果Arr
}

#pragma mark - dataArr(模拟从服务器获取到的数据)

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if ([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)]) {
    [self setExtendedLayoutIncludesOpaqueBars:YES];
  }

    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
  allUsers = [NSMutableDictionary new];
  allKeys = [NSMutableArray new];
  self.dataArr = [NSMutableArray array];
  allUsers = nil;//[self sortedArrayWithPinYinDic:self.dataArr];
  
  //configNav
  [self configNav];
  //布局View
    
//  UISearchController *searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
//   // 设置结果更新代理
//  searchVC.searchResultsUpdater = self;
//  // 因为在当前控制器展示结果, 所以不需要这个透明视图
//  searchVC.dimsBackgroundDuringPresentation = NO;
//    searchVC.hidesNavigationBarDuringPresentation = NO;
//  self.searchController = searchVC;
    
    [self setUpView];
//    self.tableView.tableHeaderView = self.searchBar;

    
    self.curChooseState = 1;
    
  _searchResultArr=[NSMutableArray array];
    [self cmp_showProgressHUD];
    __weak CMPRCUserListViewController *weakself = self;
    [self.dataSource getSelectingUserList:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
        [weakself loadAllUserInfoList:userList];
    }];
}

- (void)loadAllUserInfoList:(NSArray *)userList {
    [self.dataArr removeAllObjects];
    for (RCUserInfo *userInfo in userList) {
        if (![userInfo.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            [self.dataArr addObject:userInfo];
        }
    }
    
    NSMutableDictionary *tmpDict = [self sortedArrayWithPinYinDic:self.dataArr];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->allUsers = tmpDict;
        NSArray *arr = [[tmpDict allKeys]
                   sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                       return [obj1 compare:obj2 options:NSNumericSearch];
                   }];
        self->allKeys = nil;
        self->allKeys = [NSMutableArray arrayWithArray:arr];
        [self cmp_hideProgressHUD];
        if (self.hasPermissionAtAll && self.curChooseState == 1) {
            NSString *akey = @"";
            [self->allKeys insertObject:akey atIndex:0];
            RCUserInfo *aUserInfo = [[RCUserInfo alloc] initWithUserId:kRCUserId_AtAll name:SY_STRING(@"msg_at_all") portrait:@""];
            [self->allUsers setValue:@[aUserInfo] forKey:akey];
        }
        [self.tableView reloadData];
    });
}

- (void)configNav{
    self.navigationItem.title = SY_STRING(@"msg_userListTitle");
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 72, 23);
    UILabel *backText =
    [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 70, 22)];
    backText.text = SY_STRING(@"common_cancel");
    [backText setBackgroundColor:[UIColor clearColor]];
//    [backText setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)leftBarButtonItemPressed:(id)sender {
    if(_cancelBlock){
        _cancelBlock(nil);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - setUpView
- (void)setUpView{
//    [self.tableView
//     setBackgroundColor: [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1]];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBar];
}
- (UISearchBar *)searchBar{
    if (!_searchBar) {
//        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
//        _searchBar = self.searchController.searchBar;
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.frame = CGRectMake(0, 44+CMP_STATUSBAR_HEIGHT, kScreenWidth, 40);
        [_searchBar sizeToFit];
        [_searchBar setPlaceholder:SY_STRING(@"common_search")];
        [_searchBar.layer setBorderWidth:0.5];
        [_searchBar.layer setBorderColor:[UIColor colorWithRed:229.0/255 green:229.0/255 blue:229.0/255 alpha:1].CGColor];
        [_searchBar setDelegate:self];
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchBar;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.searchBar.frame), kScreenWidth, kScreenHeight-  CGRectGetMaxY(self.searchBar.frame)) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor lightGrayColor]];
        [_tableView setBackgroundColor:[UIColor cmp_colorWithName:@"p-bg"]];
//        _tableView.tableHeaderView = self.searchBar;
        //cell无数据时，不显示间隔线
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:v];
    }
    return _tableView;
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //section
    if (self.searchBar.isFirstResponder) {
        return 1;
    }else{
        return allKeys.count;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //row
    if (self.searchBar.isFirstResponder) {
        return _searchResultArr.count;
    }else{
        NSString *key = [allKeys objectAtIndex:section];
        NSArray *arr = [allUsers objectForKey:key];
        return [arr count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [RCIM sharedRCIM].globalMessagePortraitSize.height + 5 + 5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (!self.searchBar.isFirstResponder) {
        return allKeys;
    }else{
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchBar.isFirstResponder) {
        return 0;
    }else{
        if (section == 0) {
            return 0;
        }
        return 22.0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    headerV.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    UILabel *lb = [[UILabel alloc] init];
    lb.font = [UIFont boldSystemFontOfSize:12];
    lb.frame = CGRectMake(10, 0, 80, 22);
    lb.text = [allKeys objectAtIndex:section];
    [headerV addSubview:lb];
    return headerV;
}


#pragma mark - UITableView dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIde = @"cellIde";
  CMPRCUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
  if (cell == nil) {
    cell = [[CMPRCUserListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIde];
  }
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

  RCUserInfo *user = nil;
  if (self.searchBar.isFirstResponder) {
    user = _searchResultArr[indexPath.row];
  } else {
    NSString *key = [allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [allUsers objectForKey:key];
    user = arrayForKey[indexPath.row];
  }

    [cell setUser:user];
    [cell setState:self.curChooseState];
    if (self.curChooseState == 2) {
        if ([self.selectedUserIdArr containsObject:user.userId]) {
            cell.checkBox.checkState = CHECKSTATE_CHECKED;
        }else{
            cell.checkBox.checkState = CHECKSTATE_UNCHECK;
        }
    }
//  [cell.nameLabel setText:user.name];
//  cell.headImageView =
//      [[RCExtensionService sharedService] portraitView:[NSURL URLWithString:user.portraitUri]];

  return cell;
}

#pragma mark searchBar delegate
//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSArray *subViews;
    subViews = [(searchBar.subviews[0]) subviews];
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
            break;
        }
    }
    searchBar.showsCancelButton = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    CGRect r = searchBar.frame;
    r.origin.y=CMP_STATUSBAR_HEIGHT;
    searchBar.frame = r;
    
    r=self.tableView.frame;
    r.origin.y=CGRectGetMaxY(searchBar.frame);
    r.size.height = self.view.bounds.size.height-searchBar.bounds.size.height;
    self.tableView.frame = r;
    
    [self.tableView reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //取消
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    CGRect r = searchBar.frame;
    r.origin.y=CMP_STATUSBAR_HEIGHT+44;
    searchBar.frame = r;
    
    r=self.tableView.frame;
    r.origin.y=CGRectGetMaxY(searchBar.frame);
    r.size.height = self.view.bounds.size.height-searchBar.bounds.size.height-44;
    self.tableView.frame = r;
    
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [allKeys objectAtIndex:section];
    return key;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString
                                  scope:nil];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:searchText
                                  scope:nil];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCUserInfo *user;
    if (self.curChooseState == 2) {
        
        if (self.searchBar.isFirstResponder){
            if (!_searchResultArr.count) {
                return;
            }
            user = _searchResultArr[indexPath.row];
        }else{
            NSString *key = [allKeys objectAtIndex:indexPath.section];
            NSArray *arrayForKey = [allUsers objectForKey:key];
            user = arrayForKey[indexPath.row];
        }
        if (![self.selectedUserIdArr containsObject:user.userId]) {
            [self.selectedUserIdArr addObject:user.userId];
            [self.selectedUserArr addObject:user];
        }else{
            [self.selectedUserIdArr removeObject:user.userId];
            __weak typeof(self) wSelf = self;
            [self.selectedUserArr enumerateObjectsUsingBlock:^(RCUserInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userId isEqualToString:user.userId]) {
                    [wSelf.selectedUserArr removeObject:obj];
                    *stop = YES;
                }
            }];
        }
        [self.tableView reloadData];
        if (self.selectedUserArr.count>0) {
            _confirmLb.text = [NSString stringWithFormat:@"%@(%lu)",SY_STRING(@"common_ok"),(unsigned long)self.selectedUserArr.count];
            CGRect r = _confirmLb.frame;
            r.origin.x = -15;
            r.size.width = 100;
            _confirmLb.frame = r;
        }else{
            _confirmLb.text = SY_STRING(@"common_ok");
            CGRect r = _confirmLb.frame;
            r.origin.x = 0;
            r.size.width = 70;
            _confirmLb.frame = r;
        }
        
        return;
    }
    if (self.searchBar.isFirstResponder){
        user = _searchResultArr[indexPath.row];
    }else{
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [allUsers objectForKey:key];
        user = arrayForKey[indexPath.row];
    }
    if(self.selectedBlock){
        self.selectedBlock(user);
    }
    [self.searchBar resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 源字符串内容是否包含或等于要搜索的字符串内容
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (int i = 0; i < self.dataArr.count; i++) {
        NSString *storeString = [(RCUserInfo *)self.dataArr[i] name];
        NSRange storeRange = NSMakeRange(0, storeString.length);
        
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:self.dataArr[i]];
        }
        
    }
    [_searchResultArr removeAllObjects];
    [_searchResultArr addObjectsFromArray:tempResults];
}

- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)friends {
    if (!friends)
        return nil;
    NSArray *_keys = @[
              @"A",
              @"B",
              @"C",
              @"D",
              @"E",
              @"F",
              @"G",
              @"H",
              @"I",
              @"J",
              @"K",
              @"L",
              @"M",
              @"N",
              @"O",
              @"P",
              @"Q",
              @"R",
              @"S",
              @"T",
              @"U",
              @"V",
              @"W",
              @"X",
              @"Y",
              @"Z",
              ];
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    _tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (RCUserInfo *user in friends) {
          NSString *pyResult = [RCKitUtility getPinYinUpperFirstLetters:user.name];
          if (pyResult.length <= 0) {
            if (!isReturn) {
              [_tempOtherArr addObject:user];
            }
            continue;
          }
          
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:user];
            }
            
            if (isReturn)
                continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if (![tempArr count])
            continue;
        [returnDic setObject:tempArr forKey:key];
    }
    if ([_tempOtherArr count])
        [returnDic setObject:_tempOtherArr forKey:@"#"];
  
    return returnDic;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}




-(void)setCurChooseState:(NSInteger)curChooseState
{
    _curChooseState = curChooseState;
    switch (curChooseState) {
        case 1://单选
        {
            UIButton *aItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            aItemBtn.frame = CGRectMake(0, 0, 72, 23);
            UILabel *aItemLb =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 70, 22)];
            aItemLb.textAlignment = NSTextAlignmentRight;
            aItemLb.text = SY_STRING(@"picture_multi_select_btn_title");
            [aItemLb setBackgroundColor:[UIColor clearColor]];
//            [aItemLb setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
            [aItemBtn addSubview:aItemLb];
            [aItemBtn addTarget:self action:@selector(_changeToMutibleChooseState) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *aBarItem = [[UIBarButtonItem alloc] initWithCustomView:aItemBtn];
            [self.navigationItem setRightBarButtonItem:aBarItem];
        }
            break;
            
        case 2://多选
        {
            UIButton *aItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            aItemBtn.frame = CGRectMake(0, 0, 72, 23);
            UILabel *aItemLb =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 70, 22)];
            aItemLb.textAlignment = NSTextAlignmentRight;
            aItemLb.text = SY_STRING(@"common_ok");
            [aItemLb setBackgroundColor:[UIColor clearColor]];
//            [aItemLb setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
            [aItemBtn addSubview:aItemLb];
            [aItemBtn addTarget:self action:@selector(_confirmAct) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *aBarItem = [[UIBarButtonItem alloc] initWithCustomView:aItemBtn];
            [self.navigationItem setRightBarButtonItem:aBarItem];
            
            _confirmLb = aItemLb;
        }
            break;
            
        default:
            break;
    }
}


-(void)_changeToMutibleChooseState
{
    self.curChooseState = 2;
    __weak CMPRCUserListViewController *weakself = self;
    [self.dataSource getSelectingUserList:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
        [weakself loadAllUserInfoList:userList];
    }];
}


-(void)_confirmAct
{
    if(self.selectedBlock && self.selectedUserArr.count){
        NSArray *selectedUserArr = self.selectedUserArr;
        for (int i=0; i<selectedUserArr.count; i++) {
            RCUserInfo *user = selectedUserArr[i];
            if (i==0) {
                self->_selectedBlock(user);
            }else{
                user.name = [@"@" stringByAppendingString:user.name];
                self->_selectedBlock(user);
            }
        }
    }
    [self.searchBar resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableArray *)selectedUserArr
{
    if (!_selectedUserArr) {
        _selectedUserArr = [[NSMutableArray alloc] init];
    }
    return _selectedUserArr;
}
-(NSMutableArray *)selectedUserIdArr
{
    if (!_selectedUserIdArr) {
        _selectedUserIdArr = [[NSMutableArray alloc] init];
    }
    return _selectedUserIdArr;
}

@end
