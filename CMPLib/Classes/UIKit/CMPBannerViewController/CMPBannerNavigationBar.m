//
//  SyBannerNavigationBar.m
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//
#define kBannerLeftMargin 10
#define kBannerRightMargin 5

#import "CMPBannerNavigationBar.h"
#import <CMPLib/UIView+RTL.h>

@interface CMPBannerNavigationBar ()

@property (strong, nonatomic) UIView *rightCoverView;

@end

@implementation CMPBannerNavigationBar

- (void)setup {
    self.leftMargin = kBannerLeftMargin;
    self.rightMargin = kBannerRightMargin;
    self.leftViewsMargin = kBannerLeftMargin;
    self.rightViewsMargin = kBannerRightMargin;
    
    self.backgroundColor = [UIColor clearColor];
	if (!_bannerTitleView) {
		_bannerTitleView = [[CMPBannerViewTitleLabel alloc] init];
		_bannerTitleView.backgroundColor = [UIColor clearColor];
        _bannerTitleView.textColor = [UIColor cmp_colorWithName:@"main-fc"];
//        _bannerTitleView.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _bannerTitleView.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        _bannerTitleView.textAlignment = NSTextAlignmentCenter;
        __weak typeof(self) weakSelf = self;
        _bannerTitleView.viewClicked = ^{
            if (weakSelf.bannerTitleClicked) {
                weakSelf.bannerTitleClicked();
            }
        };
		[self addSubview:_bannerTitleView];
	}
	_leftBarButtonItems = [[NSMutableArray alloc] init];
	_rightBarButtonItems = [[NSMutableArray alloc] init];
}

