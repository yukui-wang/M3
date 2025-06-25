//
//  UIImage+BFImage.m
//  M3
//
//  Created by wujiansheng on 2018/12/19.
//

#import "UIImage+BFImage.h"

@implementation UIImage (BFImage)
- (UIImage *)subImageAtRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    return subImage;
}

- (UIImage *)resizedToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (NSData *)dataWithCompress:(CGFloat)compress {
    NSData* data = UIImageJPEGRepresentation(self, compress);
    if (data == nil) {
        data = UIImagePNGRepresentation(self);
    }
    return data;
}
@end
