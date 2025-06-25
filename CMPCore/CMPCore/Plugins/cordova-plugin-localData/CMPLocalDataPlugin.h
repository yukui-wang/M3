//
//  CMPLocalDataPlugin.h
//  CMPCore
//
//  Created by yang on 2017/2/21.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPLocalDataPlugin : CDVPlugin

+ (void)writeDataWithIdentifier:(NSString *)identifier data:(id)data isGlobal:(BOOL)isGlobal;
+ (id)readDataWithIdentifier:(NSString *)identifier isGlobal:(BOOL)isGlobal;
- (void)write:(CDVInvokedUrlCommand*)command;
- (void)read:(CDVInvokedUrlCommand*)command;
- (void)remove:(CDVInvokedUrlCommand*)command;

@end
