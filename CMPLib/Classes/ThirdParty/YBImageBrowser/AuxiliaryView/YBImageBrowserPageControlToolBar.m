//
//  YBImageBrowserToolBar.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/12.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBImageBrowserPageControlToolBar.h"
#import "YBIBFileManager.h"
#import "YBImageBrowserTipView.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "UIColor+Hex.h"
#import "UIView+CMPView.h"


static CGFloat kToolBarDefaultsHeight = 50.0;

@interface YBImageBrowserPageControlToolBar() {
    id<YBImageBrowserCellDataProtocol> _data;
}

@end

@implementation YBImageBrowserPageControlToolBar

@synthesize yb_browserShowSheetViewBlock = _yb_browserShowSheetViewBlock;
@synthesize pageControl = _pageControl;
@synthesize pageLable = _pageLable;

#pragma mark - life cycle

- (instancetype)initWithPageType:(YBImageBrowserPageType)type {
    self = [super init];
    if (self) {
        _pageType = type;
        if (_pageType == YBImageBrowserPageTypePageControl) {
            [self addSubview:self.pageControl];
        } else {
            [self addSubview:self.pageLable];
        }
    }
    return self;
}

#pragma mark - <YBImageBrowserToolBarProtocol>

- (void)yb_browserUpdateLayoutWithDirection:(YBImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    CGFloat height = 23 ;
    CGFloat width = containerSize.width;
    if (YBIB_IS_IPHONEX) height += YBIB_HEIGHT_EXTRABOTTOM;
    self.frame = CGRectMake(0, containerSize.height - height, width, height);
    self.pageControl.frame = CGRectMake(0,0, width, 8);
    self.pageLable.frame = CGRectMake(0,0, width, 15);
}

- (void)yb_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YBImageBrowserCellDataProtocol>)data {
    _pageControl.numberOfPages = totalPage;
    _pageControl.currentPage = pageIndex;
    _pageLable.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(pageIndex + 1),(unsigned long)totalPage];
    self->_data = data;
}

#pragma mark - getter

-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
    }
    return _pageControl;
}

-(UILabel *)pageLable {
    if (!_pageLable) {
        _pageLable = [[UILabel alloc] init];
        _pageLable.font = [UIFont systemFontOfSize:14];
        _pageLable.textColor = CMP_HEXCOLOR(0x999999);
        _pageLable.textAlignment = NSTextAlignmentCenter;
    }
    return _pageLable;
}

@end
