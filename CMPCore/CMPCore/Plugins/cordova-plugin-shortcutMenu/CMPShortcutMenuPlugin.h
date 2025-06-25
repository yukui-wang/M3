//
//  CMPShortcutMenuPlugin.h
//  CMPCore
//
//  Created by CRMO on 2017/8/24.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPShortcutMenuPlugin : CDVPlugin

/**
 显示快捷操作菜单
 */
- (void)show:(CDVInvokedUrlCommand *)command;

/**
 隐藏快捷操作菜单
 */
- (void)hide:(CDVInvokedUrlCommand *)command;

@end
