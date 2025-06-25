//
//  CMPSelectMultipleContactViewController.m
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import "CMPSelectMultipleContactViewController.h"
#import "CMPSelectMultipleContactView.h"
#import "CMPRCUserListTableViewCell.h"
#import <CMPLib/SyFaceDownloadRecordObj.h>
#import "CMPSelContactListCell.h"
#import "CMPSelContactPushCell.h"
#import "CMPMessageObject.h"
#import "AppDelegate.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPMessageForwardView.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>

#import "CMPMessageManager.h"
#import "CMPChatManager.h"
#import "CMPRCV5Message.h"
#import "CMPRCTransmitMessage.h"
#import "CMPRCSystemImMessage.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSDate+CMPDate.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/SOSwizzle.h>
#import "CMPCombineMessageCell.h"
#import "CMPRCChatViewController.h"
#import "M3-Swift.h"
#import "CMPMessageManager.h"
#import "CMPBusinessCardMessage.h"
#import <CMPLib/CMPAppListModel.h>
#import "CMPSelContactListFileAssistantTypeCell.h"
#import "CMPSelectMultipleBottomView.h"

#import "CMPSelectGroupMultipleViewController.h"
#import "CMPSelectContactManager.h"
@interface CMPSelectMultipleContactViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating,UISearchControllerDelegate, CMPForwardSearchDelegate> {
    
    CMPSelectMultipleContactView *_listView;
    CMPSelectMultipleBottomView *_bottomView;
//    CMPSelectMultipleBottomView *_bottomView1;
    NSMutableArray *_dataList;
    CGFloat _placeholderWidth;
    BOOL _searchBarPlaceMiddle;//旋转时seacrhbar
    
    NSInteger _totalForwardTag;
    NSInteger _sucessForwardTag;
    NSInteger _failForwardTag;
    NSInteger _errorCode;
    
}
@property (nonatomic, retain)CMPMessageForwardView *sendView;
@property (nonatomic, retain) CMPMessageObject *curMessageObject;
@property (nonatomic, retain) UISearchController *searchViewController;


@property (nonatomic, retain) CMPMessageObject *selectedMsgTag;
/* chatVc */
@property (strong, nonatomic) CMPRCChatViewController *chatVc;

@property (nonatomic, assign) BOOL layoutOnce;
@end

static BOOL bForwarding = NO;
//为了加快速度，直接取,无须强引用，进转发的时候，次试图必然存在
static CMPSelectMultipleContactViewController *curVC = nil;
@implementation CMPSelectMultipleContactViewController

static NSString *fileAssistantTypeCellIdentifier = @"CMPSelContactListFileAssistantTypeCell";

+ (void)cleanStatic {
    bForwarding = NO;
    curVC = nil;
}

+ (void)setCurVC:(CMPSelectMultipleContactViewController*)vc {
    curVC = vc;
}

+ (void)setForwarding:(BOOL)state {
    bForwarding = state;
}

+ (BOOL)getForwarding {
    return bForwarding;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [CMPSelectContactManager sharedInstance].selectedContact = nil;
    [CMPSelectContactManager sharedInstance].selectedCidArr = nil;
    [CMPSelectContactManager sharedInstance].msgModel = self.msgModel;
    [CMPSelectContactManager sharedInstance].targetId = self.targetId;
    [CMPSelectContactManager sharedInstance].forwardSource = self.forwardSource;
    [CMPSelectContactManager sharedInstance].selectedMessages = self.selectedMessages;
    [CMPSelectContactManager sharedInstance].sendView = nil;
    
    self.allowRotation = NO;
    // Do any additional setup after loading the view.
    [CMPSelectMultipleContactViewController cleanStatic];
    [CMPSelectMultipleContactViewController setCurVC:self];
    [CMPSelectMultipleContactViewController setForwarding:YES] ;
    
    [self setTitle:SY_STRING(@"select_multiple_chats")];
    [self createBackButton];
    
    [self createSubView];
    [self reloadContactData];
    
    UIView *tableBackgroundView = [[UIView alloc] initWithFrame:_listView.tableView.bounds];
    tableBackgroundView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    _listView.tableView.backgroundView = tableBackgroundView;
    
    [_listView.tableView registerClass:[CMPSelContactListFileAssistantTypeCell class] forCellReuseIdentifier:fileAssistantTypeCellIdentifier];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bottomSelectContact:) name:kNotificationName_SelectContactChanged object:nil];
    
    // 注册键盘弹起通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 注册键盘隐藏通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _searchViewController.searchBar.hidden = YES;
    [self removeSearchBarHide];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchViewController.searchBar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_layoutOnce) {//V5-57056 致信转发多选：ios端转发多选选人界面，选项较多时最后1个选项选不到。修改为第一次进入显示布局重新计算。
        _layoutOnce = YES;
        [self layoutBottomViewByKeyboardHeight:0];
    }
}

