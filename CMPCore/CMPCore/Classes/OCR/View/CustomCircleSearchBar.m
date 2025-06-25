//
//  CustomCircleSearchBar.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/30.
//

#import "CustomCircleSearchBar.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/Masonry.h>
static CGFloat const searchIconW = 20.0;
// icon与placeholder间距
static CGFloat const iconSpacing = 10.0;
// 占位文字的字体大小
static CGFloat const placeHolderFont = 14.0;


@interface CustomCircleSearchBar()<UITextFieldDelegate>

@property (nonatomic, assign) CGFloat placeholderWidth;

@end

@implementation CustomCircleSearchBar
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (instancetype)initWithPlaceholder:(NSString *)placeholder size:(CGSize)size{
    if (self = [super init]) {
        // 设置背景图片
//        UIImage *backImage = [self imageWithColor:UIColor.whiteColor];
//        [self setBackgroundImage:backImage];
        CGFloat height = 30;
        CGFloat leftMargin = 14.0;
        
        UIView *view = [self valueForKey:@"searchField"];
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            _textfield = field;
            field.delegate = self;
            // 重设field的frame
            field.frame = CGRectMake(leftMargin, (size.height - height)/2.0, size.width-leftMargin*2, height);
            [field mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self).offset(0);
                make.width.mas_equalTo(size.width-leftMargin*2);
                make.height.mas_equalTo(height);
            }];
            [field setBackgroundColor:[UIColor cmp_specColorWithName:@"input-bg"]];
            field.textColor = [UIColor cmp_specColorWithName:@"sup-fc2"];
            field.borderStyle = UITextBorderStyleNone;
            field.layer.cornerRadius = height/2.0;
            field.layer.masksToBounds = YES;
            field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            field.returnKeyType = UIReturnKeySearch;
            field.clearButtonMode = UITextFieldViewModeWhileEditing;
            // 设置占位文字字体颜色
            field.attributedPlaceholder = [[NSAttributedString alloc]initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor cmp_specColorWithName:@"sup-fc2"],NSFontAttributeName:[UIFont systemFontOfSize:placeHolderFont]}];
            [field layoutIfNeeded];
            if (@available(iOS 11.0, *)) {
                // 先默认居中placeholder
                [self setPositionAdjustment:UIOffsetMake((field.frame.size.width-self.placeholderWidth)/2, 0) forSearchBarIcon:UISearchBarIconSearch];
            }
        }
//        UIImage *image = [UIImage imageNamed:@"ocr_card_search_icon"];
//        [self setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        
        self.backgroundImage = [UIImage imageWithColor:[UIColor cmp_specColorWithName:@"white-bg1"]];
        self.backgroundColor = [UIColor cmp_specColorWithName:@"white-bg1"];
        UIImage *bgImage = [[UIImage imageWithName:@"searchbar_bg" inBundle:@"offlineContact"] cmp_imageWithTintColor:[UIColor cmp_specColorWithName:@"input-bg"]];
        UIImage *iconImage = [[UIImage imageWithName:@"searchbar_icon" inBundle:@"offlineContact"] cmp_imageWithTintColor:[UIColor cmp_specColorWithName:@"sup-fc2"]];
        [self setSearchFieldBackgroundImage:bgImage forState:UIControlStateNormal];
        [self setImage:iconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
// 开始编辑的时候重置为靠左
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // 继续传递代理方法
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    if (@available(iOS 11.0, *)) {
        [self setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
    return YES;
}
// 结束编辑的时候设置为居中

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        [self.delegate searchBarShouldEndEditing:self];
    }
    if (@available(iOS 11.0, *)) {
        if (textField.text.length <= 0) {
            [self setPositionAdjustment:UIOffsetMake((textField.frame.size.width-self.placeholderWidth)/2, 0) forSearchBarIcon:UISearchBarIconSearch];
        }
    }
    return YES;
}

// 计算placeholder、icon、icon和placeholder间距的总宽度
- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [self.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:placeHolderFont]} context:nil].size;
        _placeholderWidth = size.width + iconSpacing + searchIconW;
    }
    return _placeholderWidth;
}

@end
