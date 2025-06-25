//
//  XZMemberTextView.m
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//
#define kDefaultTextEditHeight 54

#import "XZMemberTextView.h"
#import "XZModelButton.h"
#import "XZMemberListView.h"
#import "XZTextField.h"
#import "XZMainProjectBridge.h"
#import "XZCore.h"
#import "XZPinyinTool.h"


@interface XZMemberTextView()<UITextFieldDelegate,XZMemberListViewDelegate,XZTextFieldDelegate> {
    UIScrollView *_inputBKView;
    NSMutableArray *_buttonList;
    XZTextField *_inputField;
    XZMemberListView *_memberView;
}
@property(nonatomic,retain)NSTimer *msgTimer;
@end

@implementation XZMemberTextView

- (void)dealloc
{
    [self removeTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_memberView removeFromSuperview];
    SY_RELEASE_SAFELY(_memberView);
    self.speakButton = nil;
    SY_RELEASE_SAFELY(_inputBKView);
    SY_RELEASE_SAFELY(_buttonList);
    SY_RELEASE_SAFELY(_inputField);
    
    [super dealloc];
}

- (void)setup
{
    [super setup];
    if (!_inputBKView) {
        _inputBKView = [[UIScrollView alloc] init];
        _inputBKView.layer.cornerRadius = 4;
        _inputBKView.layer.masksToBounds = YES;
        _inputBKView.backgroundColor = UIColorFromRGB(0xf5f5f5);
        [self addSubview:_inputBKView];
    }
    if (!_inputField) {
        _inputField = [[XZTextField alloc] init];
        _inputField.font = FONTSYS(16);
        _inputField.placeholder = @"在这里输入想说的话...";
        _inputField.returnKeyType = UIReturnKeySend;
        _inputField.delegate = self;
        _inputField.xzDelegate = self;
        _inputField.textColor = UIColorFromRGB(0x333333);
        [_inputBKView addSubview:_inputField];
    }
    if (!self.speakButton) {
        self.speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.speakButton setImage:XZ_IMAGE(@"xz_speakbtn_s.png") forState:UIControlStateNormal];
        [self addSubview:self.speakButton];
    }
    self.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)customLayoutSubviews
{
    [super customLayoutSubviews];
    CGFloat x = 15;
    [_speakButton setFrame:CGRectMake(x, self.height/2-16.5, 33, 33)];
    x += _speakButton.width+10;
    [_inputBKView setFrame:CGRectMake(x, 10, self.width-x-20, self.height-20)];
        
    if (_buttonList.count == 0) {
        NSInteger height = FONTSYS(16).lineHeight +1;
        CGFloat y = 17-height/2;
        [_inputField setFrame:CGRectMake(10, y, _inputBKView.width-x-10, height)];
    }
}

- (void)layoutButtons {
    CGFloat viewHeight = [self viewHeightForWidth:self.width];
    if (viewHeight != self.height) {
        CGRect f = self.frame;
        CGFloat maxY = CGRectGetMaxY(f);
        f.size.height = viewHeight;
        f.origin.y = maxY-f.size.height;
        self.frame = f;
     
        UIView *supperView = [self superview];
        if ([supperView isKindOfClass:[CMPBaseView class]]) {
            [(CMPBaseView *)supperView customLayoutSubviews];
        }
    }
    [self customLayoutSubviews];
    _inputBKView.contentOffset = CGPointMake(0, _inputBKView.contentSize.height-_inputBKView.height);
}


- (CGFloat)viewHeightForWidth:(CGFloat)width {
    if (_buttonList.count == 0) {
        CGFloat height = kDefaultTextEditHeight;
        CGFloat bkX = _inputBKView.originX;
        [_inputBKView setFrame:CGRectMake(bkX, 10, width-bkX-20, height-20)];
        [_inputBKView setContentSize:CGSizeMake(_inputBKView.width,  _inputBKView.height)];
        return height;
    }
    CGFloat bkX = _inputBKView.originX;
    [_inputBKView setFrame:CGRectMake(bkX, 10, width-bkX-20, _inputBKView.height)];
    
    NSInteger btnHeight = FONTSYS(16).lineHeight +1;
    CGFloat y = 17-btnHeight/2;
    CGFloat x = 10;
    CGFloat maxX = _inputBKView.width-x*2;
    CGFloat btnWidth = 0;
    for (XZModelButton *btn in _buttonList) {
        btnWidth = btn.textWWidth;
        if (x+btnWidth >maxX && x!= 10) {
            x = 10;
            y += btnHeight;
        }
        [btn setFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        if (x+btnWidth >= maxX) {
            x = 10;
            y += btnHeight;
        }
        else {
            x += btnWidth;
        }
    }
    [_inputField setFrame:CGRectMake(x, y, _inputBKView.width-x-10, btnHeight)];
    y += btnHeight +(17-btnHeight/2);
    [_inputBKView setContentSize:CGSizeMake(_inputBKView.width,  y)];
    
    CGFloat height =  y > 80 ? 100: y +20;
    return height;
}



- (void)addTimer {
    [self removeTimer];
    self.msgTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchMember) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.msgTimer forMode:NSRunLoopCommonModes];
}
- (void)removeTimer {
    if (self.msgTimer && [self.msgTimer isValid]) {
        [self.msgTimer invalidate];
    }
    self.msgTimer = nil;
}