// 处理键盘弹起事件
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    if (![[CMPSelectContactManager sharedInstance].sendView isContentFieldEditing]) {
        //留言输入的时候不改变底部控件位置 V5-57027
        [self layoutBottomViewByKeyboardHeight:keyboardHeight];
    }
}

// 处理键盘隐藏事件
- (void)keyboardWillHide:(NSNotification *)notification {
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
    
    //更新搜索返回结果底部bottomView
    [_searchResultVC.searchResultManager.mainView layoutSubviews];
}

- (void)removeSearchBarHide{
    [self.searchViewController setActive:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addNotis {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleForwardSucess:) name:kDidForwardSucess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleForwardFail:) name:kDidForwardFail object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [CMPSelectMultipleContactViewController cleanStatic];
    // 移除键盘弹起通知的监听
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
    // 移除键盘隐藏通知的监听
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
}

- (void)backBarButtonAction:(id)sender {
    if (self.forwardCancel) {
        self.forwardCancel();
        self.forwardCancel = nil;
    }
    [CMPSelectMultipleContactViewController cleanStatic];
    [super backBarButtonAction:sender];
}

- (void)createBackButton {
    self.bannerNavigationBar.leftMargin = 10.f;
    NSString *backTitle = SY_STRING(@"common_cancel");
    CGFloat backW = [backTitle sizeWithFontSize:[UIFont systemFontOfSize:16.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setFrame:CGRectMake(0, 0, backW, 44)];
    [returnButton setTitle:backTitle forState:UIControlStateNormal];
    
    [returnButton setTitleColor:[CMPThemeManager sharedManager].iconColor forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [returnButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    self.bannerNavigationBar.leftBarButtonItems = @[returnButton];
    [self.bannerNavigationBar hideBottomLine:YES];
}

- (void)createSubView {
    //底部共用组件
    _bottomView = [[CMPSelectMultipleBottomView alloc]init];
    [self.view addSubview:_bottomView];
    _bottomView.viewController = self;//关联VC
    
//    _bottomView1 = [[CMPSelectMultipleBottomView alloc]init];
//    _bottomView1.viewController = self;//关联VC
    
    //确认操作
    __weak typeof(self) weakSelf = self;
//    _bottomView1.confirmBtnBlcok = ^{
//        [weakSelf.searchResultVC.searchBar resignFirstResponder];
//        [weakSelf removeSearchBarHide];
//    };
    
    _bottomView.confirmBtnBlcok = ^{
        [weakSelf.searchResultVC.searchBar resignFirstResponder];
        [weakSelf removeSearchBarHide];
    };
    
    //取消操作
    _bottomView.cancelBtnBlcok = ^{
        [weakSelf.searchResultVC.searchBar resignFirstResponder];
        [weakSelf removeSearchBarHide];
    };
//    _bottomView1.cancelBtnBlcok = ^{
//        [weakSelf.searchResultVC.searchBar resignFirstResponder];
//        [weakSelf removeSearchBarHide];
//    };
    
    //列表
    _listView = (CMPSelectMultipleContactView *)self.mainView;
    _listView.tableView.dataSource = self;
    _listView.tableView.delegate = self;
    _listView.tableView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    if (!_searchResultVC) {
        [self setupSearchBar];
    }
    
    
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    if (_searchBarPlaceMiddle) {
        CGRect f = _searchViewController.searchBar.frame;
        f.size.width = frame.size.width;
        _searchViewController.searchBar.frame = f;
        [self searchBarPlaceholderToMiddle:_searchViewController.searchBar];
    }
    
    _sendView.frame = self.view.bounds;
    [self layoutBottomViewByKeyboardHeight:0];
}

#pragma mark - SearchBar
- (void)setupSearchBar
{
    _searchResultVC = [[CMPForwardSearchViewController alloc] init];
    _searchResultVC.allowRotation = NO;
    _searchResultVC.delegate = self;
    _searchResultVC.isMultipleSelect = YES;//多选
    _searchViewController = [[UISearchController alloc] initWithSearchResultsController:_searchResultVC];
    _searchResultVC.searchBar = _searchViewController.searchBar;
    _searchViewController.hidesNavigationBarDuringPresentation = NO;
    _searchViewController.searchResultsUpdater = self;
    _searchViewController.delegate = self;
    
    _searchViewController.searchBar.placeholder = SY_STRING(@"common_search");
    
    _searchResultVC.searchBarHeight = _searchViewController.searchBar.height;
    if (_searchViewController.searchBar.height == 0) {
        CGRect r = _searchViewController.searchBar.frame;
        r.size.height = 44;
        r.size.width = _listView.width;
        _searchViewController.searchBar.frame = r;
    }
    _searchViewController.searchBar.barTintColor = [UIColor cmp_colorWithName:@"white-bg1"];
    _searchViewController.searchBar.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    _searchViewController.searchBar.searchBarStyle =  UISearchBarStyleMinimal;
    _searchViewController.searchBar.barStyle = UIBarStyleBlack;
    UITextField *searchField = [CMPCommonTool getSearchFieldWithSearchBar:_searchViewController.searchBar];
    searchField.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
    searchField.font = [UIFont systemFontOfSize:14];
    
    searchField.layer.masksToBounds = YES;
    searchField.layer.cornerRadius = 15;
    
    UISearchBar *searchBar = _searchViewController.searchBar;
    [self searchBarPlaceholderToMiddle:searchBar];
    NSDictionary *attrDic = @{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc2"] ,
                              NSFontAttributeName : [UIFont systemFontOfSize:14]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:searchBar.placeholder attributes:attrDic];
    searchField.attributedPlaceholder = attrStr;
    
    [searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(14);
        make.right.offset(-14);
        make.height.equalTo(30).priorityHigh();
    }];
    
    _listView.tableView.tableHeaderView = _searchViewController.searchBar;
    
//    searchField.inputAccessoryView = _bottomView1;
    
}

/**
 将searchBar的文字、图标居中显示
 */
- (void)searchBarPlaceholderToMiddle:(UISearchBar *)searchBar {
    _searchBarPlaceMiddle = YES;
    if (@available(iOS 11.0, *)) {
        [searchBar setPositionAdjustment:UIOffsetMake((searchBar.width - self.placeholderWidth - 16) / 2, 0) forSearchBarIcon:UISearchBarIconSearch];
    }
}

/**
 将searchBar的文字、图标靠左显示
 */
- (void)searchBarPlaceholderToLeft:(UISearchBar *)searchBar {
    _searchBarPlaceMiddle = NO;
    if (@available(iOS 11.0, *)) {
        [searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}
- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [_searchViewController.searchBar.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
        _placeholderWidth = size.width + 5 + 20;
    }
    return _placeholderWidth;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //检索符合条件的数据，更新搜索结果vc
    _searchResultVC.searchKeyword = searchController.searchBar.text;
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchViewController.searchBar];
        [cancelButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        UITextField *tf = [CMPCommonTool getSearchFieldWithSearchBar:_searchViewController.searchBar];
        [tf mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-14-cancelButton.bounds.size.width-14);
        }];
    });
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    [self searchBarPlaceholderToLeft:_searchViewController.searchBar];
    // 调整SearchBar位置
    CGFloat height = [UIView staticStatusBarHeight];
    UIView *view = [searchController.searchBar superview];
    if (view.superview == searchController.view ) {
        CGRect f = view.frame;
        f.origin.y = height;
        f.origin.x = 0;
        [UIView animateWithDuration:0.2 animations:^{
            view.frame = f;
        } completion:^(BOOL finished) {
        }];
    }
    //搜索框弹出后的
    UIView *placeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    _listView.tableView.tableHeaderView = placeView;
}

