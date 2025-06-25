//
//  CMPLanguagePlugin.h
//  M3
//
//  Created by 程昆 on 2019/6/11.
//

#import <CordovaLib/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

NSString *_CMPLanguageUserAgent = @"";

@interface CMPLanguagePlugin : CDVPlugin


/**
 设置APP语言

 @param command
 */
- (void)set:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
