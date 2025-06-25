//
//  CMPTabBarViewController.h
//  CMPCore
//
//  Created by yang on 2017/2/13.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPTabBarPlugin : CDVPlugin
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)setDefaultIndex:(CDVInvokedUrlCommand*)command;
- (void)getDefaultIndex:(CDVInvokedUrlCommand*)command;
- (void)setBadge:(CDVInvokedUrlCommand*)command;

/**
 V7.1新增插件，获取门户配置信息
 数据来源网络接口：ConfigInfo

 @return
 [
 {
 "portalID": "-8525808048035838414",
 "name": "最高权限的模板",
 "sortNum": 19,
 "createDate": "2018-12-28 16:59:47",
 "updateDate": "2019-01-07 10:15:26",
 "canModify": 0,
 "defIndex": "1",
 "indexAppkey": "-8928172526699038655",
 "valueAuths": null,
 "disAuths": null,
 "navBar": {},
 }]
 */
- (void)getPortalConfig:(CDVInvokedUrlCommand*)command;

/**
 V7.1新增插件，更新底导航配置数据
 
 @Param 同getPortalConfig
 */
- (void)updatePortalConfig:(CDVInvokedUrlCommand*)command;

/**
 V7.1新增插件，是否展示常用应用
 */
- (void)isShowCommonAPP:(CDVInvokedUrlCommand*)command;

/**
 设置常用应用按钮类型

 @param command command color ：#ffffff
 */
- (void)setCommonAPPColor:(CDVInvokedUrlCommand*)command;

@end
