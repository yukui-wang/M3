//
//  CMPLoginView.m
//  M3
//
//  Created by CRMO on 2017/10/26.
//

#import "CMPLoginView.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/NSData+ImageContentType.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIButton+WebCache.h>
#import <CMPLib/CMPDateHelper.h>
#import "CMPInputObserver.h"
#import <CMPLib/CMPThemeManager.h>
#import "TrustdoLoginManager.h"
//#import "CMPLoginDBProvider.h"

@implementation CMPLoginViewStyle

+ (instancetype)defaultStyle {
    CMPLoginViewStyle *style = [[CMPLoginViewStyle alloc] init];
    style.tagSelectColor = [UIColor colorWithHexString:@"333333"];
    style.tagUnSelectColor = [UIColor colorWithHexString:@"666666"];
    style.inputTextColor = [UIColor cmp_colorWithName:@"cont-fc"];
    
    style.scanColor = [UIColor cmp_colorWithName:@"tapsup-fc"];
    style.titleColor = [UIColor cmp_colorWithName:@"cont-fc"];
    style.toServerSiteColor = [UIColor cmp_colorWithName:@"theme-fc"];
    
    style.backgroundMaskColor = nil;
    style.backgroundImage = nil;
    style.backgroundLandscapeImage = nil;
    return style;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.tagSelectColor forKey:@"tagSelectColor"];
    [aCoder encodeObject:self.tagUnSelectColor forKey:@"tagUnSelectColor"];
    [aCoder encodeObject:self.inputTextColor forKey:@"inputTextColor"];
    [aCoder encodeObject:self.scanColor forKey:@"scanColor"];
    [aCoder encodeObject:self.titleColor forKey:@"titleColor"];
    [aCoder encodeObject:self.toServerSiteColor forKey:@"toServerSiteColor"];
    [aCoder encodeObject:self.backgroundMaskColor forKey:@"backgroundMaskColor"];
    [aCoder encodeDouble:self.backgroundMaskAlpha forKey:@"backgroundMaskAlpha"];
    [aCoder encodeObject:self.backgroundImage forKey:@"backgroundImage"];
    [aCoder encodeObject:self.backgroundLandscapeImage forKey:@"backgroundLandscapeImage"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.tagSelectColor = [aDecoder decodeObjectForKey:@"tagSelectColor"];
        self.tagUnSelectColor = [aDecoder decodeObjectForKey:@"tagUnSelectColor"];
        self.inputTextColor = [aDecoder decodeObjectForKey:@"inputTextColor"];
        self.scanColor = [aDecoder decodeObjectForKey:@"scanColor"];
        self.titleColor = [aDecoder decodeObjectForKey:@"titleColor"];
        self.toServerSiteColor = [aDecoder decodeObjectForKey:@"toServerSiteColor"];
        self.backgroundMaskColor = [aDecoder decodeObjectForKey:@"backgroundMaskColor"];
        self.backgroundMaskAlpha = [aDecoder decodeDoubleForKey:@"backgroundMaskAlpha"];
        self.backgroundImage = [aDecoder decodeObjectForKey:@"backgroundImage"];
        self.backgroundLandscapeImage = [aDecoder decodeObjectForKey:@"backgroundLandscapeImage"];
    }
    return self;
}

- (NSString *)description {
    NSString *str = [NSString stringWithFormat:@"tagSelectColor:%@,tagUnSelectColor:%@,inputTextColor:%@,backgroundMaskColor:%@,backgroundMaskAlpha:%f,backgroundImage:%@", self.tagSelectColor, self.tagUnSelectColor, self.inputTextColor, self.backgroundMaskColor, self.backgroundMaskAlpha, self.backgroundImage];
    return str;
}

@end

static const NSTimeInterval switchDuration = 0.3;

@interface CMPLoginView()<CMPLoginViewTextFieldDelegate>

/** 背景图蒙层 **/
@property (strong, nonatomic) UIView *backgroundView;

/** 背景图蒙层 **/
@property (strong, nonatomic) UIView *backgroundImageMaskView;

/** 用户名输入框 **/
@property (nonatomic, strong) CMPLoginViewTextField *usernameView;
/** 用户名输入框下方横线 **/
@property (nonatomic, strong) UIView *userNameUnderline;
/** 用户名登录密码输入框 **/
@property (nonatomic, strong) CMPLoginViewTextField *pwdView;
/** 密码输入框下方横线 **/
@property (nonatomic, strong) UIView *passwordUnderline;
/** 手机盾新增：手机盾用户名输入框 **/
@property (nonatomic, strong) CMPLoginViewTextField *mokeyUserNameView;

/** 设置按钮 **/
@property (nonatomic, strong) UIButton *settingButton;
/** 登陆按钮 **/
@property (nonatomic, strong) UIButton *loginButton;
/** 忘记密码 **/
@property (nonatomic, strong) UIButton *forgetPwdButton;
/** 手机盾新增：扫一扫按钮 **/
@property (nonatomic, strong) UIButton *scanButton;
/** 键盘弹出导致的view高度变化 **/
@property (nonatomic, assign) CGFloat viewAddHeight;
/** 保存键盘高度 **/
@property (nonatomic, assign) CGFloat lastKeyboardHeight;
/** 键盘高度 **/
@property (nonatomic, assign) CGFloat KeyboardHeight;
/** 键盘动画时间 **/
@property (nonatomic, assign) NSTimeInterval animationDuration;
/** 手机号登录 **/
@property (strong, nonatomic) UIButton *phoneLoginTag;
/** 原账号登录 **/
@property (strong, nonatomic) UIButton *legacyLoginTag;
/** phoneLoginTag,legacyLoginTag 容器 **/
@property (strong, nonatomic) UIView *loginTagView;
/** 手机盾新增：手机盾登录 **/
@property (strong, nonatomic) UIButton *mokeyLoginTag;
/** 切换页签下方横线 **/
@property (strong, nonatomic) UIImageView *loginTagUnderLine;
@property (strong, nonatomic) MASConstraint *loginTagCenterXConstraint;

