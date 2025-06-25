//
//  CMPBaseLoginView.m
//  M3
//
//  Created by wujiansheng on 2020/4/26.
//

#import "CMPBaseLoginView.h"

@implementation CMPBaseLoginView
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)attributesDictionary {
    return @{NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"sup-fc2"],
             NSFontAttributeName : [UIFont systemFontOfSize:16.f]};
}
- (UIColor *)textColor {
    return [UIColor cmp_colorWithName:@"cont-fc"];
}

- (void)setup {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
    if (!_accountTF) {
        _accountTF = [[CMPLoginTextField alloc] init];
        _accountTF.textField.textColor = [self textColor];
        _accountTF.textField.returnKeyType = UIReturnKeyNext;
        _accountTF.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _accountTF.textField.keyboardType = UIKeyboardTypeDefault;
        _accountTF.textField.delegate = self;
        _accountTF.textField.font = [UIFont boldSystemFontOfSize:16.f];
        [self addSubview:_accountTF];
    }
}

- (void)shouldRefreshVerification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRefreshVerification)]) {
        [self.delegate shouldRefreshVerification];
    }
}
- (void)shouldLogin {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldLogin)]) {
        [self.delegate shouldLogin];
    }
}

- (void)setupVerificationImg:(UIImage *)image {
    
}
- (void)textFieldTextDidChangeNoti:(NSNotification *)noti {
}

- (BOOL)verificationCodeRequired {
    return NO;
}

@end
