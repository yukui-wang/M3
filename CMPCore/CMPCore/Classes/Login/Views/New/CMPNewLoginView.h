//
//  CMPNewLoginView.h
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#import <CMPLib/CMPBaseView.h>
#import "CMPLoginSwitchButton.h"
#import "CMPLoginAnimButton.h"
#import "CMPOrgLoginView.h"
#import "CMPUserLoginView.h"
#import "CMPMokeyLoginView.h"
#import "CMPSMSLoginView.h"
#import <CMPLib/CMPBubbleTipsView.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, CMPNewLoginViewMode) {
    CMPNewLoginViewModeLegacy = 0,// 企业账号/手机号 登录
    CMPNewLoginViewModeSMS,// 短信 登录
    CMPNewLoginViewModeMokey,// 手机盾 登录
    CMPNewLoginViewModeOrg // 组织码 登录

};


@interface CMPNewLoginView : CMPBaseView

/* 背景图片/视频 */
@property (nonatomic, retain) UIImageView *bgImgView;

/* 背景图蒙层 */
@property (nonatomic, retain) UIView *backgroundImageMaskView;

/* 登录提示文字label */
@property (nonatomic, retain) UILabel *loginTipsLabel;
@property (nonatomic, retain) UILabel *orgTipsLabel;

/* 扫一扫btn */
@property (nonatomic, retain) UIButton *scanBtn;
/* 设置服务器按钮 */
@property (nonatomic, retain) UIButton *setServerBtn;

/* tipsBubbleView未设置服务器时的文字提示 */
@property (nonatomic, retain) CMPBubbleTipsView *tipsBubbleView;



/*组织码登陆*/
@property (nonatomic, retain) CMPOrgLoginView *orgLoginView;
/*用户一般登陆*/
@property (nonatomic, retain) CMPUserLoginView *userLoginView;
/*手机盾登陆*/
@property (nonatomic, retain) CMPMokeyLoginView *mokeyLoginView;

/* 登录按钮 */
@property (nonatomic, retain) CMPLoginAnimButton *loginBtn;

/* 其他登录方式按钮 */
@property (nonatomic, retain) CMPLoginSwitchButton *otherLoginBtn;

/* 手机号验证码按钮 */
@property (nonatomic, retain) CMPLoginSwitchButton *phoneLoginBtn;
/*短信登陆*/
@property (nonatomic, retain) CMPSMSLoginView *smsLoginView;

/* 忘记密码按钮 */
@property (nonatomic, retain) CMPLoginSwitchButton *forgetPwdBtn;

/** 手机盾新增：扫一扫按钮 **/
@property (nonatomic, strong) UIButton *mokeyScanButton;

/*切换组织码登陆环境用的  测试用，正式环境需屏蔽*/
@property (nonatomic, strong) UIButton *orgCodeChangeButton;
/*测试时为true，正式发布为false*/
@property (nonatomic, assign) BOOL showOrgCodeChangeButton;



/* 勾选按钮 */
@property (nonatomic, retain) UIButton *selectBtn;
/* 读和同意label */
@property (nonatomic, retain) UILabel *readAndAgreeLabel;
/* 协议按钮 */
@property (nonatomic, retain) UIButton *agreementBtn;


@property (nonatomic, assign) CMPNewLoginViewMode loginMode;

- (void)setLoginMode:(CMPNewLoginViewMode)loginMode delegate:(id<CMPNewLoginViewDelegate>)delegate;
- (NSString *)mokeyText;
- (void)setupVerificationImg:(UIImage *)image;
- (void)hideVerification;
- (void)showServertipsView;
//隐私协议相关按钮是否显示
- (void)setupPrivacyInfoHidden:(BOOL)hidden;

- (void)hiddenSMSLoginButton:(BOOL)hidden;
@end

NS_ASSUME_NONNULL_END
