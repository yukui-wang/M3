//
//  UIImage+SyImage.h
//  M1Core
//
//  Created by guoyl on 12-11-6.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CMPImage)
// 拉伸图片
- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets;
- (UIImage *)cmp_scaleToSize:(CGSize)size;
- (UIImage *)addTextWithBottom:(NSString *)text size:(CGSize)size;
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur;
//解决UIImage图片旋转
- (UIImage *)fixOrientation;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageFromColor:(UIColor *)color withSize:(CGSize)size;
+ (UIImage *)imageWithTop:(NSString *)tImgStr center:(NSString *)cImgStr bottom:(NSString *)bImgStr size:(CGSize)size;
//裁切图片
+ (UIImage*)imageWithClipImage:(UIImage*)image inRect:(CGRect)rect;
//压缩图片（kb为单位），返回image
+(UIImage *)imageWithCompressImage:(UIImage *)image toKbSize:(NSUInteger)kb;
- (NSData *)compressQualityWithLengthLimit:(NSInteger)maxLength;
//压缩图片（kb为单位），返回data
+(NSData *)dataWithCompressImage:(UIImage *)image toKbSize:(NSUInteger)kb;
+ (UIImage *)textFieldBackgorundWithSize:(CGSize)size;

/**
 根据Bundle名与文件名获取图片，推荐用该方法替代imageNamed:,可以自动释放不使用的图片
 */
+ (UIImage *)imageWithName:(NSString *)name type:(NSString *)type inBundle:(NSString *)bundle;

/**
 同+ (UIImage *)imageNamed:(NSString *)name type:(NSString *)type inBundle:(NSString *)bundle;
 type默认为png
 */
+ (UIImage *)imageWithName:(NSString *)name inBundle:(NSString *)bundle;

/**
 改变图片颜色

 @param tintColor 需要改变的颜色
 @return 修改后的图片
 */
- (UIImage *)cmp_imageWithTintColor:(UIColor *)tintColor;

/**
 改变图片透明度
 
 @param alpha 透明度 0.0 ~ 1.0
 @return 修改后的图片
 */
- (UIImage*)imageByApplyingAlpha:(CGFloat)alpha;

//图片拉伸到指定大小
- (UIImage *)resizedToSize:(CGSize)size;


/// 返回UIImage占用的内存大小
- (NSInteger)cmp_imgMemorySize;

-(UIImage*)imageWithCornerRadius:(CGFloat)radius;

@end
