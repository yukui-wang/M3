//
//  CMPListLoadingCircleView.h
//  CMPLib
//
//  Created by CRMO on 2018/10/27.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPListLoadingCircleView : UIView

- (void)startAnimating;
- (void)stopAnimating;
- (void)setShowPercent:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
