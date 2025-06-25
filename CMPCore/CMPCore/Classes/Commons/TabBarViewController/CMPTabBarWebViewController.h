//
//  CMPTabBarWebViewController.h
//  M3
//
//  Created by youlin on 2018/6/29.
//

#import <CMPLib/CMPBannerWebViewController.h>

@class CMPTabBarItemAttribute;

@interface CMPTabBarWebViewController : CMPBannerWebViewController

@property (copy, nonatomic) NSString *startPageUrl;
@property (nonatomic, retain)CMPTabBarItemAttribute *itemAttribute;
@property (nonatomic, copy) void(^viewDidAppearCallBack)(void);

/**
 更新非原生导航栏展示的常用应用按钮颜色

 @param color 颜色值
 */
- (void)updateCommonAppButtonColor:(UIColor *)color;
- (void)hideCommonAppButton:(BOOL)hide;
- (void)hideBannerBackPageButton:(BOOL)hide;
- (void)hideBannerFarwardPageButton:(BOOL)hide;

@end
