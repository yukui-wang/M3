//
//  UIButton+CMPButton.m
//  CMPCore
//
//  Created by youlin guo on 14-11-11.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "UIButton+CMPButton.h"
#import "UIImageView+WebCache.h"
#import "UIImage+CMPImage.h"
#import <objc/runtime.h>
#import "UIImage+JCColor2Image.h"
#import "UIColor+Hex.h"
#import "UIButton+WebCache.h"
#import "NSString+CMPString.h"
#import "CMPCachedUrlParser.h"
#import "NSObject+Thread.h"
#import "CMPThemeManager.h"
#import "UIImage+RTL.h"
#import "SOSwizzle.h"

@implementation UIButton (CMPButton)

//1  2
//2  1

//2  3
//3  2

+ (void)load {
    SOSwizzleInstanceMethod([UIButton class], @selector(layoutSubviews),@selector(cmp_button_layoutSubviews));
}

+ (UIButton *)buttonWithImageName:(NSString *)aImageName
{
	if (!aImageName)  return nil;
	UIImage *img = [UIImage imageNamed:aImageName];
	return [UIButton buttonWithImage:img];
}

+ (UIButton *)buttonWithImage:(UIImage *)aImage
{
	if (!aImage) {
		NSLog(@"%@", @"can't create a button, beacuse the image is nil");
		return nil;
	}
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setImage:aImage forState:UIControlStateNormal];
	aButton.frame = CGRectMake(0, 0, aImage.size.width, aImage.size.height);
	return aButton;
}

+ (CGFloat )widthForTitle:(NSString *)title  font:(CGFloat)font
{
	return  [title sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByWordWrapping].width+8;
}

+ (UIButton *)defualtButtonWithFrame:(CGRect)frame title:(NSString *)aTitle
{
	UIImage *aImage = [[UIImage imageNamed:@"banner_btn_banner_def"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *aSelectImage = [[UIImage imageNamed:@"banner_btn_banner_pre"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setBackgroundImage:aImage forState:UIControlStateNormal];
	[aButton setBackgroundImage:aSelectImage forState:UIControlStateSelected];
	CGFloat width = [UIButton widthForTitle:aTitle font:14.0f];
	if (width >frame.size.width) {
		frame.size.width = width;
	}
	aButton.frame = frame;
	[aButton setTitle:aTitle forState:UIControlStateNormal];
	[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	aButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	return aButton;
}

+ (UIButton *)buttonWithImageName:(NSString *)aImgName frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment {
    return [UIButton buttonWithImageName:aImgName frame:aFrame buttonImageAlignment:aImageAlignment modifyImage:YES];
}

+ (UIButton *)buttonWithImageName:(NSString *)aImgName frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment modifyImage:(BOOL)modifyImage {
    aImageAlignment = kButtonImageAlignment_Center;
    if (!aImgName) return nil;
    UIImage *aImg = [UIImage imageNamed:aImgName];
    if (modifyImage) {
        aImg = [aImg cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
    }
    if (!aImg) return nil;
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:aImg forState:UIControlStateNormal];
    aButton.frame = aFrame;
    CGSize imgSize = aImg.size;
    CGSize btnSize = aFrame.size;
    CGFloat y = btnSize.height/2 - imgSize.height/2;
    CGFloat x = btnSize.width/2 - imgSize.width/2;
    if (aImageAlignment == kButtonImageAlignment_Left) {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, 0, y, x*2)];
    }
    else if (aImageAlignment == kButtonImageAlignment_Center) {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, x, y, x)];
    }
    else {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, x*2, y, 0)];
    }
    //    [aButton setBackgroundImage:[UIImage imageNamed:@"banner_icon_pre.png"] forState:UIControlStateHighlighted];
    return aButton;
}

+ (UIButton *)buttonWithImagePath:(NSString *)aImagePath frame:(CGRect)aFrame buttonImageAlignment:(NSInteger)aImageAlignment
{
    aImageAlignment = kButtonImageAlignment_Center;
    if (!aImagePath) return nil;
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:aImagePath] options:SDWebImageHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error) {
            [self dispatchAsyncToChild:^{
                UIImage *scaleImage = [[image cmp_scaleToSize:CGSizeMake(22, 22)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [aButton setImage:scaleImage forState:UIControlStateNormal];
                });
            }];
        }
    }];
    aButton.frame = aFrame;
    CGSize imgSize = CGSizeMake(22, 22);
    CGSize btnSize = aFrame.size;
    CGFloat y = btnSize.height/2 - imgSize.height/2;
    CGFloat x = btnSize.width/2 - imgSize.width/2;
    if (aImageAlignment == kButtonImageAlignment_Left) {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, 0, y, x*2)];
    }
    else if (aImageAlignment == kButtonImageAlignment_Center) {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, x, y, x)];
    }
    else {
        [aButton setImageEdgeInsets:UIEdgeInsetsMake(y, x*2, y, 0)];
    }
    //    [aButton setBackgroundImage:[UIImage imageNamed:@"banner_icon_pre.png"] forState:UIControlStateHighlighted];
    return aButton;
}

