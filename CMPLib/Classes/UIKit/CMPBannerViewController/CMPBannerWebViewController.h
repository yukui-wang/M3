//
//  SyBannerViewController.h
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kBannerButton_Left              1               //
#define kBannerButton_Right             2               //


#import "CMPBaseWebViewController.h"
#import "CMPBannerNavigationBar.h"

typedef void(^CMPWebViewBackButtonDidClick)(void);

@interface CMPBannerWebViewController : CMPBaseWebViewController<UINavigationControllerDelegate> {
}

@property (nonatomic, copy) NSString *presentAlphaBgColor;//present方式生效#RRGGBBAA
@property (nonatomic, strong) CMPBannerNavigationBar *bannerNavigationBar;
@property (nonatomic, assign) BOOL backBarButtonItemHidden;
@property (nonatomic, assign) BOOL isShowOrientationButton;//默认不显示
@property (nonatomic, readonly) UIImage *bannerBackgroundImage;
@property (nonatomic, assign) BOOL hideBannerNavBar; // 是否隐藏导航条
/** 返回按钮点击事件 **/
@property (copy, nonatomic) CMPWebViewBackButtonDidClick backButtonDidClick;

/** 界面将要关闭 add by wujs 20181010 **/
@property (nonatomic, copy) void (^viewWillClose)(void);

/** 调用goback 完成 **/
@property (nonatomic, copy) void (^goBackCompleteBloack)(void);
/**dismissCompletion回调**/
@property (nonatomic,copy) void(^dismissCompletionBlock)(void);
// method
@property (nonatomic, copy) NSString *bannerViewTitle;
@property (nonatomic, assign) BOOL hasRecordTopScreenClick;//记录当前web是否已经记录负一屏点击
@property (nonatomic, assign) BOOL closeButtonHidden;  // 是否显示关闭按钮
@property (nonatomic, assign)NSInteger statusBarStyle; // 0= 黑色 1 =白色
@property (nonatomic, assign)NSInteger backButtonStyle; // 0= 默认样式 1 =关闭
@property (nonatomic, assign)BOOL autoShowBackButton; // 是否自动显示返回按钮
@property (nonatomic, assign)BOOL isShowBannerProgress;//是否显示webview进度条
@property (nonatomic, readonly)NSMutableArray *pageStack;
@property (nonatomic, retain) NSDictionary *pageParam; // 来自上一个页面的参数
@property (assign, nonatomic) BOOL isTailWebView; // 多WebView，超过阈值后不再新开WebView，而是单页面跳转，isTailWebView为YES
@property (assign, nonatomic) CMPBannerTitleType titleType;

@property (nonatomic, copy) void(^didShowViewControllerCallBack)(void);
@property (assign, nonatomic) BOOL willClose;

@property (nonatomic, assign)BOOL isSupportOSystemShare; // 是否支持系统分享
@property (nonatomic, copy) void(^actionBlk)(id params, NSError *error, NSInteger act);//ks add -- 8.2 即时会议,其它也可以用
@property (nonatomic, assign) BOOL ignoreJsBackHandle;

///设置是否显示进度条
- (void)setShowBannerProgress:(NSString *)isShowBannerProgress;

- (CGFloat)bannerBarHeight;
/**
 顶部导航标题样式，默认居中
 需要修改重载该函数
 */
- (CMPBannerTitleType)bannerTitleType;

- (void)setTitle:(NSString *)title; // 设置没有功能标记的标题
- (void)backBarButtonAction:(id)sender;

// 如果为返回为nil就是图片颜色
- (UIColor *)bannerNavigationBarBackgroundColor;
- (void)showNavBarforWebView:(NSNumber *)aValue;
// 设置返回按钮样式
- (void)setBackButtonStyle:(NSInteger)aType;
// 页面加载完成
- (void)pageDidLoad:(NSNotification *)notification;

// 多webview
// 打开html页面
- (void)pushPage:(NSDictionary *)aParam;
// 关闭html页面
- (BOOL)popPage:(NSDictionary *)aParam backIndex:(NSInteger)aBackIndex;
// 加载html页面
- (void)_loadUrl:(NSString *)url showNavBar:(BOOL)showNavBar isSupportOSystemShare:(BOOL)isSupportOSystemShare;

- (BOOL)executePopPage:(NSDictionary *)aParam backIndex:(NSInteger)aBackIndex animated:(BOOL)animated;
- (NSString *)getParams;
- (NSString *)getBackData;

/**
 webView数量是否超过阈值
 */
+ (BOOL)isWebViewMaxCount;

- (void)setDefaultBackButtonAndCloseButton;

- (void)progressFinishedLoad;
- (void)setupNaviBar;
@end

