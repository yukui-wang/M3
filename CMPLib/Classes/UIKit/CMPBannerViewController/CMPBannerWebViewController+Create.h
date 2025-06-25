//
//  CMPBannerWebViewController+Create.h
//  CMPLib
//
//  Created by CRMO on 2018/10/18.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPBannerWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPBannerWebViewController (Create)

/**
 向指定UINavigationController push一个WebView
 

 @param url 页面URL
 @param navigation navigation
 */
+ (void)pushWithUrl:(NSString *)url toNavigation:(UINavigationController *)navigation;

/**
 跳转到新的 CMPBannerWebViewController
 如果当前vc有 UINavigationController，直接push
 如果没有，present

 @param url 页面URL
 @param params 多webview参数
 @param controller 当前vc
 */
+ (void)pushWithUrl:(NSString *)url
             params:(NSDictionary *)params
       toController:(UIViewController *)controller;

/**
 新建一个CMPBannerWebViewController
 自动处理好页面堆栈

 @param url 页面url
 @param param 穿透参数
 @return CMPBannerWebViewController对象
 */
/// params以字符串的形式传入
+ (CMPBannerWebViewController *)bannerWebViewWithUrl:(NSString *)url params:(NSDictionary *)param;
/// params以对象的形式传入
+ (CMPBannerWebViewController *)bannerWebView1WithUrl:(NSString *)url params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
