//
//  CMPTopCornerView.m
//  M3
//
//  Created by MacBook on 2019/10/25.
//

#import "CMPTopCornerView.h"
#import <CMPLib/UIView+CMPView.h>

@implementation CMPTopCornerView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    UIColor *drawColor = UIColor.whiteColor;
    CGFloat cornerRadius = 14.f;
    //如果自定义颜色没有的话，就默认是白色
    if (self.customBgColor) {
        drawColor = [self.customBgColor copy];
    }
    if (self.cornerRadius) {
        cornerRadius = self.cornerRadius;
    }
    //绘制背景path
    UIBezierPath *drawPath = [UIBezierPath bezierPath];
    [drawPath moveToPoint:CGPointMake(0, cornerRadius)];
    [drawPath addLineToPoint:CGPointMake(0, self.height)];
    [drawPath addLineToPoint:CGPointMake(self.width, self.height)];
    [drawPath addLineToPoint:CGPointMake(self.width, cornerRadius)];
    [drawPath addArcWithCenter:CGPointMake(self.width - cornerRadius, cornerRadius) radius:cornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
    [drawPath addLineToPoint:CGPointMake(cornerRadius, 0)];
    [drawPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
    [drawColor set];
    [drawPath fill];
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
