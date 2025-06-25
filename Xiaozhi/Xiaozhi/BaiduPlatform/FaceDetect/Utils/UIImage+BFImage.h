//
//  UIImage+BFImage.h
//  M3
//
//  Created by wujiansheng on 2018/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (BFImage)
- (UIImage *)subImageAtRect:(CGRect)rect;
- (UIImage *)resizedToSize:(CGSize)size;
- (NSData *)dataWithCompress:(CGFloat)compress;

@end

NS_ASSUME_NONNULL_END
