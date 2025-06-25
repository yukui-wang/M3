//
//  CMPNavigationPlugin.h
//  CMPCore
//
//  Created by youlin on 2016/8/6.
//
//

#import <CordovaLib/CDVPlugin.h>

@interface CMPNavigationPlugin : CDVPlugin

/**
 设置H5接管返回事件
 */
- (void)overrideBackbutton:(CDVInvokedUrlCommand*)command;

// 设置导航栏标题
- (void)setTitle:(CDVInvokedUrlCommand *)command;

// 设置返回按钮样式，默认是尖角返回样式，当设置为关闭按钮样式，closeButton按钮自动隐藏
// 0=默认返回  1=关闭样式
- (void)setBackButtonStyle:(CDVInvokedUrlCommand *)command;

// 设置关闭按钮隐藏值
- (void)setCloseButtonHidden:(CDVInvokedUrlCommand *)command;

/**
 设置是否允许手势返回

 @param command state：0-关闭 1-打开
 */
- (void)setGestureBackState:(CDVInvokedUrlCommand *)command;

+ (NSString *)getParams:(NSDictionary *)aDict;

/**
 设置关闭按钮隐藏值 1.显示 0 隐藏
 */
- (void)setNavigationBarHidden:(CDVInvokedUrlCommand *)command;


/**
 关闭当前WebView
 */
- (void)webviewDestroy:(CDVInvokedUrlCommand *)command;

/**
 导航栏右边增加按钮
 type:"text",   //类型 text image
 info:{
 text类型参数
 text:"123",  //文字
 textColor:"#ff0000",  //文字颜色，非必传，默认蓝色
 textSize:16 //文字大小，非必传，默认16sp
 image类型参数
 imageUrl:"[表情]eyon/apps_res/m3/images/navbar/active-doc.png"
 },
 callback:"alert('xxx')"
 */
- (void)addRightButton:(CDVInvokedUrlCommand *)command;
/**
 自定义导航栏左边按钮
 */
- (void)addLeftButton:(CDVInvokedUrlCommand *)command;
/**
 使导航栏左边按钮选中
 */
- (void)activeLeftButton:(CDVInvokedUrlCommand *)command;
/**
 设置导航栏背景色和原生按钮颜色和标题颜色
 */
- (void)setNavigationBarGlobalStyle:(CDVInvokedUrlCommand *)command;

/**
 V7.1SP1 新增插件，iPad 模式下切换全屏、分屏展示模式
 参数： fullScreen 0-分屏模式 1-全屏模式
 注意： 只能在内容区调用该插件，在操作区调用无效
 */
- (void)switchFullScreenMode:(CDVInvokedUrlCommand *)command;

/**
 V7.1SP1 新增插件，iPad 模式下 清空操作区内容
 注意：只能在操作区调用
 */
- (void)clearDetailPad:(CDVInvokedUrlCommand *)command;

/**
 V7.1SP1 新增插件，iPad 模式下 获取当前页面是否在内容区
 */
- (void)isInDetailPad:(CDVInvokedUrlCommand *)command;

@end