- (void)setTitleType:(CMPBannerTitleType)titleType {
    _titleType = titleType;
    if (titleType == CMPBannerTitleTypeCenter) {
        _bannerTitleView.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        _bannerTitleView.textAlignment = NSTextAlignmentCenter;
    } else if (titleType == CMPBannerTitleTypeLeft) {
        _bannerTitleView.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        _bannerTitleView.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)autoLayout {
    CGFloat w = 0.0f;
    CGFloat x = self.leftMargin;
    for (UIView *aView in _leftBarButtonItems) {
        CGRect frame = aView.frame;
        frame.origin.x = x;
        NSInteger y = self.height/2 - frame.size.height/2 ;
        frame.origin.y = y;
        aView.frame = frame;
        [aView removeFromSuperview];
        [self addSubview:aView];
        [aView resetFrameToFitRTL];
        x += aView.frame.size.width;
    }
    w = x;
    CGFloat lMargin = w;
    x = self.width - self.rightMargin;
    if (_rightBarButtonItems.count > 0) {
        for (NSInteger i = _rightBarButtonItems.count - 1; i >= 0; i --) {
            UIView *aView = [_rightBarButtonItems objectAtIndex:i];
            CGRect frame = aView.frame;
            x -= frame.size.width;
            frame.origin.x = x;
            NSInteger y = self.height/2 - frame.size.height/2 + 1;
            frame.origin.y = y;
            aView.frame = frame;
            [aView removeFromSuperview];
            [self addSubview:aView];
            [aView resetFrameToFitRTL];
            x -= self.rightViewsMargin;
        }
    }
    
    CGFloat rMargin = self.width - x;
    CGFloat margin = lMargin;
    if (lMargin < rMargin) {
        margin = rMargin;
    }
    
    // 左边有按钮或者标题样式居中
    if (self.leftBarButtonItems.count > 0 || self.titleType == CMPBannerTitleTypeCenter) {
        _bannerTitleView.frame = CGRectMake(margin, 0, self.width - 2*margin, self.height);
        
        NSArray *leftButtons = self.leftBarButtonItems;
        CGFloat leftMargin;
        CGFloat leftItemMargin;
        CGFloat x;
        if (leftButtons.count > 0 && self.titleType == CMPBannerTitleTypeNull) {
            _bannerTitleView.hidden = YES;
            leftMargin = 10;
            leftItemMargin = 6;
            x = leftMargin;
            for (UIView *button in leftButtons) {
                button.cmp_x = x;
                button.cmp_y = 9;
                x += (button.width + leftItemMargin);
                [button resetFrameToFitRTL];
            }
            NSArray *rightButtons = _rightBarButtonItems;
            for (UIView *button in rightButtons) {
                button.cmp_y = 5;
            }
        } else if (leftButtons.count > 0 && self.titleType == CMPBannerTitleTypeNullWithTextButton) {
            _bannerTitleView.hidden = YES;
            leftMargin = 14;
            leftItemMargin = 20;
            x = leftMargin;
            for (UIView *button in leftButtons) {
                button.cmp_x = x;
                button.cmp_bottom = 40;
                x += (button.width + leftItemMargin);
                [button resetFrameToFitRTL];
            }
            NSArray *rightButtons = _rightBarButtonItems;
            for (UIView *button in rightButtons) {
                button.cmp_bottom =  40 + 10.5;
            }
        }
        
    } else if (self.titleType == CMPBannerTitleTypeLeft) {
        // 左边没有按钮且标题样式居左
//        _bannerTitleView.frame = CGRectMake(20, 5, self.width - (42*3 + self.rightMargin), self.height);
         _bannerTitleView.frame = CGRectMake(14,16, self.width - (42*3 + self.rightMargin + 40), 24);
        // 右边所有按钮向下移动5
        NSArray *rightButtons = _rightBarButtonItems;
        for (UIView *button in rightButtons) {
            button.cmp_y = 5;
        }
    }
    
    if (_titleExtContentView && _titleExtContentView.superview && _titleExtContentView.subviews.count) {
        CGRect titleFr = _bannerTitleView.frame;
        titleFr.size.height = titleFr.size.height*2/3;
        _bannerTitleView.frame = titleFr;
        
        _titleExtContentView.frame = CGRectMake(titleFr.origin.x, titleFr.origin.y+titleFr.size.height, titleFr.size.width, self.height - (titleFr.origin.y+titleFr.size.height));
    }
    
    if (_rightCoverView) {
        [self bringSubviewToFront:_rightCoverView];
    }
    
    // 更新分割线frame
    if (self.titleType == CMPBannerTitleTypeCenter) {
         _bottomLineView.frame = CGRectMake(0, self.height-0.5, self.width, 0.5);
    } else {
         _bottomLineView.frame = CGRectMake(14, self.height-0.3, self.width - 14*2 , 0.3);
    }
   
    [_bannerTitleView resetFrameToFitRTL];
    [_bottomLineView resetFrameToFitRTL];
}

#pragma mark- leftBarButtonItems
- (void)setLeftBarButtonItems:(NSArray *)aLeftBarButtonItems
{
    UIView *aPopoverButton = nil;
    for (UIView *aView in _leftBarButtonItems) {
        [aView removeFromSuperview];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    if (aPopoverButton) {
        [items addObject:aPopoverButton];
    }
    [items addObjectsFromArray:aLeftBarButtonItems];
    
    _leftBarButtonItems = [items copy];
    [self autoLayout];
}

- (void)insertLeftBarButtonItem:(UIButton *)aButton atIndex:(NSInteger)index 
{
    NSMutableArray *items = [_leftBarButtonItems mutableCopy];
    
    if ([items containsObject:aButton]) {
        [items removeObject:aButton];
    }
    if (items.count > 0) {
        [items insertObject:aButton atIndex:index];
    }
    else {
        [items addObject:aButton];
    }
    
    _leftBarButtonItems = [items copy];
    
    [self autoLayout];
}

- (void)insertLeftBarButtonItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    NSMutableArray *items = [_leftBarButtonItems mutableCopy];
    [items insertObjects:array atIndexes:indexes];
    _leftBarButtonItems = [items copy];
    [self autoLayout];
}

- (void)removeLeftBarButtonItemAtIndex:(NSInteger)index
{
    if (index >= 0 && index < _leftBarButtonItems.count) {
        UIView *aView = [_leftBarButtonItems objectAtIndex:index];
        [aView removeFromSuperview];
        NSMutableArray *items = [_leftBarButtonItems mutableCopy];
        [items removeObjectAtIndex:index];
        _leftBarButtonItems = [items copy];
        [self autoLayout];
    }
}

#pragma mark- RightBarButtonItems
- (void)setRightBarButtonItems:(NSMutableArray *)aRightBarButtonItems
{
    for (UIView *aView in _rightBarButtonItems) {
        [aView removeFromSuperview];
    }
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:aRightBarButtonItems];
    _rightBarButtonItems = [items copy];
    
    [self autoLayout];
}