@property (assign, readwrite, nonatomic) CMPLoginViewMode loginMode;

/** 验证码输入框下方横线 **/
@property (nonatomic, strong) UIView *verificationUnderline;
@property (strong, nonatomic) CMPInputObserver *inputObserver;
@property (strong, nonatomic) MASConstraint *loginTopConstraint;
/** 企业登录展示验证码 **/
@property (assign, nonatomic) BOOL legacyShowVerification;
/** 手机号登录展示验证码 **/
@property (assign, nonatomic) BOOL phoneShowVerification;
/** 手机盾新增：手机盾状态 **/
//@property (nonatomic, copy) NSString *trustdoStatus;

/** 隐私条例View **/
@property (strong, nonatomic) UIView *policyView;

/** 已阅读并同意 **/
@property (strong, nonatomic) UILabel *policyLabel;
/** 隐私保护协议详情按钮 **/
@property (strong, nonatomic) UIButton *policyDetailButton;

@end

@implementation CMPLoginView

@synthesize username = _username;
@synthesize password = _password;
@synthesize mokeyUsername = _mokeyUsername;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:[CMPLoginViewStyle defaultStyle] mode:CMPLoginViewModeLegacy];
}

- (instancetype)initWithFrame:(CGRect)frame
                        style:(CMPLoginViewStyle *)style
                         mode:(CMPLoginViewMode)mode {
    if (self = [super initWithFrame:frame]) {
        
        [self initView];
        [self registNotifications];
        [self addObserver];
        if (mode == CMPLoginViewModeLegacy) {
            [self initLegacyLogin];
            self.loginMode = CMPLoginViewModeLegacy;
        } else if (mode == CMPLoginViewModePhone) {
            [self initPhoneLogin];
            self.loginMode = CMPLoginViewModePhone;
        } else if (mode == CMPLoginViewModeMokey) {
//            [self.backgroundView addSubview:self.mokeyLoginTag];
            [self.loginTagView addSubview:self.mokeyLoginTag];
            [self initMokeyLogin];
            self.loginMode = CMPLoginViewModeMokey;
        }
        self.style = style;
//        self.policyView.hidden = [[CMPCore sharedInstance] isByPopUpPrivacyProtocolPage];
        self.policyView.hidden = NO;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.inputObserver removeAll];
}

- (void)registNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark-
#pragma mark-KVO

- (void)addObserver {
    if (!_inputObserver) {
        _inputObserver = [[CMPInputObserver alloc] init];
    }
    
    __weak __typeof(self)weakSelf = self;
    self.inputObserver.didAllFill = ^{
        weakSelf.loginButton.enabled = YES;
    };
    self.inputObserver.didSomeEmpty = ^{
        weakSelf.loginButton.enabled = NO;
    };
}

#pragma mark-
#pragma mark-UI布局

- (void)initView {
    
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.backgroundImageView];
    [self.backgroundView addSubview:self.backgroundImageIconView];
    [self.backgroundView addSubview:self.backgroundImageMaskView];
    [self.backgroundView addSubview:self.settingButton];
    [self.backgroundView addSubview:self.usernameView];
    [self.backgroundView addSubview:self.phoneView];
    [self.backgroundView addSubview:self.phonePwdView];
    [self.backgroundView addSubview:self.userNameUnderline];
    [self.backgroundView addSubview:self.pwdView];
    [self.backgroundView addSubview:self.passwordUnderline];
    [self.backgroundView addSubview:self.loginButton];
    [self.backgroundView addSubview:self.forgetPwdButton];
    [self.backgroundView addSubview:self.loginTagView];
    [self.loginTagView addSubview:self.legacyLoginTag];
    [self.loginTagView addSubview:self.phoneLoginTag];
    [self.backgroundView addSubview:self.loginTagUnderLine];
    [self.backgroundView addSubview:self.policyView];
    [self.backgroundView addSubview:self.mokeyUserNameView];
    [self.backgroundView addSubview:self.scanButton];
    self.backgroundColor = [UIColor whiteColor];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}


