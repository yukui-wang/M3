//
//  CMPPageControl.h
//  CMPCore
//
//  Created by wujiansheng on 16/8/19.
//
//

#import <UIKit/UIKit.h>


typedef enum {
    SyPageControlAlignmentLeft = 1,
    SyPageControlAlignmentCenter,
    SyPageControlAlignmentRight
} SyPageControlAlignment;

typedef enum {
    SyPageControlVerticalAlignmentTop = 1,
    SyPageControlVerticalAlignmentMiddle,
    SyPageControlVerticalAlignmentBottom
}SyPageControlVerticalAlignment;


@interface CMPPageControl : UIControl
{
    NSInteger       _numberOfPages;
    NSInteger       _currentPage;
    CGFloat         _indicatorMargin;
    CGFloat         _indicatorDiameter;      // 直径
    
    UIColor         *_pageIndicatorTintColor;
    UIColor         *_currentPageIndicatorTintColor;
    
    UIImage         *_pageIndicatorImage;
    UIImage         *_currentPageIndicatorImage;
    
    BOOL            _hidesForSinglePage;        //
    BOOL            _defersCurrentPageDisplay;  //
    
    
    SyPageControlAlignment          _alignment;
    SyPageControlVerticalAlignment  _verticalAlignment;
    
    
}
@property (nonatomic, assign) NSInteger     numberOfPages;
@property (nonatomic, assign) NSInteger     currentPage;
@property (nonatomic, assign) CGFloat       indicatorMargin;    // default 10
@property (nonatomic, assign) CGFloat       indicatorDiameter;  // default 6
@property (nonatomic, retain) UIColor       *pageIndicatorTintColor;// ignored if pageIndicatorImage is set
@property (nonatomic, retain) UIColor       *currentPageIndicatorTintColor;// ignored if pageIndicatorImage is set
@property (nonatomic, retain) UIImage       *pageIndicatorImage;
@property (nonatomic, retain) UIImage       *currentPageIndicatorImage;
@property (nonatomic, assign) BOOL          hidesForSinglePage;// hide the the indicator if there is only one page. default is NO
@property (nonatomic, assign) BOOL          defersCurrentPageDisplay;// if set, clicking to a new page won't update the currently displayed page until -updateCurrentPageDisplay is called. default is NO

@property (nonatomic, assign) SyPageControlAlignment            alignment;     // default center
@property (nonatomic, assign) SyPageControlVerticalAlignment    verticalAlignment;     //  default middle




- (void)updateCurrentPageDisplay;// update page display to match the currentPage. ignored if defersCurrentPageDisplay is NO. setting the page value directly will update immediately

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
- (CGRect)rectForPageIndicator:(NSInteger)pageIndex;


- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView;

@end