+ (UIButton *)buttonWithTitle:(NSString *)aTitle textColor:(UIColor *)textColor textSize:(CGFloat)textSize
{
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitleColor:textColor forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:textSize weight:UIFontWeightMedium];
    [aButton sizeToFit];
    aButton.cmp_width += 18;
    return aButton;
}


+ (UIButton *)blueButtonWithFrame:(CGRect)frame title:(NSString *)aTitle
{
    UIImage *aImage = [[UIImage imageNamed:@"banner_btn_banner_b_def"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *aSelectImage = [[UIImage imageNamed:@"banner_btn_banner_b_pre"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:aImage forState:UIControlStateNormal];
    [aButton setBackgroundImage:aSelectImage forState:UIControlStateSelected];
    CGFloat width = [UIButton widthForTitle:aTitle font:14.0f];
    if (width >frame.size.width) {
        frame.size.width = width;
    }
    aButton.frame = frame;
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    return aButton;
}

+ (UIButton *)cmp_buttonWithParamDic:(NSDictionary *)paramDic {
    NSString *idKey = [paramDic objectForKey:@"id"];
    NSString *backgroundColor = [paramDic objectForKey:@"backgroundColor"];
    NSString *activeBackgroundColor = [paramDic objectForKey:@"activeBackgroundColor"];
    NSString *backgroundImage = [paramDic objectForKey:@"backgroundImage"];
    NSString *activeBackgroundImage = [paramDic objectForKey:@"activeBackgroundImage"];
    NSString *text = [paramDic objectForKey:@"text"];
    NSString *activeText = [paramDic objectForKey:@"activeText"];
    NSString *textColor = [paramDic objectForKey:@"textColor"];
    NSString *activeTextColor = [paramDic objectForKey:@"activeTextColor"];
    NSString *textSizeString = [paramDic objectForKey:@"textSize"];
    NSString *activeTextSizeString = [paramDic objectForKey:@"activeTextSize"];
   
    //OA-212021【UE应用检查】底导航中有签到的时候，切换至签到内容显示不出来，m3会闪退
    if([textSizeString isKindOfClass:[NSNumber class]]) {
        textSizeString = [(NSNumber *)textSizeString stringValue];
    }
    if([activeTextSizeString isKindOfClass:[NSNumber class]]) {
        activeTextSizeString = [(NSNumber *)activeTextSizeString stringValue];
    }
    
    CGFloat textSizeF = 20.f;
    CGFloat activeTextSizeF = 20.f;
    if (textSizeString.length) {
        textSizeF = textSizeString.floatValue;
    }
    if (activeTextSizeString.length) {
       activeTextSizeF = activeTextSizeString.floatValue;
    }
    
    NSDictionary *attrTitleAttributesDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:textSizeF], NSForegroundColorAttributeName : CMP_HEXSTRINGCOLOR(textColor)};
    NSDictionary *activeAttrTitleAttributesDic = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:activeTextSizeF], NSForegroundColorAttributeName : CMP_HEXSTRINGCOLOR(activeTextColor)};
    NSAttributedString *attrTitle = [NSAttributedString.alloc initWithString:text attributes:attrTitleAttributesDic];
    NSAttributedString *activeAttrTitle = [NSAttributedString.alloc initWithString:activeText attributes:activeAttrTitleAttributesDic];
    
    UIButton *button = [[UIButton alloc] init];
    [button setAttributedTitle:attrTitle forState:UIControlStateNormal];
    [button setAttributedTitle:activeAttrTitle forState:UIControlStateSelected];
    
    CGSize textSize = CGSizeZero;
    CGSize activeTextSize = CGSizeZero;
    CGSize contentMaxSizes = CGSizeMake(100, MAXFLOAT);
    textSize = [text boundingRectWithSize:contentMaxSizes options:NSStringDrawingUsesLineFragmentOrigin attributes:attrTitleAttributesDic context:nil].size;
    activeTextSize = [activeText boundingRectWithSize:contentMaxSizes options:NSStringDrawingUsesLineFragmentOrigin attributes:activeAttrTitleAttributesDic context:nil].size;
    
    if(![NSString isNull:backgroundColor] && ![NSString isNull:activeBackgroundColor]){
        textSize = CGSizeMake(textSize.width + 20, 30);
        activeTextSize = CGSizeMake(activeTextSize.width + 20, 30);
        UIImage *aBackgroundImage = [UIImage cmp_createImageWithColor:CMP_HEXSTRINGCOLOR(backgroundColor) addCornerWithRadius:15 andSize:textSize];
        UIImage *aActiveBackgroundImage = [UIImage cmp_createImageWithColor:CMP_HEXSTRINGCOLOR(activeBackgroundColor) addCornerWithRadius:15 andSize:activeTextSize];
        [button setBackgroundImage:aBackgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:aActiveBackgroundImage forState:UIControlStateSelected];
        button.buttonShadowColor = [CMP_HEXSTRINGCOLOR(activeBackgroundColor) colorWithAlphaComponent:0.5];
        button.buttonBackgroundColor = CMP_HEXSTRINGCOLOR(backgroundColor);
        button.buttonActiveBackgroundColor = CMP_HEXSTRINGCOLOR(activeBackgroundColor);
        button.buttonSize = textSize;
        button.buttonActiveSize = activeTextSize;
        button.cmp_size = textSize;
        button.cmp_ButtonType = CMPButtonTypeWithBgColorAndRadius;
    } else {
        button.buttonSize = textSize;
        button.buttonActiveSize = activeTextSize;
        button.cmp_size = textSize;
        button.cmp_ButtonType = CMPButtonTypeWithText;
    }
    if(![NSString isNull:backgroundImage] && ![NSString isNull:activeBackgroundImage] ){
        if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:backgroundImage]]) {
            backgroundImage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:backgroundImage]];
        }
        if ([CMPCachedUrlParser chacedUrl:[NSURL URLWithString:activeBackgroundImage]]) {
            activeBackgroundImage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:activeBackgroundImage]];
        }
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:backgroundImage] forState:UIControlStateNormal];
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:activeBackgroundImage] forState:UIControlStateNormal];
    }
    
    button.buttonId = idKey;
    
    return button;
}

