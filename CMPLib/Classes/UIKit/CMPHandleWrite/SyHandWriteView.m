//
//  SyHandPaintView.m
//  SyCanvasViewTest
//
//  Created by admin on 12-3-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kLayoutLaterTypeForward     1
#define kLayoutLaterTypeBack        2
#define kSubViewsDictKeyFormat      @"%ld"
#define kAnimationIdBlinking        @"opacity"
#define kTextSpaceWidth             5.0f
#define kAnimationRepeatCount       1

#import "SyHandWriteView.h"
#import "GLCursorView.h"
#import <QuartzCore/QuartzCore.h>
#import "SyColorPickerView.h"
#import "SyHandWriteTextView.h"
#import "UIView+CMPView.h"
#import "UIImage+CMPImage.h"
#import "CMPConstant.h"

@interface SyHandWriteView ()<CAAnimationDelegate> {
	UIImageView *_visibleImageView;
}

@property (nonatomic, assign)CGRect visibleFrame;
@property (nonatomic, assign) CGSize    initSize;

- (void)setupProperty;


@end

@implementation SyHandWriteView

@synthesize rowHeight = rowHeight_;
@synthesize columnWidth = columnWidth_;
@synthesize textColor = textColor_;
@synthesize textSize = textSize_;
@synthesize delegate = delegate_;
@synthesize currentRow = currentRow_;
@synthesize touchesBeganTime = touchesBeganTime_;
@synthesize moveView = moveView_;
@synthesize touchPoint = touchPoint_;
@synthesize shouldTextHelp;
@synthesize shouldImageHelp;
@synthesize textHelpView = textHelpView_;
@synthesize imageHelpView = imageHelpView_;
@synthesize uniqueId = uniqueId_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setupWithInitSize:(CGSize )aInitSize
{
    self.initSize = aInitSize;
    CGFloat aStartX = (self.width - aInitSize.width)/2;
    if (aStartX < 0) {
        aStartX = 0;
    }
    self.visibleFrame = CGRectMake(aStartX, 0, aInitSize.width, self.height);
    currentX_ = self.visibleFrame.origin.x;
    [self setupProperty];
    subViewsDict_ = [[NSMutableDictionary alloc] init];
    NSString *aImgName = @"CMPHandleWrite.bundle/bg_m_world.png";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        aImgName = @"CMPHandleWrite.bundle/bg_m_world_pad.png";
    }
    CGFloat visibleWidth = MIN(self.width, self.height)*0.8;
    CGSize aSize = CGSizeMake(visibleWidth, visibleWidth);
    UIImage *aImage = [UIImage imageNamed:aImgName];
    _visibleImageView = [[UIImageView alloc] initWithImage:aImage];
    _visibleImageView.userInteractionEnabled = NO;
    _visibleImageView.frame = CGRectMake(self.width/2 - aSize.width/2, self.height - aSize.height - 30, aSize.width , aSize.height);
    [self addSubview:_visibleImageView];
    
    canvasView_ = [[GLCanvasView alloc] initWithFrame:_visibleImageView.frame];
    canvasView_.delegate = self;
    canvasView_.canvasType = kCanvasTypeHandPaint;
    canvasView_.imgeSize = CGSizeMake(rowHeight_, columnWidth_);
    
    CGRect f = _visibleImageView.frame;
    f.origin.x += 5;
    f.origin.y += 5;
    f.size.height -= 10;
    f.size.width -= 10;
    canvasView_.visibleFrame =  f;
    [self addSubview:canvasView_];
    
    cursorView_  = [[GLCursorView alloc] initWithFrame:CGRectMake(currentX_, 0.0f, 0.0f, 50.f)];
    [self addSubview:cursorView_];
    
    shouldDrawLine_ = YES;
    imageViews_ = [[NSMutableArray alloc] init];
    
    subViews_ = [[NSMutableArray alloc] init];
    removedSubViews_ = [[NSMutableArray alloc] init];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
}

