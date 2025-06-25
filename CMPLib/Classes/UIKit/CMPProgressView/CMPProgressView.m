//
//  UIProgressBar.h
//  
//
//  Created by xiangwei.ma
//  
//

#import "CMPProgressView.h"


@implementation CMPProgressView

@synthesize  minValue, maxValue, currentValue;
@synthesize lineColor, progressRemainingColor, progressColor;
@synthesize progress = _progress;

- (void)dealloc {
    [lineColor release];
    [progressColor release];
    [progressRemainingColor release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
	{
		minValue = 0;
		maxValue = 1;
		currentValue = 0;
		self.backgroundColor = [UIColor colorWithRed:(213.0/255.0) green:(213.0/255.0) blue:(213.0/255.0) alpha:1];
		lineColor = [[UIColor whiteColor] retain];
		progressColor = [[UIColor darkGrayColor] retain];
		progressRemainingColor = [[UIColor lightGrayColor] retain];
        
        self.layer.cornerRadius = 2;
//        self.layer.borderWidth = 0.6;
//        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.layer.masksToBounds = YES;
    }
    return self;
}

void drawLinearGradient(CGContextRef context,
                        CGRect rect,
                        CGColorRef startColor,
                        CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0,1.0}; //颜色所在位置
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor,(id)endColor, nil];//渐变颜色数组
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);//构造渐变
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    CGContextSaveGState(context);//保存状态，主要是因为下面用到裁剪。用完以后恢复状态。不影响以后的绘图
    CGContextAddRect(context, rect);//设置绘图的范围
    CGContextClip(context);//裁剪
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);//绘制渐变效果图
    CGContextRestoreGState(context);//恢复状态
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect
{
   //使用
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef startColor = [UIColor colorWithRed:(16.0/255.0) green:(156.0/255.0) blue:(238.0/255.0) alpha:1].CGColor;
    CGColorRef endColor = [UIColor colorWithRed:(65.0/255.0) green:(60.0/255.0) blue:(206.0/255.0) alpha:1].CGColor;
    float amount = (currentValue/(maxValue - minValue)) * (rect.size.width);
    CGRect paperRect = self.bounds;
    paperRect.size.width = amount;
    drawLinearGradient(context, paperRect, startColor, endColor);
}

-(void)setNewRect:(CGRect)newFrame 
{
	self.frame = newFrame;
	[self setNeedsDisplay];

}

-(void)setMinValue:(float)newMin
{
	minValue = newMin;
	[self setNeedsDisplay];

}

-(void)setMaxValue:(float)newMax
{
	maxValue = newMax;
	[self setNeedsDisplay];

}

-(void)setCurrentValue:(float)newValue
{
	currentValue = newValue;
//    NSLog(@"currentValue %f", newValue);
	[self setNeedsDisplay];
}

-(void)setLineColor:(UIColor *)newColor
{
	[newColor retain];
	[lineColor release];
	lineColor = newColor;
	[self setNeedsDisplay];

}

-(void)setProgressColor:(UIColor *)newColor
{
	[newColor retain];
	[progressColor release];
	progressColor = newColor;
	[self setNeedsDisplay];

}

-(void)setProgressRemainingColor:(UIColor *)newColor
{
	[newColor retain];
	[progressRemainingColor release];
	progressRemainingColor = newColor;
	[self setNeedsDisplay];

}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setCurrentValue:progress];
}

@end