- (void)presentSearchController:(UISearchController *)searchController
{
    
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    CGFloat height = [UIView staticStatusBarHeight];
    UIView *view = [searchController.searchBar superview];
    if (view.superview == searchController.view ) {
        CGRect f = view.frame;
        f.origin.y = height;
        f.origin.x = 0;
        [UIView animateWithDuration:0.2 animations:^{
            view.frame = f;
        } completion:^(BOOL finished) {
        }];
    }
    UITextField *tf = [CMPCommonTool getSearchFieldWithSearchBar:_searchViewController.searchBar];
    [tf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-14);
    }];
//    _searchViewController.searchBar.hidden = YES;
}
- (void)didDismissSearchController:(UISearchController *)searchController
{
    [self searchBarPlaceholderToMiddle:_searchViewController.searchBar];
    _listView.tableView.tableHeaderView = _searchViewController.searchBar;
//    _searchViewController.searchBar.hidden = NO;
}

#pragma mark - loadData
- (void)reloadContactData {
    
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    
    [_dataList removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
    
    __weak CMPSelectMultipleContactViewController *weakSelf = self;
    [[CMPMessageManager sharedManager] messageList:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf filterInvalidData:result];
        });
    }];
}

//过滤无效数据，并将有效的加入数组
- (void)filterInvalidData:(NSArray*)arr {
    
    for (NSInteger i = 0; i < arr.count; i++) {
        CMPMessageObject *info = arr[i];
        if (info.type == CMPMessageTypeRC) {
            [_dataList addObject:info];
        }
        if (info.type == CMPMessageTypeFileAssistant) {
            info.appName = SY_STRING(info.appName);
            [_dataList addObject:info];
        }
    }
    [_listView.tableView reloadData];
}