- (void)reloadWithInitSize {
    if (self.initSize.width == 0) {
        return;
    }
    CGFloat aStartX = (self.width - self.initSize.width)/2;
    if (aStartX < 0) {
        aStartX = 0;
    }
    CGFloat startXChange = self.visibleFrame.origin.x - aStartX;
    self.visibleFrame = CGRectMake(aStartX, 0, self.width - aStartX*2, self.height);

    currentX_ -= startXChange;
    if (currentX_ < aStartX) {
        currentX_ = aStartX;
    }
    
    CGFloat visibleWidth = MIN(self.width, self.height)*0.8;
    CGSize aSize = CGSizeMake(visibleWidth, visibleWidth);
    _visibleImageView.frame = CGRectMake(self.width/2 - aSize.width/2, self.height - aSize.height - 30, aSize.width , aSize.height);
    canvasView_.frame =_visibleImageView.frame;
    
    CGRect f = _visibleImageView.frame;
    f.origin.x += 5;
    f.origin.y += 5;
    f.size.height -= 10;
    f.size.width -= 10;
    canvasView_.visibleFrame =  f;
    if (subViews_.count == 0) {
        [self refreshCursorView];
    }
    else {
        
        for (SyHandWriteTextView *textView in  subViews_) {
            if([textView isKindOfClass:[SyHandWriteTextView class]] ||
               [textView isKindOfClass:[UIImageView class]]) {
                CGRect f = textView.frame;
                f.origin.x -= startXChange;
                textView.frame = f;
            }
        }
        
        UIView *view = subViews_.lastObject;
        CGRect aFrame = cursorView_.frame;
        aFrame.size.height = rowHeight_;
        aFrame.origin.x = CGRectGetMaxX(view.frame);
        aFrame.origin.y = view.originY;
        cursorView_.frame = aFrame;
    }
    
    
}

- (void)setupProperty
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.backgroundColor = [UIColor colorWithRed:0.952 green:0.917 blue:0.803 alpha:1.0];
    }
    else {
        self.backgroundColor = [UIColor colorWithRed:0.949 green:0.921 blue:0.8 alpha:1.0];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [canvasView_ clearCanvas];
    UIView *aView = touchView_;
    touchView_ = nil;
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint point = [gestureRecognizer locationInView:self];
    currentRow_ = point.y/rowHeight_;
    if (aView && [aView isKindOfClass:[SyHandWriteTextView class]]) {
        SyHandWriteTextView *textView = (SyHandWriteTextView *)aView;
        currentX_ = textView.frame.origin.x;
        NSString *aKey = textView.key;
        NSMutableArray *array = [subViewsDict_ objectForKey:aKey];
        currentIndex_ = [array indexOfObject:textView];
    }
    else {
        if (point.x < self.visibleFrame.origin.x) {
            currentX_ = self.visibleFrame.origin.x;
        }
        else if (point.x > self.visibleFrame.origin.x + self.visibleFrame.size.height) {
            currentX_ = self.visibleFrame.origin.x + self.visibleFrame.size.height;
        }
        else {
            currentX_ = point.x;
        }
        [self correctCurrentIndex];
    }
    [self refreshCursorView];
	if ([self.delegate respondsToSelector:@selector(handWriteViewDidFinishDraw:)]) {
        [self.delegate handWriteViewDidFinishDraw:self];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    if (newSuperview) {
        [self startBlinkAnimation];
    }
    else {
        [self stopBlinkAnimation];
    }
    [super willMoveToSuperview:newSuperview];
}

- (void)removeFromSuperview {
    [self stopBlinkAnimation];
    [super removeFromSuperview];
}

- (void)dealloc 
{   
    canvasView_.delegate = nil;
    [canvasView_ removeFromSuperview];
    [canvasView_ release];
    canvasView_ = nil;
    
    shouldContinueBlinking_ = NO;
    [cursorView_.layer removeAllAnimations];
    [cursorView_ removeFromSuperview];
    [cursorView_ release];
    cursorView_ = nil;
    
    [subViewsDict_ removeAllObjects];
    [subViewsDict_ release];
    subViewsDict_ = nil;
    
    [textColor_ release];
    textColor_ = nil;
    
    [imageViews_ removeAllObjects];
    [imageViews_ release];
    imageViews_ = nil;
    
    [touchesBeganTime_ release];
    
    [moveView_ release];
    moveView_ = nil;
    
    [subViews_ removeAllObjects];
    [subViews_ release];
    subViews_ = nil;
    
    [removedSubViews_ removeAllObjects];
    [removedSubViews_ release];
    removedSubViews_ = nil;
    
    [textHelpView_ release];
    textHelpView_ = nil;
    
    [imageHelpView_ release];
    imageHelpView_ = nil;
    
    [uniqueId_ release];
    uniqueId_ = nil;
	
	[_visibleImageView release];
	_visibleImageView = nil;
    
    [super dealloc];
}

- (void)setTextColor:(UIColor *)aTextColor 
{
    canvasView_.currentBrushColor = aTextColor;
    [textColor_ release];
    textColor_ = [aTextColor retain];
}

- (UIColor *)textColor
{
    return canvasView_.currentBrushColor;
}

- (void)setTextSize:(CGFloat)aTextSize 
{
    canvasView_.currentBrushSize = aTextSize;
    textSize_ = aTextSize;
}

- (void)drawRect:(CGRect)rect
{
    rect = self.visibleFrame;
    CGFloat aWidth = rect.size.width;
    CGFloat aHeight = rect.size.height;
    CGFloat aStartX = rect.origin.x;
    
    rowCount_ = aHeight/rowHeight_;
    columnCount_ = aWidth/columnWidth_;
    if (shouldDrawLine_) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetShouldAntialias(context, YES);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            CGContextSetRGBStrokeColor(context, 0.709, 0.64, 0.415, 1); 
        }
        else {
            CGContextSetRGBStrokeColor(context, 0.709, 0.65, 0.411, 1); 
        }
        for (NSUInteger i = 1; i <= rowCount_; i ++) {
            CGContextMoveToPoint(context, aStartX, i*rowHeight_);
            CGContextAddLineToPoint(context, aStartX + aWidth, i*rowHeight_);
        }
        CGContextStrokePath(context);
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reloadWithInitSize];
    [self setNeedsDisplay];
}

