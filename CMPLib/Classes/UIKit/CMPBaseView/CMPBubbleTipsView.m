//
//  CMPBubbleTipsView.m
//  CMPLib
//
//  Created by MacBook on 2019/12/11.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPBubbleTipsView.h"
#import "UIView+CMPView.h"
#import "NSString+CMPString.h"

static CGFloat const ZLPopBubbleViewArcW = 20.f;
static CGFloat const ZLPopBubbleViewRectangleW = 8.f;
static CGFloat const ZLPopBubbleViewRectangleH = 8.f;

@implementation CMPBubbleTipsView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (!self.viewColor) {
        self.viewColor = [UIColor whiteColor];
    }
    [self drawBg];
}

/// 绘制带有阴影的图形
- (void)drawBg {
    //获取绘制上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *drawColor = self.viewColor;
    CGFloat cornerRadius = 14.f;
    CGFloat shapreLayerH = self.height - ZLPopBubbleViewRectangleH;
    
    if (self.cornerRadius) {
        cornerRadius = self.cornerRadius;
    }
    //绘制背景path
    UIBezierPath *drawPath = [UIBezierPath bezierPath];
    [drawPath moveToPoint:CGPointMake(0, cornerRadius)];
    //左下
    [drawPath addLineToPoint:CGPointMake(0, self.height - cornerRadius)];
    [drawPath addArcWithCenter:CGPointMake(cornerRadius, shapreLayerH - cornerRadius) radius:cornerRadius startAngle:-M_PI endAngle:(-M_PI_2)*3 clockwise:NO];
    //绘制三角形
    [drawPath addLineToPoint:CGPointMake(self.width - ZLPopBubbleViewArcW, shapreLayerH)];
    [drawPath addLineToPoint:CGPointMake(self.width - ZLPopBubbleViewArcW + ZLPopBubbleViewRectangleW/2.f, self.height)];
    [drawPath addLineToPoint:CGPointMake(self.width - ZLPopBubbleViewArcW + ZLPopBubbleViewRectangleW, shapreLayerH)];
    //右下
    [drawPath addLineToPoint:CGPointMake(self.width - cornerRadius, shapreLayerH)];
    [drawPath addArcWithCenter:CGPointMake(self.width - cornerRadius,shapreLayerH - cornerRadius) radius:cornerRadius startAngle:(-M_PI_2)*3 endAngle:0 clockwise:NO];
    //右上
    [drawPath addLineToPoint:CGPointMake(self.width, cornerRadius)];
    [drawPath addArcWithCenter:CGPointMake(self.width - cornerRadius, cornerRadius) radius:cornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
    //左上
    [drawPath addLineToPoint:CGPointMake(cornerRadius, 0)];
    [drawPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
     
    //等价于保存上下文
    CGContextSaveGState(context);
     
    //准备阴影
    CGColorRef shadow = drawColor.CGColor;
    CGSize shadowOffset = CGSizeZero;
    CGFloat shadowBlurRadius = 2.f;
     
    //此函数创建和应用阴影
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
     
    //绘制路径；它将带有一个阴影
    [drawColor setFill];
    [drawPath fill];
     
    //等价于重载上下文
    CGContextRestoreGState(context);
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

@end