-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect mainViewFrame = [UIScreen mainScreen].bounds;
    
    if (iPhone5) {
        
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(mainViewFrame.size.width);
            make.height.equalTo(mainViewFrame.size.height);
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(-self.viewAddHeight);
            
        }];
        
        [self.loginTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView).inset(self.backgroundView.cmp_height * 0.28 + 40);
            make.centerX.equalTo(self.backgroundView);
        }];
        
    }else{
        
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(mainViewFrame.size.width);
            make.height.equalTo(mainViewFrame.size.height);
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(-self.viewAddHeight);
            
        }];
        
        [self.loginTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView).inset(mainViewFrame.size.height * 0.327 + 40);
            make.centerX.equalTo(self.backgroundView);
        }];
    }
    
    [self.backgroundImageMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(mainViewFrame.size.width);
        make.height.equalTo(mainViewFrame.size.height);
        make.top.leading.equalTo(self);
        
    }];
    
    if (INTERFACE_IS_PAD) {
        [self.usernameView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginTagUnderLine.mas_bottom).inset(41);
            make.centerX.equalTo(self.backgroundView);
            make.width.equalTo(MIN(mainViewFrame.size.width, mainViewFrame.size.height) * 0.5 );
            make.height.equalTo(@25);
        }];
    }else {
        [self.usernameView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginTagUnderLine.mas_bottom).inset(41);
            make.leading.trailing.equalTo(self.backgroundView).inset(28);
            make.height.equalTo(@25);
        }];
    }
    
    [self.phoneView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginTagUnderLine.mas_bottom).inset(41);
        make.leading.trailing.equalTo(self.usernameView);
        make.height.equalTo(@25);
    }];
    
    [self.settingButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom).inset(10);
        make.leading.equalTo(self.loginButton.mas_leading);
    }];
    
    [self.policyView mas_updateConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11, *)) {
//            make.bottom.equalTo(self.backgroundView.mas_safeAreaLayoutGuideBottom).inset(20);
//        } else {
//            make.bottom.equalTo(self.backgroundView.mas_bottom).inset(20);
//        }
        make.height.equalTo(14);
//        make.centerX.equalTo(self.backgroundView);
        make.width.greaterThanOrEqualTo(192);
        make.left.equalTo(self.settingButton.mas_left);
        make.top.equalTo(self.settingButton.mas_bottom).offset(20);
    }];
    
    [self.backgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundView);
    }];
    
    [self.backgroundImageIconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundView.mas_bottom).dividedBy(7);
        make.centerX.equalTo(self.backgroundView);
        make.width.equalTo(191);
        make.height.equalTo(38);
    }];
    
    [self.userNameUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.usernameView.mas_bottom).inset(3);
        make.leading.equalTo(self.usernameView).inset(-5);
        make.trailing.equalTo(self.usernameView).inset(5);
        make.height.equalTo(@1);
    }];
    
    [self.pwdView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameUnderline.mas_bottom).inset(28);
        make.leading.trailing.equalTo(self.usernameView);
        make.height.equalTo(@25);
    }];
    
    [self.phonePwdView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameUnderline.mas_bottom).inset(28);
        make.leading.trailing.equalTo(self.usernameView);
        make.height.equalTo(@25);
    }];
    
    [self.passwordUnderline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdView.mas_bottom).inset(3);
        make.leading.trailing.equalTo(self.userNameUnderline);
        make.height.equalTo(@1);
    }];
    
    [self.mokeyUserNameView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginTagUnderLine.mas_bottom).inset(41);
        make.leading.trailing.equalTo(self.usernameView);
        make.height.equalTo(@25);
    }];
    
    [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.usernameView);
        make.height.equalTo(@42);
    }];
    
    [self.forgetPwdButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.settingButton);
        make.trailing.equalTo(self.loginButton.mas_trailing);
    }];
    
    
    [self.legacyLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self.loginTagView);
        make.trailing.equalTo(self.phoneLoginTag.mas_leading).offset(-20);
    }];
    
    [self.phoneLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self.loginTagView);
        make.leading.equalTo(self.legacyLoginTag.mas_trailing).offset(20);
    }];
    
    [self.scanButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.settingButton);
        make.trailing.equalTo(self.loginButton.mas_trailing);
    }];
    
    if (TrustdoLoginManager.sharedInstance.isHaveMokeyLoginPermission) {
        //有手机盾登录
        if (CMPCore.sharedInstance.isShowPhoneLogin) {
            [self.phoneLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.loginTagView);
                make.leading.equalTo(self.legacyLoginTag.mas_trailing).offset(20);
                make.trailing.equalTo(self.mokeyLoginTag.mas_leading).offset(-20);
            }];
            if (NULL != _mokeyLoginTag) {
                [self.mokeyLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.trailing.bottom.equalTo(self.loginTagView);
                    make.leading.equalTo(self.phoneLoginTag.mas_trailing).offset(20);
                }];
            }
        }
        else {
            self.phoneLoginTag.hidden = YES;
            [self.phoneLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(0);
            }];
            
            [self.legacyLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.loginTagView);
                make.leading.equalTo(self.loginTagView.mas_leading).offset(20);
                make.trailing.equalTo(self.loginTagView.mas_trailing).offset(20);
            }];
            
            if (NULL != _mokeyLoginTag) {
                [self.mokeyLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.trailing.bottom.equalTo(self.loginTagView);
                    make.leading.equalTo(self.legacyLoginTag.mas_trailing).offset(20);
                }];
            }
            
            [self switchToLegacyLoginWithAnimation:NO];
        }
        
    }else {
        //没有手机盾登录
        if (!CMPCore.sharedInstance.isShowPhoneLogin) {
            self.phoneLoginTag.hidden = YES;
            [self.phoneLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(0);
            }];
            self.legacyLoginTag.hidden = YES;
            [self.legacyLoginTag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.bottom.equalTo(self.loginTagView);
                make.trailing.equalTo(self.loginTagView.mas_trailing).offset(-20);
            }];
            
            [self.loginTagView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(0);
            }];
            self.loginTagView.hidden = YES;
            self.loginTagUnderLine.hidden = YES;
            [self switchToLegacyLoginWithAnimation:NO];
            
        }
    }
    
    
    [self.loginTagUnderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.legacyLoginTag.mas_bottom);
        if (!self.loginTagCenterXConstraint) {
            self.loginTagCenterXConstraint = make.centerX.equalTo(self.legacyLoginTag.mas_centerX);
        }
    }];
    
    
}


#pragma mark-
#pragma mark-按钮点击事件

- (void)tapSettingButton {
    if (self.settingAction) {
        self.settingAction();
    }
}

- (void)tapLoginButton {
    [self dismissKeybord];
    if (self.loginAction) {
        self.loginAction();
    }
}

- (void)tapForgetPwdButton {
    if (self.forgetPwdAction) {
        self.forgetPwdAction();
    }
}

// 手机盾扫一扫按钮
-(void)tapScanButton {
    if (self.mokeyUserNameView.text.length > 0) {
        if (self.scanAction) {
            self.scanAction(YES);
        }
    } else {
        self.scanAction(NO);
    }
}

// 登录模式切换按钮点击事件
- (void)tapLoginTag:(UIButton *)sender {
    [self dismissKeybord];
    if (sender == self.legacyLoginTag) {
        if (self.loginMode == CMPLoginViewModePhone || self.loginMode == CMPLoginViewModeMokey) {
            [self switchToLegacyLoginWithAnimation:YES];
        }
    } else if (sender == self.phoneLoginTag) {
        if (self.loginMode == CMPLoginViewModeLegacy || self.loginMode == CMPLoginViewModeMokey) {
            [self switchToPhoneLoginWithAnimation:YES];
        }
    } else if (sender == self.mokeyLoginTag) {
        if (self.loginMode == CMPLoginViewModePhone || self.loginMode == CMPLoginViewModeLegacy) {
            [self switchToMokeyLoginWithAnimation:YES];
        }
    }
}