- (void)canvasView:(GLCanvasView *)aCanvasView didFinishDrawWithStrokes:(NSArray *)aStrokes
{
    //    [canvasView_ removeFromSuperview];
    CGFloat aScale = rowHeight_/canvasView_.visibleFrame.size.height;
//    UIImage *image = [aCanvasView screenImage];//[aCanvasView imageWithUIView:aCanvasView];
//    image = [image scaleToSize:CGSizeMake(image.size.width*scale, image.size.height*scale)];
    SyHandWriteTextView *aTextView = [[SyHandWriteTextView alloc] initWithFrame:CGRectZero];
    aTextView.backgroundColor = [UIColor clearColor];
    aTextView.originalSize = canvasView_.visibleFrame.size;
    aTextView.strokes = [NSArray arrayWithArray:aStrokes];
    aTextView.scale = aScale;
//    aTextView.scaleSize = CGSizeMake(canvasView_.visibleFrame.size.width*scale, \
//                                     canvasView_.visibleFrame.size.height*scale\
//                                     );
    CGRect aContentFrame = aCanvasView.contentFrame;
    aTextView.splitWidth = aContentFrame.origin.x;
//    [aTextView setupImage:image size:image.size];
    CGFloat w = (aContentFrame.size.width - aContentFrame.origin.x)*aScale;
    
    if ((currentX_ + w) > (self.visibleFrame.origin.x + self.visibleFrame.size.width)) {
        currentX_ = self.visibleFrame.origin.x;
        currentRow_ ++;
        currentIndex_ = 0;
    }
    
    if (currentRow_ >= rowCount_) {
        UIAlertView *sAlert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:SY_STRING(@"Common_InputLimit")
                                                        delegate:self
                                               cancelButtonTitle:SY_STRING(@"common_ok")
                                               otherButtonTitles:nil];
        sAlert.tag = -1;
        [sAlert show];
        [sAlert release];
        [aTextView release];
        return;
    }
    
    aTextView.frame = CGRectMake(\
                                 currentX_, \
                                 rowHeight_ * currentRow_, \
                                 w+2*2, \
                                 rowHeight_\
                                 );
    [self insertSubview:aTextView atIndex:0];
    [subViews_ addObject:aTextView];
    [self bringSubviewToFront:aTextView];
    
    NSString *aKey = [self getRowKey:currentRow_];
    NSMutableArray *array = [subViewsDict_ objectForKey:aKey];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:0];
        currentIndex_ = 0;
    }
    
    if (currentIndex_ < array.count) {
        [array insertObject:aTextView atIndex:currentIndex_];
    }
    else {
        [array addObject:aTextView];
        currentIndex_ = array.count - 1;
    }
    
    [subViewsDict_ setObject:array forKey:aKey];
    aTextView.key = aKey;
    currentX_ += w;
    currentX_ += kTextSpaceWidth;
    [aTextView release];
    [self layoutViewForAdd:currentRow_ index:currentIndex_ distance:w];
    currentIndex_ ++;
    [self refreshCursorView];
    textCount ++;
    if (textCount == 2) {
        if (self.shouldTextHelp) {
            [self showTextHelpView];
        }
    }
}

