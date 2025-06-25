//
//  CMPCameraShutterButton.h
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CMPCameraShutterButtonStatusPhoto,
    CMPCameraShutterButtonStatusVideo,
} CMPCameraShutterButtonStatus;

@interface CMPCameraShutterButton : UIButton

/* CMPCameraShutterButtonStatus */
@property (assign, nonatomic) CMPCameraShutterButtonStatus status;
/* 拍摄视频的最长时长 */
@property (assign, nonatomic) CGFloat videoMaxTime;

/* 动画做完回调 */
@property (copy, nonatomic) void(^videoShutCompleted)(void);

- (void)changeInnerLayerToCycleWithBgColor:(UIColor *)bgColor;

- (void)changeInnerLayerToRectWithBgColor:(UIColor *)bgColor;

- (void)startAnim;
- (void)stopAnim;

//拍照时的动画
- (void)shrink;
- (void)expand;

@end

NS_ASSUME_NONNULL_END
