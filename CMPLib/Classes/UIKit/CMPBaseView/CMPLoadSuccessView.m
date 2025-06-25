//
//  CMPLoadSuccessView.m
//  CMPLib
//
//  Created by CRMO on 2019/5/24.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPLoadSuccessView.h"

@implementation CMPLoadSuccessView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    CAShapeLayer *tickLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:tickLayer];
    CGFloat width = 38;
    CGFloat height = 27;
    tickLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    tickLayer.lineWidth = 5;
    tickLayer.lineCap = kCALineCapRound;
    tickLayer.lineJoin = kCALineCapRound;
    tickLayer.fillColor = [UIColor clearColor].CGColor;
    tickLayer.strokeColor = [UIColor whiteColor].CGColor;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, 13)];
    [path addLineToPoint:CGPointMake(12, height)];
    [path addLineToPoint:CGPointMake(width, 0)];
    tickLayer.path = [path CGPath];
    [self.layer addSublayer:tickLayer];
}

@end