- (void)insertRightBarButtonItem:(UIButton *)aButton {
    [self insertRightBarButtonItems:@[aButton]];
}

- (void)insertRightBarButtonItems:(NSArray *)array {
    NSMutableArray *items = [_rightBarButtonItems mutableCopy];
    
    for (UIButton *button in array) {
        if (![items containsObject:button]) {
            [items addObject:button];
        }
    }
    
    NSMutableArray *result = [items mutableCopy];
    [items enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![CMPBannerNavigationBar isAddPlugFlagForView:button]) {
            [result removeObject:button];
            [result addObject:button];
        }
    }];
    
    _rightBarButtonItems = [result copy];
    [self autoLayout];
}

- (void)removeRightBarButtonItems:(NSArray *)array {
    NSMutableArray *arr = [_rightBarButtonItems mutableCopy];
    [arr removeObjectsInArray:array];
    _rightBarButtonItems = [arr copy];
}

- (void)removeAddPlugRightBarButton {
    NSMutableArray *items = [_rightBarButtonItems mutableCopy];
    NSMutableArray *removeArr = [NSMutableArray array];
    for (UIButton *button in items) {
        if ([CMPBannerNavigationBar isAddPlugFlagForView:button]) {
            [removeArr addObject:button];
            [button removeFromSuperview];
        }
    }
    [items removeObjectsInArray:removeArr];
    _rightBarButtonItems = [items copy];
}

- (void)coverRightViews:(BOOL)aValue
{
    /*if (!_rightCoverView && aValue) {
        _rightCoverView = [[UIView alloc] init];
        _rightCoverView.backgroundColor = [UIColor clearColor];
        _rightCoverView.userInteractionEnabled = YES;
    }
    if (aValue) {
        CGFloat x = _bannerTitleView.originX + _bannerTitleView.width;
        _rightCoverView.frame = CGRectMake(x, 0, self.width - x, self.height);
        [_rightCoverView removeFromSuperview];
        [self addSubview:_rightCoverView];
        [self bringSubviewToFront:_rightCoverView];
        [_rightCoverView resetFrameToFitRTL];
    }
    else {
        [_rightCoverView removeFromSuperview];
    }
     */
}

- (void)setBannerBackgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor = backgroundColor;
}

- (UIColor *)bannerNavigationBarBackgroundColor
{
	return [UIColor cmp_colorWithName:@"white-bg"];
}

- (void)addBottomLine {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
        [self addSubview:_bottomLineView];
    }
    _bottomLineView.frame = CGRectMake(0, self.height-0.5, self.width, 0.5);
    _bottomLineView.hidden = NO;
}

- (void)hideBottomLine:(BOOL)isHidden {
   _bottomLineView.hidden = isHidden;
}

- (void)updateBannerTitle:(NSString *)title {
    self.bannerTitleView.text = title;
}

+ (void)addPlugFlagForView:(UIView *)view {
     objc_setAssociatedObject(view, @selector(addPlugFlagForView:), [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)isAddPlugFlagForView:(UIView *)view {
    NSNumber *num = objc_getAssociatedObject(view, @selector(addPlugFlagForView:));
    BOOL isAddPlugFlag = num.boolValue;
    return isAddPlugFlag;
}

-(CMPBaseView *)titleExtContentView
{
    if (!_titleExtContentView) {
        _titleExtContentView = [[CMPBaseView alloc] init];
        _titleExtContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleExtContentView];
    }
    return _titleExtContentView;
}

@end
