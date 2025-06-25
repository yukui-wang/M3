//
//  CMPDevice.h
//  CMPCore
//
//  Created by youlin on 2016/9/5.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPDevicePlugin : CDVPlugin

/**
 隐藏键盘
 */
- (void)hideSoftKeyboard:(CDVInvokedUrlCommand*)command;

/**
 获取键盘展示状态
 返回值 1：显示 0：未显示
 */
- (void)isSoftKeyboardShow:(CDVInvokedUrlCommand*)command;

@end
