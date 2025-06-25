//
//  CMPUserLoginView.m
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#import "CMPUserLoginView.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPLoginDBProvider.h>
#define kTextFieldH  44.f

@interface CMPUserLoginView (){
}
@property(nonatomic, copy)NSString *loginName;
@end

@implementation CMPUserLoginView

- (void)setup {
    [super setup];
    UIColor *textColor = [self textColor];
    if (!_pwdTF) {
        //登陆密码输入框
        _pwdTF = [[CMPLoginTextField alloc] init];
        _pwdTF.textField.textColor = textColor;
        _pwdTF.textField.secureTextEntry = YES;
        _pwdTF.textField.returnKeyType = UIReturnKeyGo;
        _pwdTF.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwdTF.textField.delegate = self;
        _pwdTF.textField.font = [UIFont boldSystemFontOfSize:16.f];
        [self addSubview:_pwdTF];
    }
    
    //图片验证码输入框
    if (!_imgVerificaitionTF) {
        _imgVerificaitionTF = [[CMPLoginTextField alloc] init];
        _imgVerificaitionTF.textField.textColor = textColor;
        _imgVerificaitionTF.textField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:_imgVerificaitionTF];
    }
    
    if (!_imgVerificationImgBtn) {
        _imgVerificationImgBtn = [[UIButton alloc] init];
        [_imgVerificationImgBtn addTarget:self action:@selector(verificationViewClicked) forControlEvents:UIControlEventTouchUpInside];
        _imgVerificaitionTF.rightView = _imgVerificationImgBtn;
    }
    _isShowImgVerificaitionTF = NO;
    _isShowImgVerificaitionTF = [CMPCore sharedInstance].firstShowValidateCode;//判断0次验证码
    _imgVerificaitionTF.hidden = !_isShowImgVerificaitionTF;
    
   
    NSDictionary *attributesDictionary = [self attributesDictionary];
    NSString *accountString = SY_STRING(@"login_account_placeholder");
    if (CMPCore.sharedInstance.isShowPhoneLogin ||
        CMPCore.sharedInstance.loginDBProvider.countOfServer == 0) {
        accountString = SY_STRING(@"login_account_phone_num");
    }
    _accountTF.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:accountString attributes:attributesDictionary];
    _pwdTF.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_password") attributes:attributesDictionary];
    _imgVerificaitionTF.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_verification") attributes:attributesDictionary];
}

- (CGFloat)viewHeight {
    return _isShowImgVerificaitionTF?212:158;
}

- (void)customLayoutSubviews {
    [_accountTF setFrame:CGRectMake(0, 30, self.width, 44)];
    [_pwdTF setFrame:CGRectMake(0, 84, self.width, 44)];
    [_imgVerificationImgBtn setFrame:CGRectMake(0, 0, 68.f, 44)];
    [_imgVerificaitionTF setFrame:CGRectMake(0, 138, self.width, 44)];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 放弃第一响应者
    [_pwdTF.textField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.accountTF.textField]) {
        [textField resignFirstResponder];
        [self.pwdTF.textField becomeFirstResponder];
    } else {
        [self shouldLogin];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.accountTF.textField]) {
        [self.pwdTF showCheckoutPwdBtn:NO];
    } else {
        if (self.pwdTF.text.length) {
            [self.pwdTF showCheckoutPwdBtn:YES];
        }
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([textField isEqual:self.pwdTF.textField]) {
    }
    return YES;
}

- (void)textFieldTextDidChangeNoti:(NSNotification *)noti {
    UITextField *tf = noti.object;
    NSString *text = tf.text;
    if ([tf isEqual:self.accountTF.textField]) {
        if ([CMPCore sharedInstance].firstShowValidateCode) {
            //如果需要输入验证码，则不去监听文本变化
            return;
        }
        NSString *tmpLoginName = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (self.isShowImgVerificaitionTF && [self.loginName isEqualToString: tmpLoginName]) {
            _imgVerificaitionTF.hidden = NO;
        }
        else {
            _imgVerificaitionTF.hidden = YES;
        }
    }
    else if([tf isEqual:self.pwdTF.textField]){
        BOOL isShown = text.length > 0;
        [self.pwdTF showCheckoutPwdBtn:isShown];
    }
}

- (BOOL)verificationCodeRequired {
    return self.isShowImgVerificaitionTF && !_imgVerificaitionTF.hidden;
}

- (void)verificationViewClicked {
    [self shouldRefreshVerification];
}

- (void)setupVerificationImg:(UIImage *)image {
    _isShowImgVerificaitionTF = YES;
    _imgVerificaitionTF.hidden = !_isShowImgVerificaitionTF;
    [_imgVerificationImgBtn setImage:image forState:UIControlStateNormal];
    [_imgVerificaitionTF layoutSubviews];
    self.loginName = _accountTF.text;
    _imgVerificaitionTF.text = @"";
}

@end

