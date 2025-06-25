//
//  XZMainView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#import "XZMainView.h"
#import "SPTools.h"

@interface XZMainView(){
    CGFloat _keyboardHeight;
}
@end

@implementation XZMainView

- (void)dealloc {
    [UIView setAnimationDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
    [self showTableView];
    [self showBottomBarView];
}

- (void)customLayoutSubviews {
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    
    CGFloat maxHeight = 0;
    switch (_viewType) {
        case mainViewInputType_text:{
            CGFloat selfHeight = self.height;
            CGRect r = _textEditView.frame;
            CGFloat orgy = selfHeight - _keyboardHeight-r.size.height;
            r.origin.y = orgy;
            r.size.width = self.width;
            [_textEditView setFrame:r];
            [_textEditView customLayoutSubviews];
            maxHeight = orgy;
            
            _textEditView.hidden = NO;
            _memberInpitView.hidden = YES;
            _bottomBar.hidden = YES;
        }
            break;
        case mainViewInputType_member:{
            CGFloat selfHeight = self.height;
            CGRect r = _memberInpitView.frame;
            r.size.width = self.width;
            r.size.height = [_memberInpitView viewHeightForWidth:r.size.width];
            CGFloat orgy = selfHeight - _keyboardHeight-r.size.height;
            r.origin.y = orgy;
            [_memberInpitView setFrame:r];
            [_memberInpitView customLayoutSubviews];
            maxHeight = orgy;
            _textEditView.hidden = YES;
            _memberInpitView.hidden = NO;
            _bottomBar.hidden = YES;
        }
            break;
            
        default: {
            CGFloat selfHeight = self.height-edgeInsets.bottom;
            [_bottomBar setFrame:CGRectMake(0,selfHeight-kXZBottomBarHeight, self.width, kXZBottomBarHeight)];
            [_bottomBar customLayoutSubviews];
            maxHeight = _bottomBar.originY;
           
            _textEditView.hidden = YES;
            _memberInpitView.hidden = YES;
            _bottomBar.hidden = NO;
        }
            break;
    }
    [_tableView setFrame:CGRectMake(edgeInsets.left, 0, self.width-edgeInsets.left-edgeInsets.right, maxHeight)];
}


#pragma mark TableView
- (void)showTableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
}