//选择群组
- (void)enterSelGroupVC {
    CMPSelectGroupMultipleViewController *groupVC = [[CMPSelectGroupMultipleViewController alloc]init];
    [self.navigationController pushViewController:groupVC animated:YES];
}

//底部取消人员后通知
- (void)bottomSelectContact:(NSNotification *)notify{
    [_listView.tableView reloadData];
    [_bottomView refreshData];
    [self layoutBottomViewByKeyboardHeight:0];
}
#pragma mark - UITable

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.1f : 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return  UIView.new;
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listView.width, 40)];
    view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];

    UIView *labelBgView =  [[UIView alloc] initWithFrame:CGRectMake(0, 14, _listView.width, 26)];
    labelBgView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    [view addSubview:labelBgView];

    //最近联系人title
    UILabel * label = [[UILabel alloc]init];
    label.frame = CGRectMake(14, 14, 150, 26);
    label.text = SY_STRING(@"forward_recent_contact");
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor =  [UIColor cmp_colorWithName:@"sup-fc1"];
    label.font = FONTSYS(12);
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *pushCell = @"pushCell";
        CMPSelContactPushCell *cell = [tableView dequeueReusableCellWithIdentifier:pushCell];
        if (cell == nil) {
            cell = [[CMPSelContactPushCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:pushCell];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.infoLabel.text = SY_STRING(@"forward_choose_group");
        cell.separatorImageView.hidden = YES;
        return cell;
    }
    
    //最近联系人
    CMPMessageObject *object = _dataList[indexPath.row];
    if (object.type == CMPMessageTypeFileAssistant) { //文件助手
        CMPSelContactListFileAssistantTypeCell *fileAssistantTypeCell = [tableView dequeueReusableCellWithIdentifier:fileAssistantTypeCellIdentifier];
        [fileAssistantTypeCell setDataModel:object];
        [fileAssistantTypeCell setSelectImageConfig];
        fileAssistantTypeCell.selectCell = [[CMPSelectContactManager sharedInstance].selectedCidArr containsObject:object.cId];
        
        return fileAssistantTypeCell;
    }
    
    static NSString *cellIde = @"cellIdeMultiple";
    CMPSelContactListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[CMPSelContactListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIde];
    }
    [cell setSelectImageConfig];
