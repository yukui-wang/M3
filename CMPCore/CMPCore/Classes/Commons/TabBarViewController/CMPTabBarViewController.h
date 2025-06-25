//
//  CMPTabBarViewController.h
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import <UIKit/UIKit.h>
#import <CMPLib/RDVTabBarController.h>

UIKIT_EXTERN NSString *const CMPWillReloadTabBarClearViewNotification;

#define CMPTabBarItemTag 1000
#define CMPTabBarExpandItemTag 2000

@class CMPTabBarItemAttribute;
@class CMPTabBarAttribute;
@interface CMPTabBarViewController : RDVTabBarController

@property (nonatomic,strong) CMPTabBarAttribute *tabAttr;
@property (nonatomic,strong) NSArray *itemAttrs;
@property (nonatomic, copy) void(^viewDidAppearCallBack)(void);
@property (strong, nonatomic) RDVTabBarShortcutItem *commonAppItem;

- (NSArray *)deleteNeedHiddenApps:(NSSet *)deleteSet appList:(NSArray *)itemAttrArr;

- (void)setTabBarBadge:(NSString *)appID show:(BOOL)show;

- (NSUInteger)fetchTabBarIndexWithAppID:(NSString *)appID;

- (NSUInteger)fetchTabBarIndexWithAppKey:(NSString *)appKey;

/**
 根据APPID获取APPKey
 */
- (NSString *)appKeyWithAppID:(NSString *)appID;

/**
 切换到消息
 */
- (void)selectMessage;

/**
 iPad 版本方法
 打开常用应用
 工作台在底导航打开工作台，否则定位到常用应用页签
 */
- (void)openCommonApp;

/**
 消息的index
 */
- (NSInteger)indexOfMessage;

#pragma mark-
#pragma mark 首页设置

//设置tabBar默认选择的页签，用户下次登录生效
+ (void)setHomeTabBar:(NSString *)appID;

/**
 获取主页
 */
+ (NSString *)tabBarHomeKey;

/**
 默认首页
 */
- (NSString *)defaultHomeAppID;

#pragma mark-
#pragma mark 子类继承

/**
 子类重载该方法，自定义如果底导航只配置了一个，处理逻辑
 */
- (void)onlyOneTabBarItem;

/**
 子类重载该方法，自定义如果底导航item的容器类型
 */
- (UIViewController *)itemViewControllerWithRoot:(UIViewController *)rootVc appID:(NSString *)appID;

/**
 子类重载该方法，自定义快捷操作区
 */
- (void)setupPortaitAntShortcuts;
- (void)reloadTabBarIfNeed;

- (void)reloadTabBarAndReloadWebview;

@end
