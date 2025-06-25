//
//  SyImageDealView.m
//  M1Core
//
//  Created by Aries on 14-3-18.
//
//

#import "CMPImageShowView.h"

@implementation CMPImageShowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	SY_RELEASE_SAFELY(_pageControl);
	SY_RELEASE_SAFELY(_scrollView);
    [super dealloc];
}
- (void)setup
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
   
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        _pageControl.alpha = 1;
        [self addSubview:_pageControl];
    }
}

- (void)customLayoutSubviews
{
    _scrollView.frame = CGRectMake(0, 0, self.width, self.height);
    _pageControl.frame = CGRectMake(0,self.height - 60, self.width, 60);
    if(_scrollView.subviews && _scrollView.subviews.count){
        for (UIScrollView *s in _scrollView.subviews) {
            
            if([s isKindOfClass:[UIScrollView class]]){
                s.frame = CGRectMake(s.originX, s.originY, s.width, _scrollView.bounds.size.height);
                for (UIView *imageView in s.subviews) {
                    
                    if([imageView isKindOfClass:[UIImageView class]]){
                        imageView.frame = CGRectMake(imageView.originX, imageView.originY, imageView.width, _scrollView.bounds.size.height);
                    }
                }
            }
        }
    }
}
@end