#pragma mark-
#pragma mark 模式切换

- (void)switchToLegacyLogin {
    [self switchToLegacyLoginWithAnimation:YES];
}

- (void)switchToLegacyLoginWithAnimation:(BOOL)animation {
    CGFloat timeInterval = animation ? switchDuration : 0;
    self.loginMode = CMPLoginViewModeLegacy;
    [UIView animateWithDuration:timeInterval
                     animations:^{
                         [self initLegacyLogin];
                         [self layoutIfNeeded];
                     }];
}

- (void)initLegacyLogin {
    self.phoneView.alpha = 0;
    self.phonePwdView.alpha = 0;
    self.usernameView.alpha = 1;
    self.pwdView.alpha = 1;
    self.passwordUnderline.alpha = 1;
    self.mokeyUserNameView.alpha = 0;
    self.settingButton.alpha = 1;
    self.forgetPwdButton.alpha = 1;
    self.scanButton.alpha = 0;
    [self.loginTagCenterXConstraint uninstall];
    [self.loginTagUnderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        self.loginTagCenterXConstraint = make.centerX.equalTo(self.legacyLoginTag.mas_centerX);
    }];
    [self.legacyLoginTag setTitleColor:self.style.tagSelectColor forState:UIControlStateNormal];
    [self.legacyLoginTag setTitleColor:[self.style.tagSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.phoneLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
    [self.phoneLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    if (NULL != _mokeyLoginTag) {
        [self.mokeyLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
        [self.mokeyLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    }
    [self.inputObserver registerInput:self.usernameView];
    [self.inputObserver registerInput:self.pwdView];
    [self.inputObserver removeInput:self.phoneView];
    [self.inputObserver removeInput:self.phonePwdView];
    [self.inputObserver removeInput:self.mokeyUserNameView];
    if (_legacyShowVerification) {
        [self showVerification];
    } else {
        [self hideVerification];
    }
}

- (void)switchToPhoneLoginWithAnimation:(BOOL)animation {
    CGFloat timeInterval = animation ? switchDuration : 0;
    self.loginMode = CMPLoginViewModePhone;
    [UIView animateWithDuration:timeInterval
                     animations:^{
                         [self initPhoneLogin];
                         [self layoutIfNeeded];
                     }];
}

- (void)initPhoneLogin {
    self.phoneView.alpha = 1;
    self.phonePwdView.alpha = 1;
    self.usernameView.alpha = 0;
    self.pwdView.alpha = 0;
    self.passwordUnderline.alpha = 1;
    self.mokeyUserNameView.alpha = 0;
    self.settingButton.alpha = 0;
    self.forgetPwdButton.alpha = 0;
    self.scanButton.alpha = 0;
    [self.loginTagCenterXConstraint uninstall];
    [self.loginTagUnderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        self.loginTagCenterXConstraint = make.centerX.equalTo(self.phoneLoginTag.mas_centerX);
    }];
    [self.legacyLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
    [self.legacyLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.phoneLoginTag setTitleColor:self.style.tagSelectColor forState:UIControlStateNormal];
    [self.phoneLoginTag setTitleColor:[self.style.tagSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    if (NULL != _mokeyLoginTag) {
        [self.mokeyLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
        [self.mokeyLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    }
    [self.inputObserver registerInput:self.phoneView];
    [self.inputObserver registerInput:self.phonePwdView];
    [self.inputObserver removeInput:self.usernameView];
    [self.inputObserver removeInput:self.pwdView];
    [self.inputObserver removeInput:self.mokeyUserNameView];
    if (_phoneShowVerification) {
        [self showVerification];
    } else {
        [self hideVerification];
    }
}

- (void)switchToMokeyLoginWithAnimation:(BOOL)animation {
    CGFloat timeInterval = animation ? switchDuration : 0;
    self.loginMode = CMPLoginViewModeMokey;
    [UIView animateWithDuration:timeInterval
                     animations:^{
                         [self initMokeyLogin];
                         [self layoutIfNeeded];
                     }];
}

- (void)initMokeyLogin {
    self.mokeyUserNameView.alpha = 1;
    self.phoneView.alpha = 0;
    self.phonePwdView.alpha = 0;
    self.usernameView.alpha = 0;
    self.pwdView.alpha = 0;
    self.passwordUnderline.alpha = 0;
    self.settingButton.alpha = 1;
    self.forgetPwdButton.alpha = 0;
    self.scanButton.alpha = 1;
    [self.loginTagCenterXConstraint uninstall];
    [self.loginTagUnderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        self.loginTagCenterXConstraint = make.centerX.equalTo(self.mokeyLoginTag.mas_centerX);
    }];
    [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
        self.loginTopConstraint = make.top.equalTo(self.userNameUnderline.mas_bottom).inset(20);
    }];
    [self.legacyLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
    [self.legacyLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.phoneLoginTag setTitleColor:self.style.tagUnSelectColor forState:UIControlStateNormal];
    [self.phoneLoginTag setTitleColor:[self.style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.mokeyLoginTag setTitleColor:self.style.tagSelectColor forState:UIControlStateNormal];
    [self.mokeyLoginTag setTitleColor:[self.style.tagSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.inputObserver registerInput:self.mokeyUserNameView];
    [self.inputObserver removeInput:self.phoneView];
    [self.inputObserver removeInput:self.phonePwdView];
    [self.inputObserver removeInput:self.usernameView];
    [self.inputObserver removeInput:self.pwdView];
}

#pragma mark-
#pragma mark 验证码

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//
//    static BOOL aa = YES;
//
//    if (aa) {
//
//        [self showVerification];
//        aa = NO;
//
//    }else{
//
//        [self hideVerification];
//        aa = YES;
//
//    }
//
//}

- (void)clearVerificationState {
    _legacyShowVerification = NO;
    _phoneShowVerification = NO;
    _verificationInputView.text = @"";
}

- (void)showVerification {
    if (self.loginMode == CMPLoginViewModeLegacy) {
        _legacyShowVerification = YES;
    } else if (self.loginMode == CMPLoginViewModePhone) {
        _phoneShowVerification = YES;
    }
    [self.backgroundView addSubview:self.verificationView];
    [self.backgroundView addSubview:self.verificationInputView];
    [self.backgroundView addSubview:self.verificationUnderline];
    [self.inputObserver registerInput:self.verificationInputView];
    
    [self.verificationInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordUnderline.mas_bottom).inset(28);
        make.leading.equalTo(self.backgroundView).inset(28);
        make.trailing.equalTo(self.backgroundView).inset(100+28+12);
        make.height.equalTo(@25);
    }];
    
    if (INTERFACE_IS_PAD) {
        [self.verificationInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordUnderline.mas_bottom).inset(28);
            make.leading.equalTo(self.passwordUnderline.mas_leading);
            make.trailing.equalTo(self.passwordUnderline.mas_trailing).offset(-100-12);
            make.height.equalTo(@25);
        }];
    }else {
        [self.verificationInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordUnderline.mas_bottom).inset(28);
            make.leading.equalTo(self.backgroundView).inset(28);
            make.trailing.equalTo(self.backgroundView).inset(100+28+12);
            make.height.equalTo(@25);
        }];
    }
    
    [self.verificationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.verificationUnderline);
        make.leading.equalTo(self.verificationInputView.mas_trailing).inset(12);
        make.height.equalTo(44);
        make.width.equalTo(100);
    }];
    
    [self.verificationUnderline mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verificationInputView.mas_bottom).inset(3);
        make.leading.trailing.equalTo(self.verificationInputView);
        make.height.equalTo(@1);
    }];
    
    [self.loginTopConstraint uninstall];
    [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
        self.loginTopConstraint = make.top.equalTo(self.verificationUnderline.mas_bottom).inset(20);
    }];
}

