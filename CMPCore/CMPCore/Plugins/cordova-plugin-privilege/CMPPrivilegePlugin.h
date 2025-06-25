//
//  CMPPrivilegePlugin.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPPrivilegePlugin : CDVPlugin

/**
 获取权限
 */
- (void)getAuthorityByKey:(CDVInvokedUrlCommand *)command;

@end
