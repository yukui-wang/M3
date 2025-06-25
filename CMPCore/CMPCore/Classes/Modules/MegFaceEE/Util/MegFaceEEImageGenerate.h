//
//  MegFaceEEImageGenerate.h
//  MegFaceEE
//
//  Created by Megvii on 2023/2/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEImageGenerate : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)frameImageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

+ (UIColor *)getHighlightColor:(UIColor *)color;

+ (UIColor *)modifyAlphaWithColor:(UIColor *)color alpha:(CGFloat)alpha;

+ (UIImage *)imageFillWithImage:(UIImage *)srcImage color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
