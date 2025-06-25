//
//  CMPBaseLoginView.h
//  M3
//
//  Created by wujiansheng on 2020/4/26.
//

#import <CMPLib/CMPBaseView.h>
#import "CMPLoginTextField.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CMPNewLoginViewDelegate <NSObject>

- (void)shouldRefreshVerification;
- (void)shouldLogin;

@end
@interface CMPBaseLoginView : CMPBaseView<UITextFieldDelegate>  {
    CMPLoginTextField *_accountTF;
}

@property(nonatomic,assign)id<CMPNewLoginViewDelegate>delegate;
/* 用户名输入框 */
@property (nonatomic, retain) CMPLoginTextField *accountTF;
- (NSDictionary *)attributesDictionary;
- (UIColor *)textColor;
- (void)shouldRefreshVerification;
- (void)shouldLogin;
- (void)setupVerificationImg:(UIImage *)image;
//是否必须输入验证码
- (BOOL)verificationCodeRequired;
@end

NS_ASSUME_NONNULL_END
