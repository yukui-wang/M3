//
//  CMPPageControl.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#define kDefault_Width_Indicator        6.0f
#define kDefault_Margin_Indicator       10.0f

#import "CMPPageControl.h"

@interface CMPPageControl ()
{
@private
    NSInteger   _displayedPage;
    CGFloat     _measuredIndicatorWidth;
    CGFloat     _measuredIndicatorHeight;
    NSMutableDictionary      *_pageImages;
    NSMutableDictionary      *_currentPageImages;
}

- (CGFloat)topOffset;

- (CGFloat)leftOffset;

- (void)setCurrentPage:(NSInteger)currentPage sendEvent:(BOOL)sendEvent canDefer:(BOOL)defer;
- (void)updateMeasuredIndicatorSizes;

@end

@implementation CMPPageControl
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize indicatorMargin = _indicatorMargin;
@synthesize indicatorDiameter = _indicatorDiameter;
@synthesize pageIndicatorTintColor = _pageIndicatorTintColor;
@synthesize currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
@synthesize pageIndicatorImage = _pageIndicatorImage;
@synthesize currentPageIndicatorImage = _currentPageIndicatorImage;
@synthesize hidesForSinglePage = _hidesForSinglePage;
@synthesize defersCurrentPageDisplay = _defersCurrentPageDisplay;

@synthesize alignment = _alignment;
@synthesize verticalAlignment = _verticalAlignment;

- (void)dealloc
{
    [_pageIndicatorTintColor release],_pageIndicatorTintColor = nil;
    [_currentPageIndicatorTintColor release],_currentPageIndicatorTintColor = nil;
    [_pageIndicatorImage release],_pageIndicatorImage = nil;
    [_currentPageIndicatorImage release],_currentPageIndicatorImage = nil;
    [_pageImages release],_pageImages = nil;
    [_currentPageImages release],_currentPageImages = nil;
    [super dealloc];
}




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _numberOfPages = 0;
        _displayedPage = 0;
        self.backgroundColor = [UIColor clearColor];
        
        _measuredIndicatorWidth = kDefault_Width_Indicator;
        _measuredIndicatorHeight = kDefault_Width_Indicator;
        _indicatorDiameter = kDefault_Width_Indicator;
        _indicatorMargin = kDefault_Margin_Indicator;
        
        _alignment = SyPageControlAlignmentCenter;
        _verticalAlignment = SyPageControlVerticalAlignmentMiddle;
        
        _pageImages = [[NSMutableDictionary alloc] init];
        _currentPageImages = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (_numberOfPages < 2 && _hidesForSinglePage) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat xOffset = [self leftOffset];
    CGFloat yOffset = [self topOffset];
    UIColor *fillColor = nil;
    UIImage *image = nil;
    
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        if (i == _displayedPage) {
            fillColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor : [UIColor whiteColor];
            image = [_currentPageImages objectForKey:[NSString stringWithFormat:@"%ld", (long)i]]; //_currentPageImages[@(i)];
            if (image == nil) {
                image = _currentPageIndicatorImage;
            }
        }
        else {
            fillColor = _pageIndicatorTintColor ? _pageIndicatorTintColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3];
            //            image = _pageImages[@(i)];
            image = [_pageImages objectForKey:[NSString stringWithFormat:@"%ld", (long)i]];
            if (image == nil) {
                image = _pageIndicatorImage;
            }
        }
        
        [fillColor set];
        
        if (image) {
            [image drawAtPoint:CGPointMake(xOffset, yOffset)];
        }
        else {
            CGContextFillEllipseInRect(context, CGRectMake(xOffset, yOffset, _measuredIndicatorWidth, _measuredIndicatorHeight));
        }
        xOffset += (_measuredIndicatorWidth + _indicatorMargin);
    }
    
}

- (void)updateCurrentPageDisplay
{
    _displayedPage = _currentPage;
    [self setNeedsDisplay];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages != _numberOfPages) {
        _numberOfPages = MAX(0, numberOfPages);
        [self setNeedsDisplay];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [self setCurrentPage:currentPage sendEvent:NO canDefer:NO];
}


- (void)setIndicatorDiameter:(CGFloat)indicatorDiameter
{
    if (indicatorDiameter != _indicatorDiameter) {
        _indicatorDiameter = indicatorDiameter;
        [self updateMeasuredIndicatorSizes];
        [self setNeedsDisplay];
    }
}


