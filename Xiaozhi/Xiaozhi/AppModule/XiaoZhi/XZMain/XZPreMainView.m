//
//  XZMainView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#import "XZPreMainView.h"
#import "SPTools.h"

@interface XZPreMainView()<UIGestureRecognizerDelegate>{
    UIImageView *_logoBgView;//顶部头像
    XZBottomView *_bottomView;//底部条
    XZSubSearchView *_subSearchView;//显示搜索小模块
    XZPreFrequentView *_frequentView;//常用联系人
    XZTextEditView *_textEditView;//键盘输入
    XZRecorderWave *_speakingWaveView;//语音波浪线界面
    XZRippleView *_rippleView;//波纹
    XZMemberTextView *_memberInpitView;//选人输入界面
    UILabel *_toastView;
    CGFloat _bottomH;
    BOOL _isMemberView;//当前是选人
    BOOL _isMulti;//选人多选
    
    CGFloat _keyboardHeight;

}

@end

@implementation XZPreMainView

- (void)dealloc {
    [UIView setAnimationDelegate:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    SY_RELEASE_SAFELY(_rippleView);
    
    self.speakButton = nil;
    SY_RELEASE_SAFELY(_logoView);
    SY_RELEASE_SAFELY(_tableView);
    SY_RELEASE_SAFELY(_logoBgView);
    SY_RELEASE_SAFELY(_bottomView);
    SY_RELEASE_SAFELY(_subSearchView);
    SY_RELEASE_SAFELY(_speakingWaveView);
    SY_RELEASE_SAFELY(_frequentView);
    SY_RELEASE_SAFELY(_textEditView);
    SY_RELEASE_SAFELY(_memberInpitView);
    SY_RELEASE_SAFELY(_toastView);
    [super dealloc];
}

- (void)setup {
    [self addTableView];
    [self addBottomView];
    [self addlogoView];
    [self addSpeakButton];
    self.backgroundColor = UIColorFromRGB(0xf2f5f7);

}

- (void)customLayoutSubviews {
    
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    CGFloat selfHeight = self.height-edgeInsets.bottom;
    if (_keyboardHeight != 0) {
        selfHeight = self.height;
    }
    [_logoBgView setFrame:CGRectMake(self.width/2-34.5, 0, 69, 23)];
    [_logoView setFrame:CGRectMake(self.width/2-23, -40, 46, 60)];
    [_bottomView setFrame:CGRectMake(0,selfHeight-kXZBottomViewH, self.width, kXZBottomViewH)];
    [_speakButton setFrame:CGRectMake(self.width/2-30, selfHeight-60-18, 60, 60)];
    [_bottomView customLayoutSubviews];
    
    CGFloat maxHeight = _bottomView.originY;
    CGFloat tableHeight = _bottomView.originY;
    BOOL showotherViews = YES;
    if (_textEditView && !_textEditView.hidden) {
        CGRect r = _textEditView.frame;
        r.origin.y = selfHeight - _keyboardHeight-r.size.height;
        r.size.width = self.width;
        [_textEditView setFrame:r];
        [_textEditView customLayoutSubviews];
        maxHeight = _textEditView.originY;
        tableHeight = maxHeight;
    }
    else if (_memberInpitView && !_memberInpitView.hidden) {
        CGRect r = _memberInpitView.frame;
        r.origin.y = selfHeight - _keyboardHeight-r.size.height;
        r.size.width = self.width;
        [_memberInpitView setFrame:r];
        [_memberInpitView customLayoutSubviews];
        maxHeight = _memberInpitView.originY;
        tableHeight = maxHeight;
    }
    else if (_speakingWaveView && !_speakingWaveView.hidden) {
        //语音波纹
        [_speakingWaveView setFrame:CGRectMake(0, maxHeight-_speakingWaveView.height, self.width, _speakingWaveView.height)];
        maxHeight = _speakingWaveView.originY;
        tableHeight = maxHeight;
        [_speakingWaveView customLayoutSubviews];
        if (_rippleView && !_rippleView.hidden) {
            _rippleView.center = _speakButton.center;
            [self bringSubviewToFront:_rippleView];
        }
    }
    else {
        showotherViews = NO;
    }
    
    if (_frequentView && !_frequentView.hidden) {
        //常用联系人
        if (!showotherViews) {
            maxHeight = _speakButton.originY;
        }
        [_frequentView setFrame:CGRectMake(0, maxHeight-_frequentView.height, self.width, _frequentView.height)];
        maxHeight = _frequentView.originY;
        tableHeight = maxHeight;
        [_frequentView customLayoutSubviews];
    }
    if (_subSearchView && !_subSearchView.hidden) {
        //搜索小项
        if (!showotherViews) {
            maxHeight = _speakButton.originY;
        }
        [_subSearchView setFrame:CGRectMake(0, maxHeight-_subSearchView.height, self.width, _subSearchView.height)];
        maxHeight = _subSearchView.originY;
        tableHeight = maxHeight;
        [_subSearchView customLayoutSubviews];
    }
    [_tableView setFrame:CGRectMake(edgeInsets.left, 0, self.width-edgeInsets.left-edgeInsets.right, tableHeight)];
    [self scrollTableViewBottom];
}

- (void)showSpeakingWaveView{
    
}

- (void)hideSpeakingWaveView{
    if (_speakingWaveView) {
        [_speakingWaveView removeFromSuperview];
        SY_RELEASE_SAFELY(_speakingWaveView);
    }
}
#pragma mark 标志
- (void)addlogoView{
    if (!_logoBgView) {
        _logoBgView = [[UIImageView alloc] init];
        _logoBgView.image = XZ_IMAGE(@"xz_half.png");
        [self addSubview:_logoBgView];
    }
    if (!_logoView) {
        _logoView = [[UIImageView alloc] init];
        [self addSubview:_logoView];
    }
}

- (void)showLogoView:(BOOL)show {
    _logoBgView.hidden = !show;
    _logoView.hidden = _logoBgView.hidden;
    [self bringSubviewToFront:_logoBgView];
    [self bringSubviewToFront:_logoView];
}

- (void)addSpeakButton {
    if (!self.speakButton) {
        self.speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.speakButton setImage:XZ_IMAGE(@"xz_speakbtn_def.png") forState:UIControlStateNormal];
        [self.speakButton setImage:XZ_IMAGE(@"xz_speakbtn_pre.png") forState:UIControlStateSelected];
        [self addSubview:self.speakButton];
        [self.speakButton addTarget:self action:@selector(speakButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)speakButtonAction:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(speakButtonClickedWithMainView:)]) {
        [self.delegate speakButtonClickedWithMainView:self];
    }
}


