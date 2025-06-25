//
//  CMPAccountPlugin.h
//  M3
//
//  Created by CRMO on 2018/1/22.
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPAccountPlugin : CDVPlugin

/**
 获取登陆接口返回报文
 */
- (void)getLoginInfo:(CDVInvokedUrlCommand *)command;

/**
 设置登陆接口返回报文
 参数：loginInfo
 */
- (void)setLoginInfo:(CDVInvokedUrlCommand *)command;

/**
 验证密码
 @param command password 待验证密码
 */
- (void)checkPassword:(CDVInvokedUrlCommand *)command;

/**
 获取getConfigInfo接口返回报文
 */
- (void)getConfigInfo:(CDVInvokedUrlCommand *)command;

/**
 获取当前服务器信息
 */
- (void)getServerInfo:(CDVInvokedUrlCommand *)command;

/**
 获取是否配置了关联账号

 @param command 无
 返回 state: 0-没有配置关联账号，1-配置了关联账号
 */
- (void)getAssociateAccountState:(CDVInvokedUrlCommand *)command;

/**
 打开关联账号管理列表原生页面

 @param command 没有参数
 */
- (void)openAssociateAccountList:(CDVInvokedUrlCommand *)command;

/**
 打开关联账号切换原生页面

 @param command 没有参数
 */
- (void)openAssociateAccountSwitcher:(CDVInvokedUrlCommand *)command;

/**
 获取AppList、ConfigInfo异步更新状态
 
 @param command 没有参数
 */
- (void)getAppAndConfigRequestStatus:(CDVInvokedUrlCommand *)command;

/**
 再次刷新AppList、ConfigInfo

 @param command 没有参数
 */
- (void)refreshAppListAndConfigInfo:(CDVInvokedUrlCommand *)command;

/**
 刷新AppList
 */
- (void)refreshAppList:(CDVInvokedUrlCommand *)command;

/**
 设置辅助性文字字体大小
 
 @param command size
 */
- (void)setMinStandardFont:(CDVInvokedUrlCommand *)command;

/**
 展示隐私协议页
 
 @param command 没有参数
 */
- (void)showPrivacyProtection:(CDVInvokedUrlCommand *)command;

@end
