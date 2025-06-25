//
//  CMPFilePlugin.h
//  CMPCore
//
//  Created by youlin on 2016/8/1.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPFilePlugin : CDVPlugin

/**
 读取本地文件
 Note：大小限制5M，超过报异常

 @param command {"url" : "http://cmp.xx.xx/xx.json"}
 */
- (void)readLocalFile:(CDVInvokedUrlCommand *)command;

@end
