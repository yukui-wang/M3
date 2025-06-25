//
//  CMPAppManager.h
//  CMPCore
//
//  Created by youlin on 16/5/30.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPAppManagerPlugin : CDVPlugin

/**
 参数：appType：appType的key
 appId
 注意： 适用于1.8.0以后版本服务器接口
 */
- (void)getAppInfoByIdAndType:(CDVInvokedUrlCommand *)command;

/**
 参数：appID数组 {"appIDs":["1","2"]}
 返回：[{"appID":"1","md5":"xxx","path":"xxx"}]
 */
- (void)getMD5ByIDs:(CDVInvokedUrlCommand *)command;

/**
 在浏览器打开URL
 参数： {"url":"https://www.baidu.com"}
 */
- (void)loadInExplorer:(CDVInvokedUrlCommand *)command;

/**
 参数：appId
 返回：图片url（相对路径）
 */
- (void)getAppIconUrlByAppId:(CDVInvokedUrlCommand *)command;

/**
 参数：无 (消息的应用ID为55)
 返回：success
 */
- (void)loadMessageApp:(CDVInvokedUrlCommand *)command;

- (CDVPluginResult *)loadAppAction:(NSDictionary *)argumentsMap;

@end
