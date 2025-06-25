//
//  CMPLoginViewController.h
//  M3
//
//  Created by CRMO on 2017/10/24.
//  8.0以前的登陆页

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBaseViewController.h>

@interface CMPLoginViewController : CMPBaseViewController

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSError *error;
// SSO登录失败，回调用户名密码
@property (strong, nonatomic) NSString *defaultUsername;
@property (strong, nonatomic) NSString *defaultPassword;

@end
