//
//  CMPDebugConfigPlugin.h
//  M3
//
//  Created by CRMO on 2018/5/30.
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPDebugConfigPlugin : CDVPlugin

/**
 设置调试开启状态
 */
- (void)debugSwitch:(CDVInvokedUrlCommand *)command;

/**
 获取调试开启状态
 */
- (void)getDebugConfig:(CDVInvokedUrlCommand *)command;

/**
 设置调试信息
 */
- (void)pathMapping:(CDVInvokedUrlCommand *)command;

@end
