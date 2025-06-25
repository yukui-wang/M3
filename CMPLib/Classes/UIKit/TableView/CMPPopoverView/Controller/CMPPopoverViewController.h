//
//  CMPPopoverViewController.h
//  CMPLib
//
//  Created by MacBook on 2019/11/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const CMPPopoverShowingViewTimeInterval;

NS_ASSUME_NONNULL_BEGIN

@interface CMPPopoverViewController : UIViewController

/* showingView */
@property (strong, nonatomic) UIView *showingView;
/* viewClicked */
@property (copy, nonatomic) void(^viewClicked)(BOOL hasAnimation);

- (void)hideViewWithoutAnimation;

@end

NS_ASSUME_NONNULL_END