//    cell.selectCell = indexPath.row%2==0;//测试数据
    
    cell.selectCell = [[CMPSelectContactManager sharedInstance].selectedCidArr containsObject:object.cId];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init];
    obj.serverId = [CMPCore sharedInstance].serverID;
    if (object.subtype == CMPRCConversationType_GROUP) {
        obj.memberId = [NSString stringWithFormat:@"rcgroup_%@",object.cId] ;
        obj.downloadUrl = [CMPCore rcGroupIconUrlWithGroupId:object.cId];
    }
    else if (object.type == CMPMessageTypeFileAssistant) {
//        obj.memberId = object.cId;
//        obj.downloadUrl = @"image:msg_file_assistant:2719739";//[CMPCore memberIconUrlWithId:object.cId];
    }
    else {
        obj.memberId = object.cId;
        obj.downloadUrl = [CMPCore memberIconUrlWithId:object.cId];
    }
    cell.faceView.memberIcon = obj;
    cell.userNameLabel.text = object.appName;
    if (indexPath.row == _dataList.count - 1) {
        cell.separatorImageView.hidden = YES;
    } else {
        cell.separatorImageView.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    [self removeSearchBarHide];
    if (indexPath.section == 0) {
        [self enterSelGroupVC];
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CMPMessageObject *object = _dataList[row];
        BOOL select = NO;
        
        if ([cell isKindOfClass:CMPSelContactListCell.class]) {
            CMPSelContactListCell *listCell = (CMPSelContactListCell *)cell;
            listCell.selectCell = !listCell.selectCell;
            select = listCell.selectCell;
        }else if ([cell isKindOfClass:CMPSelContactListFileAssistantTypeCell.class]) {
            CMPSelContactListFileAssistantTypeCell *assistantCell = (CMPSelContactListFileAssistantTypeCell *)cell;
            assistantCell.selectCell = !assistantCell.selectCell;
            select = assistantCell.selectCell;
        }
        
        if(select){
            BOOL canSelect = [[CMPSelectContactManager sharedInstance] addSelectContact:object.cId
                                                                  name:object.appName
                                                                  type:object.type
                                                               subType:object.subtype];
            if(!canSelect){
                [self.searchResultVC.searchBar resignFirstResponder];
                if ([cell isKindOfClass:CMPSelContactListCell.class]) {
                    CMPSelContactListCell *listCell = (CMPSelContactListCell *)cell;
                    listCell.selectCell = NO;
                }else if ([cell isKindOfClass:CMPSelContactListFileAssistantTypeCell.class]) {
                    CMPSelContactListFileAssistantTypeCell *assistantCell = (CMPSelContactListFileAssistantTypeCell *)cell;
                    assistantCell.selectCell = NO;
                }
            }
        }else{
            [[CMPSelectContactManager sharedInstance] delSelectContact:object.cId];
        }
    }
}

- (void)selectRowAtIndexPath:(CMPMessageObject *)object {
    [self removeSearchBarHide];
    [self showForwardView:object];
}

- (void)closeUI {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showForwardView:(CMPMessageObject*)object {
    self.curMessageObject = object;
    if (!_sendView) {
        CGRect rect = self.view.bounds;
        _sendView = [[CMPMessageForwardView alloc] initWithFrame: CGRectMake(0, 0, rect.size.width, rect.size.height)];
        __weak typeof(self) weakSelf = self;
        _sendView.selectedBlock = ^(NSString *str,BOOL isCheck){
            NSMutableArray *selArr = [NSMutableArray array];
            [selArr addObject:weakSelf.curMessageObject];
            [weakSelf getSelectContactFinish:selArr content:[weakSelf.sendView getContentFieldText] isChecked:isCheck];
        };
        [weakSelf addNotis];
    }
    
    [self.view addSubview:_sendView];
    
    NSString *content = @"";
    UIImage *thumbnailImage = nil;
    NSString *fileSize = @"";
    if ([_msgModel.content isKindOfClass:[RCTextMessage class]] ||
        [_msgModel.content isKindOfClass:[CMPRCSystemImMessage class]]) {
        RCTextMessage *textMsg = (RCTextMessage*)_msgModel.content;
        content = textMsg.content;
    }
    else if ([_msgModel.content isKindOfClass:[RCFileMessage class]]) {
        
        RCFileMessage *fileMsg = (RCFileMessage*)_msgModel.content;
        content = [SY_STRING(@"msg_file") stringByAppendingString:fileMsg.name];
        NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:fileMsg.type];
        thumbnailImage = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];
        fileSize = [RCKitUtility getReadableStringForFileSize:fileMsg.size];
    }
    else if ([_msgModel.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imgMsg = (RCImageMessage*)_msgModel.content;
        thumbnailImage = imgMsg.thumbnailImage;
        content = SY_STRING(@"msg_image");
    }
    else if ([_msgModel.content isKindOfClass:[RCVoiceMessage class]]) {
        content = SY_STRING(@"msg_voice");
        
    }
    else if ([_msgModel.content isKindOfClass:[RCLocationMessage class]]) {
        RCLocationMessage *message = (RCLocationMessage *)_msgModel.content;
        content =  NSLocalizedStringFromTable(@"RC:LBSMsg", @"RongCloudKit", nil);
        content = [NSString stringWithFormat:@"%@%@",content,message.locationName];
    }
    else if ([_msgModel.content isKindOfClass:[CMPRCTransmitMessage class]]) {
        CMPRCTransmitMessage *textMsg = (CMPRCTransmitMessage*)_msgModel.content;
        content = textMsg.content;
    }
    else if ([_msgModel.content isKindOfClass:[CMPCombineMessage class]]) {
        CMPCombineMessage *textMsg = (CMPCombineMessage*)_msgModel.content;
        content = textMsg.title;
        content = [NSString stringWithFormat:@"「%@」%@",SY_STRING(@"rc_merge_message_forward"),content];
    }
    else if (_forwardSource == CMPForwardSourceTypeSingleMessages) {
        content = [NSString stringWithFormat:@"共%lu条消息",(unsigned long)self.selectedMessages.count] ;
        content = [NSString stringWithFormat:@"「%@」%@",SY_STRING(@"rc_single_messages_forward"),content];
    }
    else if ([_msgModel.content isKindOfClass:[CMPBusinessCardMessage class]]) {
        CMPBusinessCardMessage *cardMessage = (CMPBusinessCardMessage*)_msgModel.content;
        content = [NSString stringWithFormat:@"%@ %@",SY_STRING(@"rc_msg_business_card"),cardMessage.name] ;
    }
    
    SyFaceDownloadObj *iconObj = [[SyFaceDownloadObj alloc] init];
    iconObj.serverId = [CMPCore sharedInstance].serverID;
    if (object.subtype == CMPRCConversationType_GROUP) {
        iconObj.memberId = [NSString stringWithFormat:@"rcgroup_%@",object.cId] ;
        iconObj.downloadUrl = [CMPCore rcGroupIconUrlWithGroupId:object.cId];
    }
    else {
        iconObj.memberId = object.cId;
        iconObj.downloadUrl = [CMPCore memberIconUrlWithId:object.cId];
    }
    
    if (self.shareToUcDic) {
        NSString *title = self.shareToUcDic[@"title"];
        content = title;
        BOOL allowCheckedOutside = [self.shareToUcDic[@"params"][@"isShowFlow"] boolValue];
        if (allowCheckedOutside) {
            _sendView.allowCheckedOutside = allowCheckedOutside;
        }
    }
    
    [_sendView setThumbnailImage:thumbnailImage fileSize:fileSize];
    if (_filePaths.count) {
        _sendView.fileCount = _filePaths.count;
    }
    
    if (object.type == CMPMessageTypeFileAssistant) {
        [_sendView setLocalIcon:[UIImage imageNamed:@"msg_file_assistant_icon"]];
    } else {
        [_sendView setHeadIcon:iconObj];
    }
    
    [_sendView setName:object.appName];
    if ([content isKindOfClass:NSString.class]) {
        [_sendView setContent:content];
    }
}

