//
//  CMPLoginViewTextField.m
//  M3
//
//  Created by CRMO on 2018/9/4.
//

#import "CMPLoginViewTextField.h"
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIView+RTL.h>

@interface CMPLoginViewTextField()<UITextFieldDelegate>

@property (assign, nonatomic) CMPLoginViewTextFieldType type;
@property (assign, nonatomic) BOOL showPassword;
@property (assign, nonatomic) BOOL showPasswordSwitch;
@property (strong, nonatomic) UIButton *showPwdButton;
@property (strong, nonatomic) UIView *rightOverlayView;
@property (strong, nonatomic) NSArray *blankLocations;

@end

@implementation CMPLoginViewTextField

#pragma mark-
#pragma mark- Init

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame placeHolder:nil type:CMPLoginViewTextFieldTypeUsername];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero placeHolder:nil type:CMPLoginViewTextFieldTypeUsername];
}

- (instancetype)initWithFrame:(CGRect)frame
                         placeHolder:(nullable NSString *)placeHolder
                         type:(CMPLoginViewTextFieldType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.attributedPlaceholder =
        [[NSAttributedString alloc] initWithString:placeHolder
                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium],
                                                     NSForegroundColorAttributeName : [UIColor colorWithHexString:@"d4d4d4"]}];
        self.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        self.type = type;
        self.rightOverlayView.hidden = YES;
        self.delegate = self;
    }
    return self;
}

- (instancetype)initWithPlaceHolder:(NSString *)placeHolder
                               type:(CMPLoginViewTextFieldType)type {
    return [self initWithFrame:CGRectNull placeHolder:placeHolder type:type];
}

#pragma mark-
#pragma mark- UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // 输入文字大于0时，展示右边操作按钮
    [self updateRightViewWithText:toBeString];
    
    // 处理手机号格式，自动加空格
    if (self.type == CMPLoginViewTextFieldTypePhone) {
        if ([_textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [_textFieldDelegate textField:self shouldChangeCharactersInRange:range replacementString:string];
        }
        return [[self class] inputTextField:textField shouldChangeCharactersInRange:range replacementString:string blankLocations:self.blankLocations limitCount:70];
    }
    
    BOOL result = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        result = [_textFieldDelegate textField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    return result;
}

- (NSArray *)blankLocations {
    if (!_blankLocations) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@3];
        NSInteger i = 3+5;
        while (i <= 70) {
            [arr addObject:[NSNumber numberWithInteger:i]];
            i+=5;
        }
        _blankLocations = [arr copy];
    }
    return _blankLocations;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateRightViewWithText:textField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.rightOverlayView.hidden = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_textFieldDelegate textFieldDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(CMPLoginViewTextField *)textField {
    BOOL result = YES;
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        result = [_textFieldDelegate textFieldShouldReturn:textField];
    }
    return result;
}

#pragma mark-
#pragma mark- 类型样式

- (void)setType:(CMPLoginViewTextFieldType)type {
    _type = type;
    switch (type) {
        case CMPLoginViewTextFieldTypeUsername:
            [self usernameType];
            break;
        case CMPLoginViewTextFieldTypePassword:
            [self passwordType];
            break;
        case CMPLoginViewTextFieldTypePhone:
            [self phoneType];
            break;
        case CMPLoginViewTextFieldTypeVerification:
            [self verificationType];
            break;
        default:
            break;
    }
}

- (void)usernameType {
//    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType = UIReturnKeyNext;
    
    if (!self.rightOverlayView) {
        CGFloat iconHeight = 18;
        CGFloat iconWidth = iconHeight;
        
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconHeight)];
        [clearButton addTarget:self action:@selector(tapClearButton) forControlEvents:UIControlEventTouchUpInside];
        UIImage *clearButtonImage = [UIImage imageWithName:@"login_input_clear" type:@"png" inBundle:@"CMPLogin"];
        [clearButton setImage:clearButtonImage forState:UIControlStateNormal];
        
        self.rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconHeight)];
        [self.rightOverlayView addSubview:self.showPwdButton];
        [self.rightOverlayView addSubview:clearButton];
        
        [self.showPwdButton resetFrameToFitRTL];
        [clearButton resetFrameToFitRTL];
    }
    
    self.rightView = self.rightOverlayView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)phoneType {
    [self usernameType];
    self.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)passwordType {
    self.returnKeyType = UIReturnKeySend;
    
    if (!self.rightOverlayView) {
        CGFloat iconHeight = 18;
        CGFloat iconWidth = iconHeight;
        CGFloat iconSpacing = 20;
        
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconHeight)];
        [clearButton addTarget:self action:@selector(tapClearButton) forControlEvents:UIControlEventTouchUpInside];
        UIImage *clearButtonImage = [UIImage imageWithName:@"login_input_clear" type:@"png" inBundle:@"CMPLogin"];
        [clearButton setImage:clearButtonImage forState:UIControlStateNormal];
        
        self.showPwdButton = [[UIButton alloc] initWithFrame:CGRectMake(iconWidth + iconSpacing, 0, iconWidth, iconHeight)];
        self.showPassword = NO;
        [self.showPwdButton addTarget:self action:@selector(tapShowPwdButton) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iconWidth * 2 + iconSpacing, iconHeight)];
        [self.rightOverlayView addSubview:self.showPwdButton];
        [self.rightOverlayView addSubview:clearButton];
        
        [self.showPwdButton resetFrameToFitRTL];
        [clearButton resetFrameToFitRTL];
    }
    
    self.rightView = self.rightOverlayView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)verificationType {
    [self usernameType];
    self.returnKeyType = UIReturnKeyDefault;
}

