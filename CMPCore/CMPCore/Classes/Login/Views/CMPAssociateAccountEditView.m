//
//  CMPAssociateAccountView.m
//  M3
//
//  Created by CRMO on 2018/6/7.
//

#import "CMPAssociateAccountEditView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIImage+CMPImage.h>
#import "CMPCircleButton.h"
#import <CMPLib/UIView+CMPView.h>
#import "CMPInputObserver.h"
#import <CMPLib/CMPThemeManager.h>

static const NSInteger kHostViewTag = 10000;
static const NSInteger kPortViewTag = 10001;
static const NSInteger kUsernameViewTag = 10002;
static const NSInteger kPasswordViewTag = 10003;
static const NSInteger kNoteViewTag = 10004;

static CGFloat kTopTipViewHeight;

static CGFloat kCommonInset;

static NSString * const kTopTipViewBackgroundColor = @"FFF7DA";
static NSString * const kTopTipViewTextColor = @"FFA500";

@interface CMPAssociateAccountEditView()<UITextFieldDelegate,CMPLoginViewTextFieldDelegate>
@property (strong, nonatomic) UIView *topTipView;
@property (strong, nonatomic) UIImageView *topTipIconView;
@property (strong, nonatomic) UILabel *topTipLabelView;

@property (strong, nonatomic) UIView *hostUnderline;
@property (strong, nonatomic) UIView *portUnderline;
@property (strong, nonatomic) UIView *usernameUnderline;
@property (strong, nonatomic) UIView *passwordUnderline;
@property (strong, nonatomic) UIView *noteUnderline;
@property (strong, nonatomic) CMPCircleButton *scanButton;
@property (strong, nonatomic) CMPButtonEnableObserver *buttonEnableObserver;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, copy) void(^tapScanButtonAction)(void);
@end

@implementation CMPAssociateAccountEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self registNotifications];
        [self initObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)initObserver {
    if (!_buttonEnableObserver) {
        _buttonEnableObserver = [CMPButtonEnableObserver observerWithButton:self.saveButton inputs:@[self.hostView, self.portView, self.usernameView, self.passwordView]];
    }
}

#pragma mark-
#pragma mark-按钮点击事件

- (void)showScanButtonWithAction:(void (^)(void))action {
    _tapScanButtonAction = action;
    _scanButton = [[CMPCircleButton alloc] init];
    [self addSubview:_scanButton];
    UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScanButton)];
    [_scanButton addGestureRecognizer:tapRecongnizer];
}

- (void)tapScanButton {
    if (_tapScanButtonAction) {
        _tapScanButtonAction();
    }
}

- (void)tapSaveButton {
    [self dismissKeybord];
    if (self.saveAction) {
        self.saveAction([self.hostView.text trim], [self.portView.text trim], self.noteView.text, [self.usernameView.text trim], [self.passwordView.text trim]);
    }
}

- (void)tapDeleteButton {
    [self dismissKeybord];
    if (self.deleteAction) {
        self.deleteAction();
    }
}

#pragma mark-
#pragma mark-UI布局

