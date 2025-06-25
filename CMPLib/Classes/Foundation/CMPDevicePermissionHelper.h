//
//  NSObject+CMPObject.h
//  CMPLib
//
//  Created by wujiansheng on 2016/10/28.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPObject.h"

@interface CMPDevicePermissionHelper :CMPObject

//iOS 判断应用是否有使用相机的权限
+ (BOOL)hasPermissionsForCamera;
//iOS 判断应用是否有使用相机的权限,不弹设置提示框
+ (BOOL)cheackPermissionsForCamera;
//iOS 判断应用是否有使用相册的权限
+ (void)permissionsForPhotosTrueCompletion:(void (^)(void))trueCompletion
                           falseCompletion:(void (^)(void))falseCompletion
                                 showAlert:(BOOL)showAlert;
//麦克风权限
+ (void)microphonePermissionTrueCompletion:(void (^)(void))trueCompletion falseCompletion:(void (^)(void))falseCompletion;
//相机权限
+ (void)cameraPermissionTrueCompletion:(void (^)(void))trueCompletion falseCompletion:(void (^)(void))falseCompletion;
//位置权限
+ (BOOL)isHasLocationPermission;

//弹出权限设置
+ (void)showAlertWithTitle:(NSString *)title messsage:(NSString *)msg;

@end
