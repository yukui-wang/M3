//
//  CMPNewLoginViewController.h
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//  默认、8.0及云租户登陆页

#import <CMPLib/CMPBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPNewLoginViewController : CMPBaseViewController
@property (nonatomic, strong) NSString * _Nullable errorMessage;
@property (nonatomic, strong) NSError * _Nullable error;
// SSO登录失败，回调用户名密码
@property (strong, nonatomic) NSString *defaultUsername;
@property (strong, nonatomic) NSString *defaultPassword;

@end

NS_ASSUME_NONNULL_END
