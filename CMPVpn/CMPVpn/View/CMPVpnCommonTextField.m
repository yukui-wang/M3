//
//  CMPVpnCommonTextField.m
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/8.
//

#import "CMPVpnCommonTextField.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>


@implementation CMPVpnCommonTextField

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
        [self cmp_setCornerRadius:6.f];
        [self addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField.alloc initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _textField.backgroundColor = UIColor.clearColor;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 10.f, self.height)];
        _textField.font = [UIFont systemFontOfSize:16.f];
        _textField.tintColor = [UIColor cmp_colorWithName:@"theme-fc"];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //关闭键盘首字母大写
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _textField;
}

@end
