//
//  CMPLoginTextField.m
//  M3
//
//  Created by MacBook on 2019/12/4.
//

#import "CMPLoginTextField.h"

#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIButton+CMPButton.h>

//倒计时时间  秒
static NSInteger const kCountdownTime = 60;

@interface CMPLoginTextField()
{
    // +86文字
    UIButton *_areaCodeButton;
}

/* leftView用于显示左边的+86 */
@property (strong, nonatomic) UIView *leftAreaCodeView;
/* rightView用于显示右边验证码 */
@property (strong, nonatomic) UIView *rightSMSView;
/* rightEyeBtn */
@property (strong, nonatomic) UIButton *rightEyeBtn;
/* smsBtn */
@property (strong, nonatomic) UIButton *smsBtn;

/* 定时器，用于获取验证码 */
@property (strong, nonatomic) MSWeakTimer *timer;
/* 倒计时 */
@property (assign, nonatomic) int count;
/* enteredBgTime */
@property (strong, nonatomic) NSDate *enteredBgDate;

@end

@implementation CMPLoginTextField

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField.alloc initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _textField.backgroundColor = UIColor.clearColor;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 10.f, self.height)];
        _textField.font = [UIFont systemFontOfSize:16.f];
        _textField.tintColor = [UIColor cmp_colorWithName:@"theme-fc"];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //关闭键盘首字母大写
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _textField;
}


- (void)dealloc {
    CMPFuncLog;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        [self cmp_setCornerRadius:6.f];
        [self addSubview:self.textField];
        self.areaCode = @"+86";
    }
    return self;
}

#pragma mark - 外部方法

- (void)showLeftView:(BOOL)isShown {
    if (!_leftAreaCodeView) {
        _leftAreaCodeView = UIView.alloc.init;
        _leftAreaCodeView.frame = CGRectMake(0, 0, 70.f, self.height);
        if (!_areaCodeButton) {
            UIImage *image = [UIImage imageNamed:@"login_tf_areacode_arrow"];
            _areaCodeButton = [UIButton.alloc initWithFrame:_leftAreaCodeView.bounds];
            [_areaCodeButton setImage:image forState:UIControlStateNormal];
            [_areaCodeButton setTitle:self.areaCode forState:UIControlStateNormal];
            [_areaCodeButton setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
            _areaCodeButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
            CGFloat titleWidth = [_areaCodeButton.titleLabel.text sizeWithFontSize:_areaCodeButton.titleLabel.font defaultSize:CGSizeMake(70.f, self.height)].width;
            CGFloat imageWidth = image.size.width;
            [_areaCodeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth-2, 0, imageWidth+2)];
            [_areaCodeButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleWidth+2, 0, -titleWidth-2)];
            [_areaCodeButton addTarget:self action:@selector(leftAreaCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [_leftAreaCodeView addSubview:_areaCodeButton];
        }
    }
    
    if (isShown) {
        self.textField.leftView = _leftAreaCodeView;
    }else {
        self.textField.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 10.f, self.height)];
    }
}

- (void)setAreaCode:(NSString *)areaCode {
    _areaCode = areaCode;
    if (_areaCodeButton) {
        [_areaCodeButton setTitle:self.areaCode forState:UIControlStateNormal];
    }
}

- (void)showRightView:(BOOL)isShown {
    if (!_rightView) return;
    
    if (isShown) {
        [self addSubview:_rightView];
        self.rightView.cmp_x = self.width - _rightView.width;
        self.textField.cmp_width = self.width - _rightView.width;
        
    }else {
        [_rightView removeFromSuperview];
        self.textField.cmp_width = self.width;
    }
}

