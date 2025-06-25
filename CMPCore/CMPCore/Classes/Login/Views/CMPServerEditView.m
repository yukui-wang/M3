//
//  CMPServerEditView.m
//  M3
//
//  Created by CRMO on 2017/10/30.
//

#import "CMPServerEditView.h"
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
static const NSInteger kNoteViewTag = 10002;

@interface CMPServerEditView()<UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *hostUnderline;
@property (nonatomic, strong) UIView *portUnderline;
@property (nonatomic, strong) UIView *noteUnderline;
@property (strong, nonatomic) UIView *inputArea;
@property (strong, nonatomic) CMPCircleButton *scanButton;
@property (strong, nonatomic) CMPButtonEnableObserver *buttonEnableObserver;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat landscapeKeyboardHeight;
@property (nonatomic, assign) CGFloat landscapeOfsetHeight;
@property (nonatomic, copy) void(^tapScanButtonAction)(void);

@end

@implementation CMPServerEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self registNotifications];
        [self initObserver];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tapGesture];
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
        _buttonEnableObserver = [CMPButtonEnableObserver observerWithButton:self.saveButton inputs:@[self.hostView, self.portView]];
    }
}

- (void)showScanButtonWithAction:(void (^)(void))action {
    _tapScanButtonAction = action;
    _scanButton = [[CMPCircleButton alloc] init];
    [self.containerView addSubview:_scanButton];
    UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScanButton)];
    [_scanButton addGestureRecognizer:tapRecongnizer];
}

- (void)tapScanButton {
    if (_tapScanButtonAction) {
        _tapScanButtonAction();
    }
}

#pragma mark-
#pragma mark-UI布局

- (void)initView {
    [self setBackgroundColor:[UIColor colorWithHexString:@"F8F9FB"]];
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.inputArea];
    [self.containerView addSubview:self.hostView];
    [self.containerView addSubview:self.hostUnderline];
    [self.containerView addSubview:self.portView];
    [self.containerView addSubview:self.portUnderline];
    [self.containerView addSubview:self.noteView];
    [self.containerView addSubview:self.noteUnderline];
    [self.containerView addSubview:self.deleteButton];
    [self.containerView addSubview:self.saveButton];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    [self setNeedsUpdateConstraints];
    
}

