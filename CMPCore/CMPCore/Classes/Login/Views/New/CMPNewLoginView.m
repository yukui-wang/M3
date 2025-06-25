//
//  CMPNewLoginView.m
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#define kIpadLoginViewLandscapeY  90.f
#define kIpadLoginViewPortraitY  245.f
#define kViewMargin  35.f
#define kSmallFontSize  14.f
#define kBigFontSize  16.f
#define kLoginBtnH  40.f
#define kSmallBtnH  20.f


#import "CMPNewLoginView.h"
#import "CMPCustomManager.h"

@interface CMPNewLoginView()

@property (nonatomic, retain) UIView *otherLoginLineView;
@end

@implementation CMPNewLoginView

- (void)setup {
    self.showOrgCodeChangeButton = YES;
    #if APPSTORE
    self.showOrgCodeChangeButton = NO;
    #endif
    
    self.backgroundColor = [UIColor whiteColor];
    /* 背景图片/视频 */
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.contentMode = UIViewContentModeScaleToFill;
        _bgImgView.backgroundColor = UIColor.clearColor;
        [self addSubview:_bgImgView];
    }
    /* 背景图蒙层 */
    if (!_backgroundImageMaskView) {
        _backgroundImageMaskView = [[UIView alloc] init];
        _backgroundImageMaskView.hidden = YES;
        [self addSubview:_backgroundImageMaskView];
    }
    /* 登录提示文字label */
    if (!_loginTipsLabel) {
        NSString *loginTipsLabelText = SY_STRING(@"login_please_login_tips");
        CGFloat loginTipsLabelW = 200;// [loginTipsLabelText sizeWithFontSize:[UIFont boldSystemFontOfSize:kSmallBtnH] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        _loginTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kViewMargin, 103.f, loginTipsLabelW, 28.f)];
        _loginTipsLabel.font = [UIFont boldSystemFontOfSize:kSmallBtnH];
        _loginTipsLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
        _loginTipsLabel.textAlignment = NSTextAlignmentLeft;
        _loginTipsLabel.text = loginTipsLabelText;
        [self addSubview:_loginTipsLabel];
    }
    
    
    /* 扫一扫btn */
    if (!_scanBtn) {
        _scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(244.f, 0, 16.f, 16.f)];
        [_scanBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"login_view_scan_qrcode_gray_icon"] forState:UIControlStateNormal];
        [self addSubview:_scanBtn];
    }
    /* 设置服务器按钮 */
    if (!_setServerBtn) {
        NSString *setServerBtnTitle = SY_STRING(@"login_server_setting");
        NSInteger setServerBtnW = [setServerBtnTitle sizeWithFontSize:[UIFont systemFontOfSize:kSmallFontSize] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 4.f;
        _setServerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, setServerBtnW, 22.f)];
        _setServerBtn.titleLabel.font = [UIFont systemFontOfSize:kSmallFontSize];
        [_setServerBtn setTitle:setServerBtnTitle forState:UIControlStateNormal];
        [_setServerBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
        _setServerBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_setServerBtn];
    }
    /* 登录按钮 */
    if (!_loginBtn) {
        _loginBtn = [[CMPLoginAnimButton alloc] initWithFrame:CGRectMake(kViewMargin, 289.f, self.width - 2.f*kViewMargin, kLoginBtnH)];
        _loginBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
        [_loginBtn setTitle:SY_STRING(@"login_login") forState:UIControlStateNormal];
        [_loginBtn setTitle:SY_STRING(@"login_login_ing") forState:UIControlStateDisabled];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:kBigFontSize];
        [_loginBtn setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
        [_loginBtn cmp_setRoundView];
        [self addSubview:_loginBtn];
    }
    
    if (!_phoneLoginBtn) {
        
        _otherLoginLineView = [[UIView alloc] initWithFrame:CGRectMake(_otherLoginBtn.cmp_right + 5, 349.f, 1, kSmallBtnH)];
        _otherLoginLineView.backgroundColor = RGBACOLOR(228, 228, 228, 1);
//        _otherLoginLineView.hidden = YES;
        [self addSubview:_otherLoginLineView];
        
        NSString *title = SY_STRING(@"login_sms_login_btn");
//        CGFloat width = [title sizeWithFontSize:[UIFont systemFontOfSize:kSmallFontSize] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
//        width = width > 140 ? 140 : width;
        CGFloat width = 140;
        _phoneLoginBtn = [[CMPLoginSwitchButton alloc] initWithFrame:CGRectMake(_otherLoginBtn.cmp_right + 20.f, 349.f, width, kSmallBtnH)];
        _phoneLoginBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_phoneLoginBtn setTitle:title forState:UIControlStateNormal];
        _phoneLoginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _phoneLoginBtn.hidden = YES;
        [self addSubview:_phoneLoginBtn];
    }
    
    self.smsLoginView.frame = CGRectMake(kViewMargin, 200, self.width - 2.f*kViewMargin, 158);
    self.smsLoginView.hidden = YES;
    
    /* 其他登录方式按钮 */
    if (!_otherLoginBtn) {
        //登录方式切换按钮
        NSString *title = SY_STRING(@"login_other_login");
        CGFloat width = [title sizeWithFontSize:[UIFont systemFontOfSize:kSmallFontSize] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        width = width > 120 ? 120 : width;
        _otherLoginBtn = [[CMPLoginSwitchButton alloc] initWithFrame:CGRectMake(kViewMargin, 349.f, width, kSmallBtnH)];
        _otherLoginBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_otherLoginBtn setTitle:title forState:UIControlStateNormal];
        [self addSubview:_otherLoginBtn];
    }
    
    /* 忘记密码按钮 */
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [[CMPLoginSwitchButton alloc] init];
        
        NSString *forgetPwdBtnTitle = SY_STRING(@"login_forget_password");
        NSInteger forgetPwdBtnW = [forgetPwdBtnTitle sizeWithFontSize:_forgetPwdBtn.titleLabel.font defaultSize:CGSizeMake(MAXFLOAT, 0)].width+1;
        _forgetPwdBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_forgetPwdBtn setFrame:CGRectMake(0, 0, forgetPwdBtnW, kSmallBtnH)];
        [_forgetPwdBtn setTitle:forgetPwdBtnTitle forState:UIControlStateNormal];
        [self addSubview:_forgetPwdBtn];
    }
    /* 手机盾新增：手机盾扫一扫按钮*/
    if (!_mokeyScanButton) {
        _mokeyScanButton = [[UIButton alloc] init];
        _mokeyScanButton.titleLabel.font = [UIFont systemFontOfSize:14];
        NSString *title = SY_STRING(@"login_mokey_scan");
        NSInteger mokeyScanButtonW = [title sizeWithFontSize:_mokeyScanButton.titleLabel.font defaultSize:CGSizeMake(MAXFLOAT, 0)].width+1;
        [_mokeyScanButton setFrame:CGRectMake(0, 0, mokeyScanButtonW, 15)];
        [_mokeyScanButton setTitle:title forState:UIControlStateNormal];
        [_mokeyScanButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
        [_mokeyScanButton setTitleColor:[[UIColor cmp_colorWithName:@"sup-fc2"] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [self addSubview:_mokeyScanButton];
    }
    /*切换组织码登陆环境用的  测试用，正式环境需屏蔽*/
    if(self.showOrgCodeChangeButton && !_orgCodeChangeButton) {
        _orgCodeChangeButton = [[UIButton alloc] init];
        _orgCodeChangeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_orgCodeChangeButton setFrame:CGRectMake(0, 0, 80, 15)];
        [_orgCodeChangeButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
        [_orgCodeChangeButton setTitleColor:[[UIColor cmp_colorWithName:@"sup-fc2"] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [self addSubview:_orgCodeChangeButton];
        _orgCodeChangeButton.hidden = YES;
    }
   
    /* 勾选按钮 */
    if (!_selectBtn) {
        int s = 10;
        _selectBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSmallFontSize+s*2, kSmallFontSize+s*2)];
        [_selectBtn setImage:[UIImage imageNamed:@"share_btn_unselected_circle"] forState:UIControlStateNormal];
        [_selectBtn setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"share_btn_selected_circle"] forState:UIControlStateSelected];
        [_selectBtn setImageEdgeInsets:UIEdgeInsetsMake(s, s, s, s)];
        [_selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.selected = NO;
        [self addSubview:_selectBtn];
    }
    
    /* 读和同意label */
    if (!_readAndAgreeLabel) {
        NSString *readAndAgreeString = SY_STRING(@"login_policy_agree");
        CGFloat readAndAgreeStringW = [readAndAgreeString sizeWithFontSize:[UIFont systemFontOfSize:kSmallFontSize] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        _readAndAgreeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, readAndAgreeStringW, kSmallBtnH)];
        _readAndAgreeLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
        _readAndAgreeLabel.font = [UIFont systemFontOfSize:kSmallFontSize];
        _readAndAgreeLabel.text = readAndAgreeString;
        [self addSubview:_readAndAgreeLabel];
        
    }
    /* 协议按钮 */
    if (!_agreementBtn) {
        NSString *loginPolicyString = SY_STRING(@"login_policy_detail");
        CGFloat loginPolicyStringW = [loginPolicyString sizeWithFontSize:[UIFont systemFontOfSize:kSmallFontSize] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        
        _agreementBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, loginPolicyStringW, _readAndAgreeLabel.height)];
        _agreementBtn.titleLabel.font = [UIFont systemFontOfSize:kSmallFontSize];
        [_agreementBtn setTitle:loginPolicyString forState:UIControlStateNormal];
        [_agreementBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
        [self addSubview:_agreementBtn];
    }
}

- (void)customLayoutSubviews {
    [_bgImgView setFrame:self.bounds];
    [_backgroundImageMaskView setFrame:self.bounds];
    
    CGFloat startY = 103;
    CGFloat startX = 35;
    if (INTERFACE_IS_PAD) {
        startX = (self.width-512)/2;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            startY = kIpadLoginViewPortraitY;
        }
        else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            startY = kIpadLoginViewLandscapeY;
        }
    }
    CGFloat maxX = self.width-startX;
    /* 登录提示文字label */
    [_loginTipsLabel setFrame:CGRectMake(startX, startY, _loginTipsLabel.width, _loginTipsLabel.height)];
    if (_orgTipsLabel) {
        _orgTipsLabel.frame = CGRectMake(_loginTipsLabel.originX, CGRectGetMaxY(_loginTipsLabel.frame), _loginTipsLabel.width, _orgTipsLabel.height);
    }

    
    /* 设置服务器按钮 */
    _setServerBtn.cmp_x = maxX-_setServerBtn.width;
    _setServerBtn.cmp_centerY = _loginTipsLabel.center.y;
    /* 扫一扫btn */
    _scanBtn.cmp_x = _setServerBtn.originX-10-_scanBtn.width;
    _scanBtn.cmp_centerY = _loginTipsLabel.center.y;
    
    CGFloat inputHeight =  158;//todo
    startY = CGRectGetMaxY(_loginTipsLabel.frame);
    if (_orgLoginView && !_orgLoginView.hidden) {
        [_orgLoginView setFrame:CGRectMake(startX, startY, self.width-startX*2, [_orgLoginView viewHeight])];
        inputHeight = _orgLoginView.height;
    }
    if (self.loginMode == CMPNewLoginViewModeLegacy && _userLoginView && !_userLoginView.hidden) {
        [_userLoginView setFrame:CGRectMake(startX, startY, self.width-startX*2, [_userLoginView viewHeight])];
        inputHeight = _userLoginView.height;
    }
    if (_orgLoginView && !_orgLoginView.hidden) {
        [_orgLoginView setFrame:CGRectMake(startX, startY, self.width-startX*2, [_orgLoginView viewHeight])];
        inputHeight = _orgLoginView.height;
    }
    if (_mokeyLoginView && !_mokeyLoginView.hidden) {
        [_mokeyLoginView setFrame:CGRectMake(startX, startY, self.width-startX*2, [_mokeyLoginView viewHeight])];
        inputHeight = _mokeyLoginView.height;
    }
    if (self.loginMode == CMPNewLoginViewModeSMS && _smsLoginView && !_smsLoginView.hidden) {
        [_smsLoginView setFrame:CGRectMake(startX, startY, self.width-startX*2, [_smsLoginView viewHeight])];
        inputHeight = _smsLoginView.viewHeight;
    }
    
    /* 登录按钮 */
    startY += inputHeight;
    [_loginBtn setFrame:CGRectMake(startX, startY, self.width-startX*2, _loginBtn.height)];
    startY = CGRectGetMaxY(_loginBtn.frame)+20;
    /* 其他登录方式按钮 */
    [_otherLoginBtn setFrame:CGRectMake(startX, startY, _otherLoginBtn.width, _otherLoginBtn.height)];
    /* 其他登录方式按钮 | */
    CGFloat otherLineOffsetY = _otherLoginBtn.cmp_y + (_otherLoginBtn.cmp_height - 10) / 2;
    [_otherLoginLineView setFrame:CGRectMake(_otherLoginBtn.cmp_right + 6, otherLineOffsetY, _otherLoginLineView.width, 10)];
    /* 手机号密码登陆 */
    [_phoneLoginBtn setFrame:CGRectMake(_otherLoginBtn.cmp_right + 12.f, startY, _phoneLoginBtn.width, _phoneLoginBtn.height)];
    /* 忘记密码按钮 */
    [_forgetPwdBtn setFrame:CGRectMake(maxX-_forgetPwdBtn.width, startY, _forgetPwdBtn.width, _forgetPwdBtn.height)];
    
    /* 手机盾新增：手机盾扫一扫按钮*/
    [_mokeyScanButton setFrame:CGRectMake(maxX-_mokeyScanButton.width, startY, _mokeyScanButton.width, _mokeyScanButton.height)];
    if (self.showOrgCodeChangeButton) {
        [_orgCodeChangeButton setFrame:CGRectMake(maxX-_orgCodeChangeButton.width, startY, _orgCodeChangeButton.width, _orgCodeChangeButton.height)];
    }
    
    CGFloat marg = 6;
    startX = (self.width - _selectBtn.width-marg-_readAndAgreeLabel.width-marg-_agreementBtn.width)/2;
    startY = self.height- 37-_readAndAgreeLabel.height;
    
    startX = _otherLoginBtn.frame.origin.x;
    startY = CGRectGetMaxY(_otherLoginBtn.frame) + 13;

    
    /* 勾选按钮 */
    [_selectBtn setFrame:CGRectMake(startX-10, startY+3-10, _selectBtn.width, _selectBtn.height)];
    /* 读和同意label */
    [_readAndAgreeLabel setFrame:CGRectMake(CGRectGetMaxX(_selectBtn.frame)+marg, startY, _readAndAgreeLabel.width, _readAndAgreeLabel.height)];
    /* 协议按钮 */
    [_agreementBtn setFrame:CGRectMake(CGRectGetMaxX(_readAndAgreeLabel.frame)+marg, startY, _agreementBtn.width, _readAndAgreeLabel.height)];
    if (self.tipsBubbleView) {
        self.tipsBubbleView.cmp_x = CGRectGetMaxX(self.setServerBtn.frame) - self.tipsBubbleView.width;
        self.tipsBubbleView.cmp_y = CGRectGetMinY(self.setServerBtn.frame) - self.tipsBubbleView.height;
    }

}


