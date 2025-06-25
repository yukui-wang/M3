//
//  CMPCameraSelectFlashTypeView.h
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    CMPCameraSelectFlashTypeAuto = 0,
    CMPCameraSelectFlashTypeOn,
    CMPCameraSelectFlashTypeOff
    
} CMPCameraSelectFlashType;

@interface CMPCameraSelectFlashTypeView : UIView

/* 点击后回调 */
@property (copy, nonatomic) void(^flashClicked)(CMPCameraSelectFlashType type, UIImage *btnImg);

@end

NS_ASSUME_NONNULL_END