- (void)sendForwardMsg:(RCMessageContent*)msg tag:(CMPMessageObject*)msgTag isChecked:(BOOL)isChecked
{
    RCConversationType chatType = (RCConversationType)msgTag.subtype;
    if (self.shareToUcDic) {//如果是分享组件调起的话，就直接转通过发送卡片的形式进行发送
        __weak typeof(self) weakSelf = self;
        if (msg) {//如果是文本消息就发送文本消息
            [[RCIMClient sharedRCIMClient] sendMessage:chatType targetId:msgTag.cId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
                //不使用 weak, 因为使用weak 本控制器不被释放
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
            } error:^(RCErrorCode nErrorCode, long messageId) {
                //不使用 weak, 因为使用weak 本控制器不被释放
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
            }];
            return;
        }
        //这里是BusinessMessage
        NSString *receiverIds = msgTag.cId;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.shareToUcDic[@"params"]];
        params[@"isForward"] = [NSString stringWithFormat:@"%d",isChecked];
        //        params[@"isShowFlow"] = nil;
        [[CMPMessageManager sharedManager] sendBusinessMessageWithParam:params receiverIds:receiverIds  success:^(NSString * _Nonnull messageId,id _Nonnull data) {
            NSString *status = data[@"status"];
            if ([status isEqualToString:@"failed"]) {
                if (weakSelf.forwardFail) {
                    weakSelf.forwardFail(-1);
                }
                return;
            }
            if (weakSelf.forwardSucess) {
                weakSelf.forwardSucess();
            }
            if (weakSelf.forwardSucessWithMsgObj) {
                weakSelf.forwardSucessWithMsgObj(msgTag, self.filePaths);
            }
        } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
            if (weakSelf.forwardFail) {
                weakSelf.forwardFail(-1);
            }
        }];
        return;
    }
    //
    //    if (self.willForwardMsg && !self.filePaths.count) {
    //        self.willForwardMsg(msgTag.cId);
    //        self.willForwardMsg = nil;
    //    }
    
    // 任务消息、催办消息
    if ([msg isKindOfClass:[CMPRCSystemImMessage class]]) {
        CMPRCSystemImMessage *systemImMessage = (CMPRCSystemImMessage*)msg;
        CMPRCTransmitMessage *traMsg = [[CMPRCTransmitMessage alloc] init];
        CMPRCSystemImMessageExtraMessage *extraMessage = systemImMessage.extraData.message;
        traMsg.sendName = [extraMessage.extra objectForKey:@"managers"];
        NSString *sendTime = extraMessage.t;
        sendTime = [[sendTime componentsSeparatedByString:@"."] firstObject];
        NSDate *sendDate = [CMPDateHelper dateFromStr:sendTime dateFormat:kDateFormate_yyyy_mm_dd_HH_mm];
        traMsg.sendTime = [sendDate cmp_millisecondStr];
        traMsg.mobilePassURL = extraMessage.mMl;
        if (systemImMessage.category == RCSystemImMessageCategoryTask) {
            traMsg.title = @"任务通知";
            traMsg.sendName = [extraMessage.extra objectForKey:@"managers"];
        } else if (systemImMessage.category == RCSystemImMessageCategoryColHasten) {
            traMsg.title = @"催办通知";
            traMsg.sendName = extraMessage.sn;
        }
        
        traMsg.appId = systemImMessage.appId;
        traMsg.extra = @"";
        traMsg.actionType = extraMessage.at;
        traMsg.content = systemImMessage.content;
        traMsg.PCPassURL = extraMessage.ml;
        traMsg.type = extraMessage.mt;
        msg = traMsg;
    }
    
    NSDictionary *extraDic = nil;
    //调用不影响ui发送，因为发生的对象不是当前ui不要关心
    if ([msg respondsToSelector:@selector(setExtra:)]) {
        NSString *chatTitle = msgTag.appName;
        if ([NSString isNull:chatTitle]) {
            chatTitle = @"";
        }
        extraDic = [NSDictionary dictionaryWithObjectsAndKeys:chatTitle, @"toName", [NSString uuid], @"msgId", msgTag.cId, @"toId", [CMPCore sharedInstance].userID, @"userId", [CMPCore sharedInstance].currentUser.name, @"userName" ,self.filePath.lastPathComponent,@"fileName",nil];
        [msg performSelector:@selector(setExtra:) withObject:[extraDic JSONRepresentation]];
    }
    /* 屏蔽掉，目前几个场景都没有进该方法，且该方法有问题。
     if (self.isSharedFromOtherApps && ![msg isKindOfClass: RCTextMessage.class]) {
     _chatVc = CMPRCChatViewController.alloc.init;
     _chatVc.targetId = msgTag.cId;
     _chatVc.conversationType = chatType;
     [_chatVc sendLocalFilesWithExtra:extraDic mediaModel: (RCMediaMessageContent *)self.msgModel.content];
     _chatVc.filePaths = self.filePaths;
     
     return;
     }*/
    
    if (![NSString isNull:self.targetId] && [msgTag.cId isEqualToString:self.targetId]) {
        //如果选择的是当前聊天的页面，当前界面转发给当前的人，就是重复一次   方便迅速刷新
        [[RCIM sharedRCIM] sendMessage:chatType targetId:self.targetId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
            //不使用 weak, 因为使用weak 本控制器不被释放
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            //不使用 weak, 因为使用weak 本控制器不被释放
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
        }];
    }
    else {
        [[RCIMClient sharedRCIMClient] sendMessage:chatType targetId:msgTag.cId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
            //不使用 weak, 因为使用weak 本控制器不被释放
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            //不使用 weak, 因为使用weak 本控制器不被释放
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
        }];
    }
}

