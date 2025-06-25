//
//  SyDrawView.m
//  SyCanvasViewTest
//
//  Created by admin on 12-3-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kDefualtBrushSize     5.0
#define kDefualtBrushSizePad  8.0
#define kDictionaryKeyPoints  @"points"
#define kDictionaryKeyColor   @"color"
#define kDictionaryKeySize    @"size"
#define kClearCanvasDelayTime 1.0
#define kDefualtImageSize     CGSizeMake(80.0, 80.0)


#import "GLCanvasView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GLCanvasView

@synthesize strokes = strokes_;
@synthesize abandonedStrokes = abandonedStrokes_;
@synthesize currentBrushColor = currentBrushColor_;
@synthesize currentBrushSize = currentBrushSize_;
@synthesize backgroundImage = backgroundImage_;
@synthesize screenImage = screenImage_;
@synthesize delegate = delegate_;
@synthesize imgeSize = imgeSize_;
@synthesize canvasType = canvasType_;
@synthesize contentFrame = contentFrame_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.backgroundColor = [UIColor clearColor];
		self.visibleFrame = self.bounds;
    }
    return self;
}

- (void)initData 
{
    self.strokes = [NSMutableArray array];
    self.abandonedStrokes = [NSMutableArray array];
    self.currentBrushSize = kDefualtBrushSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.currentBrushSize = kDefualtBrushSizePad;
    }
    self.currentBrushColor = [UIColor blackColor];
    self.imgeSize = kDefualtImageSize;
    self.canvasType = kCanvasTypeGraffiti;
    self.contentFrame = CGRectZero;
}

- (void)dealloc 
{
    [backgroundImage_ release];
	[screenImage_ release];
    [strokes_ removeAllObjects];
	[strokes_ release];
    [abandonedStrokes_ removeAllObjects];
	[abandonedStrokes_ release];
	[currentBrushColor_ release];
    [super dealloc];
}

- (void)addStroke:(CGPoint)point
{
    NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
	NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
	[dictStroke setObject:arrayPointsInStroke forKey:kDictionaryKeyPoints];
	[dictStroke setObject:self.currentBrushColor forKey:kDictionaryKeyColor];
	[dictStroke setObject:[NSNumber numberWithFloat:self.currentBrushSize] forKey:kDictionaryKeySize];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	[self.strokes addObject:dictStroke];
    if (self.strokes.count <= 1) {
        contentFrame_.origin.x = point.x;
        contentFrame_.origin.y = point.y;
        contentFrame_.size.width = point.x;
        contentFrame_.size.height = point.y;
    }
    else {
        [self refreshContentFrame:point];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.canvasType == kCanvasTypeHandPaint) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishDraw) object:nil];
    }
    // add by guoyl at 20130606
    if ([self.delegate respondsToSelector:@selector(canvasViewDidStartDraw:)]) {
        [self.delegate canvasViewDidStartDraw:self];
    }
    // add end
    NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
	NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
	[dictStroke setObject:arrayPointsInStroke forKey:kDictionaryKeyPoints];
	[dictStroke setObject:self.currentBrushColor forKey:kDictionaryKeyColor];
	[dictStroke setObject:[NSNumber numberWithFloat:self.currentBrushSize] forKey:kDictionaryKeySize];
	
	CGPoint point = [[touches anyObject] locationInView:self];
	/*if (point.x < _visibleFrame.origin.x || point.x > _visibleFrame.origin.x + _visibleFrame.size.width || point.y < _visibleFrame.origin.y || point.y > _visibleFrame.origin.y + _visibleFrame.size.height) {
		return;
	}*/
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	[self.strokes addObject:dictStroke];
    if (self.strokes.count <= 1) {
        contentFrame_.origin.x = point.x;
        contentFrame_.origin.y = point.y;
        contentFrame_.size.width = point.x;
        contentFrame_.size.height = point.y;
    }
    else {
        [self refreshContentFrame:point];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
	/*if (point.x < _visibleFrame.origin.x || point.x > _visibleFrame.origin.x + _visibleFrame.size.width || point.y < _visibleFrame.origin.y || point.y > _visibleFrame.origin.y + _visibleFrame.size.height) {
		return;
	}*/
	CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];
	NSMutableArray *arrayPointsInStroke = [[self.strokes lastObject] objectForKey:kDictionaryKeyPoints];
	[arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	CGRect rectToRedraw = CGRectMake(\
									 ((prevPoint.x>point.x)?point.x:prevPoint.x)-currentBrushSize_,\
									 ((prevPoint.y>point.y)?point.y:prevPoint.y)-currentBrushSize_,\
									 fabs(point.x-prevPoint.x)+2*currentBrushSize_,\
									 fabs(point.y-prevPoint.y)+2*currentBrushSize_\
									 );
    
	[self setNeedsDisplayInRect:rectToRedraw];
    [self refreshContentFrame:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.canvasType == kCanvasTypeHandPaint) {
        NSDictionary *aDict = [self.strokes lastObject];
        if (self.strokes.count == 1 && [[aDict objectForKey:kDictionaryKeyPoints] count] == 1) {
            [self.delegate canvasView:self touchesEnded:touches withEvent:event];
            [self clearCanvas];
        }
        else {
            [self performSelector:@selector(didFinishDraw) withObject:nil afterDelay:kClearCanvasDelayTime];
        }
    }
}