- (void)canvasView:(GLCanvasView *)aCanvasView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)layoutViewForAdd:(NSInteger)aRow index:(NSInteger)aIndex distance:(CGFloat)aDistance
{
    NSString *aKey = [self getRowKey:aRow];
    NSMutableArray *views = [subViewsDict_ objectForKey:aKey];
    NSInteger nextIndex = aIndex + 1;
    if (views.count > nextIndex) {
        SyHandWriteTextView *aView = (SyHandWriteTextView *)[views objectAtIndex:aIndex];
        SyHandWriteTextView *aNextView = (SyHandWriteTextView *)[views objectAtIndex:nextIndex];
        CGRect aFrame = aView.frame;
        CGRect aNextFrame = aNextView.frame;
        
        CGFloat w = aNextFrame.origin.x - aFrame.origin.x - aFrame.size.width;
        if (w > kTextSpaceWidth) {
            return;
        }
        aView = aNextView;
        aFrame = aNextFrame;
        aIndex = nextIndex;
        if ((aFrame.origin.x + aDistance + aFrame.size.width) < (self.visibleFrame.origin.x + self.visibleFrame.size.width)) {
            aFrame.origin.x += aDistance;
            aFrame.origin.y = aRow * rowHeight_;
            aView.frame = aFrame;
            [self layoutViewForAdd:aRow index:aIndex distance:aDistance];
        }
        else {
            NSIndexSet *subSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(aIndex, \
                                                                                    views.count-aIndex)];
            NSArray *subArray = [views objectsAtIndexes:subSet];
            aRow ++;
            if (aRow >= rowCount_) {
                for (SyHandWriteTextView *sView in subArray) {
                    [sView removeFromSuperview];
                }
                [views removeObjectsInArray:subArray];
                return;
            }
            NSString *key1 = [self getRowKey:aRow];
            NSMutableArray *array1 = [subViewsDict_ objectForKey:key1];
            if (array1 == nil) {
                array1 = [NSMutableArray arrayWithCapacity:0];
            }
            NSIndexSet *insertSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,\
                                                                                       subArray.count)];
            [array1 insertObjects:subArray atIndexes:insertSet];
            [subViewsDict_ setObject:array1 forKey:key1];
            [views removeObjectsInArray:subArray];
            
            CGFloat s = aFrame.origin.x - kTextSpaceWidth;
            
            for (SyHandWriteTextView *sView in subArray) {
                CGRect sFrame = sView.frame;
                sFrame.origin.x -= s;
                sFrame.origin.y = aRow * rowHeight_;
                sView.frame = sFrame;
                sView.key = key1;
            }
            
            aDistance = 0.0f;
            if (subArray.count > 0) {
                UIView *lView = [subArray lastObject];
                aDistance = lView.frame.origin.x + lView.frame.size.width;
            }
            
            aIndex = subArray.count - 1;
            [self layoutViewForAdd:aRow index:aIndex distance:aDistance];
        }
    }
}

