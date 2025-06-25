//
//  OfficePlugin.h
//  M3
//
//  Created by CRMO on 2017/12/14.
//

#import <CordovaLib/CDVPlugin.h>

@interface OfficePlugin : CDVPlugin

- (void)openDocument:(CDVInvokedUrlCommand *)command;
- (void)clearDocument:(CDVInvokedUrlCommand *)command;
- (void)closeDocument:(CDVInvokedUrlCommand *)command;

/**
 以只读方式打开文档
 */
- (void)openReadonlyDocument:(CDVInvokedUrlCommand *)command controller:(UIViewController *)controller;

@end