#pragma mark TableView
- (void)addTableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f5f7);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)] autorelease];
        header.backgroundColor = UIColorFromRGB(0xf2f5f7);
        _tableView.tableHeaderView = header;
        
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)] autorelease];
        footer.backgroundColor = UIColorFromRGB(0xf2f5f7);
        _tableView.tableFooterView = footer;
        
        [self addSubview:_tableView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
        tapGestureRecognizer.delegate = self;
        [_tableView addGestureRecognizer:tapGestureRecognizer];
        SY_RELEASE_SAFELY(tapGestureRecognizer)
       
    }
}

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self endEditing:YES];
//    if ([self keyboardIsShow]) {
//        [self hideKeyboard];
//        [_tableView  reloadData];
//    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:NSClassFromString(@"XZTapLabel")]) {
        return NO;
    }
    if ([touch.view isKindOfClass:NSClassFromString(@"XZBaseItem")]) {
        return NO;
    }
    if ([touch.view isKindOfClass:NSClassFromString(@"UITextView")]) {
        return NO;
    }
    return  YES;
}

#pragma mark 底部条界面
- (void)addBottomView{
    if (!_bottomView) {
        _bottomView = [[XZBottomView alloc] initWithFrame:CGRectMake(0, self.height-kXZBottomViewH, self.width, kXZBottomViewH)];
        [self addSubview:_bottomView];
    }
    [_bottomView.keyboardButton addTarget:self action:@selector(keyboardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _bottomH = _bottomView.height;
}


- (void)keyboardButtonAction:(id)sender{
    if (_isMemberView) {
        [self showMemberInputView];
    }
    else {
        [self showTextEditView];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardButtonClickedWithMainView:)]) {
        [self.delegate keyboardButtonClickedWithMainView:self];
    }
}

- (void)helpButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showHelpViewWithMainView:)]) {
        [self.delegate showHelpViewWithMainView:self];
    }
}

