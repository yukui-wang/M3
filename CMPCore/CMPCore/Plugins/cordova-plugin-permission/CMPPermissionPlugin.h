//
//  CMPPermissionPlugin.h
//  M3
//
//  Created by 程昆 on 2019/3/1.
//

#import <CordovaLib/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPermissionPlugin : CDVPlugin


/**
 查询权限插件

 @param command 
 */
- (void)hasPermission:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
