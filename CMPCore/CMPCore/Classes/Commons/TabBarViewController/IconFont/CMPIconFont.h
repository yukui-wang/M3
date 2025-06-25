//
//  CMPIconFont.h
//  iconfont
//
//  Created by yang on 2017/2/13.
//  Copyright © 2017年 yang. All rights reserved.
//
#import "UIImage+CMPIconFont.h"
#import "CMPIconInfo.h"

#define CMPIconInfoMake(text, imageSize, imageColor) [CMPIconInfo iconInfoWithText:(text) size:imageSize color:imageColor]

@interface CMPIconFont : NSObject

+ (UIFont *)fontWithSize: (CGFloat)size;
+ (void)setFontName:(NSString *)fontName;

@end
