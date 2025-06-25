//
//  CMPLoginView.h
//  M3
//
//  Created by CRMO on 2017/10/26.
//

#import <UIKit/UIKit.h>
#import "CMPLoginViewTextField.h"
#import <CMPLib/FLAnimatedImageView.h>

typedef NS_ENUM(NSUInteger, CMPLoginViewMode) {
    CMPLoginViewModeLegacy, // 企业账号登录
    CMPLoginViewModePhone, // 手机号登录
    CMPLoginViewModeMokey   // 手机盾登录
};

@interface CMPLoginViewStyle : NSObject<NSCoding>

/**
 默认样式
 */
+ (instancetype)defaultStyle;

@property (strong, nonatomic) UIColor *tagSelectColor;
@property (strong, nonatomic) UIColor *tagUnSelectColor;
@property (strong, nonatomic) UIColor *inputTextColor;

//v8.0登录页新增颜色
@property (strong, nonatomic) UIColor *scanColor;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *toServerSiteColor;

@property (strong, nonatomic) UIColor *backgroundMaskColor;
@property (assign, nonatomic) CGFloat backgroundMaskAlpha;
@property (copy, nonatomic) NSString *backgroundImage;
@property (copy, nonatomic) NSString *backgroundLandscapeImage;

@end


@interface CMPLoginView : UIView

@property (nonatomic, copy) void(^settingAction)(void);
@property (nonatomic,copy) void(^forgetPwdAction)(void);
@property (nonatomic,copy) void(^loginAction)(void);
/** 手机号、用户名变化 **/
@property (nonatomic,copy) void(^loginAccountDidChange)(void);
@property (nonatomic,copy) void(^policyAction)(void);

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (strong, nonatomic) NSString *phone;

/** 背景图 **/
@property (nonatomic, strong) FLAnimatedImageView *backgroundImageView;
/** 背景图图标 **/
@property (nonatomic, strong) UIImageView *backgroundImageIconView;
/** 手机号码输入框 **/
@property (nonatomic, strong) CMPLoginViewTextField *phoneView;
/** 手机号登录密码输入框 **/
@property (nonatomic, strong) CMPLoginViewTextField *phonePwdView;
@property (assign, readonly, nonatomic) CMPLoginViewMode loginMode;
@property (strong, nonatomic) CMPLoginViewStyle *style;
/** 验证码显示框 **/
@property (strong, nonatomic) UIButton *verificationView;
/** 验证码输入框 **/
@property (strong, nonatomic) CMPLoginViewTextField *verificationInputView;

/** 手机盾新增：扫码时用户名是否存在 **/
@property (nonatomic,copy) void(^scanAction)(BOOL);
/** 手机盾新增：手机盾用户名 **/
@property (nonatomic, strong) NSString *mokeyUsername;

/** 隐私条例勾选框 **/
@property (strong, nonatomic) UIButton *policySelectButton;

- (instancetype)initWithFrame:(CGRect)frame
                        style:(CMPLoginViewStyle *)style
                         mode:(CMPLoginViewMode)mode;

/**
 展示验证码输入框
 */
- (void)showVerification;

/**
 隐藏验证码输入框
 */
- (void)hideVerification;

/**
 设置所有验证码不展示
 */
- (void)clearVerificationState;

- (void)dismissKeybord;

- (void)switchToLegacyLogin;

/**
 手机盾模块
 */
- (void)useMokeyTag;

@end