- (void)getSelectContactFinish:(NSArray*)userList content:(NSString*)str isChecked:(BOOL)isChecked
{
    if (self.filePaths) {
        if(self.forwardSucessWithMsgObj){
            self.forwardSucessWithMsgObj(userList.firstObject, self.filePaths);
            if (![NSString isNull:str]) {
                RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
                [self sendForwardMsg:msgNews tag:userList.firstObject isChecked:isChecked];
            }
        }
        /* if (self.forwardSucess || self.forwardSucessWithMsgObj) {
         if (self.willForwardMsg) {
         self.willForwardMsg(self.targetId);
         }
         
         CMPMessageObject *msgTag = userList.firstObject;
         RCConversationType chatType = (RCConversationType)msgTag.subtype;
         _chatVc = CMPRCChatViewController.alloc.init;
         _chatVc.targetId = msgTag.cId;
         _chatVc.conversationType = chatType;
         _chatVc.filePaths = self.filePaths.copy;
         
         __weak typeof(self) weakSelf = self;
         _chatVc.forwardSuccess = ^{
         
         if (weakSelf.forwardSucess) {
         weakSelf.forwardSucess();
         }
         if (weakSelf.forwardSucessWithMsgObj) {
         weakSelf.forwardSucessWithMsgObj(msgTag);
         }
         };
         
         [_chatVc sendFiesWtihFilePaths];
         
         if (![NSString isNull:str]) {
         RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
         [self sendForwardMsg:msgNews tag:userList.firstObject isChecked:isChecked];
         }
         }
         
         else if(self.forwardSucessWithMsgObj){
         if (self.willForwardMsg) {
         self.willForwardMsg(self.targetId);
         }
         self.forwardSucessWithMsgObj(userList.firstObject);
         }
         */
        return;
    }
    
    _totalForwardTag = [NSString isNull:str] ?userList.count :userList.count*2;
    if (userList.count > 0) {
        for (NSInteger i = 0; i < userList.count; i++) {
            CMPMessageObject *msgTag = userList[i];
            RCMessageContent *msg = self.msgModel.content;
            self.selectedMsgTag = msgTag;
            if (self.forwardSource == CMPForwardSourceTypeOnlySingleMessage) {
                [self sendForwardMsg:msg tag:msgTag isChecked:isChecked];
            }
            if (self.forwardSource == CMPForwardSourceTypeSingleMessages || self.forwardSource == CMPForwardSourceTypeMergeMessage) {
                if (self.getSelectContactFinishBlock) {
                    RCConversation *conversation = [[RCConversation alloc] init];
                    conversation.conversationType = (RCConversationType)msgTag.subtype;
                    conversation.targetId = msgTag.cId;
                    
                    RCConversation *senderConversation = [[RCConversation alloc] init];
                    senderConversation.conversationType = (RCConversationType)msgTag.subtype;
                    senderConversation.targetId = self.targetId;
                    
                    self.getSelectContactFinishBlock(@[conversation,senderConversation]);
                    
                    if (self.willForwardMsg) {
                        self.willForwardMsg(msgTag.cId);
                        self.willForwardMsg = nil;
                    }
                }
            }
            if (![NSString isNull:str]) {
                RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
                [self sendForwardMsg:msgNews tag:msgTag isChecked:isChecked];
            }
        }
    }
}

