//
//  UIViewController+KSSafeArea.h
//  CMPLib
//
//  Created by Kaku Songu on 5/10/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static inline UIEdgeInsets ks_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@interface UIViewController (KSSafeArea)

@property (nonatomic,strong,readonly) UIView *baseSafeView;
@property (nonatomic,copy) void(^baseSafeViewFrameChangedBlock)(CGRect safeFrame,UIEdgeInsets safeEdge);
@property (nonatomic,assign) BOOL isNeedManualClipToTop;

@end

NS_ASSUME_NONNULL_END