- (void)updateConstraints {
    
    CGFloat mainViewHeight = 0;
    
    if (InterfaceOrientationIsPortrait) {
        
        mainViewHeight = self.height;
        
    }else{
        
        if (self.canDelete) {
            
            mainViewHeight = self.height;
            
        } else {
            
            if (self.height >= 450) {
                
                mainViewHeight = self.height;
                
            }else{
                
                mainViewHeight = 500;
                
            }
            
        }
        
    }
    
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
        
    }];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.height.equalTo(mainViewHeight);
        
    }];
    
    [self.hostView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).inset(17 + 14);
        make.leading.equalTo(self.containerView).inset(20);
        make.trailing.equalTo(self.containerView);
        make.height.equalTo(@20);
    }];
    
    [self.hostUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).inset(20);
        make.trailing.equalTo(self.containerView);
        make.height.equalTo(@1);
        make.top.equalTo(self.hostView.mas_bottom).inset(15);
    }];
    
    [self.portView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hostUnderline.mas_bottom).inset(15);
        make.leading.equalTo(self.hostView);
        make.trailing.equalTo(self.hostView);
        make.height.equalTo(@20);
    }];
    
    [self.portUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).inset(20);
        make.trailing.equalTo(self.containerView);
        make.height.equalTo(@1);
        make.top.equalTo(self.portView.mas_bottom).inset(15);
    }];
    
    [self.noteView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portUnderline.mas_bottom).inset(15);
        make.leading.equalTo(self.hostView);
        make.trailing.equalTo(self.hostView);
        make.height.equalTo(@20);
    }];
    
    [self.noteUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).inset(20);
        make.trailing.equalTo(self.containerView);
        make.height.equalTo(@1);
        make.top.equalTo(self.noteView.mas_bottom).inset(15);
    }];
    
    [self.inputArea mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.containerView);
        make.top.equalTo(self.containerView).offset(14);
        make.bottom.equalTo(self.noteUnderline);
    }];
    
    [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.noteUnderline.mas_bottom).offset(30);
        if (@available(iOS 11.0,*)) {
            if (self.canDelete) {
                
//                make.top.equalTo(self.containerView.mas_safeAreaLayoutGuideTop).inset(self.height - 42 - 20 - self.keyboardHeight);
                make.trailing.equalTo(self.containerView.mas_safeAreaLayoutGuideTrailing).inset(20);
                
            }else{
                
                if (InterfaceOrientationIsPortrait) {
                    
//                    make.top.equalTo(self.containerView.mas_safeAreaLayoutGuideTop).inset(mainViewHeight - 42 - 20 - self.keyboardHeight);
                    make.trailing.equalTo(self.containerView.mas_safeAreaLayoutGuideTrailing).inset(20);
                    
                }else{
                    
//                    make.top.equalTo(self.containerView.mas_safeAreaLayoutGuideTop).inset(mainViewHeight - 42 - 90 - self.keyboardHeight);
                    make.trailing.equalTo(self.containerView.mas_safeAreaLayoutGuideTrailing).inset(20);
                    
                }
                
            }
            
        } else {
            make.top.equalTo(self.containerView.mas_top).inset(self.height - 42 - 20 - self.keyboardHeight);
            make.trailing.equalTo(self.containerView.mas_trailing).inset(20);
        }
        make.height.equalTo(@42);
    
        if (self.canDelete) {
            make.leading.equalTo(self.containerView.mas_centerX).inset(7.5);
        } else {
            make.leading.equalTo(self.containerView.mas_leading).inset(20);
        }
    }];
    
    [self.deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.top.equalTo(self.saveButton.mas_top);
            make.leading.equalTo(self.mas_safeAreaLayoutGuideLeading).inset(20);
        } else {
            make.top.equalTo(self.saveButton.mas_top);
            make.leading.equalTo(self.mas_leading).inset(20);
        }
        make.height.equalTo(@42);
        if (self.canDelete) {
            make.trailing.equalTo(self.mas_centerX).inset(7.5);
        } else {
            make.width.equalTo(@0);
        }
    }];
    
    [_scanButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@141);
        make.height.equalTo(@141);
        make.center.equalTo(self.containerView);
    }];
    
    [super updateConstraints];
}

#pragma mark-
#pragma mark-按钮点击事件

- (void)tapSaveButton {
    [self dismissKeybord];
    if (self.saveAction) {
        self.saveAction([self.hostView.text trim], [self.portView.text trim], self.noteView.text);
    }
}

- (void)tapDeleteButton {
    if (self.deleteAction) {
        self.deleteAction();
    }
}

#pragma mark-
#pragma mark-处理键盘弹出
-(void)tapGestureAction:(UITapGestureRecognizer *)gesture{
    
    [self dismissKeybord];
    
}

-(void)landscapeOfsetAnimatedWithKeyboardHeight:(CGFloat)KeyboardHeight{
    
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    
    _landscapeOfsetHeight = self.height - firstResponder.originY - firstResponder.height - KeyboardHeight - 20;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, - self.landscapeOfsetHeight) ];
        
    }];
    
   
    
}

- (void)dismissKeybord {
    if (InterfaceOrientationIsLandscape) {
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:YES];
        
    }
    [self.hostView resignFirstResponder];
    [self.portView resignFirstResponder];
    [self.noteView resignFirstResponder];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    if (InterfaceOrientationIsLandscape) {
//
//        if (self.landscapeKeyboardHeight != endFrame.size.height) {
//
//            [self landscapeOfsetAnimatedWithKeyboardHeight: endFrame.size.height];
//
//        }
//        self.landscapeKeyboardHeight  = endFrame.size.height;
//
//        return;
//
//    }
    
    if (endFrame.origin.y == [[UIScreen mainScreen ] bounds].size.height) {
        self.keyboardHeight = 0;
        _scanButton.hidden = NO;
    } else {
        self.keyboardHeight = endFrame.size.height;
        _scanButton.hidden = YES;
        
        if (self.height - 42 - 20 - self.keyboardHeight < 170) {
            self.keyboardHeight -= 150;
        }
        
    }

    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }];
}

#pragma mark-
#pragma mark-UITextFieldDelegate

