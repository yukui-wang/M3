//
//  UIImage+RTL.m
//  CMPLib
//
//  Created by 程昆 on 2019/9/4.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "UIImage+RTL.h"
#import "UIView+RTL.h"

@implementation UIImage (RTL)

- (UIImage *)rtl_imageFlippedForRightToLeftLayoutDirection
{
    if ([UIView isRTL]) {
        return [UIImage imageWithCGImage:self.CGImage
                                   scale:self.scale
                             orientation:UIImageOrientationUpMirrored];
    }
    
    return self;
}

+ (UIImage *)imageNamedAutoRTL:(NSString *)name {
    return [[self imageNamed:name] rtl_imageFlippedForRightToLeftLayoutDirection];
}

@end