+ (UIButton *)transparentButtonWithFrame:(CGRect)frame title:(NSString *)aTitle
{
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [aButton setBackgroundImage:aImage forState:UIControlStateNormal];
    //    [aButton setBackgroundImage:aSelectImage forState:UIControlStateSelected];
    CGFloat width = [UIButton widthForTitle:aTitle font:14.0f];
    if (width >frame.size.width) {
        frame.size.width = width;
    }
    aButton.frame = frame;
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    return aButton;
}

+ (UIButton *)greenButtonWithFrame:(CGRect)frame title:(NSString *)aTitle
{
    UIImage *aImage = [[UIImage imageNamed:@"banner_btn_banner_g_def"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *aSelectImage = [[UIImage imageNamed:@"banner_btn_banner_g_pre"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:aImage forState:UIControlStateNormal];
    [aButton setBackgroundImage:aSelectImage forState:UIControlStateSelected];
    CGFloat width = [UIButton widthForTitle:aTitle font:14.0f];
    if (width >frame.size.width) {
        frame.size.width = width;
    }
    aButton.frame = frame;
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    return aButton;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)aTitle
{
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = [UIButton widthForTitle:aTitle font:14.0f];
    if (width >frame.size.width) {
        frame.size.width = width;
    }
    aButton.frame = frame;
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    return aButton;
}

- (void)setButtonId:(NSString *)buttonId {
    objc_setAssociatedObject(self, @selector(setButtonId:), buttonId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)buttonId{
    return  objc_getAssociatedObject(self, @selector(setButtonId:));
}

- (void)setButtonShadowColor:(UIColor *)shadowColor {
    objc_setAssociatedObject(self, @selector(setButtonShadowColor:), shadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)buttonShadowColor {
    return  objc_getAssociatedObject(self, @selector(setButtonShadowColor:));
}

- (void)setButtonBackgroundColor:(UIColor *)backgroundColor {
    objc_setAssociatedObject(self, @selector(setButtonBackgroundColor:), backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)buttonBackgroundColor {
    return  objc_getAssociatedObject(self, @selector(setButtonBackgroundColor:));
}

- (void)setButtonActiveBackgroundColor:(UIColor *)activeBackgroundColor {
    objc_setAssociatedObject(self, @selector(setButtonActiveBackgroundColor:), activeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)buttonActiveBackgroundColor {
    return  objc_getAssociatedObject(self, @selector(setButtonActiveBackgroundColor:));
}

- (void)setButtonSize:(CGSize)size {
    objc_setAssociatedObject(self, @selector(setButtonSize:), NSStringFromCGSize(size) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize )buttonSize {
    NSString *sizeStr = objc_getAssociatedObject(self, @selector(setButtonSize:));
    return CGSizeFromString(sizeStr);
}
- (void)setButtonActiveSize:(CGSize)size {
    objc_setAssociatedObject(self, @selector(setButtonActiveSize:), NSStringFromCGSize(size) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize )buttonActiveSize {
    NSString *sizeStr = objc_getAssociatedObject(self, @selector(setButtonActiveSize:));
       return CGSizeFromString(sizeStr);
}

- (void)setCmp_ButtonType:(CMPButtonType)buttonType {
    objc_setAssociatedObject(self, @selector(setCmp_ButtonType:), @(buttonType) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CMPButtonType)cmp_ButtonType {
    NSNumber *buttonType = objc_getAssociatedObject(self, @selector(setCmp_ButtonType:));
    return buttonType.integerValue;
}

- (void)cmp_button_layoutSubviews {
    [self cmp_button_layoutSubviews];

    if (self.layoutSubviewsCallback) {
        self.layoutSubviewsCallback(self);
    }
}


@end