- (void)hideVerification {
    // 手机盾新增判断(用来地址切换后状态的改变)
    if (self.loginMode == CMPLoginViewModeMokey && !TrustdoLoginManager.sharedInstance.isHaveMokeyLoginPermission) {
        self.loginMode = CMPLoginViewModeLegacy;
    }
    if (self.loginMode == CMPLoginViewModeLegacy) {
        _legacyShowVerification = NO;
    } else if (self.loginMode == CMPLoginViewModePhone) {
        _phoneShowVerification = NO;
    }
    [self.verificationView removeFromSuperview];
    [self.verificationInputView removeFromSuperview];
    [self.verificationUnderline removeFromSuperview];
    [self.inputObserver removeInput:self.verificationInputView];
    
    [self.loginTopConstraint uninstall];
    // 手机盾新增：判断是否为手机盾登录模块 修改登录按钮的位置
    if (self.loginMode == CMPLoginViewModeMokey) {
        [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
            self.loginTopConstraint = make.top.equalTo(self.userNameUnderline.mas_bottom).inset(20);
        }];
    } else {
        [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
            self.loginTopConstraint = make.top.equalTo(self.passwordUnderline.mas_bottom).inset(20);
        }];
    }
}

#pragma mark 手机盾模块
/**
 展示手机盾模块
 */
- (void)useMokeyTag {
    if (TrustdoLoginManager.sharedInstance.isHaveMokeyLoginPermission) {
            // 增加手机盾模块
            [self.loginTagView addSubview:self.mokeyLoginTag];
            self.mokeyLoginTag.hidden = NO;
    } else {
            self.mokeyLoginTag.hidden = YES;
            if (_loginMode == CMPLoginViewModeMokey) {
                [self initLegacyLogin];
            }
    }
    [self setNeedsLayout];
}

#pragma mark-
#pragma mark-处理键盘弹出

- (void)dismissKeybord {
    [self.usernameView resignFirstResponder];
    [self.phoneView resignFirstResponder];
    [self.pwdView resignFirstResponder];
    [self.phonePwdView resignFirstResponder];
    [self.verificationInputView resignFirstResponder];
    // 手机盾新增：增加手机盾输入框的键盘处理
    [self.mokeyUserNameView resignFirstResponder];
}

//-(void)textDidBeginEditing:(NSNotification *)notification{
//
//    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
//
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//
//        return;
//
//    }
//
//    if (!_KeyboardHeight) {
//
//        return;
//
//    }
//
//    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
//    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
//
//    if (iPhone5){
//
//        self.viewAddHeight = _KeyboardHeight - ([UIWindow mainScreenSize].width - firstResponder.frame.origin.y - firstResponder.frame.size.height - ([UIWindow mainScreenSize].width - [UIWindow mainScreenSize].height - ([UIWindow mainScreenSize].width * 0.28 + 40 - 10))) + 10;
//
//    }else{
//
//        self.viewAddHeight = _KeyboardHeight - ([UIWindow mainScreenSize].width - firstResponder.frame.origin.y - firstResponder.frame.size.height - ([UIWindow mainScreenSize].width - [UIWindow mainScreenSize].height - ([UIWindow mainScreenSize].width * 0.327 + 40 - 10))) + 10;
//
//    }
//
//    if (INTERFACE_IS_PAD) {
//
//        self.viewAddHeight = 0;
//    }
//
//
//
//    [UIView animateWithDuration:_animationDuration animations:^{
//
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//
//    }];
//
//
//}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (endFrame.origin.y == _lastKeyboardHeight && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        return;
    }
    
    if (endFrame.origin.y == [[UIScreen mainScreen ] bounds].size.height) {
        self.viewAddHeight = 0;
    } else {
        
        self.viewAddHeight = endFrame.size.height - ([UIWindow mainScreenSize].height - _forgetPwdButton.frame.origin.y - _forgetPwdButton.frame.size.height);
        
        if (INTERFACE_IS_PAD && InterfaceOrientationIsPortrait) {

            self.viewAddHeight = 0;
        }
        
//        if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && _KeyboardHeight != endFrame.size.height) {
//
//            UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
//            UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
//
//
//            if (iPhone5) {
//
//                self.viewAddHeight = endFrame.size.height - ([UIWindow mainScreenSize].width - firstResponder.frame.origin.y - firstResponder.frame.size.height - ([UIWindow mainScreenSize].width - [UIWindow mainScreenSize].height - ([UIWindow mainScreenSize].width * 0.28 + 40 - 10))) + 10;
//
//            }else{
//
//                self.viewAddHeight = endFrame.size.height - ([UIWindow mainScreenSize].width - firstResponder.frame.origin.y - firstResponder.frame.size.height - ([UIWindow mainScreenSize].width - [UIWindow mainScreenSize].height - ([UIWindow mainScreenSize].width * 0.327 + 40 - 10))) + 10;
//
//            }
//
////            if (INTERFACE_IS_PAD) {
////
////                self.viewAddHeight = 0;
////            }
//
//            _KeyboardHeight = endFrame.size.height;
//            _animationDuration = animationDuration;
//            _lastKeyboardHeight = endFrame.origin.y;
//
//            [UIView animateWithDuration:animationDuration animations:^{
//
//                [self setNeedsLayout];
//                [self layoutIfNeeded];
//
//            }];
//
//            return;
//
//        }
        
    }

    _lastKeyboardHeight = endFrame.origin.y;
    
