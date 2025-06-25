//
//  CMPLoginTextField.h
//  M3
//
//  Created by MacBook on 2019/12/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLoginTextField : UIView

- (void)showLeftView:(BOOL)isShown;
- (void)showRightView:(BOOL)isShown;
- (void)showRightSMSView:(BOOL)isShown;

- (void)fireCountdonwTimer;
- (void)fireCountdonwTimer:(NSInteger)count;

/* 左边国家电话区号按钮点击block */
@property (copy, nonatomic) void(^leftViewBtnClicked)(void);
/* 获取验证码按钮点击block */
@property (copy, nonatomic) void(^getSMSCodeBtnClicked)(void);

/* textField */
@property (strong, nonatomic) UITextField *textField;
/* text */
@property (copy, nonatomic) NSString *text;

/* rightView */
@property (strong, nonatomic) UIView *rightView;

/* 区号 默认+86 显示时 设置有效 */
@property (copy, nonatomic) NSString *areaCode;

- (void)showCheckoutPwdBtn:(BOOL)isShown;


@end

NS_ASSUME_NONNULL_END
