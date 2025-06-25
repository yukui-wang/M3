//
//  UIButton+CMPButton.h
//  CMPCore
//
//  Created by youlin guo on 14-11-11.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBannerImageButtonFrame CGRectMake(0, 0, 45, 44)
#define kBannarButtonFrame CGRectMake(0, 0, 50, 35)
#define kBannerIconButtonFrame CGRectMake(0, 0, 42, 45)


#define kButtonImageAlignment_Left 1
#define kButtonImageAlignment_Center 2
#define kButtonImageAlignment_Right 3

typedef NS_ENUM(NSInteger, CMPButtonType) {
    CMPButtonTypeWithBgColorAndRadius,
    CMPButtonTypeWithText
};

@interface UIButton (CMPButton)

@property (nonatomic,copy)NSString *buttonId;

+ (UIButton *)buttonWithImageName:(NSString *)aImageName;
+ (UIButton *)buttonWithImage:(UIImage *)aImage;
+ (UIButton *)defualtButtonWithFrame:(CGRect)frame title:(NSString *)aTitle;
+ (UIButton *)buttonWithImageName:(NSString *)aImgName frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment;
/*
 modifyImage 是否修改按钮图片颜色，buttonWithImageName:frame:buttonImageAlignment:为默认修改
 */
+ (UIButton *)buttonWithImageName:(NSString *)aImgName frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment modifyImage:(BOOL)modifyImage;
+ (UIButton *)buttonWithImagePath:(NSString *)aImagePath frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment;
+ (UIButton *)buttonWithTitle:(NSString *)aTitle textColor:(UIColor *)textColor textSize:(CGFloat)textSize;

+ (UIButton *)blueButtonWithFrame:(CGRect)frame title:(NSString *)aTitle;
+ (UIButton *)greenButtonWithFrame:(CGRect)frame title:(NSString *)aTitle;
+ (CGFloat )widthForTitle:(NSString *)title  font:(CGFloat)font;
+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)aTitle;
+ (UIButton *)transparentButtonWithFrame:(CGRect)frame title:(NSString *)aTitle;
+ (UIButton *)cmp_buttonWithParamDic:(NSDictionary *)paramDic;

- (void)setButtonShadowColor:(UIColor *)shadowColor;
- (UIColor *)buttonShadowColor;
- (void)setButtonBackgroundColor:(UIColor *)backgroundColor;
- (UIColor *)buttonBackgroundColor;
- (void)setButtonActiveBackgroundColor:(UIColor *)activeBackgroundColor;
- (UIColor *)buttonActiveBackgroundColor;
- (void)setButtonSize:(CGSize)size;
- (CGSize )buttonSize;
- (void)setButtonActiveSize:(CGSize)size;
- (CGSize )buttonActiveSize;
- (void)setCmp_ButtonType:(CMPButtonType)buttonType;
- (CMPButtonType)cmp_ButtonType;

@end
