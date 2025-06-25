//
//  UITabBar+badge.m
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import "UITabBar+badge.h"
#import <CMPLib/CMPConstant.h>

static const NSInteger kCMPTabBarBadgeTag = 888;

@implementation UITabBar (badge)

//显示小红点
- (void)showBadgeOnItemIndex:(int)index {
    if (index >= self.items.count) {
        return;
    }
    
    // 如果之前添加过，直接设置hidden为NO
    UIView *icon = [self __iconViewWithIndex:index];
    for (UIView *subView in icon.subviews) {
        if (subView.tag == kCMPTabBarBadgeTag) {
            subView.hidden = NO;
            return;
        }
    }
    
    // 新建小红点
    UIView *badgeView = [[UIView alloc] init];
    badgeView.tag = kCMPTabBarBadgeTag;
    badgeView.layer.cornerRadius = 5;//圆形
    badgeView.backgroundColor = UIColorFromRGB(0xff5c5c);
    badgeView.frame = CGRectMake(icon.cmp_width - 5, 0, 9, 9);
    [icon addSubview:badgeView];
}

// 隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index {
    UIView *icon = [self __iconViewWithIndex:index];
    for (UIView *subView in icon.subviews) {
        if (subView.tag == kCMPTabBarBadgeTag) {
            subView.hidden = YES;
        }
    }
}

// 获取图标所在View
- (UIView *)__iconViewWithIndex:(int)index {
    UITabBarItem *item = self.items[index];
    //解决<UITabBarButton 0x149e82620> valueForUndefinedKey:]: this class is not key value coding-compliant for the key _info的bug
    UIView *tabBarButton = [item valueForKeyPath:@"_view"];
    if (@available(iOS 13.0, *)) {
//        UIView *icon = [tabBarButton valueForKeyPath:@"_info"];
//        return icon;
        return nil;
    }else {
        UIView *icon = [tabBarButton valueForKeyPath:@"_info"];
        return icon;
    }
    
}

@end