#pragma mark 键盘输入界面
- (void)addTextEditView {
    _speakButton.hidden = YES;
    _speakButton.userInteractionEnabled = YES;
    if (!_textEditView) {
        _keyboardHeight = 10;// OA-144678 先设置个初始值
        _textEditView = [[XZTextEditView alloc] initWithFrame:CGRectMake(0, self.height-_keyboardHeight-kDefaultTextEditHeight, self.width, kDefaultTextEditHeight)];
        [self addSubview:_textEditView];
        _textEditView.delegate = self.delegate;
        [_textEditView.speakButton addTarget:self action:@selector(speakButtonAction_textEditView:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self customLayoutSubviews];
}

- (void)speakButtonAction_textEditView:(id)sender {
    _speakButton.hidden = NO;
    _speakButton.userInteractionEnabled = YES;
    [self hideTextEditView];
    [self customLayoutSubviews];
    [self speakButtonAction:nil];
}

- (void)showTextEditView{
    _textEditView.hidden = NO;
    [self addTextEditView];
    _textEditView.delegate = self.delegate;
    [_textEditView.textView becomeFirstResponder];
    [self hideWaveView];
}

- (void)hideTextEditView{
    _textEditView.hidden = YES;
    [self hideKeyboard];
}

- (void)clearInput {
    [_textEditView clearInput];
    [_memberInpitView clearInput];
}

#pragma mark 语音编辑界面
- (void)showWaveView{
    [self hideTextEditView];
    if (!_speakingWaveView) {
        _speakingWaveView = [[XZRecorderWave alloc] initWithFrame:CGRectMake(0, _bottomView.originY-46, self.width, 46)];
        [self addSubview:_speakingWaveView];
    }
    [_speakingWaveView setFrame:CGRectMake(0, _bottomView.originY-46, self.width, 46)];
    [_tableView setFrame:CGRectMake(0, 0, self.width, _speakingWaveView.originY)];
    if (!_rippleView) {
        _rippleView = [[XZRippleView alloc] initWithFrame:CGRectMake(self.width/2-40, _bottomView.originY-40, 80, 80)];
        [self addSubview:_rippleView];
        _rippleView.delegate = self.delegate;
    }
    [_rippleView show];
    [self customLayoutSubviews];
}

- (void)showWaveViewAnalysis {
    [self bringSubviewToFront:_rippleView];
    [_rippleView showAnalysisAnimation];
}

- (void)hideWaveView {
    if (!_speakingWaveView || _speakingWaveView.hidden) {
        return;
    }
    _speakingWaveView.hidden = YES;
    [_speakingWaveView removeFromSuperview];
    SY_RELEASE_SAFELY(_speakingWaveView);
    _rippleView.hidden = YES;
    [_rippleView removeFromSuperview];
    SY_RELEASE_SAFELY(_rippleView);
    [self customLayoutSubviews];
    [self hideToast];
    [self checkSpeakButtonHidden];
}

- (void)hideToast {
    [_toastView removeFromSuperview];
    SY_RELEASE_SAFELY(_toastView);
}

#pragma mark 索小模块
- (void)showSearchItemsView{
    if (!_subSearchView) {
        _subSearchView = [[XZSubSearchView alloc] initWithFrame:CGRectMake(0, _bottomView.originY, self.width, 50)];
        _subSearchView.delegate = self.delegate;
        [self addSubview:_subSearchView];        
    }
    [_subSearchView setFrame:CGRectMake(0, _speakingWaveView&&!_speakingWaveView.hidden ? _speakingWaveView.originY-50:_bottomView.originY-50-30, self.width, 50)];//30语音按钮
    [_tableView setFrame:CGRectMake(0, 0, self.width, _subSearchView.originY)];
    [self customLayoutSubviews];
}

- (void)hideSearchItemsView{
    _subSearchView.hidden = YES;
    [_subSearchView removeFromSuperview];
    SY_RELEASE_SAFELY(_subSearchView);
    [_tableView setFrame:CGRectMake(0, 0, self.width, _speakingWaveView&&!_speakingWaveView.hidden ? _speakingWaveView.originY:_bottomView.originY)];
    [self customLayoutSubviews];
}

#pragma mark 选人

- (void)showMemberView:(BOOL)multi {
    _isMulti = multi;
    _isMemberView = YES;
    if (_textEditView && !_textEditView.hidden) {
        //键盘输入界面没有隐藏
        _textEditView.hidden = YES;
        [self showMemberInputView];
    }
    
}

- (void)hideMemberView {
    _isMemberView = NO;
    if (_memberInpitView && !_memberInpitView.hidden) {
        _textEditView.hidden = NO;
        [_textEditView.textView becomeFirstResponder];
    }
    [self hideFrequentView];
    [self hideMemberInputView];
}

- (void)showMemberInputView {
    _speakButton.hidden = YES;
    _speakButton.userInteractionEnabled = YES;
    if (!_memberInpitView) {
        _memberInpitView = [[XZMemberTextView alloc] initWithFrame:CGRectMake(0, self.height-_keyboardHeight-kDefaultTextEditHeight, self.width, kDefaultTextEditHeight)];
        [self addSubview:_memberInpitView];
        _memberInpitView.delegate = self.delegate;
        [_memberInpitView.speakButton addTarget:self action:@selector(speakButton_memberInpitView) forControlEvents:UIControlEventTouchUpInside];
    }
    _memberInpitView.isMultiSelect = _isMulti;
    _memberInpitView.isShow = YES;
    [_memberInpitView showKeyboard];
}

- (void)speakButton_memberInpitView {
    _speakButton.hidden = NO;
    _memberInpitView.isShow = NO;
    [self hideKeyboard];
    [self customLayoutSubviews];
}

- (void)hideMemberInputView {
    _memberInpitView.isShow = NO;
}

#pragma mark 常用联系人
- (void)showFrequentView:(BOOL)multi members:(NSArray *)members {
    if (!_frequentView) {
        CGFloat height = [XZPreFrequentView defaultHeight];
        CGRect r = CGRectMake(0, _bottomView.originY-20-height, self.width,height);
        _frequentView = [[XZPreFrequentView alloc] initWithFrame:r];
        [self addSubview:_frequentView];
        _frequentView.delegate = (id)self.delegate;
        _frequentView.backgroundColor = UIColorFromRGB(0xf2f5f7);
    }
    _frequentView.members = members;
    _frequentView.isMultiSelect = multi;
    [self customLayoutSubviews];
}

- (void)hideFrequentView {
    [_frequentView removeFromSuperview];
    SY_RELEASE_SAFELY(_frequentView);
    [self customLayoutSubviews];
}

- (void)restoreView {
    [self hideKeyboard];
    
    [_subSearchView removeFromSuperview];
    SY_RELEASE_SAFELY(_subSearchView);
        
    [_frequentView removeFromSuperview];
    SY_RELEASE_SAFELY(_frequentView);
    
    [_speakingWaveView removeFromSuperview];
    SY_RELEASE_SAFELY(_speakingWaveView);
    
    [_rippleView removeFromSuperview];
    SY_RELEASE_SAFELY(_rippleView);
    
    _textEditView.hidden = YES;
    _speakButton.hidden = NO;
    [self bringSubviewToFront:_speakButton];
    
    [self hideToast];
    
    [self customLayoutSubviews];
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    NSDictionary *obj = [noti userInfo];
    CGRect keyboardRect = [[obj objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    CGFloat aCurve = [[obj objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(keyboardShowStop)];
    [self customLayoutSubviews];
    [UIView commitAnimations];
}

- (void)keyboardShowStop {
    NSInteger count = [_tableView numberOfRowsInSection:0];
    if (count >0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti{
    _keyboardHeight = 0;
    NSDictionary *obj = [noti userInfo];
    CGFloat aCurve = [[obj objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [self customLayoutSubviews];
    [UIView commitAnimations];
    [_memberInpitView clearView];
}

- (void)scrollTableViewBottom {
    [_tableView  reloadData];
    NSInteger count = [_tableView numberOfRowsInSection:0];
    if (count >0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        if (_tableView.contentSize.height > _tableView.height) {
            CGPoint offset = _tableView.contentOffset;
            offset.y += 30;
            [_tableView setContentOffset:offset animated:NO];
        }
    }
}

- (void)showKeyboard {
    if (_textEditView && !_textEditView.hidden) {
        [_textEditView.textView becomeFirstResponder];
    }
    else if (_memberInpitView && !_memberInpitView.hidden) {
        [_memberInpitView showKeyboard];
    }
}

- (void)hideKeyboard {
    if ([self keyboardIsShow]) {
        [_textEditView hideKeyboard];
        [_memberInpitView hideKeyboard];
    }
    [self checkSpeakButtonHidden];
}

- (BOOL)keyboardIsShow {
    return _keyboardHeight >0 ;
}

- (BOOL)isInSpeechView {
    if (_textEditView && !_textEditView.hidden) {
        return NO;
    }
    if (_memberInpitView && !_memberInpitView.hidden) {
        return NO;
    }
    return  YES;
}

- (void)checkSpeakButtonHidden {
    
    if (_speakingWaveView && !_speakingWaveView.hidden) {
        self.speakButton.hidden = YES;
    }
    else if (_textEditView && !_textEditView.hidden) {
        self.speakButton.hidden = YES;
    }
    else if (_memberInpitView && !_memberInpitView.hidden) {
        self.speakButton.hidden = YES;
    }
    else {
        self.speakButton.hidden = NO;
    }
}

@end