//    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && self.viewAddHeight){
//
//        return;
//
//    }

    [UIView animateWithDuration:animationDuration animations:^{
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    }];
    
    
}

#pragma mark-
#pragma mark-CMPLoginViewTextFieldDelegate

- (BOOL)textFieldShouldReturn:(CMPLoginViewTextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_pwdView becomeFirstResponder];
    } else if (textField.returnKeyType == UIReturnKeySend) {
        [self tapLoginButton];
    }
    return YES;
}



- (BOOL)textField:(CMPLoginViewTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _usernameView || textField == _phoneView) {
        [self hideVerification];
        if (self.loginAccountDidChange) {
            self.loginAccountDidChange();
        }
    }
    return YES;
}

- (void)textFieldDidClear:(CMPLoginViewTextField *)textField {
    if (textField == _usernameView || textField == _phoneView) {
        [self hideVerification];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
}

#pragma mark-
#pragma mark-Getter & Setter

-(UIView *)backgroundView{
    
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _backgroundView;
    
}

- (FLAnimatedImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[FLAnimatedImageView alloc] init];
    }
    return _backgroundImageView;
}

- (UIImageView *)backgroundImageIconView {
    if (!_backgroundImageIconView) {
        _backgroundImageIconView = [[UIImageView alloc] init];
        _backgroundImageIconView.image = [UIImage imageWithName:@"login_bg_icon" type:@"png" inBundle:@"CMPLogin"];
    }
    return _backgroundImageIconView;
}