// 选择按钮点击
// @param btn 按钮
- (void)selectBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
}

/*组织码登陆*/
- (CMPOrgLoginView *)orgLoginView {
    if (!_orgLoginView) {
        _orgLoginView = [[CMPOrgLoginView alloc] init];
        [self addSubview:_orgLoginView];
    }
    return _orgLoginView;
}
/*用户一般登陆*/
- (CMPUserLoginView *)userLoginView {
    if (!_userLoginView) {
        _userLoginView = [[CMPUserLoginView alloc] init];
        [self addSubview:_userLoginView];
    }
    return _userLoginView;
}
/*手机盾登陆*/
- (CMPMokeyLoginView *)mokeyLoginView {
    if (!_mokeyLoginView) {
        _mokeyLoginView = [[CMPMokeyLoginView alloc] init];
        [self addSubview:_mokeyLoginView];
    }
    return _mokeyLoginView;
}
/*短信登陆*/
- (CMPSMSLoginView *)smsLoginView {
    if (!_smsLoginView) {
        _smsLoginView = [[CMPSMSLoginView alloc] initWithFrame:CGRectMake(kViewMargin, 200, self.width - 2.f*kViewMargin, 158)];
        [self addSubview:_smsLoginView];
    }
    return _smsLoginView;
}

- (UILabel *)orgTipsLabel {
    if (!_orgTipsLabel) {
        NSString *tips = SY_STRING(@"login_please_org_tips");
        UIFont *font = [UIFont systemFontOfSize:12.f];
        _orgTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(_loginTipsLabel.originX, CGRectGetMaxY(_loginTipsLabel.frame), _loginTipsLabel.width, font.lineHeight)];
        _orgTipsLabel.font = font;
        _orgTipsLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
        _orgTipsLabel.textAlignment = NSTextAlignmentLeft;
        _orgTipsLabel.text = tips;
        [self addSubview:_orgTipsLabel];
    }
    return _orgTipsLabel;
}
- (void)setLoginMode:(CMPNewLoginViewMode)loginMode delegate:(id<CMPNewLoginViewDelegate>)delegate {
    self.loginMode = loginMode;
    _orgLoginView.hidden = YES;
    _userLoginView.hidden = YES;
    _mokeyLoginView.hidden = YES;
    _smsLoginView.hidden = YES;
   
    _forgetPwdBtn.hidden = (loginMode != CMPNewLoginViewModeLegacy && loginMode != CMPNewLoginViewModeSMS);
    _mokeyScanButton.hidden = loginMode != CMPNewLoginViewModeMokey;
    
    _scanBtn.hidden = loginMode == CMPNewLoginViewModeOrg;
    _setServerBtn.hidden = _scanBtn.hidden;
    [self.phoneLoginBtn setTitle:loginMode == CMPNewLoginViewModeSMS ? SY_STRING(@"login_account_login") : SY_STRING(@"login_sms_login_btn") forState:UIControlStateNormal];

    _orgTipsLabel.hidden = YES;
    if (self.showOrgCodeChangeButton) {
        _orgCodeChangeButton.hidden = loginMode != CMPNewLoginViewModeOrg;
    }
    switch (loginMode) {
        case CMPNewLoginViewModeLegacy: {
            /*企业账号/手机号 登录*/
            _loginTipsLabel.text = SY_STRING(@"login_please_login_tips");
            self.userLoginView.hidden = NO;
            self.userLoginView.delegate = delegate;
        }
            break;
        case CMPNewLoginViewModeSMS: {
            /*手机号验证码 登录*/
            _loginTipsLabel.text = SY_STRING(@"login_please_login_tips");
            self.smsLoginView.hidden = NO;
            self.smsLoginView.delegate = delegate;
        }
            break;
        case CMPNewLoginViewModeMokey: {
            /*手机盾 登录*/
            _loginTipsLabel.text = SY_STRING(@"login_tag_mokey");
            self.mokeyLoginView.hidden = NO;
            self.mokeyLoginView.delegate = delegate;
        }
            break;
        case CMPNewLoginViewModeOrg: {
            /*组织码 登录*/
            _loginTipsLabel.text = SY_STRING(@"login_orgcode_login");
            self.orgLoginView.hidden = NO;
            self.orgLoginView.delegate = delegate;
            self.orgTipsLabel.hidden = NO;
        }
            break;
        default:
            break;
    }
    if (self.tipsBubbleView) {
        self.tipsBubbleView.hidden = self.setServerBtn.hidden;
    }
    [self customLayoutSubviews];
}
- (NSString *)mokeyText {
    return _mokeyLoginView.accountTF.text;
}

