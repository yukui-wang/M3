//
//  CMPWaterMarkUtil.m
//  CMPLib
//
//  Created by CRMO on 2018/7/2.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import "CMPWaterMarkUtil.h"
#import "UIColor+Hex.h"

@implementation CMPWaterMarkStyle

+ (instancetype)defaultStyle {
    CMPWaterMarkStyle *style = [[CMPWaterMarkStyle alloc] init];
    style.rotationAngle = M_PI / 9;
    style.textFont = [UIFont systemFontOfSize:14];
    style.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    style.textAlpha = 0.15;
    style.paddingX = 45;
    style.paddingY = 10;
    return style;
}

@end

@interface CMPWaterMarkUtil()

@property (strong, nonatomic) CMPWaterMarkStyle *style;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *colorCache;

@end

@implementation CMPWaterMarkUtil

- (instancetype)initWithText:(NSString *)text Style:(CMPWaterMarkStyle *)style {
    if (self = [super init]) {
        self.text = text;
        self.style = style;
    }
    return self;
}

- (void)addWaterMarkToView:(UIView *)view {
    view.backgroundColor = self.colorCache;
}

- (UIImage *)imageWithText:(NSString *)text {
    CGFloat rotationAngle = self.style.rotationAngle;
    UIFont *font = self.style.textFont;
    CGFloat paddingX = self.style.paddingX;
    CGFloat paddingY = self.style.paddingY;
    
    CGSize textSize = [text sizeWithFontSize:font defaultSize:CGSizeZero];
    CGFloat viewWidth = textSize.width * cos(rotationAngle) + textSize.height * sin(rotationAngle);
    CGFloat viewHeight = textSize.width * sin(rotationAngle) + textSize.height * cos(rotationAngle);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth + paddingX * 2, viewHeight + paddingY * 2)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    label.center = view.center;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.style.textColor;
    label.alpha = self.style.textAlpha;
    label.font = font;
    label.text = text;
    label.transform = CGAffineTransformMakeRotation(-rotationAngle);
    [view addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark-
#pragma mark Getter

- (UIColor *)colorCache {
    if (!_colorCache) {
        UIImage *backgroudImage = [self imageWithText:self.text];
        _colorCache = [[UIColor alloc] initWithPatternImage:backgroudImage];
    }
    return _colorCache;
}

@end