- (UIView *)backgroundImageMaskView {
    if (!_backgroundImageMaskView) {
        _backgroundImageMaskView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundImageMaskView.hidden = YES;
    }
    return _backgroundImageMaskView;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 15)];
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_settingButton setTitle:SY_STRING(@"login_server_setting") forState:UIControlStateNormal];
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        [_settingButton setTitleColor:themeColor forState:UIControlStateNormal];
        [_settingButton setTitleColor:[themeColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_settingButton addTarget:self action:@selector(tapSettingButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

- (CMPLoginViewTextField *)usernameView {
    if (!_usernameView) {
        _usernameView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_username") type:CMPLoginViewTextFieldTypeUsername];
        _usernameView.textFieldDelegate = self;
        [_usernameView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _usernameView;
}

- (CMPLoginViewTextField *)phoneView {
    if (!_phoneView) {
        _phoneView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_phone") type:CMPLoginViewTextFieldTypePhone];
        _phoneView.textFieldDelegate = self;
        [_phoneView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _phoneView;
}

- (UIView *)userNameUnderline {
    if (!_userNameUnderline) {
        _userNameUnderline = [[UIView alloc] init];
        _userNameUnderline.backgroundColor = [UIColor colorWithHexString:@"D4D4D4"];
    }
    return _userNameUnderline;
}

- (CMPLoginViewTextField *)pwdView {
    if (!_pwdView) {
        _pwdView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_password") type:CMPLoginViewTextFieldTypePassword];
        _pwdView.textFieldDelegate = self;
        [_pwdView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _pwdView;
}

- (CMPLoginViewTextField *)phonePwdView {
    if (!_phonePwdView) {
        _phonePwdView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_password") type:CMPLoginViewTextFieldTypePassword];
        _phonePwdView.textFieldDelegate = self;
        [_phonePwdView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _phonePwdView;
}

- (UIView *)passwordUnderline {
    if (!_passwordUnderline) {
        _passwordUnderline = [[UIView alloc] init];
        _passwordUnderline.backgroundColor = [UIColor colorWithHexString:@"D4D4D4"];
    }
    return _passwordUnderline;
}

// 手机盾新增：手机盾用户输入框
- (CMPLoginViewTextField *)mokeyUserNameView {
    if (!_mokeyUserNameView) {
        _mokeyUserNameView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_account_placeholder") type:CMPLoginViewTextFieldTypeMokeyUsername];
        _mokeyUserNameView.textFieldDelegate = self;
        [_mokeyUserNameView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _mokeyUserNameView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:SY_STRING(@"login_login") forState:UIControlStateNormal];
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        UIImage *image = [[UIImage imageWithName:@"login_button_bg" type:@"png" inBundle:@"CMPLogin"] cmp_imageWithTintColor:themeColor];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)];
        UIImage *highlightedImage = [[UIImage imageWithName:@"login_button_bg" type:@"png" inBundle:@"CMPLogin"] cmp_imageWithTintColor:[themeColor colorWithAlphaComponent:0.7]];
        highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5, highlightedImage.size.height * 0.5, highlightedImage.size.width * 0.5)];
        _loginButton.enabled = NO;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [_loginButton setBackgroundImage:image forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        [_loginButton addTarget:self action:@selector(tapLoginButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *)forgetPwdButton {
    if (!_forgetPwdButton) {
        _forgetPwdButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 15)];
        _forgetPwdButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_forgetPwdButton setTitle:SY_STRING(@"login_forget_password") forState:UIControlStateNormal];
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        [_forgetPwdButton setTitleColor:themeColor forState:UIControlStateNormal];
        [_forgetPwdButton setTitleColor:[themeColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_forgetPwdButton addTarget:self action:@selector(tapForgetPwdButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPwdButton;
}

// 手机盾新增：手机盾扫一扫按钮
- (UIButton *)scanButton {
    if (!_scanButton) {
        _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 15)];
        _scanButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_scanButton setTitle:SY_STRING(@"login_mokey_scan") forState:UIControlStateNormal];
        [_scanButton setTitleColor:[UIColor colorWithHexString:@"3AADFB"] forState:UIControlStateNormal];
        [_scanButton setTitleColor:[UIColor colorWithHexString:@"3AADFB" alpha:0.5] forState:UIControlStateDisabled];
        [_scanButton addTarget:self action:@selector(tapScanButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanButton;
}

- (UIButton *)legacyLoginTag {
    if (!_legacyLoginTag) {
        _legacyLoginTag = [[UIButton alloc] init];
        _legacyLoginTag.titleLabel.font = [UIFont systemFontOfSize:14];
        [_legacyLoginTag sizeToFit];
        [_legacyLoginTag setTitle:SY_STRING(@"login_tag_legacy") forState:UIControlStateNormal];
        [_legacyLoginTag addTarget:self action:@selector(tapLoginTag:) forControlEvents:UIControlEventTouchUpInside];
        [_legacyLoginTag cmp_expandClickArea:UIOffsetMake(0, 15)];
    }
    return _legacyLoginTag;
}

- (UIButton *)phoneLoginTag {
    
    if (!_phoneLoginTag) {
        _phoneLoginTag = [[UIButton alloc] init];
        _phoneLoginTag.titleLabel.font = [UIFont systemFontOfSize:14];
        [_phoneLoginTag sizeToFit];
        [_phoneLoginTag setTitle:SY_STRING(@"login_tag_phone") forState:UIControlStateNormal];
        [_phoneLoginTag addTarget:self action:@selector(tapLoginTag:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneLoginTag cmp_expandClickArea:UIOffsetMake(0, 15)];
    }
    return _phoneLoginTag;
}

- (UIView *)loginTagView {
    if (!_loginTagView) {
        _loginTagView = [[UIView alloc] init];
    }
    return _loginTagView;
}

// 手机盾新增：手机盾选择按钮
-(UIButton *)mokeyLoginTag {
    if (!_mokeyLoginTag) {
        _mokeyLoginTag = [[UIButton alloc] init];
        _mokeyLoginTag.titleLabel.font = [UIFont systemFontOfSize:14];
        [_mokeyLoginTag sizeToFit];
        [_mokeyLoginTag setTitle:SY_STRING(@"login_tag_mokey") forState:UIControlStateNormal];
        [_mokeyLoginTag addTarget:self action:@selector(tapLoginTag:) forControlEvents:UIControlEventTouchUpInside];
        [_mokeyLoginTag cmp_expandClickArea:UIOffsetMake(0, 15)];
    }
    return _mokeyLoginTag;
}

- (UIImageView *)loginTagUnderLine {
    if (!_loginTagUnderLine) {
        _loginTagUnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 3)];
        _loginTagUnderLine.image = [UIImage imageWithName:@"login_tag_underline" type:@"png" inBundle:@"CMPLogin"];
    }
    return _loginTagUnderLine;
}

- (CMPLoginViewTextField *)verificationInputView {
    if (!_verificationInputView) {
        _verificationInputView = [[CMPLoginViewTextField alloc] initWithPlaceHolder:SY_STRING(@"login_verification") type:CMPLoginViewTextFieldTypeVerification];
        [_verificationInputView cmp_expandClickArea:UIOffsetMake(10, 15)];
    }
    return _verificationInputView;
}

- (UIButton *)verificationView {
    if (!_verificationView) {
        _verificationView = [[UIButton alloc] init];
        _verificationView.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _verificationView.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
        _verificationView.adjustsImageWhenHighlighted = NO;
    }
    return _verificationView;
}

- (UIView *)verificationUnderline {
    if (!_verificationUnderline) {
        _verificationUnderline = [[UIView alloc] init];
        _verificationUnderline.backgroundColor = [UIColor colorWithHexString:@"D4D4D4"];
    }
    return _verificationUnderline;
}

- (NSString *)username {
    _username = [self.usernameView.text trim];
    return _username;
}

- (NSString *)password {
    _password = [self.pwdView.text trim];
    return _password;
}

- (NSString *)phone {
    _phone = self.phoneView.text;
    _phone = [_phone replaceCharacter:@" " withString:@""];
    return _phone;
}

// 手机盾新增：手机盾用户输入字符串
-(NSString *)mokeyUsername {
    _mokeyUsername = [self.mokeyUserNameView.text trim];
    return _mokeyUsername;
}

- (void)setUsername:(NSString *)username {
    _username = username;
    self.usernameView.text = username;
}

- (void)setPassword:(NSString *)password {
    _password = password;
    self.pwdView.text = password;
}

// 手机盾新增：手机盾用户输入
-(void)setMokeyUsername:(NSString *)mokeyUsername {
    _mokeyUsername = mokeyUsername;
    self.mokeyUserNameView.text = mokeyUsername;
}

- (void)setStyle:(CMPLoginViewStyle *)style {
    _style = style;
    UIButton *selectButton = nil;
    UIButton *unselectButton = nil;
    // 手机盾新增：增加替换按钮
    UIButton *otherUnselectButton = nil;
    if (self.loginMode == CMPLoginViewModeLegacy) {
        selectButton = self.legacyLoginTag;
        unselectButton = self.phoneLoginTag;
        if (NULL != _mokeyLoginTag) {
            otherUnselectButton = self.mokeyLoginTag;
        }
    } else if (self.loginMode == CMPLoginViewModePhone) {
        selectButton = self.phoneLoginTag;
        unselectButton = self.legacyLoginTag;
        if (NULL != _mokeyLoginTag) {
            otherUnselectButton = self.mokeyLoginTag;
        }
    } else if (self.loginMode == CMPLoginViewModeMokey) {
        selectButton = self.mokeyLoginTag;
        unselectButton = self.legacyLoginTag;
        if (NULL != _mokeyLoginTag) {
            otherUnselectButton = self.phoneLoginTag;
        }
    }
    [selectButton setTitleColor:style.tagSelectColor forState:UIControlStateNormal];
    [selectButton setTitleColor:[style.tagSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [unselectButton setTitleColor:style.tagUnSelectColor forState:UIControlStateNormal];
    [unselectButton setTitleColor:[style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [otherUnselectButton setTitleColor:style.tagUnSelectColor forState:UIControlStateNormal];
    [otherUnselectButton setTitleColor:[style.tagUnSelectColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    self.usernameView.textColor = style.inputTextColor;
    self.pwdView.textColor = style.inputTextColor;
    self.phonePwdView.textColor = style.inputTextColor;
    self.phoneView.textColor = style.inputTextColor;
    self.verificationInputView.textColor = style.inputTextColor;
    self.usernameView.text = self.usernameView.text;
    self.pwdView.text = self.pwdView.text;
    self.phonePwdView.text = self.phonePwdView.text;
    self.usernameView.text = self.usernameView.text;
    self.verificationInputView.text = self.verificationInputView.text;
    // 手机盾新增
    self.mokeyUserNameView.textColor = style.inputTextColor;
    // 手机盾新增
    self.mokeyUserNameView.text = self.mokeyUserNameView.text;
    
    if (style.backgroundMaskColor) {
        self.backgroundImageMaskView.hidden = NO;
        self.backgroundImageMaskView.backgroundColor = style.backgroundMaskColor;
        self.backgroundImageMaskView.alpha = style.backgroundMaskAlpha;
        self.backgroundImageMaskView.frame = self.bounds;
    } else {
        self.backgroundImageMaskView.hidden = YES;
    }
}

#pragma mark-
#pragma mark 隐私政策

- (UIView *)policyView {
    if (!_policyView) {
        _policyView = [[UIView alloc] init];
        [_policyView addSubview:self.policySelectButton];
        [_policyView addSubview:self.policyLabel];
        [_policyView addSubview:self.policyDetailButton];
        [self.policySelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.policyView);
            make.centerY.equalTo(self.policyView);
            make.width.height.equalTo(14);
        }];
        [self.policyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.policySelectButton.mas_trailing).inset(5);
            make.centerY.equalTo(self.policyView);
            make.height.equalTo(15);
        }];
        [self.policyDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.policyLabel.mas_trailing).inset(5);
            make.centerY.equalTo(self.policyView);
            make.height.equalTo(14);
            make.trailing.equalTo(self.policyView.mas_trailing);
        }];
    }
    return _policyView;
}

- (UIButton *)policySelectButton {
    if (!_policySelectButton) {
        _policySelectButton = [[UIButton alloc] init];
        _policySelectButton.selected = YES;
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        [_policySelectButton setImage:[[UIImage imageNamed:@"CMPLogin.bundle/login_checkbox_unselect"] cmp_imageWithTintColor:themeColor] forState:UIControlStateNormal];
        [_policySelectButton setImage:[[UIImage imageNamed:@"CMPLogin.bundle/login_checkbox_select"] cmp_imageWithTintColor:themeColor] forState:UIControlStateSelected];
        [_policySelectButton addTarget:self action:@selector(tapPolicySelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [_policySelectButton cmp_expandClickArea:UIOffsetMake(40, 0)];
    }
    return _policySelectButton;
}

- (UILabel *)policyLabel {
    if (!_policyLabel) {
        _policyLabel = [[UILabel alloc] init];
        _policyLabel.text = SY_STRING(@"login_policy_agree");
        _policyLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _policyLabel.textColor = [UIColor colorWithHexString:@"d4d4d4"];
    }
    return _policyLabel;
}

- (UIButton *)policyDetailButton {
    if (!_policyDetailButton) {
        _policyDetailButton = [[UIButton alloc] init];
        UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_policy_detail")
                                                                    attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightRegular],
                                                                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"3aadfb"]
                                                                                 }];
        [_policyDetailButton setAttributedTitle:title forState:UIControlStateNormal];
        [_policyDetailButton addTarget:self action:@selector(tapPolicyDetailButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _policyDetailButton;
}

// 勾选隐私协议，屏蔽所有按钮点击
- (void)tapPolicySelectButton:(UIButton *)sender {
    BOOL isSelected = sender.isSelected;
    sender.selected = !isSelected;
    self.usernameView.enabled = sender.selected;
    self.phoneView.enabled = sender.selected;
    self.pwdView.enabled = sender.selected;
    self.phonePwdView.enabled = sender.selected;
    self.verificationView.enabled = sender.selected;
    self.verificationInputView.enabled = sender.selected;
    self.settingButton.enabled = sender.selected;
    self.forgetPwdButton.enabled = sender.selected;
    self.phoneLoginTag.enabled = sender.selected;
    self.legacyLoginTag.enabled = sender.selected;
    
    // 手机盾新增：屏蔽手机盾用户输入框
    self.mokeyUserNameView.enabled = sender.selected;
    // 手机盾新增：屏蔽手机盾模块扫一扫按钮
    self.scanButton.enabled = sender.selected;
    
    if (sender.selected) {
        // 勾选隐私政策，登录按钮需要根据输入框状态更新可点击状态
        [self.inputObserver refreshState];
    } else {
        self.loginButton.enabled = sender.selected;
    }
}

// 点击隐私协议
- (void)tapPolicyDetailButton:(UIButton *)sender {
    if (self.policyAction) {
        self.policyAction();
    }
}

@end
