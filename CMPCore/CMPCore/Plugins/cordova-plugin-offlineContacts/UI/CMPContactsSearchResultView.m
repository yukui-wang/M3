//
//  CMPContactsSearchResultView.m
//  M3
//
//  Created by CRMO on 2017/11/27.
//

#import "CMPContactsSearchResultView.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPSelectMultipleBottomView.h"
#import "CMPSelectContactManager.h"
#import "CMPForwardSearchViewController.h"
#import "CMPSelectMultipleContactViewController.h"
CGFloat const CMPContactsSearchResultViewSearchFieldFont = 12;

@interface CMPContactsSearchResultView()

@property (assign, nonatomic) CGFloat searchBarHeight;
@property (assign, nonatomic) BOOL showSearchBar;
@property (assign, nonatomic) BOOL isMultipleSelect;//多选

@property (strong, nonatomic) CMPSelectMultipleBottomView *bottomView;
@property (assign, nonatomic) CGFloat keyboardHeight;

@property (weak, nonatomic) id dddelegate;
@end

@implementation CMPContactsSearchResultView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
              searchBarHeight:(CGFloat)searchBarHeight {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [UIColor cmp_colorWithName:@"white-bg1"];
        self.showSearchBar = showSearchBar;
        self.searchBarHeight = searchBarHeight;
        if (self.showSearchBar) {
            [self addSubview:self.searchBar];
        }
        [self addSubview:self.tableView];
        
        // 注册取消按钮KVO
        UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchBar];
        [cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        [cancelButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                showSearchBar:(BOOL)showSearchBar
              searchBarHeight:(CGFloat)searchBarHeight
                isMultipleSelect:(BOOL)isMultipleSelect
             delegate:(id)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.dddelegate = delegate;
        self.isMultipleSelect = isMultipleSelect;
        self.backgroundColor =  [UIColor cmp_colorWithName:@"white-bg1"];
        self.showSearchBar = showSearchBar;
        self.searchBarHeight = searchBarHeight;
        if (self.showSearchBar) {
            [self addSubview:self.searchBar];
        }
        [self addSubview:self.tableView];
        if(isMultipleSelect){
            //add bottomView
            _bottomView = [[CMPSelectMultipleBottomView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, [CMPSelectMultipleBottomView defaultHeight])];
            _bottomView.viewController = delegate;
            [self addSubview:_bottomView];
            //关联VC
            if([delegate isKindOfClass:NSClassFromString(@"CMPForwardSearchViewController")]){
                CMPForwardSearchViewController *vc = delegate;
                
                CMPSelectMultipleContactViewController *mVC = (CMPSelectMultipleContactViewController *)vc.delegate;
                _bottomView.viewController = mVC;
                
                __weak typeof(mVC) weakMVC = mVC;
                _bottomView.confirmBtnBlcok = ^{
                    [weakMVC.searchResultVC.searchBar resignFirstResponder];
                    [weakMVC removeSearchBarHide];
                };
                _bottomView.cancelBtnBlcok = ^{
                    [weakMVC.searchResultVC.searchBar resignFirstResponder];
                    [weakMVC removeSearchBarHide];
                };
            }
            
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
        
        // 注册取消按钮KVO
        UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchBar];
        [cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        [cancelButton addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionOld context:nil];
        
    }
    return self;
}

//底部取消人员后通知
- (void)bottomSelectContact:(NSNotification *)notify{
    [_tableView reloadData];
    [_bottomView refreshData];
}

- (void)removeObserver {
    UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchBar];
    [cancelButton removeObserver:self forKeyPath:@"enabled"];
}

// 保证取消按钮保持enabled
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[UIButton class]]) {
        UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchBar];
        if (!cancelButton.enabled) {
            cancelButton.enabled = YES;
        }
    }
}

- (void)focusTextView {
    [_searchBar becomeFirstResponder];
}

- (void)unFocusTextView {
    [_searchBar resignFirstResponder];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.showSearchBar) {
        _searchBar.frame = CGRectMake(7, CMP_STATUSBAR_HEIGHT, self.frame.size.width-14, self.searchBarHeight);
    }
    CGFloat botH = [CMPSelectMultipleBottomView defaultHeight];
    //V5-56990 进入多选界面，搜索人员名称后，名字会被遮挡 56 + 40+10 加了个10高度
    CGFloat tableY = self.showSearchBar?CGRectGetMaxY(_searchBar.frame):(IS_IPHONE_X_UNIVERSAL?56 + 40+10:56 + 20);

    CGFloat tableH = _isMultipleSelect?self.frame.size.height - (botH+CMP_SafeBottomMargin_height):self.frame.size.height;
    tableH = tableH - tableY;
    
    tableH = tableH - _keyboardHeight;
    if (_keyboardHeight>0) {
        tableH = tableH + CMP_SafeBottomMargin_height;
    }
    
    _tableView.frame = CGRectMake(0, tableY, self.frame.size.width, tableH);
    
    if (_bottomView) {
        _bottomView.frame = CGRectMake(0, CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame), botH);
    }
}

#pragma mark-键盘
// 处理键盘弹起事件
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    [self layoutSubviews];
}
// 处理键盘隐藏事件
- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    [self layoutSubviews];
}

#pragma mark-Getter&Setter

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
            _searchBar.placeholder = SY_STRING(@"contacts_searchkey_new");
        } else {
            _searchBar.placeholder = SY_STRING(@"contacts_searchkey_old");
        }
        
        _searchBar.showsCancelButton = YES;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor cmp_colorWithName:@"white-bg1"]];
        _searchBar.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
        UIImage *bgImage = [[UIImage imageWithName:@"searchbar_bg" inBundle:@"offlineContact"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"input-bg"]];
        UIImage *iconImage = [[UIImage imageWithName:@"searchbar_icon" inBundle:@"offlineContact"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"sup-fc2"]];
        [_searchBar setSearchFieldBackgroundImage:bgImage forState:UIControlStateNormal];
        [_searchBar setImage:iconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        _searchBar.searchTextPositionAdjustment = UIOffsetMake(5, 0);
        
        UITextField *searchField = [CMPCommonTool getSearchFieldWithSearchBar:_searchBar];
        NSDictionary *attrDic = @{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc2"] ,
                                  NSFontAttributeName : [UIFont systemFontOfSize:14]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:_searchBar.placeholder attributes:attrDic];
        searchField.attributedPlaceholder = attrStr;
        searchField.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        searchField.font = [UIFont systemFontOfSize:14];
        
        UIButton *cancelButton = [CMPCommonTool getCancelButtonWithSearchBar:_searchBar];
        [cancelButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat y;
        if (self.showSearchBar) {
            y = CGRectGetMaxY(self.searchBar.frame);
        } else {
            y = 0;
        }
        CGRect tabFrame = CGRectMake(0, y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - y);
        _tableView = [[UITableView alloc] initWithFrame:tabFrame style:UITableViewStylePlain];
        _tableView.backgroundColor =  [UIColor cmp_colorWithName:@"white-bg1"];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
    }
    return _tableView;
}

@end