- (void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
    self.hidden = !isShow;
    _memberView.isShow = isShow;
}

- (void)showKeyboard{
    _memberView.hidden =  NO;
    [_inputField becomeFirstResponder];
}

- (void)hideKeyboard{
    _memberView.hidden = YES;
    [_inputField resignFirstResponder];
}

- (void)clearInput {
    [self clearView];
    for (XZModelButton *btn in _buttonList) {
        [btn removeFromSuperview];
    }
    [_buttonList removeAllObjects];
    _inputField.text = nil;
    _inputField.placeholder = @"在这里输入想说的话...";
    [self layoutButtons];
}

- (void)clearView {
    [_memberView removeFromSuperview];
    SY_RELEASE_SAFELY(_memberView);
    [self removeTimer];
}

- (void)clickSend{
    [self clearView];
    NSMutableArray *array = [NSMutableArray array];
    for (XZModelButton *btn in _buttonList) {
        [array addObject:btn.info];
        [btn removeFromSuperview];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(memberTextView:didSelectMembers:string:)]) {
        [_delegate memberTextView:self didSelectMembers:array string:_inputField.text];
    }
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(memberTextViewDidSelectMembers:string:isMultiSelect:)]) {
        [self.viewDelegate memberTextViewDidSelectMembers:array string:_inputField.text isMultiSelect:self.isMultiSelect];
    }
    [_buttonList removeAllObjects];
    _inputField.text = nil;
    _inputField.placeholder = @"在这里输入想说的话...";
    [self layoutButtons];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickSend];
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!_isMultiSelect && _buttonList.count >0) {
        NSString *info = @"只能输入一个人";
        if (_delegate && [_delegate respondsToSelector:@selector(view:needShowMessage:)]) {
            [_delegate view:self needShowMessage:info];
        }
        if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(needShowMessage:)]) {
            [self.viewDelegate needShowMessage:info];
        }
        return NO;
    }
    return YES;
}
- (void)nullDeleteBackward {
    XZModelButton *btn = [_buttonList lastObject];
    if (btn) {
        [btn removeFromSuperview];
        [_buttonList removeObject:btn];
        _inputField.placeholder = _buttonList.count == 0? @"在这里输入想说的话...":@"";
    }
    [self layoutButtons];
}

- (void)textChange:(NSNotification *) notif
{
    _inputField.text.length == 0 ? [self clearView] :[self addTimer];
}

- (void)searchMember
{
    NSString *key = _inputField.text;
    if ([NSString isNull:key]) {
        [self clearView];
        return;
    }
    NSLog(@"searchMember %@ ",key);
    __weak typeof(self) weakSelf = self;
    if ([XZCore sharedInstance].isM3ServerIsLater8) {
        XZSearchMemberType type = _isMultiSelect ? XZSearchMemberType_Flow_Keyboard:XZSearchMemberType_Contact_Keyboard;
        [XZPinyinTool obtainMembersWithNameArray:@[key] memberType:type complete:^(NSArray* memberArray, NSArray *defSelectArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showSearchResult:memberArray];
            });
        }];
        return;
    }
    [XZMainProjectBridge searchMemberWithKey:key isFlow:_isMultiSelect completion:^(NSArray * result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSearchResult:result];
        });
    }];
}

- (void)showSearchResult:(NSArray *)array {
    if (!_memberView) {
        _memberView = [[XZMemberListView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.originY)];
        _memberView.delegate = self;
        [self.superview addSubview:_memberView];
    }
    [_memberView showMembers:array];
}

- (XZModelButton *)btnWithInfo:(CMPOfflineContactMember *)member {
    XZModelButton *btn = [XZModelButton buttonWithType:UIButtonTypeCustom];
    NSString *title = [NSString stringWithFormat:@"%@、",member.name];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    btn.titleLabel.font = FONTSYS(16);
    btn.info = member;
    [_inputBKView addSubview:btn];
    return btn;
}

- (void)memberListViewDidSelectMember:(CMPOfflineContactMember *)member {
    [self removeTimer];
    if (!_buttonList) {
        _buttonList = [[NSMutableArray alloc] init];
    }
    [_buttonList addObject:[self btnWithInfo:member]];
    [self layoutButtons];
    _inputField.text = @"";
    _inputField.placeholder = nil;
    [self clearView];
}

- (void)showText:(NSString *)text {
    _inputField.text = text;
}
@end
