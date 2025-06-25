//
//  CMPMSMLoginView.m
//  M3
//
//  Created by zy on 2022/2/14.
//

#import "CMPSMSLoginView.h"

@interface CMPSMSLoginView ()


@end



@implementation CMPSMSLoginView

@synthesize areaCode = _areaCode;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.userInteractionEnabled = YES;
    self.areaCode = @"+86";
    
    if (!_phoneTextField) {
        _phoneTextField = [[CMPLoginTextField alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        _phoneTextField.textField.placeholder = SY_STRING(@"login_phone");
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:_phoneTextField];
        [_phoneTextField showLeftView:YES];
    }
    
    if (!_smsCodeField) {
        _smsCodeField = [[CMPLoginTextField alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        _smsCodeField.textField.placeholder = SY_STRING(@"login_verification_code_can_not_be_null");
        _smsCodeField.textField.clearButtonMode = UITextFieldViewModeNever;
        [self addSubview:_smsCodeField];
        [_smsCodeField showRightSMSView:YES];
    }
}

- (void)setAreaCode:(NSString *)areaCode {
    _areaCode = areaCode;
    
}

- (NSString *)areaCode {
    return _areaCode;
}

- (NSString *)phoneNumber {
    return _phoneTextField.text;
}

- (NSString *)smsCode {
    return _smsCodeField.text;
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneTextField.text = phoneNumber;
}

- (void)setSmsCode:(NSString *)smsCode {
    _smsCodeField.text = smsCode;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_phoneTextField setFrame:CGRectMake(0, 30, self.width, 44)];
    [_smsCodeField setFrame:CGRectMake(0, _phoneTextField.cmp_bottom + 10, self.width, 44)];
}

- (CGFloat)viewHeight {
    return 158;
}

- (BOOL)isValidPhoneNumber {
    // 空
    if ([NSString isNull:self.phoneNumber]) {
        return NO;
    }
    
    // 国内长度不对
    BOOL isChina = [self.areaCode isEqualToString:@"+86"];
    if (isChina) {
        // 非11位
        if (self.phoneNumber.length != 11) {
            return NO;
        }
        // 非数字
        if (![NSString isNumber:self.phoneNumber]) {
            return NO;
        }
    }
    return YES;
}
@end