#pragma mark-
#pragma mark 按钮点击事件

- (void)tapClearButton {
    self.text = @"";
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    [self updateRightViewWithText:@""];
    if ([_textFieldDelegate respondsToSelector:@selector(textFieldDidClear:)]) {
        [_textFieldDelegate textFieldDidClear:self];
    }
}

- (void)tapShowPwdButton {
    self.showPassword = !self.showPassword;
}

- (void)setShowPassword:(BOOL)showPassword {
    if (_showPassword && !showPassword) {
        self.showPasswordSwitch = YES;
    }
    _showPassword = showPassword;
    self.secureTextEntry = !showPassword;
    NSString *text = self.text;
    self.text = nil;
    self.text = text;
    
    NSString *imageName = self.showPassword ? @"login_input_pwd_show" : @"login_input_pwd_hide";
    UIImage *iamge = [UIImage imageWithName:imageName type:@"png" inBundle:@"CMPLogin"];
    [self.showPwdButton setImage:iamge forState:UIControlStateNormal];
    [self.showPwdButton setImage:iamge forState:UIControlStateHighlighted];
}

- (void)updateRightViewWithText:(NSString *)text {
    if ([text length] > 0) {
        self.rightOverlayView.hidden = NO;
    } else {
        self.rightOverlayView.hidden = YES;
    }
}

#pragma mark-
#pragma mark Setter

- (void)setText:(NSString *)text {
    [super setText:text];
    // UITextField 调用text的set方法不会发送UIControlEventEditingChanged通知
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark-
#pragma mark 手机号格式处理

+ (BOOL)inputTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
     replacementString:(NSString *)string
        blankLocations:(NSArray<NSNumber *> *)blankLocation
            limitCount:(NSInteger)limitCount {
    // 不为空，并且不是字符串不处理
    if ([NSString isNotNull:string] && ![NSString isNumber:string]) {
        return NO;
    }
    NSString *text = textField.text;
    if ([string isEqualToString:@""]) { // 删除
        if (range.length == 1) {// 删除一位
            if (range.location == text.length - 1) { // location是下标 此句表示删除的最后一位
                return YES;
            } else { // 不是最后一位
                NSInteger offset = range.location;
                if (range.location < text.length && [text characterAtIndex:range.location] == ' ' && [textField.selectedTextRange isEmpty]) {
                    [textField deleteBackward];
                    offset --;
                }
                [textField deleteBackward];
                textField.text = [self insertString:textField.text withBlankLocations:blankLocation];
                //设置光标的位置
                [self setCursorLocation:textField withOffset:offset];
                return NO;
            }
        } else if (range.length > 1) {
            BOOL lastOne = NO;
            if (range.location + range.length == text.length) {//是否是最后一位
                lastOne = YES;
            }
            [textField deleteBackward];
            textField.text = [self insertString:textField.text withBlankLocations:blankLocation];
            NSInteger offset = range.location;
            if (lastOne) {
                // 最后一个不需要设置光标
            } else {
                [self setCursorLocation:textField withOffset:offset];
            }
            return NO;
        } else {
            return YES;
        }
    } else if (string.length > 0) {
        if ([self removeBlankString:textField.text].length + string.length - range.length > limitCount ) {// [self whiteSpaseString:textField.text].length 目前textfield中有的 内容的长度 string.length 即将加入的内容的长度 range.length
            return NO;
        }
    }
    [textField insertText:string];
    textField.text = [self insertString:textField.text withBlankLocations:blankLocation];
    NSInteger offset = range.location + string.length;
    
    for (NSNumber *location in blankLocation) {
        if (range.location == location.integerValue) {
            offset++;
        }
    }
    
    [self setCursorLocation:textField withOffset:offset];
    return NO;
}

// 在指定的位置添加空格
+ (NSString*)insertString:(NSString*)string withBlankLocations:(NSArray<NSNumber *>*)locations {
    if (!string) {
        return nil;
    }
    NSMutableString* mutableString = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@" " withString:@""]];
    for (NSNumber *location in locations) {
        if (mutableString.length > location.integerValue) {
            [mutableString insertString:@" " atIndex:location.integerValue];
        }
    }
    return  mutableString;
}

// 去除空格
+ (NSString*)removeBlankString:(NSString*)string {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 设置光标
+ (void)setCursorLocation:(UITextField *)textField withOffset:(NSInteger) offset{
    UITextPosition *newPostion = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
    textField.selectedTextRange = [textField textRangeFromPosition:newPostion toPosition:newPostion];
}

@end