- (void)layoutViewForDelete:(NSInteger)aRow index:(NSInteger)aIndex distance:(CGFloat)distance
{
    NSString *aKey = [self getRowKey:aRow];
    NSMutableArray *views = [subViewsDict_ objectForKey:aKey];
    if (views.count > aIndex) {
        SyHandWriteTextView *aView = (SyHandWriteTextView *)[views objectAtIndex:aIndex];
        if (aView) {
            CGRect aFrame = aView.frame;
            aFrame.origin.x -= distance;
            aView.frame = aFrame;
            [self layoutViewForDelete:aRow index:aIndex+1 distance:distance];
        }
    }
}

- (void)refreshCursorView
{
    CGRect aFrame = cursorView_.frame;
    aFrame.size.height = rowHeight_;
    aFrame.origin.x = currentX_;
    if (currentRow_ < rowCount_) {
        aFrame.origin.y = rowHeight_ * currentRow_;
    }
    if (aFrame.origin.x < self.visibleFrame.origin.x) {
        aFrame.origin.x = self.visibleFrame.origin.x;
    }
    else if (aFrame.origin.x > (self.visibleFrame.origin.x + self.visibleFrame.size.width)) {
        aFrame.origin.x = self.visibleFrame.origin.x + self.visibleFrame.size.width;
    }
    cursorView_.frame = aFrame;
}

- (NSString *)getRowKey:(NSInteger)aRow
{
    return [NSString stringWithFormat:kSubViewsDictKeyFormat, (long)aRow]; 
}

- (void)addImage:(UIImage *)aImage 
{
    UIImageView *aImageView = [[UIImageView alloc] initWithImage:aImage];
    aImageView.backgroundColor = [UIColor clearColor];
    CGRect fFrame = CGRectMake(\
                               currentX_, \
                               rowHeight_ * currentRow_, \
                               aImage.size.width,\
                               aImage.size.height\
                               );
    if (fFrame.origin.x + fFrame.size.width > self.visibleFrame.origin.x + self.visibleFrame.size.width) {
        //换行
        fFrame.origin.x = self.visibleFrame.origin.x;//+ self.visibleFrame.size.width - fFrame.size.width;
        fFrame.origin.y = rowHeight_ * (currentRow_+1);
    }
    
    if (fFrame.origin.y + fFrame.size.height > self.frame.size.height) {
        fFrame.origin.y = self.frame.size.height - fFrame.size.height;
    }
    aImageView.frame = fFrame;
    
    [self insertSubview:aImageView atIndex:0];
    
    [imageViews_ addObject:aImageView];
    [subViews_ addObject:aImageView];
    aImageView.userInteractionEnabled = YES;
    [aImageView release];
    if (self.shouldImageHelp) {
        [self showImageHelpView];  
    }
}

- (void)deleteImage 
{
    UIImageView *aImageView = [imageViews_ lastObject];
    if (aImageView) {
        [aImageView removeFromSuperview];
        [imageViews_ removeLastObject];
        [subViews_ removeObject:aImageView];
    }
}

- (IBAction)deleteAllImages
{
    for (UIImageView *aImageView in imageViews_) {
        [aImageView removeFromSuperview];
    }
    [subViews_ removeObjectsInArray:imageViews_];
    [imageViews_ removeAllObjects];
}

