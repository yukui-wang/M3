//
//  CMPTheme.m
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/29.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import "CMPTheme.h"
#import <CMPLib/CMPThemeManager.h>

@implementation CMPTheme

- (UIColor *)maskViewBackgroundColor {
    return [UIColor cmp_colorWithName:@"mask-bgc"];
}

- (UIColor *)alertBackgroundColor {
    return [UIColor cmp_colorWithName:@"white-bg"];
}

- (UIColor *)alertAllButtonTitleColor {
    return [UIColor cmp_colorWithName:@"theme-fc"];
}

- (UIFont *)alertAllButtionTitleFont {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
}

- (UIColor *)alertAllBodyLineColor {
    return [UIColor cmp_colorWithName:@"cmp-line"];
}

- (UIColor *)alertButtonLineColor {
    return [UIColor cmp_colorWithName:@"cmp-line"];
}


- (CGFloat)alertMessageFont {
    return 16;
}

- (UIColor *)alertCancelColor {
    return [UIColor cmp_colorWithName:@"desc-fc"];
   
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
