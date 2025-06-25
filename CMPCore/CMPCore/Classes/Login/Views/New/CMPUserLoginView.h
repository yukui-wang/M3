//
//  CMPUserLoginView.h
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#import "CMPBaseLoginView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPUserLoginView : CMPBaseLoginView
/* 密码输入框 */
@property (nonatomic, retain) CMPLoginTextField *pwdTF;
/* 图片验证码输入框 */
@property (nonatomic, retain) CMPLoginTextField *imgVerificaitionTF;
/* imgVerificationImgView */
@property (nonatomic, retain) UIButton *imgVerificationImgBtn;

@property (nonatomic, assign)BOOL isShowImgVerificaitionTF;//是否显示图片验证码


- (CGFloat)viewHeight;
@end

NS_ASSUME_NONNULL_END