- (void)deleteText 
{
    if (currentRow_ == 0 && currentIndex_ == 0) {
        if (currentX_ > kTextSpaceWidth) {
            currentX_ = self.visibleFrame.origin.x;
            [self refreshCursorView];
        }
        return;
    }
    
    if (currentRow_ > 0 && currentIndex_ == 0) {
         currentRow_ --;
    }
    
    NSString *aKey = [self getRowKey:currentRow_];
    NSMutableArray *views = [subViewsDict_ objectForKey:aKey];
    if (currentIndex_ > 0) {
        if (views.count > (currentIndex_ - 1)) {
            UIView *aView = [views objectAtIndex:currentIndex_ - 1];
            CGRect aFrame = aView.frame;
            CGFloat w = currentX_ - aFrame.size.width - aFrame.origin.x;
            CGFloat aDistance = 0.0f;
            if (w < kTextSpaceWidth) {
                currentIndex_ --;
                currentX_ = aFrame.origin.x;
                aDistance = aFrame.size.width;
                [views removeObject:aView];
                [aView removeFromSuperview];
                [subViews_ removeObject:aView];
                [self layoutViewForDelete:currentRow_ index:currentIndex_ distance:aDistance];
                textCount --;
            }
            else {
                aDistance = currentX_;
                currentX_ = aFrame.origin.x + aFrame.size.width;
                aDistance -= currentX_;
                [self layoutViewForDelete:currentRow_ index:currentIndex_ distance:aDistance];
            }
        }
    }
    else if (currentIndex_ == 0) {
        currentX_ = self.visibleFrame.origin.x;
    }
    else {
        currentIndex_ = views.count;
        UIView *aView = [views lastObject];
        currentX_ = aView.frame.origin.x + aView.frame.size.width;
    }
    [self refreshCursorView];
}

- (void)deleteAllText 
{
    NSArray *array = [subViewsDict_ allValues];
//    [subViews_ removeObjectsInArray:array];
    for (NSArray *views in array) {
        for (UIView *aView in views) {
            [aView removeFromSuperview];
            [subViews_ removeObject:aView];
        }
    }
    [subViewsDict_ removeAllObjects];
    currentRow_ = 0;
    currentColumn_ = 0;
    currentIndex_ = 0;
    currentX_ = self.visibleFrame.origin.x;
    [self refreshCursorView];
    textCount = 0;
}

- (void)clear
{
    [self deleteAllText];
    [self deleteAllImages];
}

