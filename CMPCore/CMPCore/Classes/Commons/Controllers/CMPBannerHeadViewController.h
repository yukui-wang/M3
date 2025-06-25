//
//  CMPBannerHeadViewController.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/28.
//
//

#import <CMPLib/CMPBannerViewController.h>
#import "CMPNetworkTipView.h"

@interface CMPBannerHeadViewController : CMPBannerViewController

@property (retain, nonatomic) CMPNetworkTipView *networkTipView;
/**
 是否展示无网络提示
 默认展示，不展示需要重载该方法
 
 @return YES 展示， NO 不展示
 */
- (BOOL)canShowNetworkTip;

/**
 无网络提示样式更新
 子类重载该方法刷新UI
 */
- (void)didUpdateNetworkTip:(BOOL)isShow;

- (void)willUpdateNetworkTip:(BOOL)isShow;

//- (CGFloat)otherTipViewHeight;

@end
