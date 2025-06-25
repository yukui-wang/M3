//
//  YBImageBrowserToolBar.h
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/12.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBImageBrowserToolBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YBImageBrowserPageType) {
    YBImageBrowserPageTypePageControl = 0,
    YBImageBrowserPageTypepageLable   = 1,
};

@interface YBImageBrowserPageControlToolBar : UIView <YBImageBrowserToolBarProtocol>

@property (nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic, strong, readonly) UILabel *pageLable;
@property (nonatomic, assign) YBImageBrowserPageType pageType;

- (instancetype)initWithPageType:(YBImageBrowserPageType)type;

@end

NS_ASSUME_NONNULL_END
