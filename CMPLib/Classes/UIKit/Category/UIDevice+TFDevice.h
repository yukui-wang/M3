//
//  UIDevice+TFDevice.h
//  CMPLib
//
//  Created by youlin on 2018/7/3.
//  Copyright © 2018年 CMPCore. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN bool DeviceInterfaceOrientationIsPortrait(void);

@interface UIDevice (TFDevice)

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientationIncludingIPad:(UIInterfaceOrientation)interfaceOrientation;

/**
 新增api for适配iOS16
 */
+(void)newApiForSetOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