- (UIImage *)getScreenImage
{
    shouldDrawLine_ = NO;
    [self stopBlinkAnimation];
    [cursorView_ removeFromSuperview];
	_visibleImageView.hidden = YES;
    [self setNeedsDisplay];
    self.backgroundColor = [UIColor clearColor];
    
    CGRect cFrame = [self getContentFrame];
    UIImage *aResult = nil;
    // add by guoyl at 20120907
    if (cFrame.size.width == 0 || cFrame.size.height == 0) {
//        cFrame.size.width = 5;
//        cFrame.size.height = 5;
//        return nil;
    }
    else {
        UIImage *aImage = nil;
        UIGraphicsBeginImageContext(self.bounds.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        aImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect frame = CGRectMake(\
                                  cFrame.origin.x,\
                                  cFrame.origin.y,\
                                  cFrame.size.width - cFrame.origin.x,\
                                  cFrame.size.height - cFrame.origin.y\
                                  );
        
        CGImageRef imageToSplit = aImage.CGImage;
        CGImageRef partOfImageAsCG = CGImageCreateWithImageInRect(imageToSplit, frame);
        UIImage *partOfImage = [UIImage imageWithCGImage:partOfImageAsCG];
        CGImageRelease(partOfImageAsCG);
        aResult = partOfImage;
    }
    // add end   
    shouldDrawLine_ = YES;
    [self addSubview:cursorView_];
    [self startBlinkAnimation];
    [self setNeedsDisplay];
    [self setupProperty];
	_visibleImageView.hidden = NO;
    return aResult;
}

- (CGRect)getContentFrame
{
    NSArray *aSubViews = subViews_;
    CGRect cFrame = CGRectZero;
    if (aSubViews.count > 0) {
        for (NSUInteger i = 0; i < aSubViews.count; i ++) {
            UIView *aView = [aSubViews objectAtIndex:i];
            CGRect aFrame = aView.frame;
            if (i == 0) {
                cFrame = CGRectMake(\
                                    aFrame.origin.x,\
                                    aFrame.origin.y, \
                                    aFrame.origin.x + aFrame.size.width,\
                                    aFrame.origin.y + aFrame.size.height\
                                    );
                continue;
            }
            CGFloat mX = aFrame.origin.x + aFrame.size.width;
            CGFloat mY = aFrame.origin.y + aFrame.size.height;
            if (cFrame.origin.x > aFrame.origin.x) {
                cFrame.origin.x = aFrame.origin.x;
            }
            if (cFrame.origin.y > aFrame.origin.y) {
                cFrame.origin.y = aFrame.origin.y;
            }
            if (cFrame.size.width < mX) {
                cFrame.size.width = mX;
            }
            if (cFrame.size.height < mY) {
                cFrame.size.height = mY;
            }
        }
    }
    return cFrame;
}

- (void)correctCurrentIndex
{
    currentIndex_ = 0;
    NSString *key = [self getRowKey:currentRow_];
    NSArray *array = [subViewsDict_ objectForKey:key];
    if (array.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < array.count; i ++) {
        UIView *aView = [array objectAtIndex:i];
        CGRect frame = aView.frame;
        if (frame.origin.x < currentX_) {
            currentIndex_ = i + 1;
        }
    } 
}

- (UIView *)findViewByPoint:(CGPoint )aPoint
{
    UIView *v = nil;
    for (UIView *view in imageViews_) {
        CGRect f = view.frame;
        CGFloat mX = f.origin.x + f.size.width;
        CGFloat mY = f.origin.y + f.size.height;
        if (aPoint.x > f.origin.x && aPoint.x < mX \
            && aPoint.y > f.origin.y && aPoint.y < mY) {
            v = view;
            break;
        }
    }
    return v;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    touchView_ = [[touches anyObject] view];
    UIView *touchView = [self findViewByPoint:point];
    if (touchView && [touchView isKindOfClass:[UIImageView class]]) {
        self.moveView = touchView;
        CGPoint p = [[touches anyObject] locationInView:touchView];
        self.touchPoint = p;
        touchView.alpha = 0.7;
//        [self bringSubviewToFront:touchView];
        [self insertSubview:self.moveView atIndex:0];

    }
    else {
//        [canvasView_ clearCanvas];
        CGPoint p = [[touches anyObject] locationInView:_visibleImageView];
        if (p.x > 0 && p.y > 0) {
            self.touchedVisible = YES;
        }
        else {
            self.touchedVisible = NO;
            return;
        }
//        [canvasView_ touchesBegan:touches withEvent:event];
        if (delegate_ && [delegate_ respondsToSelector:@selector(handWriteView:touchesBegan:withEvent:)]) {
            [delegate_ handWriteView:self touchesBegan:touches withEvent:event];
        }
        if ([self.delegate respondsToSelector:@selector(handWriteViewDidStartDraw:)]) {
            [self.delegate handWriteViewDidStartDraw:self];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.moveView) {
        CGPoint point = [[touches anyObject] locationInView:self];
        CGRect frame = self.moveView.frame;
        CGSize aSize = self.frame.size;
        CGSize fSize = frame.size;
        frame.origin.x = point.x - self.touchPoint.x;
        frame.origin.y = point.y - self.touchPoint.y;
        
        if (frame.origin.x < self.visibleFrame.origin.x) {
            frame.origin.x = self.visibleFrame.origin.x;
        }
        if ((frame.origin.x + fSize.width) > (self.visibleFrame.origin.x + self.visibleFrame.size.width)) {
            frame.origin.x = self.visibleFrame.origin.x + self.visibleFrame.size.width - fSize.width;
        }
        if ((frame.origin.y + frame.size.height) >= aSize.height) {
            frame.origin.y = aSize.height - fSize.height - kTextSpaceWidth;
        }
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
        }
        self.moveView.frame = frame;
    }
    else {
        if ([canvasView_ superview] == nil) {
            [self addSubview:canvasView_];
            [self bringSubviewToFront:canvasView_]; 
        }
        [canvasView_ touchesMoved:touches withEvent:event]; 
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.moveView) {
        self.moveView.alpha = 1.0;
        [self.moveView removeFromSuperview];
//        [self addSubview:self.moveView];
        [self insertSubview:self.moveView atIndex:0];
        self.moveView = nil;
        return;
    }
    if (self.touchedVisible) {
        [canvasView_ touchesEnded:touches withEvent:event];
    }
}

- (void)blinkAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target
{
    if (shouldContinueBlinking_) {
        [target.layer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationId];
        [animation setFromValue:[NSNumber numberWithFloat:1.0]];
        [animation setToValue:[NSNumber numberWithFloat:0.0]];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionLinear]];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:kAnimationRepeatCount];
        [animation setDelegate:self];
        [target.layer addAnimation:animation forKey:animationId];
    }
}