- (void)handleForwardSucess:(NSNotification *)not {
    [self checkForwardWithSucess:YES errorCode:0];
}

- (void)handleForwardFail:(NSNotification *)not {
    NSNumber *number = not.object;
    NSInteger code = [number integerValue];
    [self checkForwardWithSucess:NO errorCode:code];
}

- (void)checkForwardWithSucess:(BOOL)sucess errorCode:(NSInteger)code {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sucess) {
            self->_sucessForwardTag++;
        }
        else {
            self->_failForwardTag++;
            self->_errorCode = code;
        }
        if (self->_sucessForwardTag + self->_failForwardTag == self->_totalForwardTag) {
            if (self->_failForwardTag == 0) {
                if (weakSelf.forwardSucess) {
                    weakSelf.forwardSucess();
                    weakSelf.forwardSucess = nil;
                }
                
                if (weakSelf.forwardSucessWithMsgObj) {
                    weakSelf.forwardSucessWithMsgObj(weakSelf.selectedMsgTag, self.filePaths);
                    weakSelf.forwardSucessWithMsgObj = nil;
                }
            }
            else {
                if (weakSelf.forwardFail) {
                    weakSelf.forwardFail(self->_errorCode);
                    weakSelf.forwardFail = nil;
                }
            }
            [CMPSelectMultipleContactViewController cleanStatic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
            });
        }
    });
}

/*
#pragma mark 文件发送回调
- (void)messageBaseCellUpdateSendingStatus:(NSNotification *)noti {
    RCMessageCellNotificationModel *model = noti.object;
    if ([CONVERSATION_CELL_STATUS_SEND_SUCCESS isEqualToString:model.actionName] && !self.filePaths.count) {
        //成功回调
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
        
    }else if ([CONVERSATION_CELL_STATUS_SEND_FAILED isEqualToString:model.actionName] && !self.filePaths.count) {
        //失败回调
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:-1]];
    }
}
*/

@end