- (void)setIndicatorMargin:(CGFloat)indicatorMargin
{
    if (indicatorMargin != indicatorMargin) {
        _indicatorMargin = indicatorMargin;
        [self setNeedsDisplay];
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
    if (pageIndicatorImage != _pageIndicatorImage) {
        [_pageIndicatorImage release],_pageIndicatorImage = nil;
        _pageIndicatorImage = [pageIndicatorImage retain];
        [self updateMeasuredIndicatorSizes];
        [self setNeedsDisplay];
    }
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage
{
    if (currentPageIndicatorImage != _currentPageIndicatorImage) {
        [_currentPageIndicatorImage release],_currentPageIndicatorImage = nil;
        _currentPageIndicatorImage = [currentPageIndicatorImage retain];
        [self updateMeasuredIndicatorSizes];
        [self setNeedsDisplay];
    }
}


- (void)updateMeasuredIndicatorSizes
{
    _measuredIndicatorWidth = _indicatorDiameter;
    _measuredIndicatorHeight = _indicatorDiameter;
    
    if (_pageIndicatorImage && _currentPageIndicatorImage) {
        _measuredIndicatorWidth = 0;
        _measuredIndicatorHeight = 0;
    }
    if (_pageIndicatorImage) {
        _measuredIndicatorWidth = MAX(_indicatorDiameter, _pageIndicatorImage.size.width);
        _measuredIndicatorHeight = MAX(_indicatorDiameter, _pageIndicatorImage.size.height);
    }
    
    if (_currentPageIndicatorImage) {
        _measuredIndicatorWidth = MAX(_indicatorDiameter, _currentPageIndicatorImage.size.width);
        _measuredIndicatorHeight = MAX(_indicatorDiameter, _currentPageIndicatorImage.size.height);
    }
}

- (void)setCurrentPage:(NSInteger)currentPage sendEvent:(BOOL)sendEvent canDefer:(BOOL)defer
{
    if (currentPage < 0 || currentPage > _numberOfPages) {
        return;
    }
    
    _currentPage = currentPage;
    if (self.defersCurrentPageDisplay == NO || defer == NO) {
        _displayedPage = _currentPage;
        [self setNeedsDisplay];
    }
    
    if (sendEvent) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CGFloat)leftOffset
{
    CGRect rect = self.bounds;
    CGSize size = [self sizeForNumberOfPages:_numberOfPages];
    CGFloat left = 0.0f;
    switch (_alignment) {
        case SyPageControlAlignmentCenter:
            left = CGRectGetMidX(rect) - (size.width / 2.0f);
            break;
        case SyPageControlAlignmentRight:
            left = CGRectGetMaxX(rect) - size.width;
            
        case SyPageControlAlignmentLeft:
            left = 0.0f;
        default:
            break;
    }
    return left;
}

- (CGFloat)topOffset
{
    CGRect rect = self.bounds;
    CGSize size = [self sizeForNumberOfPages:_numberOfPages];
    CGFloat top = 0.0f;
    switch (_verticalAlignment) {
        case SyPageControlVerticalAlignmentMiddle:
            top = CGRectGetMidY(rect) - (_measuredIndicatorHeight / 2.0f);
            break;
        case SyPageControlVerticalAlignmentBottom:
            top = CGRectGetMaxY(rect) - size.height;
            break;
        case SyPageControlVerticalAlignmentTop:
            top = 0.0f;
        default:
            break;
    }
    return top;
}



- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat marginSpace = MAX(0, pageCount - 1) * _indicatorMargin;
    CGFloat indicatorSpace = pageCount * _measuredIndicatorWidth;
    return CGSizeMake(marginSpace + indicatorSpace, _measuredIndicatorHeight);
}

- (CGRect)rectForPageIndicator:(NSInteger)pageIndex
{
    if (pageIndex < 0 || pageIndex >= _numberOfPages) {
        return CGRectZero;
    }
    
    CGFloat left = [self leftOffset];
    CGFloat top = [self topOffset];
    CGSize size = [self sizeForNumberOfPages:pageIndex];
    CGRect rect = CGRectMake(left + size.width - _measuredIndicatorWidth, top - _measuredIndicatorHeight, _measuredIndicatorWidth, _measuredIndicatorHeight);
    return rect;
}

- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView
{
    NSInteger page = (int)floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.currentPage = page;
}
@end
