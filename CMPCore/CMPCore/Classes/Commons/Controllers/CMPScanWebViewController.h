//
//  CMPScanWebViewController.h
//  CMPCore
//
//  Created by wujiansheng on 2017/7/22.
//
//

#import <CMPLib/CMPBannerWebViewController.h>

@class SyScanViewController;

@interface CMPScanWebViewController : CMPBannerWebViewController

@property (nonatomic, weak)SyScanViewController *scanViewController;
/* scanImage要扫描的图片，当这个属性有值的时候，就不会显示扫一扫那个页面，直接就是一个空白页面 */
@property (strong, nonatomic) UIImage *scanImage;

- (void)dismissSubViewsAnimated:(BOOL)animated completion:(void (^)(void))completion;


@end