- (BOOL)isTap 
{
    NSDictionary *aDict = [self.strokes lastObject];
    if (self.strokes.count == 1 && [[aDict objectForKey:kDictionaryKeyPoints] count] == 1) {
        [self clearCanvas];
        return YES;
    }
    return NO;
}

- (void)drawRect:(CGRect)rect
{	
    if (self.strokes) {
		int arraynum = 0;
		for (NSDictionary *dictStroke in self.strokes) {
			NSArray *arrayPointsInstroke = [dictStroke objectForKey:kDictionaryKeyPoints];
			UIColor *color = [dictStroke objectForKey:kDictionaryKeyColor];
			float size = [[dictStroke objectForKey:kDictionaryKeySize] floatValue];
			[color set];		
			UIBezierPath *pathLines = [UIBezierPath bezierPath];
			CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
			[pathLines moveToPoint:pointStart];
			for (int i = 0; i < (arrayPointsInstroke.count - 1); i++) {
				CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
				[pathLines addLineToPoint:pointNext];
			}
			pathLines.lineWidth = size;
			pathLines.lineJoinStyle = kCGLineJoinRound;
			pathLines.lineCapStyle = kCGLineCapRound;
			[pathLines stroke];
			arraynum++;
		}
	}
}

- (void)refreshContentFrame:(CGPoint)point
{
    if (contentFrame_.origin.x > point.x) {
        contentFrame_.origin.x = point.x;
    }
    if (contentFrame_.size.width < point.x) {
        contentFrame_.size.width = point.x;
    }
    if (contentFrame_.origin.y > point.y) {
        contentFrame_.origin.y = point.y;
    }
    if (contentFrame_.size.height < point.y) {
        contentFrame_.size.height = point.y;
    }
}

- (IBAction)clearCanvas 
{
    [self.strokes removeAllObjects];
	[self.abandonedStrokes removeAllObjects];
	[self setNeedsDisplay];
    self.screenImage = nil;
    self.backgroundImage = nil;
    self.contentFrame = CGRectZero;
}

- (void)didFinishDraw
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(canvasView:didFinishDrawWithStrokes:)]) {
        [self.delegate canvasView:self didFinishDrawWithStrokes:self.strokes];
    }
    [self clearCanvas];
    if ([self.delegate respondsToSelector:@selector(canvasViewDidFinishDraw:)]) {
        [self.delegate canvasViewDidFinishDraw:self];
    }
}

- (UIImage *)screenImage
{
    //    UIImage *aImage = nil;
    //    UIGraphicsBeginImageContext(self.bounds.size);
    //	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
    //	aImage = UIGraphicsGetImageFromCurrentImageContext();
    //	UIGraphicsEndImageContext();
    //    return aImage;
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    CGRect f = contentFrame_;
    f.size.width += contentFrame_.origin.x;
    f.size.height = self.frame.size.height;
    UIGraphicsBeginImageContextWithOptions(f.size, 0, [UIScreen mainScreen].scale);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    //[view.layer drawInContext:currnetContext];
    [self.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)undo 
{
	if ([self.strokes count] > 0) {
		NSMutableDictionary *dictAbandonedStroke = [self.strokes lastObject];
		[self.abandonedStrokes addObject:dictAbandonedStroke];
		[self.strokes removeLastObject];
		[self setNeedsDisplay];
	}
}

- (IBAction)redo 
{
	if ([self.abandonedStrokes count] > 0) {
		NSMutableDictionary *dictReusedStroke = [self.abandonedStrokes lastObject];
		[self.strokes addObject:dictReusedStroke];
		[self.abandonedStrokes removeLastObject];
		[self setNeedsDisplay];
	}
}

@end
