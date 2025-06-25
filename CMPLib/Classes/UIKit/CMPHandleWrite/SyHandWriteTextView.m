//
//  SyTextView.m
//  SyCanvasViewTest
//
//  Created by admin on 12-4-19.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kDictionaryKeyPoints  @"points"
#define kDictionaryKeyColor   @"color"
#define kDictionaryKeySize    @"size"

#import "SyHandWriteTextView.h"
#import "UIImage+CMPImage.h"

@implementation SyHandWriteTextView
@synthesize strokes = strokes_;
@synthesize originalSize = originalSize_;
@synthesize scaleSize = scaleSize_;
@synthesize splitWidth = splitWidth_;
@synthesize key = key_;
@synthesize imageView = imageView_;

- (void)dealloc {
    self.strokes = nil;
    self.key = nil;
    [imageView_ release];
    imageView_ = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.strokes) {
        int arraynum = 0;
        for (NSDictionary *dictStroke in self.strokes) {
            NSArray *arrayPointsInstroke = [dictStroke objectForKey:kDictionaryKeyPoints];
            UIColor *color = [dictStroke objectForKey:kDictionaryKeyColor];
            [color set];
            UIBezierPath *pathLines = [UIBezierPath bezierPath];
            CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
            pointStart = [self scalePoint:pointStart];
            [pathLines moveToPoint:pointStart];
            for (int i = 0; i < (arrayPointsInstroke.count - 1); i++) {
                CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
                pointNext = [self scalePoint:pointNext];
                pointNext.x += 2;
                [pathLines addLineToPoint:pointNext];
            }
            pathLines.lineWidth = 2.0;
            pathLines.lineJoinStyle = kCGLineJoinRound;
            pathLines.lineCapStyle = kCGLineCapRound;
            [pathLines stroke];
            arraynum++;
        }
    }
//    self.strokes = nil;
}

- (CGPoint)scalePoint:(CGPoint)point 
{
    return CGPointMake((point.x - self.splitWidth)*_scale , point.y*_scale);
//    return CGPointMake(point.x/self.originalSize.width * self.scaleSize.width - self.splitWidth,
//                             point.y/self.originalSize.height * self.scaleSize.height - self.splitHeight);
}

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!imageView_) {
            imageView_ = [[UIImageView alloc] init];
            [self addSubview:imageView_];
        }
    }
    return self;
}

- (void)setupImage:(UIImage *)image size:(CGSize)size
{
    
    imageView_.frame = CGRectMake(0, 0, size.width, size.height);
    imageView_.image = image;
    //
    //    if ( [[UIScreen mainScreen] scale] == 2) {
    //         imageView_.image =  image;
    //    }
    //    else {
    //      imageView_.image =  [image scaleToSize:imageView_.frame.size];
    //    }
}
*/

@end
