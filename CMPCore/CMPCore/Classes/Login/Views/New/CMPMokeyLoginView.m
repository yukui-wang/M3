//
//  CMPMokeyLoginView.m
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#import "CMPMokeyLoginView.h"
#define kTextFieldH  44.f

@interface CMPMokeyLoginView (){
    BOOL _isShowImgVerificaitionTF;//是否显示图片验证码
}
@end

@implementation CMPMokeyLoginView

- (void)setup {
    [super setup];
    _accountTF.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:SY_STRING(@"login_mokey_login_tips") attributes:self.attributesDictionary];
}

- (CGFloat)viewHeight {
    return 158;
}

- (void)customLayoutSubviews {
    [_accountTF setFrame:CGRectMake(0, 30, self.width, 44)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self shouldLogin];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.accountTF showCheckoutPwdBtn:NO];
}

@end