- (void)setupVerificationImg:(UIImage *)image {
    switch (self.loginMode) {
        case CMPNewLoginViewModeLegacy:
            [_userLoginView setupVerificationImg:image];
            break;
        case CMPNewLoginViewModeSMS:
            [_userLoginView setupVerificationImg:image];
            break;
        case CMPNewLoginViewModeMokey:
            break;
        case CMPNewLoginViewModeOrg: {
            [_orgLoginView setupVerificationImg:image];
        }
            break;
        default:
            break;
    }
    [self customLayoutSubviews];
}

- (void)hideVerification {
    BOOL firstShowValidateCode = [CMPCore sharedInstance].firstShowValidateCode;
    _userLoginView.isShowImgVerificaitionTF = firstShowValidateCode;
    _userLoginView.imgVerificaitionTF.hidden = !_userLoginView.isShowImgVerificaitionTF;
    _orgLoginView.isShowImgVerificaitionTF = firstShowValidateCode;
    _orgLoginView.imgVerificaitionTF.hidden = !_orgLoginView.isShowImgVerificaitionTF;
}

- (void)showServertipsView {
    if (!self.tipsBubbleView) {
        CGFloat tipsViewW = 200.f;
        _tipsBubbleView = [CMPBubbleTipsView.alloc initWithFrame:CGRectMake(CGRectGetMaxX(_setServerBtn.frame)-tipsViewW, CGRectGetMinY(self.setServerBtn.frame) - 60.f, tipsViewW, 60.f)];
        _tipsBubbleView.viewColor = [UIColor cmp_colorWithName:@"theme-bgc"];
        _tipsBubbleView.cornerRadius = 4.5f;
        UILabel *tipsLabel = [UILabel.alloc initWithFrame:CGRectMake(3.f, 0, tipsViewW - 6.f, 60.f)];
        tipsLabel.text = SY_STRING(@"login_first_login_tips");
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.textColor = [UIColor cmp_colorWithName:@"reverse-fc"];
        tipsLabel.font = [UIFont systemFontOfSize:14.f];
        tipsLabel.numberOfLines = 0;
        CGFloat height = [tipsLabel.text sizeWithFontSize:tipsLabel.font defaultSize:CGSizeMake(tipsViewW - 12.f, MAXFLOAT)].height + 12.f;
        tipsLabel.cmp_height = height;
        [_tipsBubbleView addSubview:tipsLabel];
        _tipsBubbleView.cmp_height = height + 10.f;
        [_tipsBubbleView addSubview:tipsLabel];
        [_tipsBubbleView setNeedsDisplay];
        [self addSubview:_tipsBubbleView];
    }
    self.tipsBubbleView.cmp_x = CGRectGetMaxX(self.setServerBtn.frame) - self.tipsBubbleView.width;
    self.tipsBubbleView.cmp_y = CGRectGetMinY(self.setServerBtn.frame) - self.tipsBubbleView.height;
    self.tipsBubbleView.hidden = _setServerBtn ? _setServerBtn.hidden :YES;
}

- (void)setupPrivacyInfoHidden:(BOOL)hidden {
    hidden = NO;//ks fix 8.1修改隐私政策显示策略及位置
#if CUSTOM
    if (![CMPCustomManager sharedInstance].cusModel.hasPrivacy) {
        hidden = YES;
    }
#endif
    _selectBtn.hidden = hidden;
    _readAndAgreeLabel.hidden = hidden;
    _agreementBtn.hidden = hidden;
}

- (void)hiddenSMSLoginButton:(BOOL)hidden {
    _phoneLoginBtn.hidden = hidden;
    _otherLoginLineView.hidden = hidden;
}
@end






