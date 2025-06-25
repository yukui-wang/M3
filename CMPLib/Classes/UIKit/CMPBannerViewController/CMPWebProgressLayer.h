//
//  CMPWebProgressLayer.h
//  CMPLib
//
//  Created by 曾祥洁 on 2018/9/25.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CMPWebProgressLayer : CAShapeLayer

+ (instancetype)layerWithFrame:(CGRect)frame;

- (void)finishedLoad;
- (void)startLoad;
- (void)closeTimer;

@end

NS_ASSUME_NONNULL_END
