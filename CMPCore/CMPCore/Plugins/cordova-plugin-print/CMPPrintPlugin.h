//
//  CMPPrintPlugin.h
//  M3
//
//  Created by CRMO on 2019/2/21.
//

#import <CordovaLib/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPrintPlugin : CDVPlugin

/**
 打印文件

 @param command path：文件路径
 */
- (void)print:(CDVInvokedUrlCommand *)command;

/**
 后端打印开关是否打开
 
 @param command path：文件路径
 */
- (void)isCanPrint:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
