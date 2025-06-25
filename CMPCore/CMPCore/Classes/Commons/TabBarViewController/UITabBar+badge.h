//
//  UITabBar+badge.h
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index;  //显示小红点
- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
