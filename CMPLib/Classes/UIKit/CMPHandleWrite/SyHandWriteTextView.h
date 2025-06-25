//
//  SyTextView.h
//  SyCanvasViewTest
//
//  Created by admin on 12-4-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyHandWriteTextView : UIView {
    NSArray  *strokes_;
    CGSize   originalSize_;
    CGSize   scaleSize_;
    CGFloat  splitWidth_;
    NSString *key_;
    UIImageView *imageView_;
}

@property (nonatomic, retain) NSArray *strokes;
@property (nonatomic, assign) CGSize  originalSize;
@property (nonatomic, assign) CGSize  scaleSize;
@property (nonatomic, assign) CGFloat splitWidth;
@property (nonatomic, copy) NSString  *key;

@property (nonatomic, assign) CGFloat splitHeight;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) CGFloat scale;

//- (void)setupImage:(UIImage *)image size:(CGSize)size;

- (CGPoint)scalePoint:(CGPoint)point;

@end