- (void)startBlinkAnimation 
{
    shouldContinueBlinking_ = YES;
    [self blinkAnimation:kAnimationIdBlinking finished:YES target:cursorView_];
}

- (void)stopBlinkAnimation 
{
    [cursorView_.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kAnimationIdBlinking];
    animation.delegate = nil;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag 
{
    if (flag) {
        [self startBlinkAnimation]; 
    }
}

- (IBAction)undo
{
    if (subViews_.count > 0) {
        UIView *v = [subViews_ lastObject];
        CGRect fFrame = v.frame;
        [v removeFromSuperview];
        [subViews_ removeObject:v];  
        if ([v isKindOfClass:[SyHandWriteTextView class]]) {
            SyHandWriteTextView *tv = (SyHandWriteTextView *)v;
            NSMutableArray *array = [subViewsDict_ objectForKey:tv.key];
            [array removeObject:tv];
        }
        else {
            [imageViews_ removeObject:v];
            return;
        }
        
        v = [subViews_ lastObject];
        if (v == nil) {
            currentRow_ = 0;
            currentX_ = self.visibleFrame.origin.x;
            currentIndex_ = 0;
        }
        else if (v && [v isKindOfClass:[SyHandWriteTextView class]]) {
            SyHandWriteTextView *tv = (SyHandWriteTextView *)v;
            currentX_ = v.frame.origin.x + v.frame.size.width;
            currentRow_ = [tv.key integerValue];
            NSMutableArray *array = [subViewsDict_ objectForKey:tv.key];
            currentIndex_ = [array indexOfObject:tv];
        }
        else if (v && [v isKindOfClass:[UIImageView class]]) {
            currentX_ = fFrame.origin.x;
        }
        [self refreshCursorView];
    }
}

- (IBAction)redo 
{
    if (removedSubViews_.count > 0) {
        //TODO
    }
}

- (BOOL)shouldTextHelp
{
    BOOL result = NO;
  /*  result = !self.sySetting.promptFlags.hadShowHandTextHelpPrompt;
    self.sySetting.promptFlags.hadShowHandTextHelpPrompt = YES;
    [self.sySetting.promptFlags saveToLocalFile];*/
    return result;
}

- (BOOL)shouldImageHelp
{
    BOOL result = NO;
   /* result = !self.sySetting.promptFlags.hadShowSignatureHelpPrompt;
    self.sySetting.promptFlags.hadShowSignatureHelpPrompt = YES;
    [self.sySetting.promptFlags saveToLocalFile];*/
    return result;
}

- (void)showTextHelpView
{
    //[[SyGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"Common_ChooseStartLocation")];
}

- (void)showImageHelpView
{
   // [[SyGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"Common_ChooseSealLocation")];
}

#pragma -mark GLCanvasViewDelegate
- (void)canvasViewDidStartDraw:(GLCanvasView *)aCanvasView
{
    if ([self.delegate respondsToSelector:@selector(handWriteViewDidStartDraw:)]) {
        [self.delegate handWriteViewDidStartDraw:self];
    }
}

- (void)canvasViewDidFinishDraw:(GLCanvasView *)aCanvasView
{
    if ([self.delegate respondsToSelector:@selector(handWriteViewDidFinishDraw:)]) {
        [self.delegate handWriteViewDidFinishDraw:self];
    }
}

@end
