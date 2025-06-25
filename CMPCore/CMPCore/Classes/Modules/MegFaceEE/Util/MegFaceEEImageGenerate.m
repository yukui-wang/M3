//
//  MegFaceEEImageGenerate.m
//  MegFaceEE
//
//  Created by Megvii on 2023/2/15.
//

#import "MegFaceEEImageGenerate.h"

@implementation MegFaceEEImageGenerate

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    float scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(CGSizeMake(size.width * scale, size.height * scale));
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width *scale, size.height *scale) cornerRadius:cornerRadius * scale];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width*scale, size.height*scale);
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextClip(ctx);
    CGContextFillRect(ctx, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)frameImageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    return [self frameImageWithColor:color size:size cornerRadius:cornerRadius lineWidth:1];
}

+ (UIImage *)frameImageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius lineWidth:(int)lineWidth {
    float scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(CGSizeMake(size.width * scale, size.height * scale));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(lineWidth * scale, lineWidth * scale, size.width * scale - lineWidth * scale * 2, size.height * scale - lineWidth * scale * 2) cornerRadius:cornerRadius * scale];
    path.lineWidth = lineWidth * scale;
    [color set];
    [path stroke];
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIColor *)getHighlightColor:(UIColor *)color {
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat b = 0;
    CGFloat alpha = 0;
    [color getHue:&h saturation:&s brightness:&b alpha:&alpha];
    UIColor *highlightColor = [UIColor colorWithHue:h saturation:s brightness:(b*100.0-10)/100.0 alpha:1.0];
    return highlightColor;
}

+ (UIColor *)modifyAlphaWithColor:(UIColor *)color alpha:(CGFloat)alpha {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat a;
    [color getRed:&red green:&green blue:&blue alpha:&a];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
}

+ (UIImage *)imageFillWithImage:(UIImage *)srcImage color:(UIColor *)color {
    CGFloat color_r;
    CGFloat color_g;
    CGFloat color_b;
    CGFloat color_a;
    [color getRed:&color_r green:&color_g blue:&color_b alpha:&color_a];
    unsigned char * rgbaData = [self RGBABufferWithImage:srcImage];
    CGFloat width = srcImage.size.width;
    CGFloat height = srcImage.size.height;
    unsigned char *data = (unsigned char *)malloc(width*height*4);
    for (int i = 0; i< width*height; i++) {
        NSInteger alpha = rgbaData[i*4+3];
        NSInteger r;
        NSInteger g;
        NSInteger b;
        if(alpha == 0) {
            r = (unsigned char)(color_r*255.0);
            g = (unsigned char)(color_g*255.0);
            b = (unsigned char)(color_b*255.0);
            alpha = (unsigned char)255.0;
        } else {
            r = rgbaData[i*4+0];
            g = rgbaData[i*4+1];
            b = rgbaData[i*4+2];
        }
        data[i*4] = r;
        data[i*4+1] = g;
        data[i*4+2] = b;
        data[i*4+3] = alpha;
    }
    UIImage *image = [self convertBitmapRGBA8ToUIImage:data imageWidth:width imageHeight:height];
    free(rgbaData);
    free(data);
    return image;
}

+ (unsigned char *)RGBABufferWithImage:(UIImage *)image {
    int RGBA = 4;
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*)malloc(width*height*4*sizeof(unsigned char));
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return rawData;
}

+ (UIImage *)convertBitmapRGBA8ToUIImage:(unsigned char *)buffer imageWidth:(int)imageWidth imageHeight:(int)imageHeight {
    size_t bufferLength = imageWidth * imageHeight * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * imageWidth;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef iref = CGImageCreate(imageWidth,
                                    imageHeight,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,    // data provider
                                    NULL,        // decode
                                    YES,            // should interpolate
                                    renderingIntent);
    
    uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
    if(pixels == NULL) {
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 imageWidth,
                                                 imageHeight,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef,
                                                 bitmapInfo);
    
    if(context == NULL) {
        free(pixels);
        pixels = NULL;
    }
    
    UIImage *image = nil;
    if(context) {
        
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, imageWidth, imageHeight), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        image = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    if(pixels) {
        free(pixels);
    }
    return image;
}

@end
