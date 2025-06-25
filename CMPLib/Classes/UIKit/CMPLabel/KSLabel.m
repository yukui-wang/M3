//
//  KSLabel.m
//  XGiant
//
//  Created by Songu Kaku on 5/17/19.
//  Copyright © 2019 com.xinjucn. All rights reserved.
//

#import "KSLabel.h"

@interface KSLabel()
@property (nonatomic,strong) UIView *bgView;
@end

@implementation KSLabel


//下面三个方法用来初始化edgeInsets
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}


// 修改绘制文字的区域，edgeInsets增加bounds
-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    
    /*
     调用父类该方法
     注意传入的UIEdgeInsetsInsetRect(bounds, self.edgeInsets),bounds是真正的绘图区域
     */
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds,
                                                                 self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    //根据edgeInsets，修改绘制文字的bounds
    rect.origin.x -= self.edgeInsets.left;
    rect.origin.y -= self.edgeInsets.top;
    rect.size.width += self.edgeInsets.left + self.edgeInsets.right;
    rect.size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return rect;
}

//绘制文字
- (void)drawTextInRect:(CGRect)rect
{
    //令绘制区域为原始区域，增加的内边距区域不绘制
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}


//-(void)setTextColor:(UIColor *)textColor
//{
//    [super setTextColor:KSColorWithAdjustColor(textColor, [UIColor lightTextColor])];
//}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    if (_borderLayer && self.superview) {
//        [_borderLayer removeFromSuperlayer];
//        CGRect r = self.bounds;
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:r  byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomLeft)  cornerRadii:CGSizeMake(7, 7)];
//        _borderLayer.path = maskPath.CGPath;
//        _borderLayer.lineWidth = 1;
////        _borderLayer.strokeColor = [UIColor blueColor].CGColor;
//        _borderLayer.fillColor = [UIColor clearColor].CGColor;
////        if (!_bgView) {
////            _bgView = [[UIView alloc] init];
////            _bgView.backgroundColor = [UIColor clearColor];
////            _bgView.tag = 11;
////            [self.superview insertSubview:_bgView belowSubview:self];
////        }
//        _bgView.bounds = self.bounds;
//        _bgView.center = self.center;
//        [_bgView.layer addSublayer:_borderLayer];
//    }
//}

-(void)setBorderLayer:(CAShapeLayer *)borderLayer
{
    if (_borderLayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = borderLayer;
    if (!_borderLayer) {
        return;
    }
    CGRect r = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:r  byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomLeft)  cornerRadii:CGSizeMake(7, 7)];
    _borderLayer.path = maskPath.CGPath;
    _borderLayer.lineWidth = 1;
//        _borderLayer.strokeColor = [UIColor blueColor].CGColor;
    _borderLayer.fillColor = [UIColor clearColor].CGColor;
    
    if (!_bgView && self.superview) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.tag = 11;
        [self.superview insertSubview:_bgView belowSubview:self];
    }
    if (_bgView) {
        _bgView.bounds = self.bounds;
        _bgView.center = self.center;
        [_bgView.layer addSublayer:_borderLayer];
    }
}

@end
