//
//  CMPAVPlayerTransitionAnimation.h
//  CMPLib
//
//  Created by MacBook on 2020/2/27.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMPAVPlayerTransitionType) {
    CMPAVPlayerTransitionTypePresent = 0,//present动画
    CMPAVPlayerTransitionTypeDissmiss,
    CMPAVPlayerTransitionTypePush,
    CMPAVPlayerTransitionTypePop
};

NS_ASSUME_NONNULL_BEGIN

@interface CMPAVPlayerTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

/* 动画转场类型 */
@property (nonatomic,assign) CMPAVPlayerTransitionType transitionType;

@end

NS_ASSUME_NONNULL_END
