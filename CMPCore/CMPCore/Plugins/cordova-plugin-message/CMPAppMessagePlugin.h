//
//  CMPAppMessagePlugin.h
//  M3
//
//  Created by CRMO on 2018/1/9.
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPAppMessagePlugin : CDVPlugin

/**
 设置消息置顶

 @param command appID、status（0-不置顶 1-置顶）
 */
- (void)setTopStatus:(CDVInvokedUrlCommand *)command;

/**
 获取消息置顶状态

 @param command appID
 返回 0-不置顶 1-置顶
 */
- (void)getTopStatus:(CDVInvokedUrlCommand *)command;

/**
 设置免打扰开关状态

 @param command appID、status（0-免打扰关 1-免打扰开）
 */
- (void)setRemindStatus:(CDVInvokedUrlCommand *)command;

/**
 获取免打扰开关状态

 @param command appID
 返回 0-关 1-开
 */
- (void)getRemindStatus:(CDVInvokedUrlCommand *)command;

/**
 设置消息聚合状态

 @param command appID、aggregationID（应用消息：AppMessage）、status（0-不聚合 1-聚合）
 */
- (void)setAggregationStatus:(CDVInvokedUrlCommand *)command;

/**
 获取消息聚合状态
 
 @param command appID、aggregationID（应用消息：AppMessage）
 返回 0-不聚合 1-聚合
 */
- (void)getAggregationStatus:(CDVInvokedUrlCommand *)command;

@end