- (void)initView {
    if (iPhone5) {
        kCommonInset = 10;
        kTopTipViewHeight = 30;
    } else {
        kCommonInset = 15;
        kTopTipViewHeight = 40;
    }
    [self setBackgroundColor:[UIColor cmp_colorWithName:@"p-bg"]];
    [self addSubview:self.topTipView];
    [self addSubview:self.hostView];
    [self addSubview:self.hostUnderline];
    [self addSubview:self.portView];
    [self addSubview:self.portUnderline];
    [self addSubview:self.usernameView];
    [self addSubview:self.usernameUnderline];
    [self addSubview:self.passwordView];
    [self addSubview:self.passwordUnderline];
    [self addSubview:self.noteView];
    [self addSubview:self.noteUnderline];
    [self addSubview:self.deleteButton];
    [self addSubview:self.saveButton];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.topTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(kTopTipViewHeight);
    }];
    
    CGSize tipLabelSize = [SY_STRING(@"ass_edit_top_tip") sizeWithFontSize:[UIFont systemFontOfSize:16] defaultSize:CGSizeZero];
    CGFloat iconViewWidth = 16;
    
    [self.topTipIconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topTipView);
        make.width.height.equalTo(iconViewWidth);
        make.trailing.equalTo(self.topTipLabelView.mas_leading).inset(8);
    }];
    
    [self.topTipLabelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topTipView);
        make.centerX.equalTo(self.topTipView);
        make.width.equalTo(tipLabelSize.width);
        make.height.equalTo(tipLabelSize.height);
    }];
    
    [self.hostView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self->_keyboardHeight > 0) {
            make.top.equalTo(self).inset(kCommonInset);
        } else {
            make.top.equalTo(self).inset(kTopTipViewHeight + kCommonInset);
        }
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    [self.hostUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@1);
        make.top.equalTo(self.hostView.mas_bottom).inset(kCommonInset);
    }];
    
    [self.portView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hostUnderline.mas_bottom).inset(kCommonInset);
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self).inset(20);
        make.height.equalTo(@20);
    }];
    
    [self.portUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@1);
        make.top.equalTo(self.portView.mas_bottom).inset(kCommonInset);
    }];
    
    [self.usernameView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portUnderline.mas_bottom).inset(kCommonInset);
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self).inset(20);
        make.height.equalTo(@20);
    }];
    
    [self.usernameUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@1);
        make.top.equalTo(self.usernameView.mas_bottom).inset(kCommonInset);
    }];
    
    [self.passwordView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.usernameUnderline.mas_bottom).inset(kCommonInset);
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self).inset(20);
        make.height.equalTo(@20);
    }];
    
    [self.passwordUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@1);
        make.top.equalTo(self.passwordView.mas_bottom).inset(kCommonInset);
    }];
    
    [self.noteView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordUnderline.mas_bottom).inset(kCommonInset);
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self).inset(20);
        make.height.equalTo(@20);
    }];
    
    [self.noteUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(20);
        make.trailing.equalTo(self);
        make.height.equalTo(@1);
        make.top.equalTo(self.noteView.mas_bottom).inset(kCommonInset);
    }];
    
    [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).inset(20 + self->_keyboardHeight);
            make.trailing.equalTo(self.mas_safeAreaLayoutGuideTrailing).inset(20);
        } else {
            make.bottom.equalTo(self.mas_bottom).inset(kCommonInset + self->_keyboardHeight);
            make.trailing.equalTo(self.mas_trailing).inset(20);
        }
        make.height.equalTo(@42);
        if (!self.deleteButton.hidden) {
            make.leading.equalTo(self.mas_centerX).inset(7.5);
        } else {
            make.leading.equalTo(self.mas_leading).inset(20);
        }
    }];
    
    [self.deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).inset(20 + self->_keyboardHeight);
            make.leading.equalTo(self.mas_safeAreaLayoutGuideLeading).inset(20);
        } else {
            make.bottom.equalTo(self.mas_bottom).inset(20 + self->_keyboardHeight);
            make.leading.equalTo(self.mas_leading).inset(20);
        }
        make.height.equalTo(@42);
        if (!self.deleteButton.hidden) {
            make.trailing.equalTo(self.mas_centerX).inset(7.5);
        } else {
            make.width.equalTo(@0);
        }
    }];
    
    [_scanButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@141);
        make.height.equalTo(@141);
        make.top.equalTo(self.noteUnderline.mas_bottom).inset(kCommonInset);
        make.centerX.equalTo(self);
    }];
    
    [super updateConstraints];
}

#pragma mark-
#pragma mark-UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == kHostViewTag) {
        [_portView becomeFirstResponder];
    } else if (textField.tag == kPortViewTag) {
        [_noteView becomeFirstResponder];
    } else if (textField.tag == kUsernameViewTag) {
        [_usernameView becomeFirstResponder];
    } else if (textField.tag == kPasswordViewTag) {
        [_passwordView becomeFirstResponder];
    } else if (textField.tag == kNoteViewTag) {
        [self tapSaveButton];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.noteView) {
        if (string.length == 0) return YES;
        NSInteger limit = 15;
        NSString *newStr = [textField.text stringByAppendingString:string];
        NSInteger newStrLength = newStr.length;
        newStrLength -= [textField textInRange:[textField markedTextRange]].length;
        if (newStrLength > limit) {
            NSString *tempStr = [newStr substringWithRange:[newStr rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, limit)]];
            textField.text = tempStr;
            return NO;
        }
    } else if (textField == self.portView) {
        NSString *regex = @"[0-9]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:string]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark-
#pragma mark-处理键盘弹出

- (void)dismissKeybord {
    [self.hostView resignFirstResponder];
    [self.portView resignFirstResponder];
    [self.usernameView resignFirstResponder];
    [self.passwordView resignFirstResponder];
    [self.noteView resignFirstResponder];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (endFrame.origin.y == [[UIScreen mainScreen ] bounds].size.height) {
        self.keyboardHeight = 0;
        _scanButton.hidden = NO;
        _topTipView.hidden = NO;
    } else {
        self.keyboardHeight = endFrame.size.height;
        _scanButton.hidden = YES;
        _topTipView.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }];
}

#pragma mark-
#pragma mark-Getter & Setter

