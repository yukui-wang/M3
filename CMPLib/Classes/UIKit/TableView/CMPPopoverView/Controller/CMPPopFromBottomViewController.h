//
//  CMPPopFromBottomViewController.h
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const CMPShowingViewTimeInterval;

NS_ASSUME_NONNULL_BEGIN

@interface CMPPopFromBottomViewController : UIViewController

/* showingView */
@property (strong, nonatomic) UIView *showingView;
/* viewClicked */
@property (copy, nonatomic) void(^viewClicked)(BOOL hasAnimation);

#pragma mark - 显示隐藏showingView
- (void)showShowingView;

- (void)hideShowingView;

- (void)hideViewWithoutAnimation;

@end

NS_ASSUME_NONNULL_END