- (void)showRightSMSView:(BOOL)isShown {
    if (!_rightSMSView) {
        NSString *titleString = SY_STRING(@"login_get_sms_verification_code");
        NSString *disableTitleString = SY_STRING(@"login_reget_sms_verification_code");
        CGFloat titleW = [titleString sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        CGFloat disableTitleW = [disableTitleString sizeWithFontSize:[UIFont systemFontOfSize:14.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        _rightSMSView = [UIView.alloc initWithFrame:(CGRect)CGRectMake(0, 0, MAX(titleW, disableTitleW) + 4.f, self.height)];
        _rightSMSView.backgroundColor = UIColor.clearColor;
        UIView *separator = [UIView.alloc initWithFrame:CGRectMake(0, 0, 1.f,14.f)];
        separator.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        separator.cmp_centerY = _rightSMSView.height/2.f;
        [_rightSMSView addSubview:separator];
        
        _smsBtn = [UIButton.alloc initWithFrame:CGRectMake(1.f, 0, _rightSMSView.width - 1.f, _rightSMSView.height)];
        [_smsBtn setTitle:titleString forState:UIControlStateNormal];
        [_smsBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
        [_smsBtn setTitleColor:[UIColor cmp_colorWithName:@"sup-fc3"] forState:UIControlStateDisabled];
        _smsBtn.titleLabel.font = [UIFont systemFontOfSize: 14.f];
        [_smsBtn addTarget:self action:@selector(smsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_rightSMSView addSubview:_smsBtn];
        
        _rightSMSView.cmp_x = self.width - _rightSMSView.width;
        
    }
    
    if (isShown) {
        [self addSubview:_rightSMSView];
        self.textField.cmp_width = self.width - _rightSMSView.width;
    }else {
        [_rightSMSView removeFromSuperview];
        self.textField.cmp_width = self.width;
    }
}


- (void)fireCountdonwTimer {
    self.count = kCountdownTime;
    _smsBtn.enabled = NO;
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countdown) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)fireCountdonwTimer:(NSInteger)count {
    self.count = count>=0 ? count : 0;
    _smsBtn.enabled = NO;
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countdown) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)countdown {
    if (self.count <= 0) {
        NSString *leftTime = [NSString stringWithFormat:SY_STRING(@"login_resend_sms_verification_code")];
        [_smsBtn setTitle:leftTime forState:UIControlStateNormal];
        self.smsBtn.enabled = YES;
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    NSInteger second = self.count;
    NSString *leftTime = [NSString stringWithFormat:SY_STRING(@"login_reget_sms_verification_code"),(long)second];
    [_smsBtn setTitle:leftTime forState:UIControlStateDisabled];
    self.count--;
}


#pragma mark - 按钮点击方法

- (void)leftAreaCodeBtnClicked {
    CMPFuncLog;
    if (self.leftViewBtnClicked) {
        self.leftViewBtnClicked();
    }
}

- (void)smsBtnClicked {
    CMPFuncLog;
    if (self.getSMSCodeBtnClicked) {
        self.getSMSCodeBtnClicked();
    }
}

- (NSString *)text {
    return [self.textField.text.copy trim];
}

- (void)setText:(NSString *)text {
    self.textField.text = text;
}

- (void)setRightView:(UIView *)rightView {
    
    rightView.cmp_x = self.width - rightView.width;
    rightView.cmp_y = 0;
    rightView.cmp_height = self.height;
    self.textField.cmp_width = self.width - rightView.width;
    
    [self addSubview:rightView];
    
    _rightView = rightView;
}

- (void)showCheckoutPwdBtn:(BOOL)isShown {
    if (!_rightEyeBtn) {
        _rightEyeBtn = [UIButton.alloc initWithFrame:(CGRect)CGRectMake(0, 0, 32.f, self.height)];
        _rightEyeBtn.backgroundColor = UIColor.clearColor;
        [_rightEyeBtn setImage:[UIImage imageNamed:@"login_tf_check_pwd_icon"] forState:UIControlStateNormal];
        [_rightEyeBtn setImage:[UIImage imageNamed:@"login_tf_uncheck_pwd_icon"] forState:UIControlStateSelected];
        _rightEyeBtn.selected = NO;
        
        _rightEyeBtn.cmp_x = self.width - _rightEyeBtn.width;
        
        [_rightEyeBtn addTarget:self action:@selector(eyeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (isShown) {
        _rightEyeBtn.selected = !self.textField.secureTextEntry;
        [self addSubview:_rightEyeBtn];
        self.textField.cmp_width = self.width - _rightEyeBtn.width;
    }else {
        [_rightEyeBtn removeFromSuperview];
        self.textField.cmp_width = self.width;
    }
}

#pragma mark - 按钮点击

- (void)eyeBtnClicked:(UIButton *)btn {
    CMPFuncLog;
    self.textField.secureTextEntry = btn.selected;
    btn.selected = !btn.selected;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_rightEyeBtn) {
        _textField.cmp_width = self.width;
    }
    _textField.cmp_height = self.height;
    _textField.cmp_x = 0;
    if (_rightView) {
        _rightView.cmp_x = self.width - _rightView.width;
        _textField.cmp_width = self.width - _rightView.width;
    }else if (_rightSMSView){//V5-55706 ipad短信登录，没有获取验证码
        _rightSMSView.cmp_x = self.width - _rightSMSView.width;
        _textField.cmp_width = self.width - _rightSMSView.cmp_width - _rightEyeBtn.width;
    }
}

@end
