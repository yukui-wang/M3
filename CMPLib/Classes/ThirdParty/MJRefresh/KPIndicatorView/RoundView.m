//
//  RoundView.m
//  Animation
//
//  Created by kunpo on 16/3/18.
//  Copyright © 2016年 kunpo. All rights reserved.
//

#import "RoundView.h"

@implementation RoundView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if (!self.viewColor) {
        self.viewColor = [UIColor redColor];
    }
    [self.viewColor set];
 
    UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineJoinRound;
    
    [[UIColor orangeColor] setStroke]; //设置描边，需要在[aPath stroke];前面，如果没有的话不显示。并且会不显示线色
    [aPath fill];

}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com