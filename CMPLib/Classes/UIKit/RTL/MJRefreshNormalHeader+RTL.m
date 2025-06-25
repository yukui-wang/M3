//
//  MJRefreshNormalHeader+RTL.m
//  CMPLib
//
//  Created by 程昆 on 2019/9/5.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "MJRefreshNormalHeader+RTL.h"
#import "UIView+RTL.h"

@implementation MJRefreshNormalHeader (RTL)

+ (void)load {
    SOSwizzleInstanceMethod(self, @selector(placeSubviews), @selector(rtl_placeSubviews));
}

- (void)rtl_placeSubviews {
    if ([UIView isRTL]) {
        [self rtl_placeSubviews];
        [self.subviews makeObjectsPerformSelector:@selector(resetFrameToFitRTL)];
    } else {
        [self rtl_placeSubviews];
    }
}

@end
