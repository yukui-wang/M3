//
//  UIView+Layout.h
//
//  Created by 谭真 on 15/2/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CMPOscillatoryAnimationToBigger,
    CMPOscillatoryAnimationToSmaller,
} CMPOscillatoryAnimationType;

@interface UIView (Layout)

@property (nonatomic) CGFloat CMP_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat CMP_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat CMP_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat CMP_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat CMP_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat CMP_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat CMP_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat CMP_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint CMP_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  CMP_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(CMPOscillatoryAnimationType)type;

@end