- (void)keyboardWillShow:(NSNotification *)noti{
    NSDictionary *obj = [noti userInfo];
    CGRect keyboardRect = [[obj objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:aDuration animations:^{
        [weakSelf layoutSubviewsForKeyboardShow];
    } completion:^(BOOL finished) {
        [weakSelf keyboardShowStop];
    }];

}
- (void)layoutSubviewsForKeyboardShow {
    switch (_viewType) {
        case mainViewInputType_text:{
            CGFloat selfHeight = self.height;
            CGRect r = _textEditView.frame;
            CGFloat orgy = selfHeight - _keyboardHeight-r.size.height;
            r.origin.y = orgy;
            r.size.width = self.width;
            [_textEditView setFrame:r];
            [_textEditView customLayoutSubviews];
            _textEditView.hidden = NO;
            _memberInpitView.hidden = YES;
            _bottomBar.hidden = YES;
        }
            break;
        case mainViewInputType_member:{
            CGFloat selfHeight = self.height;
            CGRect r = _memberInpitView.frame;
            r.size.width = self.width;
            r.size.height = [_memberInpitView viewHeightForWidth:r.size.width];
            CGFloat orgy = selfHeight - _keyboardHeight-r.size.height;
            r.origin.y = orgy;
            [_memberInpitView setFrame:r];
            [_memberInpitView customLayoutSubviews];
            _textEditView.hidden = YES;
            _memberInpitView.hidden = NO;
            _bottomBar.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

- (void)keyboardShowStop {
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    CGFloat maxHeight = 0;
    switch (_viewType) {
        case mainViewInputType_text:
            maxHeight = _textEditView.originY;
            break;
        case mainViewInputType_member:
            maxHeight = _memberInpitView.originY;
            break;
            
        default:
            break;
    }
    [_tableView setFrame:CGRectMake(edgeInsets.left, 0, self.width-edgeInsets.left-edgeInsets.right, maxHeight)];
    [self scrollTableViewBottom];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    _keyboardHeight = 0;
    NSDictionary *obj = [noti userInfo];
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:aDuration animations:^{
        [weakSelf layoutSubviewsForKeyboardHide];
    } completion:^(BOOL finished) {
        [weakSelf keyboardHideStop];
    }];
    [_memberInpitView clearView];
}

- (void)layoutSubviewsForKeyboardHide{
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    CGFloat selfHeight = self.height-edgeInsets.bottom;
    
    CGRect r = _textEditView.frame;
    r.origin.y = selfHeight;
    [_textEditView setFrame:r];
    [_textEditView customLayoutSubviews];
    
    r = _memberInpitView.frame;
    r.origin.y = selfHeight;
    [_memberInpitView setFrame:r];
    [_memberInpitView customLayoutSubviews];
    
    [_bottomBar setFrame:CGRectMake(0,selfHeight-kXZBottomBarHeight, self.width, kXZBottomBarHeight)];
    [_bottomBar customLayoutSubviews];
   
    CGFloat maxHeight = _bottomBar.originY;
    [_tableView setFrame:CGRectMake(edgeInsets.left, 0, self.width-edgeInsets.left-edgeInsets.right, maxHeight)];
}

- (void)keyboardHideStop {
    [self hideTextEditView];
    _memberInpitView.hidden = YES;
    _bottomBar.hidden = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(mainViewKeyboardDidKeyboardHideFinish)]) {
        [_delegate mainViewKeyboardDidKeyboardHideFinish];
    }
}

#pragma mark start

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showBottomBarView {
    self.viewType = mainViewInputType_speech;
    if (!_bottomBar) {
        _bottomBar = [[XZBottomBar alloc] initWithFrame:CGRectMake(0, self.height-kXZBottomBarHeight, self.width, kXZBottomBarHeight)];
        [self addSubview:_bottomBar];
    }
    _bottomBar.hidden = NO;
    [_bottomBar showButtonAnimation];
}

- (void)hideBottomBarView {
    _bottomBar.hidden = YES;
}

- (void)showTextEditView {
    self.viewType = mainViewInputType_text;
    if (!_textEditView) {
        _textEditView = [[XZTextEditView alloc] initWithFrame:CGRectMake(0, self.height-_keyboardHeight-kDefaultTextEditHeight, self.width, kDefaultTextEditHeight)];
        [self addSubview:_textEditView];
    }
    _textEditView.hidden = NO;
}

- (void)hideTextEditView {
    _textEditView.hidden = YES;
}

- (void)showMemberInputView {
    self.viewType = mainViewInputType_member;
    if (!_memberInpitView) {
        _memberInpitView = [[XZMemberTextView alloc] initWithFrame:CGRectMake(0, self.height-_keyboardHeight-kDefaultTextEditHeight, self.width, kDefaultTextEditHeight)];
        [self addSubview:_memberInpitView];
    }
    _memberInpitView.isMultiSelect = self.isMultiChoosemMember;
    _memberInpitView.isShow = YES;
    [_memberInpitView showKeyboard];
}

- (void)hideMemberInputView {
    [_memberInpitView removeFromSuperview];
    _memberInpitView = nil;
}

- (void)restoreView {
    [self hideKeyboard];
    [self hideTextEditView];
    [self hideMemberInputView];
    [self customLayoutSubviews];
}

- (void)clearInput {
    [_textEditView clearInput];
    [_memberInpitView clearInput];
}

- (void)showKeyboard {
    if (_viewType == mainViewInputType_text) {
        [_textEditView showKeyboard];
    }
    else if (_viewType == mainViewInputType_member) {
        [_memberInpitView showKeyboard];
    }
}

- (void)hideKeyboard {
    self.viewType = mainViewInputType_speech;
    if (_keyboardHeight >0) {
        [_textEditView hideKeyboard];
        [_memberInpitView hideKeyboard];
    }
}

- (BOOL)isInSpeechView {
    if (_viewType == mainViewInputType_text) {
        return NO;
    }
    if (_viewType == mainViewInputType_member) {
        return NO;
    }
    return  YES;
}

- (void)scrollTableViewBottom {
    [_tableView  reloadData];
    NSInteger count = [_tableView numberOfRowsInSection:0];
    if (count >0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

@end