- (UIView *)topTipView {
    if (!_topTipView) {
        _topTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kTopTipViewHeight)];
        _topTipView.backgroundColor = [UIColor colorWithHexString:kTopTipViewBackgroundColor];
        _topTipLabelView = [[UILabel alloc] init];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:SY_STRING(@"ass_edit_top_tip")
                                                                  attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:kTopTipViewTextColor] ,
                                                                               NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                                               }];
        
        _topTipIconView = [[UIImageView alloc] init];
        [_topTipIconView setImage:[UIImage imageWithName:@"ass_tip" inBundle:@"CMPLogin"]];
        [_topTipView addSubview:_topTipIconView];
        
        _topTipLabelView.attributedText = str;
        _topTipLabelView.textAlignment = NSTextAlignmentLeft;
        [_topTipView addSubview:_topTipLabelView];
    }
    return _topTipView;
}

- (UITextField *)hostView {
    if (!_hostView) {
        _hostView = [self defaultTextField];
        _hostView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_server_host") attributes:self.attributesDic];
        _hostView.tag = kHostViewTag;
    }
    return _hostView;
}

- (UIView *)hostUnderline {
    if (!_hostUnderline) {
        _hostUnderline = [self defaultUnderline];
    }
    return _hostUnderline;
}

- (UITextField *)portView {
    if (!_portView) {
        _portView = [self defaultTextField];
        _portView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_server_port") attributes:self.attributesDic];
        _portView.keyboardType = UIKeyboardTypeNumberPad;
        _portView.tag = kPortViewTag;
    }
    return _portView;
}

- (UIView *)portUnderline {
    if (!_portUnderline) {
        _portUnderline = [self defaultUnderline];
    }
    return _portUnderline;
}

- (UITextField *)usernameView {
    if (!_usernameView) {
        _usernameView = [self defaultTextField];
        _usernameView.placeholder = SY_STRING(@"login_username");
        _usernameView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_username") attributes:self.attributesDic];
        _usernameView.tag = kUsernameViewTag;
    }
    return _usernameView;
}

- (UIView *)usernameUnderline {
    if (!_usernameUnderline) {
        _usernameUnderline = [self defaultUnderline];
    }
    return _usernameUnderline;
}

- (CMPLoginViewTextField *)passwordView {
    if (!_passwordView) {
        _passwordView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_password") type:CMPLoginViewTextFieldTypePassword];
        _passwordView.textFieldDelegate = self;
        _passwordView.tag = kPasswordViewTag;
        _passwordView.keyboardType = UIKeyboardTypeDefault;
        _passwordView.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordView.returnKeyType = UIReturnKeyNext;
        _passwordView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_password") attributes:self.attributesDic];
        _passwordView.font = [UIFont systemFontOfSize:17];
        [_passwordView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _passwordView;
}


- (UIView *)passwordUnderline {
    if (!_passwordUnderline) {
        _passwordUnderline = [self defaultUnderline];
    }
    return _passwordUnderline;
}

- (UITextField *)noteView {
    if (!_noteView) {
        _noteView = [self defaultTextField];
        _noteView.returnKeyType = UIReturnKeyGo;
        _noteView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_server_note") attributes:self.attributesDic];
        _noteView.tag = kNoteViewTag;
    }
    return _noteView;
}

- (UIView *)noteUnderline {
    if (!_noteUnderline) {
        _noteUnderline = [self defaultUnderline];
    }
    return _noteUnderline;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:SY_STRING(@"ass_button") forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithName:@"login_server_save" inBundle:@"CMPLogin"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        UIImage *highlightedImage = [image imageByApplyingAlpha:0.7];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5, highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5)];
        [_saveButton setBackgroundImage:image forState:UIControlStateNormal];
        [_saveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [_saveButton addTarget:self action:@selector(tapSaveButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:SY_STRING(@"common_delete") forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithName:@"login_server_delete" inBundle:@"CMPLogin"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        UIImage *highlightedImage = [image imageByApplyingAlpha:0.7];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5, highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5)];
        [_deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [_deleteButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [_deleteButton addTarget:self action:@selector(tapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIView *)defaultUnderline {
    UIView *underline = [[UIView alloc] init];
    underline.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    return underline;
}

- (UITextField *)defaultTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyNext;
    textField.font = [UIFont systemFontOfSize:17];
    [textField cmp_expandClickArea:UIOffsetMake(10, 15)];
    textField.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
    return textField;
}

- (NSDictionary *)attributesDic {
    return @{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc2"],
    NSFontAttributeName : [UIFont systemFontOfSize:17]};
}

-(BOOL)registerContentChangedAction
{
    [_hostView addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [_portView addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [_noteView addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    return YES;
}

-(void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSLog(@"%@",textField.text);
    _contentChanged = YES;
}

@end
