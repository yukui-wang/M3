//
//  CMPCallIdentificationPlugin.h
//  M3
//
//  Created by CRMO on 2017/11/29.
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPCallIdentificationPlugin : CDVPlugin

/**
 是否展示来电识别开关
 根据是否有CallKit来判断
 参数：state
 */
- (void)isSupportCallIdentification:(CDVInvokedUrlCommand *)command;

/**
 获取来电识别状态
 参数：state
 */
- (void)getCallIdentificationState:(CDVInvokedUrlCommand *)command;

/**
 设置来电识别状态
 参数：state
 */
- (void)setCallIdentificationState:(CDVInvokedUrlCommand *)command;

@end
