//
//  BFImageUtils.h
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//  

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFImageUtils : NSObject

+ (CGRect)convertRectFrom:(CGRect)imageRect imageSize:(CGSize)imageSize detectRect:(CGRect)detectRect;

+ (UIImage *)getImageResourceForName:(NSString *)name;

@end
