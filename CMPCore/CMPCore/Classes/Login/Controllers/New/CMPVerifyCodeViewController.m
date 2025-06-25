//
//  CMPVerifyCodeViewController.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/9/19.
//

#import "CMPVerifyCodeViewController.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import "CMPAuthCodeInputView.h"
#import "CMPNewPhoneCodeLoginProvider.h"
#import "M3LoginManager.h"
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/GTMUtil.h>

@interface CMPVerifyCodeViewController ()
{
    NSString *_number;
    __block NSString *_inputCode;
    UIActivityIndicatorView *_acV;
    id _ext;
    NSString *_loginName;
}
@property (nonatomic, strong) CMPNewPhoneCodeLoginProvider *provider;
@property (nonatomic, strong) CMPAuthCodeInputView *authView;
@end

@implementation CMPVerifyCodeViewController

-(instancetype)initWithNumber:(NSString *)number
                          ext:(_Nullable id)ext
{
    if (self = [super init]) {
        _number = number;
        _ext = [ext copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[[UIImage imageNamed:@"login_view_back_btn_icon"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#92a4b5"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn sizeToFit];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(35);
        make.top.offset(59);
    }];
    
    __weak typeof(self) wSelf = self;
    _authView = [[CMPAuthCodeInputView alloc] initWithFrame:CGRectZero andPhone:_number autoFetch:YES];
    _authView.fetchSmsAction = ^{
        if (_fetchCodeAction) {
            _fetchCodeAction();
            return;
        }
        [wSelf _fetchVerifyCode];
    };
    _authView.smsCodeChangeAction = ^(NSString * _Nonnull code, BOOL complete) {
        if (complete) {
            if (_smsInputCompletion) {
                _smsInputCompletion(code,nil,nil);
                return;
            }
            _inputCode = code;
            [wSelf _defaultMutilVerifyLogin];
        }
    };
    [self.view addSubview:_authView];
    [_authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelBtn.mas_bottom).offset(30);
        make.left.offset(10);
        make.right.offset(-10);
        make.bottom.offset(-80);
    }];
    
    _acV = [[UIActivityIndicatorView alloc] init];
    [self.view addSubview:_acV];
    [_acV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_authView);
    }];
    
    //V5-56636【双因子认证】IOS端，切换关联账号，关联账号是双因子角色人员，但是输入验证码界面没有输入验证码直接后台杀进程退出了应用，再次打开M3应用发现已经进入了关联账号的首页
    [[M3LoginManager sharedInstance] clearCurrentUserLoginPassword];
    
    NSString *loginName = @"";
    if (_ext && [_ext isKindOfClass:NSDictionary.class] && _ext[@"loginName"]) {
        loginName = _ext[@"loginName"];
        if (_ext[@"encrypted"] && [@"1" isEqualToString:_ext[@"encrypted"]]){
            
        }else{
            loginName = [GTMUtil encrypt:loginName];
        }
    }
    _loginName = loginName;
}

- (void)cancelBtnClicked {
//    [_serverManager cancel];
//    if (_serverEditView.contentChanged || _vpnEnterView.contentChanged) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:@"未保存本次修改内容，是否返回" preferredStyle:UIAlertControllerStyleAlert];
//        __weak typeof(self) weakself = self;
//        UIAlertAction *delete = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakself.navigationController popViewControllerAnimated:YES];
//        }];
//        UIAlertAction *cacel = [UIAlertAction actionWithTitle:SY_STRING(@"common_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        [alert addAction:delete];
//        [alert addAction:cacel];
//        [self presentViewController:alert animated:YES completion:nil];
//        return;
//    }
    BOOL conti = YES;
    if (_cancelBlk) {
        conti = _cancelBlk(nil,nil);
        if (!conti) return;
    }
    if (self.navigationController && self.navigationController.viewControllers.count>1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if(self.presentingViewController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)_fetchVerifyCode {
    if ([NSString isNull:_number]) {
        NSLog(@"number is null");
        [self showToastWithText:@"number is null"];
        return;
    }
    __weak typeof(self) wSelf = self;
//    [self.provider phoneCodeLoginWithValidPhoneNumbe:_number success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
//
//    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
//
//    }];
    [_acV startAnimating];
    [self.provider phoneCodeLoginWithGetPhoneCode:_number verifyCode:@"" extParams:@{@"isDoubleAuth":@"1",@"name":_loginName} success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        [_acV stopAnimating];
        NSLog(@"success: %@",response);
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        NSNumber *code = dict[@"code"];
        NSString *msg = [NSString stringWithFormat:@"%@",dict[@"message"]];
        if (code.intValue == 0) {
            NSLog(@"发送成功。可填入验证了");
            [wSelf.authView fireCountdonwTimer:1*60];
            msg = SY_STRING(@"common_send_success");
        }
        [wSelf showToastWithText:msg];
    } fail:^(NSError * _Nonnull err, NSDictionary * _Nonnull userInfo) {
        [_acV stopAnimating];
        NSLog(@"err: %@",err);
        NSString *msg = [NSString stringWithFormat:@"%@",err.domain];
        [wSelf showToastWithText:msg];
    }];
}

//填入验证吗后登录
-(void)_defaultMutilVerifyLogin
{
    [_acV startAnimating];
    NSString *smsCode = _inputCode;
    NSDictionary *ext = @{@"isDoubleAuth":@"1",@"name":_loginName,@"phone_number":_number?:@""};
    [[M3LoginManager sharedInstance] requestLoginWithUserName:_number  password:@"" encrypted:NO refreshToken:NO verificationCode:@"" type:CMPLoginAccountModelLoginTypeSMS loginType:[NSString stringWithInt:CMPM3LoginTypeSMS] smsCode:smsCode externParams:ext  isFromAutoLogin:NO start:^{
        
    } success:^{
        [_acV stopAnimating];
        if (_completion) _completion(YES,nil,nil);
    } fail:^(NSError *error) {
        [_acV stopAnimating];
        if (error && (error.code == 505 || error.code == 504)) {
            [self showAlertMessageWithResetAction:error.domain];
            return;
        }
        if (_completion) _completion(NO,error,nil);
    }];
}


-(void)showAlertMessageWithResetAction:(NSString *)message
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSAttributedString *formatMessage = [[NSAttributedString alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:[formatMessage string] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cacel = [UIAlertAction actionWithTitle:cacelTitle style:UIAlertActionStyleCancel handler:nil];
//        [alert addAction:cacel];
//        [self presentViewController:alert animated:YES completion:nil];
        //修改 bug OA-172943
        UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:[formatMessage string] cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [_authView clearCodes];
            }
        }];
        [aAlertView show];
    });
}

- (CMPNewPhoneCodeLoginProvider *)provider {
    if (!_provider) {
        _provider = [[CMPNewPhoneCodeLoginProvider alloc] init];
    }
    return _provider;
}

@end