//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//
//    if (InterfaceOrientationIsPortrait) {
//
//        return;
//
//    }
//
//    if (_landscapeKeyboardHeight) {
//
//        [self landscapeOfsetAnimatedWithKeyboardHeight:_landscapeKeyboardHeight];
//
//    }
//
//
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == kHostViewTag) {
        [_portView becomeFirstResponder];
    } else if (textField.tag == kPortViewTag) {
        [_noteView becomeFirstResponder];
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
#pragma mark-Getter & Setter
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

- (UIView *)inputArea {
    if (!_inputArea) {
        _inputArea = [[UIView alloc] init];
        _inputArea.backgroundColor = [UIColor whiteColor];
    }
    return _inputArea;
}

- (UITextField *)hostView {
    if (!_hostView) {
        _hostView = [[UITextField alloc] init];
        _hostView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _hostView.returnKeyType = UIReturnKeyNext;
        _hostView.placeholder = SY_STRING(@"login_server_host");
        _hostView.autocorrectionType = UITextAutocorrectionTypeNo;
        _hostView.keyboardType = UIKeyboardTypeURL;
        _hostView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _hostView.delegate = self;
        _hostView.tag = kHostViewTag;
        [_hostView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _hostView;
}

- (UIView *)hostUnderline {
    if (!_hostUnderline) {
        _hostUnderline = [[UIView alloc] init];
        _hostUnderline.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
    }
    return _hostUnderline;
}

- (UITextField *)portView {
    if (!_portView) {
        _portView = [[UITextField alloc] init];
        _portView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _portView.returnKeyType = UIReturnKeyNext;
        _portView.placeholder = SY_STRING(@"login_server_port");
        _portView.keyboardType = UIKeyboardTypeNumberPad;
        _portView.autocorrectionType = UITextAutocorrectionTypeNo;
        _portView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _portView.delegate = self;
        _portView.tag = kPortViewTag;
        [_portView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _portView;
}

- (UIView *)portUnderline {
    if (!_portUnderline) {
        _portUnderline = [[UIView alloc] init];
        _portUnderline.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
    }
    return _portUnderline;
}

- (UITextField *)noteView {
    if (!_noteView) {
        _noteView = [[UITextField alloc] init];
        _noteView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _noteView.returnKeyType = UIReturnKeyGo;
        _noteView.placeholder = SY_STRING(@"login_server_note");
        _noteView.keyboardType = UIKeyboardTypeURL;
        _noteView.autocorrectionType = UITextAutocorrectionTypeNo;
        _noteView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _noteView.delegate = self;
        _noteView.tag = kNoteViewTag;
        [_noteView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _noteView;
}

- (UIView *)noteUnderline {
    if (!_noteUnderline) {
        _noteUnderline = [[UIView alloc] init];
        _noteUnderline.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
    }
    return _noteUnderline;
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

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:SY_STRING(@"common_save") forState:UIControlStateNormal];
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        UIImage *image = [[UIImage imageWithName:@"login_server_save" inBundle:@"CMPLogin"] cmp_imageWithTintColor:themeColor];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        UIImage *highlightedImage = [image imageByApplyingAlpha:0.7];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5, highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5)];
        [_saveButton setBackgroundImage:image forState:UIControlStateNormal];
        [_saveButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [_saveButton addTarget:self action:@selector(tapSaveButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (void)setCanDelete:(BOOL)canDelete {
    _canDelete = canDelete;
//    if (_canDelete) {
//        [self.saveButton setBackgroundImage:[UIImage imageWithName:@"login_server_save_little" inBundle:@"CMPLogin"] forState:UIControlStateNormal];
//    } else {
//        [self.saveButton setBackgroundImage:[UIImage imageWithName:@"login_server_save" inBundle:@"CMPLogin"] forState:UIControlStateNormal];
//    }
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)setHost:(NSString *)host {
    _host = host;
    [self.hostView setText:host];
    [self.hostView sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)setPort:(NSString *)port {
    _port = port;
    [self.portView setText:port];
    [self.portView sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)setNote:(NSString *)note {
    _note = note;
    [self.noteView setText:note];
    [self.noteView sendActionsForControlEvents:UIControlEventEditingChanged];
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
