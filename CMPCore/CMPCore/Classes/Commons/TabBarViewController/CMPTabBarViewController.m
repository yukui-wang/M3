//
//  CMPTabBarViewController.m
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import "CMPTabBarViewController.h"
#import "CMPTabBarItemAttribute.h"
#import "CMPTabBarAttribute.h"
#import "AppDelegate.h"
#import "CMPMessageManager.h"
#import "UITabBar+badge.h"
#import "CMPPrivilegeManager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPTabBarWebViewController.h"
#import "CMPLoginConfigInfoModel.h"
#import "CMPShortcutHelper.h"
#import "M3LoginManager.h"
#import "CMPCommonManager.h"
#import "CMPShareManager.h"
#import "CMPLoginUpdateConfigProvider.h"

#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPConstant.h>
#import "CMPOfflineContactViewController.h"
#import <CMPLib/CMPNavigationController.h>
#import "CMPMessageListViewController.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/RDVTabBarItem+WebCache.h>
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSObject+FBKVOController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPEmptyViewController.h>
#import <CMPLib/CMPPersonInfoUtils.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/NSArray+CMPArray.h>
#import <CMPLib/RTL.h>
#import <CMPLib/CMPFileManager.h>
#import "CMPCore_XiaozhiBridge.h"
#import "CMPNativeToJsModelManager.h"
#import "CMPChatManager.h"
#import <CMPLib/KSLogManager.h>
#import <CMPLib/CMPCachedResManager.h>
#import "CMPTabBarProvider.h"
#import "CMPTopScreenManager.h"
//#import <libkern/OSMemoryNotification.h>
#import "RDVTabBar+Download.h"
#import <CMPLib/CMPCustomAlertView.h>
NSString *const CMPWillReloadTabBarClearViewNotification = @"CMPWillReloadTabBarClearViewNotification";

extern int OSMemoryNotificationCurrentLevel(void);
/** 默认门户的ID **/
static NSString * const kDefaultPortalID = @"0";
static NSUInteger const kTabBarItemFont = 10;

@interface CMPTabBarViewController ()<CMPDataProviderDelegate, RDVTabBarControllerDelegate>
{
    NSInteger clickCount;
}
/** 是否隐藏TabBar **/
@property (assign, nonatomic) BOOL isHideTabBar;
@property (strong, nonatomic) CMPLoginUpdateConfigProvider *provider;

@end

@implementation CMPTabBarViewController

#pragma mark-
#pragma mark Life Circle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
}

- (void)viewDidLoad {
    
    [self initTabBar];//需要先初始化数据
    [super viewDidLoad];
    self.tabBar.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"reverse-fc"];
    self.delegate = self;
    

    [KSLogManager registerOnView:self.tabBar delegate:nil];

    clickCount = 0;
    
    self.tabBar.orientation = self.orientation;
    if ([self.tabBar respondsToSelector:NSSelectorFromString(@"addDownloadView")]) {
        [self.tabBar performSelector:NSSelectorFromString(@"addDownloadView")];
    }

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[CMPNativeToJsModelManager shareManager] safeHandleIfForce:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_TabbarViewControllerDidAppear object:nil];
    if ([CMPFeatureSupportControl isShowPendingAndMessage]) {
        [self requestUpdatePendingAndMessage];
    }
    if (self.viewDidAppearCallBack) {
        self.viewDidAppearCallBack();
        self.viewDidAppearCallBack = nil;
    }
    [self checkShareFromExternalApp];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [[CMPNativeToJsModelManager shareManager] safeHandleIfForce:NO];
    [super setSelectedIndex:selectedIndex];
}

- (void)initTabBar {
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
        CMPLoginConfigInfoModel_2 *config = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];
        
        CMPTabBarAttribute *tabbarAttribute = config.tabBar.tabbarAttribute;
        CMPTabBarAttribute *tabbarExpandAttribute = config.portal.expandNavBar.tabbarAttribute;
        CMPTabBarItemAttributeList *tabBarItemAttributes = [[CMPTabBarItemAttributeList alloc] init];
        
        tabBarItemAttributes.navBarList = [self
                                           sortTabbarItemAttributeList:config.tabBar.tabbarList];
        tabBarItemAttributes.expandNavBarList = config.portal.expandNavBar.tabbarList;
        
        
        [config.tabBar.tabbarList enumerateObjectsUsingBlock:^(CMPTabBarItemAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.dataSource = CMPTabBarItemAttributeFromNetwork;
        }];
        [config.portal.expandNavBar.tabbarList enumerateObjectsUsingBlock:^(CMPTabBarItemAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.dataSource = CMPTabBarItemAttributeFromNetwork;
        }];
        
        BOOL canModify = config.portal.canModify;
        BOOL canExpand = config.portal.openExpandNavBar;
        self.canPanExpandNavi = INTERFACE_IS_PHONE && canExpand;
        self.canEditExpandNavi = canModify;
        
        [self initTabbarWithTabAttr:tabbarAttribute expandTabAttr:tabbarExpandAttribute itemAttrArr:tabBarItemAttributes.navBarList needHiddenApps:nil expandItemAttArr:tabBarItemAttributes.expandNavBarList];
    } else {
        BOOL hasAddressBook = [CMPPrivilegeManager getCurrentUserPrivilege].hasAddressBook;
        NSString *needHideAppIDs = nil;
        if (!hasAddressBook) {
            needHideAppIDs = @"62";
        }
        [self initTabBarWithZip:needHideAppIDs];
    }
}

/**
 用Zip包52里的信息来初始化底部导航
 
 @param appIDs 需要隐藏的appID
 */
- (void)initTabBarWithZip:(NSString *)appIDs {
    // 设置是否有my模块为NO
    [CMPCore sharedInstance].hasMyInTabBar = NO;
    //52为应用包 tabBar的属性配置文件放在appID=52的应用包里
    CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:kM3AppID_Application
                                                    version:@"v"
                                                   serverId:kCMP_ServerID
                                                     owerId:kCMP_OwnerID];
    // 如果当前应用包为空，则无法登陆到首页，需要给出提示并返回到登陆页面
    if (!appInfo.path) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_UserLogout object:nil];
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_loadAppFail")];
        });
        return;
    }
    // 根据应用包里面的配置文件，加载底部菜单信息
    NSString *aRootPath = [CMPAppManager documentWithPath:appInfo.path];
    NSString *aPath = aRootPath;
    NSString *tabConfigPath = [aPath stringByAppendingPathComponent:@"tabConfig/m3TabConfig.json"];
    NSString *JSONString = [NSString stringWithContentsOfFile:tabConfigPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dict = [JSONString JSONValue];
    NSDictionary *tabAttrJSON = [dict objectForKey:@"tabBarAttribute"];
    NSArray *itemAttrArr = [dict objectForKey:@"itemAttributes"];
    CMPTabBarAttribute *tabAttr = [NSObject objectWithDictionaryRepresentation:tabAttrJSON];
    [self initTabbarWithTabAttr:tabAttr expandTabAttr:nil itemAttrArr:itemAttrArr needHiddenApps:appIDs expandItemAttArr:nil];
}

/**
 利用解析出来的样式初始化TabBar
 
 @param tabAttr tabbar样式
 @param itemAttrArr item样式
 @param appIDs 需要隐藏的APPID
 */
- (void)initTabbarWithTabAttr:(CMPTabBarAttribute *)tabAttr expandTabAttr:(CMPTabBarAttribute *)expandTabAttr itemAttrArr:(NSArray *)itemAttrArr needHiddenApps:(NSString *)appIDs expandItemAttArr:(NSArray *)expandItemAttrArr{
    // 获取需要隐藏的appIDs
    NSArray *delAppArr = [appIDs componentsSeparatedByString:@"|"];
    NSSet *delAppSet = [[NSSet alloc] initWithArray:delAppArr];
    NSArray *itemAttrs = [self deleteNeedHiddenApps:delAppSet appList:itemAttrArr];
    
    CMPTabBarItemAttribute *onlyAttribute = nil;
    BOOL isOnlyShortcut = NO;
    if (itemAttrs.count == 1) {
        onlyAttribute = itemAttrs.firstObject;
        isOnlyShortcut = [onlyAttribute.appID isEqualToString:kM3AppID_Shortcut];
    }
    
    // 如果底部导航没有数据，默认展示常用应用
    if (itemAttrs.count == 0 || isOnlyShortcut) {
        if (INTERFACE_IS_PHONE) {
            CMPTabBarWebViewController *tab = [[CMPTabBarWebViewController alloc] init];
            tab.startPageUrl = kM3CommonAppUrl;
            tab.hideBannerNavBar = NO;
            tab.viewDidAppearCallBack = ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_TabbarChildViewControllerDidAppear object:nil];
            };
            UINavigationController *nav = nil;
            nav = [[CMPNavigationController alloc] initWithRootViewController:tab];
            self.viewControllers = @[nav];
        } else if(INTERFACE_IS_PAD) {
             [self setItemAttrs:itemAttrs];
        }
       
    } else {
        // 设置底导航item
        [self setItemAttrs:itemAttrs];
    }
    
    // 设置底导航属性
    [self setTabAttr:tabAttr];
    
    // 获取默认显示应用
    NSString *appID = [self _homeApp];
    if ([delAppSet containsObject:appID]) {
        appID = [self defaultHomeAppID];
    }
    
    BOOL isSelectedPortrait = NO;
    
    if (CMP_IPAD_MODE) {
       if ([self isAppIDMy:appID]) {
           [self.tabBar portraitDidSelected:nil];
           isSelectedPortrait = YES;
       }
    }
    
    if (!isSelectedPortrait) {
        if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
               self.selectedIndex = [self fetchTabBarIndexWithAppKey:appID];
           } else {
               self.selectedIndex = [self fetchTabBarIndexWithAppID:appID];
        }
    }
    //M3上的底导航为空或者只有快捷操作的时候，选中应用中心
    if ((itemAttrs.count == 0 || isOnlyShortcut) && CMP_IPAD_MODE) {
        [self.tabBar homePageCommonAppDidSelected];
    }
    
    // 底导航只有一项时，隐藏底导航 2022-06-22产品要求一个tab也需要显示
//    if (itemAttrs.count <= 1) {
//        [self onlyOneTabBarItem];
//    }
    
    //设置expandTabBarItem
    if (self.canPanExpandNavi) {
        [self.tabBar setExpandItems:[self getExpandItem:expandItemAttrArr attr:expandTabAttr]];
    }
    
}

#pragma mark-

#pragma mark 初始化 TabBar
- (void)setItemAttrs:(NSArray *)itemAttrs {
    [self setItemAttrs:itemAttrs clearView:YES];
}
- (void)setItemAttrs:(NSArray *)itemAttrs clearView:(BOOL)clear {
    if (itemAttrs == nil ||
        itemAttrs == _itemAttrs) {
        return;
    }
    
    if ([UIView isRTL] && ![[self class] isEqual: NSClassFromString(@"CMPPadTabBarViewController")]) {
        itemAttrs = [itemAttrs cmp_convertArrar];
        _itemAttrs = itemAttrs;
    }else {
        _itemAttrs = itemAttrs;
    }
    
    // TabBar的ViewController数组
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    // TabBar的ViewController对应的标题、图标等数据
    NSMutableArray *itemContents = [[NSMutableArray alloc] init];
    
    NSUInteger count = itemAttrs.count;
    CGFloat itemWidth = self.view.cmp_width / count;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    UIFont *titleFont = [UIFont systemFontOfSize:kTabBarItemFont];
    
    UIColor *selectThemeColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    UIColor *normalColor = [CMPCore sharedInstance].serverIsLaterV7_1_SP1 ? UIColorFromRGB(0xB3C4DB) : UIColorFromRGB(0x989898);
    BOOL isSupportThemeColor = [CMPCore sharedInstance].serverIsLaterV7_1_SP1 ;
    for (int i = 0; i < count; i++) {
        CMPTabBarItemAttribute *attr = [itemAttrs objectAtIndex:i];
        
        if ([self filterUselessApp:attr.app]) {
            continue;
        }
        NSString *appID = attr.appID;
        if (clear) {
            UIViewController *vc = [self viewControllerWithAttribute:attr];
            vc.isRoot = YES;
            UIViewController *itemRootVc = [self itemViewControllerWithRoot:vc appID:attr.appID];
            if (!itemRootVc) {
                continue;
            }
            [vcs addObject:itemRootVc];
        }
        else if (INTERFACE_IS_PAD &&([appID isEqualToString:kM3AppID_My] ||[appID isEqualToString:kM3AppID_Shortcut])) {
            // iPad上 我的 快捷菜单 不展示在底导航
            continue;
        }
      
        
        NSMutableDictionary *itemContent = [NSMutableDictionary dictionary];
        
        NSInteger tag = [appID integerValue] + CMPTabBarItemTag;
        [itemContent setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
        
        NSString *title = [self titleWithAttribute:attr language:currentLanguage font:titleFont itemWidth:itemWidth];
        [itemContent setObject:title ?: @"" forKey:@"title"];
        
        UIImage *defaultImage = [attr normalImg];
        if (!defaultImage) {
            defaultImage = [UIImage imageNamed:@"tabBar.bundle/placeholder.png"];
        }
        if(isSupportThemeColor) {
            defaultImage = [defaultImage cmp_imageWithTintColor:normalColor];
        }
        [itemContent setObject:defaultImage forKey:@"defaultImage"];
        
        UIImage *defaultSelectedImage = [attr selectedImg];
        if (!defaultSelectedImage) {
            defaultSelectedImage = [UIImage imageNamed:@"tabBar.bundle/placeholder_select.png"];
        }
        if(isSupportThemeColor) {
            defaultSelectedImage = [defaultSelectedImage cmp_imageWithTintColor:selectThemeColor];
        }
        [itemContent setObject:defaultSelectedImage forKey:@"defaultSelectedImage"];
        
        if (attr.dataSource == CMPTabBarItemAttributeFromNetwork) {
            NSString *nomalImageUrl = [attr.normalImage replaceCharacter:@"\\" withString:@"/"];
            nomalImageUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl, nomalImageUrl];
            NSString *selectedImageUrl = [attr.selectedImage replaceCharacter:@"\\" withString:@"/"];
            selectedImageUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl, selectedImageUrl];
            if (CMPCore.sharedInstance.serverIsLaterV8_0) {
                NSString *theme = [CMPThemeManager sharedManager].isDisplayDrak ? @"black" : @"white";
                nomalImageUrl = [nomalImageUrl appendHtmlUrlParam:@"theme" value:theme];
                selectedImageUrl = [selectedImageUrl appendHtmlUrlParam:@"theme" value:theme];
            }
            [itemContent setObject:nomalImageUrl forKey:@"imageUrl"];
            [itemContent setObject:selectedImageUrl forKey:@"selectedImageUrl"];
        }
        
        [itemContents addObject:itemContent];
    }
    if (clear) {
        if (self.viewControllers) {
            NSUInteger preSelectedIndex = self.selectedIndex;
            if (IS_IPHONE) {
                CMPNavigationController *preSelectedViewController = (CMPNavigationController *)self.selectedViewController;
                UIViewController *preSelectedTopViewController = preSelectedViewController.topViewController;
                if (preSelectedViewController.viewControllers.count == 1 && ![preSelectedTopViewController isKindOfClass:[CMPBaseWebViewController class]]) {
                    vcs[preSelectedIndex] = preSelectedViewController;
                }
            } else {
                CMPSplitViewController *preSelectedViewController =  (CMPSplitViewController *)self.selectedViewController;
                CMPNavigationController *preNavigationController = nil;
                UIViewController *preSelectedTopViewController = nil;
                if (InterfaceOrientationIsPortrait) {
                   preNavigationController = preSelectedViewController.detailNavigation;
                   preSelectedTopViewController = preNavigationController.topViewController;
                } else {
                   preNavigationController = preSelectedViewController.masterNavigation;
                   preSelectedTopViewController = preNavigationController.topViewController;
                }
                if (preNavigationController.viewControllers.count == 1 && ![preSelectedTopViewController isKindOfClass:[CMPBaseWebViewController class]]) {
                    vcs[preSelectedIndex] = preSelectedViewController;
                    [preSelectedTopViewController cmp_clearDetailViewController];
                }
            }
        }
        self.viewControllers = vcs;
    }
    
    
    // 初始化tabBarItem的title、icon
    for (int i = 0; i < itemContents.count; ++i) {
        RDVTabBarItem *item = self.tabBar.items[i];
        NSDictionary *content = itemContents[i];
        item.tag = [content[@"tag"] integerValue];
        [item setTitle:content[@"title"]];
        // 图标展示规则：
        // 1. 先展示defaultImage、defaultSelectedImage
        // 2. 如果有imageUrl、selectedImageUrl，从url下载图标更换图标
        [item cmp_setImageUrl:content[@"imageUrl"] placeHolder:content[@"defaultImage"]];
        [item cmp_setSelectedImageUrl:content[@"selectedImageUrl"] placeHolder:content[@"defaultSelectedImage"]];
    }
    
    // 初始化快捷菜单按钮、头像
    [self setupPortaitAntShortcuts];
}

- (void)setupPortaitAntShortcuts {
}

- (UIViewController *)viewControllerWithAttribute:(CMPTabBarItemAttribute *)attr {
    UIViewController *vc = nil;
    
    if ([attr.appID isEqualToString:kM3AppID_Contacts]) {
        // 1130版本通讯录为H5页面
        if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
            CMPTabBarWebViewController * aTabBarWebViewController = [[CMPTabBarWebViewController alloc] init];
            attr.appID = @"57";
            attr.app = nil;
            aTabBarWebViewController.itemAttribute = attr;
            vc = aTabBarWebViewController;
        } else {
            vc = [[CMPOfflineContactViewController alloc] init];
        }
    } else if ([attr.appID isEqualToString:kM3AppID_Message]) {
        //消息
        vc = [[CMPMessageListViewController alloc] init];
    } else if ([attr.appID isEqualToString:kM3AppID_Shortcut]) {
        // 快捷菜单
        vc = [[UIViewController alloc] init];
    } else {
        CMPTabBarWebViewController * aTabBarWebViewController = [[CMPTabBarWebViewController alloc] init];
        aTabBarWebViewController.itemAttribute = attr;
        aTabBarWebViewController.hideBannerNavBar = YES;
        aTabBarWebViewController.viewDidAppearCallBack = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_TabbarChildViewControllerDidAppear object:nil];
        };
        vc = aTabBarWebViewController;
    }
    
    return vc;
}

- (NSString *)titleWithAttribute:(CMPTabBarItemAttribute *)attr language:(NSString *)language font:(UIFont *)font itemWidth:(CGFloat)itemWidth {
    NSString *title = nil;
    
    if ([language rangeOfString:@"en"].location != NSNotFound) {
        title = [attr.enTitle stringByTruncatingTailWithFont:font width:itemWidth];
    } else if ([language rangeOfString:@"zh-Hans"].location != NSNotFound &&
               attr.chHansTitle) {
        title = [attr.chHansTitle stringByTruncatingTailWithFont:font width:itemWidth];
    } else {
        title = [attr.chTitle stringByTruncatingTailWithFont:font width:itemWidth];
    }
    
    return title;
}

- (void)setTabAttr:(CMPTabBarAttribute *)tabAttr {
    if (tabAttr == nil) {
        return;
    }

    if (tabAttr == _tabAttr) {
        return;
    }
    
    _tabAttr = tabAttr;
    NSLog(@"rao-normal=%@|selected=%@",_tabAttr.titleColor,_tabAttr.titleSelectedColor);
    UIColor *titleNormalColor = [UIColor colorWithHexString:_tabAttr.titleColor];
    UIColor *titleSelectedColor = [UIColor colorWithHexString:_tabAttr.titleSelectedColor];
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(RDVTabBarItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.selectedTitleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:kTabBarItemFont],
                                         NSForegroundColorAttributeName:titleSelectedColor};
        item.unselectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kTabBarItemFont],
                                           NSForegroundColorAttributeName:titleNormalColor};
    }];
}

/*
 @[
 @{ @"title":@"xxx",
    @"defaultImage":defaultImage,
    @"imageUrl":@"xxx",
    @"appId":@"xxx"
 }
 ]
 */
- (NSArray *)getExpandItem:(NSArray *)itemAttrs attr:(CMPTabBarAttribute *)expandTabAttr{
    // TabBar的ViewController对应的标题、图标等数据
    NSMutableArray *itemContents = [[NSMutableArray alloc] init];
    NSUInteger count = itemAttrs.count;
    CGFloat itemWidth = self.view.cmp_width / 5;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    UIFont *titleFont = [UIFont systemFontOfSize:kTabBarItemFont];
    
    UIColor *normalColor = [CMPCore sharedInstance].serverIsLaterV7_1_SP1 ? UIColorFromRGB(0xB3C4DB) : UIColorFromRGB(0x989898);
    BOOL isSupportThemeColor = [CMPCore sharedInstance].serverIsLaterV7_1_SP1 ;
    
    UIColor *titleNormalColor = [UIColor colorWithHexString:expandTabAttr.titleColor];
//    UIColor *titleSelectedColor = [UIColor colorWithHexString:expandTabAttr.titleSelectedColor];
    
    for (int i = 0; i < count; i++) {
        CMPTabBarItemAttribute *attr = [itemAttrs objectAtIndex:i];
        if (!attr.isShow) {
            continue;
        }
        NSString *appID = attr.appID;
        
        
        NSMutableDictionary *itemContent = [NSMutableDictionary dictionary];
        [itemContent setObject:attr forKey:@"attr"];
        
        [itemContent setObject:titleNormalColor forKey:@"titleNormalColor"];
//        [itemContent setObject:titleSelectedColor forKey:@"titleSelectedColor"];
        
        NSInteger tag = [appID integerValue] + CMPTabBarExpandItemTag;
        [itemContent setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
        
        NSString *title = [self titleWithAttribute:attr language:currentLanguage font:titleFont itemWidth:itemWidth];
        [itemContent setObject:title ?: @"" forKey:@"title"];
        
        UIImage *defaultImage = [attr normalImg];
        if (!defaultImage) {
            defaultImage = [UIImage imageNamed:@"tabBar.bundle/placeholder.png"];
        }
        if(isSupportThemeColor) {
            defaultImage = [defaultImage cmp_imageWithTintColor:normalColor];
        }
        [itemContent setObject:defaultImage forKey:@"defaultImage"];
                
//        if (attr.dataSource == CMPTabBarItemAttributeFromNetwork) {
            NSString *nomalImageUrl = [attr.normalImage replaceCharacter:@"\\" withString:@"/"];
            nomalImageUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl, nomalImageUrl];
            
            NSString *selectedImageUrl = [attr.selectedImage replaceCharacter:@"\\" withString:@"/"];
            selectedImageUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl, selectedImageUrl];
            
            if (CMPCore.sharedInstance.serverIsLaterV8_0) {
                NSString *theme = [CMPThemeManager sharedManager].isDisplayDrak ? @"black" : @"white";
                nomalImageUrl = [nomalImageUrl appendHtmlUrlParam:@"theme" value:theme];
                selectedImageUrl = [selectedImageUrl appendHtmlUrlParam:@"theme" value:theme];
            }
            [itemContent setObject:nomalImageUrl forKey:@"imageUrl"];
//            [itemContent setObject:selectedImageUrl forKey:@"selectedImageUrl"];
//        }
        
        [itemContents addObject:itemContent];
    }
    return itemContents;
}

#pragma mark-
#pragma mark 切换页签

- (void)selectMessage {
    UIViewController *selectedVc = self.selectedViewController;
    if (![selectedVc isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    UINavigationController *nav = (UINavigationController *)selectedVc;
    NSArray *viewcontrollers = nav.viewControllers;
    
    if (viewcontrollers.count != 1) { // 二级页面，不跳转消息一级页面
        return;
    }
    
    self.selectedIndex = [self indexOfMessage];
}

- (NSInteger)indexOfMessage {
    NSInteger index;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        index = [self fetchTabBarIndexWithAppKey:[self appKeyWithAppID:kM3AppID_Message]];
    } else {
        index = [self fetchTabBarIndexWithAppID:kM3AppID_Message];
    }
    return index;
}

- (void)openCommonApp {
    NSUInteger commonAppIndex = -1;
    for (int i = 0; i < self.tabBar.items.count; ++i) {
        RDVTabBarItem *item = self.tabBar.items[i];
        NSInteger tag = item.tag - CMPTabBarItemTag;
        if (tag == 52) {
            commonAppIndex = i;
            break;
        }
    }
    
    if (commonAppIndex != -1) {
        [self setSelectedIndex:commonAppIndex];
    } else {
        [self openCommonAppInShortcut];
    }
}

/**
 通过快捷菜单打开常用应用
 */
- (void)openCommonAppInShortcut {
    CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
    vc.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kM3CommonAppUrl]];
    vc.hideBannerNavBar = NO;
    vc.backBarButtonItemHidden = YES;
    vc.titleType = CMPBannerTitleTypeLeft;
    CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:vc delegate:nil];
    [self replaceSelectedViewController:splitVc];
    [self.tabBar setSelectedItem:self.commonAppItem];
}

#pragma mark-
#pragma mark 网络请求

/**
 请求待办是否有未读条目
 */
- (void)requestUpdatePendingAndMessage
{
    NSString *url = [CMPCore fullUrlForPath:@"/rest/m3/common/hasPendingAndMessage"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    //修复-[__NSArrayM objectForKey:]: unrecognized selector sent to instance 0x12f8dc9b0问题
    id dic = [[aResponse responseStr] JSONValue];
    if (![dic isKindOfClass: [NSDictionary class]]) {
        NSLog(@"返回数据不是字典a");
        return;
    }
    NSInteger code = [[dic objectForKey:@"code"] integerValue];
    if (code == 200) {
        id data = [dic objectForKey:@"data"];
        if (![data isKindOfClass: [NSDictionary class]]) {
            NSLog(@"返回数据不是字典a");
            return;
        }
        BOOL pending = [[data objectForKey:@"pending"] boolValue];
        [self setTabBarBadge:kM3AppID_Todo show:pending];
        [[CMPMessageManager sharedManager] setupTabBarMsgBadge];
    }
}

#pragma mark-
#pragma mark-加载APP

/**
 判断App是否需要过滤
 */
- (BOOL)filterUselessApp:(NSDictionary *)argumentsMap {
    NSString *appType = [argumentsMap objectForKey:@"appType"];
    if ([appType isEqualToString:@"integration_shortcut"] ||
        [appType isEqualToString:@"integration_recommend"]) {
        return true;
    }
    return false;
}

/**
 删除需要隐藏的APPID对应的CMPTabBarItemAttribute
 
 @param deleteSet 需要删除的APPID
 @param itemAttrArr CMPTabBarItemAttribute数组
 @return 处理之后的数组
 */
- (NSArray *)deleteNeedHiddenApps:(NSSet *)deleteSet appList:(NSArray *)itemAttrArr
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < itemAttrArr.count; i++) {
        NSDictionary *itemAttrJSON = [itemAttrArr objectAtIndex:i];
        CMPTabBarItemAttribute *itemAttr = [NSObject objectWithDictionaryRepresentation:itemAttrJSON];
        // 判断是否有my模块
        if ([itemAttr.appID integerValue] == [kM3AppID_My integerValue]) {
            [CMPCore sharedInstance].hasMyInTabBar = YES;
        }
        if([deleteSet containsObject:itemAttr.appID] ||
           !itemAttr.isShow){
            continue;
        }
        [result addObject:itemAttr];
    }
    return result;
}

//设置tabBar item上badge 红点
- (void)setTabBarBadge:(NSString *)appID show:(BOOL)show
{
    NSUInteger index = [self fetchTabBarIndexWithAppID:appID];
    if (index == -1) {
        index = [self fetchExpandTabBarIndexWithAppID:appID];
        if (index == -1) {
            return;
        }
        //扩展导航
        [self dispatchAsyncToMain:^{
            [self setExpandBadgeShow:show atIndex:index];
        }];
    }else{
        //tab主导航
        [self dispatchAsyncToMain:^{
            [self setBadgeShow:show atIndex:index];
        }];
    }
}

- (NSUInteger)fetchTabBarIndexWithAppID:(NSString *)appID
{
    int index = -1;
    for(int i = 0; i < self.tabBar.items.count; i++){
        RDVTabBarItem *item = self.tabBar.items[i];
        if((item.tag - CMPTabBarItemTag) == [appID integerValue]){
            index = i;
            break;
        }
    }
    return index;
}
- (NSUInteger)fetchExpandTabBarIndexWithAppID:(NSString *)appID
{
    int index = -1;
    for(int i = 0; i < self.tabBar.expandItems.count; i++){
        NSDictionary *item = self.tabBar.expandItems[i];
        NSInteger tag = [item[@"tag"] integerValue];
        if((tag - CMPTabBarExpandItemTag) == [appID integerValue]){
            index = i;
            break;
        }
    }
    return index;
    return 0;
}


- (NSUInteger)fetchTabBarIndexWithAppKey:(NSString *)appKey {
    int indexOfMessage = 0;
    // 1.8.0及以上版本使用appkey来排序
    
    int offset = 0;
    for (CMPTabBarItemAttribute *item in self.itemAttrs) {
        if (INTERFACE_IS_PAD) {
            if ([item.appID isEqualToString:kM3AppID_Shortcut]) {
                offset = 1;
            }
        }
        
        if ([item.appKey isEqualToString:appKey]) {
            int index = [self.itemAttrs indexOfObject:item];
            return index - offset;
        }
        
        if ([item.appID isEqualToString:kM3AppID_Message]) {
            indexOfMessage = [self.itemAttrs indexOfObject:item];
        }
    }
    
    if (indexOfMessage < self.itemAttrs.count) {
        CMPTabBarItemAttribute *item = self.itemAttrs[indexOfMessage];
        if ([item.appID isEqualToString:kM3AppID_Shortcut]) {
            indexOfMessage = indexOfMessage + 1 % self.itemAttrs.count;
            DDLogDebug(@"zl---[%s]首页成了快捷菜单，自动往后移动一位", __FUNCTION__);
        }
    }
    
    return indexOfMessage - offset;
}

- (BOOL)isAppIDMy:(NSString *)appKey {
    for (CMPTabBarItemAttribute *item in self.itemAttrs) {
        if ([item.appKey isEqualToString:appKey] && [item.appID isEqualToString:kM3AppID_My]) {
            return YES;
        }
    }
    return NO;
}

/**
 根据APPID获取APPKey
 */
- (NSString *)appKeyWithAppID:(NSString *)appID {
    for (CMPTabBarItemAttribute *item in self.itemAttrs) {
        if ([item.appID isEqualToString:appID]) {
            return item.appKey;
        }
    }
    return nil;
}

- (NSMutableArray<CMPTabBarItemAttribute *> *)sortTabbarItemAttributeList:(NSArray *)tabBarItemAttributeList {
    NSMutableArray<CMPTabBarItemAttribute *> *sortArr = [NSMutableArray arrayWithArray:tabBarItemAttributeList];
    [sortArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CMPTabBarItemAttribute *item1 = (CMPTabBarItemAttribute *)obj1;
        CMPTabBarItemAttribute *item2 = (CMPTabBarItemAttribute *)obj2;
        if ([item1.sortNum integerValue] > [item2.sortNum integerValue]) {
            return NSOrderedDescending;
        } else if ([item1.sortNum integerValue] == [item2.sortNum integerValue]) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
    return sortArr;
}

#pragma mark-
#pragma mark 首页设置

+ (NSString *)tabBarHomeKey {
    NSString *key = _homeTabBarKey();
    CMPCore *cmpCore = [CMPCore sharedInstance];
    NSString *userID = [cmpCore userID];
    NSString *serverID = [cmpCore serverID];
    NSString *oldKey = [NSString stringWithFormat:@"%@_%@",serverID, userID];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *oldValue = [userDefault objectForKey:oldKey];
    if (![NSString isNull:oldValue]) { // 老版本数据升级
        [userDefault setObject:oldValue forKey:key];
        [userDefault removeObjectForKey:oldKey];
        [userDefault synchronize];
    }

    NSString *appID = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return appID;
}

+ (void)setHomeTabBar:(NSString *)appID {
    NSString *key = _homeTabBarKey();
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:appID forKey:key];
}

/**
 默认首页的AppKey
 */
- (NSString *)defaultHomeAppID {
    NSString *appID = nil;
    // 1.8.0版本以后默认消息
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        appID = [self appKeyWithAppID:kM3AppID_Message];
    } else {
        // 低版本默认待办
        appID = kM3AppID_Todo;
    }
    return appID;
}

/**
 用户设置的首页Key
 */
NSString *_homeTabBarKey() {
    CMPCore *cmpCore = [CMPCore sharedInstance];
    NSString *userID = [cmpCore userID];
    NSString *serverID = [cmpCore serverID];
    NSString *accountID = cmpCore.currentUser.accountID;
    NSString *key = nil;
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {
        key = [NSString stringWithFormat:@"TabBarHome_%@_%@_%@",serverID,userID,accountID];
    } else {
        key = [NSString stringWithFormat:@"%@_%@_%@",serverID,userID,accountID];
    }
    return key;
}

#pragma mark-
#pragma mark 私有方法

/**
 1、获取用户设置的首页
 2、没有用户设置的取管理员设置的
 3、前两者都没有取默认值
 
 @return 首页的AppID、AppKey
 */
- (NSString *)_homeApp {
    // 如果正在下载H5应用包，则设置消息页签
    // V7.1之后版本支持在H5页面下载应用包
    if (![CMPCore sharedInstance].serverIsLaterV7_1 &&
        ![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        return kM3AppID_Message;
    }
    
    // 点击通知消息启动的应用，默认展示消息列表
    AppDelegate *appDelegate = [AppDelegate shareAppDelegate];
    if (appDelegate.launchFromNotification) {
        return [self defaultHomeAppID];
    }
    
    // 取用户设置
    NSString *appID = [CMPTabBarViewController tabBarHomeKey];
    if(![NSString isNull:appID]) {
        return appID;
    }
    
    // 没有用户设置，使用默认首页
    return [self defaultHomeAppID];
}

#pragma mark-
#pragma mark 子类继承

- (void)onlyOneTabBarItem {
    
}

- (UIViewController *)itemViewControllerWithRoot:(UIViewController *)rootVc appID:(NSString *)appID {
    return nil;
}

#pragma mark-
#pragma mark RDVTabBarControllerDelegate

- (BOOL)tabBarControllerCanUse:(RDVTabBarController *)tabBarController {
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return NO;
    }
    return YES;
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBar shouldSelectItemAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block {
    
    clickCount++;
    if (index == tabBar.selectedIndex) {
        if ( clickCount % 2 == 0) {
            [[CMPNativeToJsModelManager shareManager] safeHandleIfForce:YES];;
            CMPNavigationController *nav = tabBar.viewControllers[index];
            if (nav && [nav isKindOfClass:[CMPNavigationController class]]) {
                if ([nav.viewControllers[0] respondsToSelector:@selector(reloadData)]) {
                    [nav.viewControllers[0] performSelector:@selector(reloadData)];
                }
            }
        }
        dispatch_time_t dipatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(dipatchTime, dispatch_get_main_queue(), ^{
            self->clickCount = 0;
        });
    }else{
        clickCount = 0;
    }
    
    void (^alertBlock) (void) = ^ {
        RDVTabBarItem *item = tabBar.tabBar.items[index];
        if (item.tag - CMPTabBarItemTag == [kM3AppID_Shortcut integerValue]) {
            if (INTERFACE_IS_PHONE) {
                UIViewController *selectVc = ((UINavigationController *)self.selectedViewController).topViewController;
                [selectVc setValue:[NSNumber numberWithBool:NO] forKey:@"allowRotation"];
            }
            [CMPShortcutHelper showInViewController:self];
            return;
        }
        block();
        return;
    };
    
    if (![self isResponseTojump]) {
        [self popUpAlertWithAlertActionBlock:alertBlock];
        return NO;
    }
    
    // 处理特殊情况，快捷菜单配置到底导航
    RDVTabBarItem *item = tabBar.tabBar.items[index];
    if (item.tag - CMPTabBarItemTag == [kM3AppID_Shortcut integerValue]) {
        if (INTERFACE_IS_PHONE) {
            UIViewController *selectVc = ((UINavigationController *)self.selectedViewController).topViewController;
            [selectVc setValue:[NSNumber numberWithBool:NO] forKey:@"allowRotation"];
        }
        [CMPShortcutHelper showInViewController:self];
        return NO;
    }

    if (CMP_IPAD_MODE && self.selectedIndex == index) {
        //ipad 竖屏状态下，重复点击，返回首页
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            UIViewController *viewController = tabBar.viewControllers[index];
            [viewController.cmp_splitViewController.detailNavigation popToRootViewControllerAnimated:YES];
            viewController.cmp_splitViewController.masterStackSize = 1;
            return NO;
        }
    }
    return YES;
}

- (void)tabBarControllerDidTapPortrait:(RDVTabBarController *)tabBarController {
    
    void (^alertBlock) (void) = ^ {
        UIViewController *vc = [CMPPersonInfoUtils userSettingViewController];
        CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:vc delegate:self];
        [self replaceSelectedViewController:splitVc];
        return;
    };
    
    if (![self isResponseTojump]) {
        [self popUpAlertWithAlertActionBlock:alertBlock];
        return;
    }
    alertBlock();
}

-(BOOL)tabBar:(RDVTabBar *)tabBar didSelectShortcutAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block{
    void (^alertBlock) (void) = ^ {
        block();
    };
    if (![self isResponseTojump]) {
        [self popUpAlertWithAlertActionBlock:alertBlock];
        return NO;
    }
    return YES;
}

- (BOOL)isResponseTojump {
    BOOL isjump = YES;
    if (CMP_IPAD_MODE) {
        CMPBaseWebViewController *viewController = (CMPBaseWebViewController *)((CMPSplitViewController *)self.selectedViewController).detailNavigation.topViewController;
        if ([viewController isKindOfClass:[CMPBaseWebViewController class]] && viewController.isLockPageOnPad) {
//            [viewController backBarButtonAction:nil];
            isjump = NO;
            return isjump;
        }
        
        viewController = (CMPBaseWebViewController *)((CMPSplitViewController *)self.selectedViewController).masterNavigation.topViewController;
        if ([viewController isKindOfClass:[CMPBaseWebViewController class]] && viewController.isLockPageOnPad) {
//            [viewController backBarButtonAction:nil];
            isjump = NO;
            return isjump;
        }
    }
    return isjump;
}

- (void)popUpAlertWithAlertActionBlock:(void (^)(void))alertblock {
    CMPAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:SY_STRING(@"pad_lock_hint") cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {//取消
            
        } else if (buttonIndex == 1){//确定
            alertblock();
        }
    }];
    [aAlertView show];
}

//扩展导航编辑按钮
- (void)expandTabBarEditClick:(id)sender{
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = @"http://my.m3.cmp/v1.0.0/layout/my-nav-set.html";
    aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aCMPBannerViewController.hideBannerNavBar = NO;
    aCMPBannerViewController.backBarButtonItemHidden = NO;
    aCMPBannerViewController.statusBarStyle = 0;
    [self pushViewController:aCMPBannerViewController];
}

- (NSString *)transitPageIndexPathWithAttribute:(CMPTabBarItemAttribute *)attr {
    CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:@"52"
                                                    version:@"1.0.0"
                                                   serverId:kCMP_ServerID
                                                     owerId:kCMP_OwnerID];
    if (!appInfo.path) {
        return nil;
    }
    
    NSString *aRootPath = [CMPCachedResManager rootPathWithHost:appInfo.url_schemes version:attr.version];
    if (aRootPath) {
        NSString *indexPath = nil;
        NSString *entry = [NSString stringWithFormat:@"layout/m3-transit-page.html?id=%@", attr.appKey];
        indexPath = [aRootPath stringByAppendingPathComponent:entry];
        indexPath = [@"file://" stringByAppendingString:indexPath];
        return indexPath;
    }
    return nil;
}

//扩展导航item点击
- (void)expandTabBarItemClick:(id)item{
    NSDictionary *itemDict = item;
    CMPTabBarItemAttribute *attrItem = itemDict[@"attr"];
    
    
    if ([attrItem.appID isEqualToString:kM3AppID_Shortcut]) {//快捷操作
        if (INTERFACE_IS_PHONE) {
            UIViewController *selectVc = ((UINavigationController *)self.selectedViewController).topViewController;
            [selectVc setValue:[NSNumber numberWithBool:NO] forKey:@"allowRotation"];
        }
        [CMPShortcutHelper showInViewController:self];
    }
    else if ([attrItem.appID isEqualToString:kM3AppID_Todo]) {//待办
        NSString *url = @"http://todo.m3.cmp/v/layout/todo-list.html";
        NSString *href = [url urlCFEncoded];
        href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        NSDictionary *aParam = @{
            @"options":@{
                @"animated":@(1),
                @"openWebview":@(1),
                @"useNativebanner":@(1)
            },
            @"param":@{
                @"fromPage":@"app"
            },
            @"url":@"http://todo.m3.cmp/v/layout/todo-list.html"
        };
        aCMPBannerViewController.startPage = href;
        aCMPBannerViewController.pageParam = aParam;
        aCMPBannerViewController.hideBannerNavBar = NO;
        aCMPBannerViewController.statusBarStyle = 0;
        [self pushViewController:aCMPBannerViewController];
        //记录pushPage点击次数
        [[CMPTopScreenManager new] pushPageClickByParam:aParam];
    }
    else if ([attrItem.appID isEqualToString:kM3AppID_Application]) {//应用中心
        NSString *url = kM3CommonAppUrl;
        NSString *href = [url urlCFEncoded];
        href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = href;
        aCMPBannerViewController.hideBannerNavBar = NO;
        aCMPBannerViewController.backBarButtonItemHidden = NO;
        aCMPBannerViewController.statusBarStyle = 0;
        [self pushViewController:aCMPBannerViewController];
    }
    else if([attrItem.appID isEqualToString:kM3AppID_Message]){//消息
        CMPMessageListViewController *mvc = [[CMPMessageListViewController alloc] init];
        [self pushViewController:mvc];
    }
    else if([attrItem.appID isEqualToString:@"65"]){//工作门户
        NSDictionary *argumentsMap = attrItem.app;
        NSString *appType = [argumentsMap objectForKey:@"appType"];
        
        //兼容两个门户appid=65的情况
        if ([appType isEqualToString:@"biz"] || [appType isEqualToString:@"integration_portal"]){
            if (!attrItem || ![attrItem isKindOfClass:CMPTabBarItemAttribute.class]) {
                [self cmp_showHUDWithText:@"底导航数据格式错误"];
                return;
            }
                        
            NSString *aRootPath = [self transitPageIndexPathWithAttribute:attrItem];
            if (aRootPath) {
                aRootPath = [aRootPath appendHtmlUrlParam:@"m3from" value:@"workbench"];
                aRootPath = [aRootPath appendHtmlUrlParam:@"useNativebanner" value:@"1"];
                
                if ([NSString isNull:aRootPath]) {
                    NSLog(@"%@",SY_STRING(@"loadApp_fail"));
                    [self cmp_showHUDWithText:SY_STRING(@"loadApp_fail")];
                    return;
                }
                
                NSDictionary *pageParam = @{
                    @"url":aRootPath,
                    @"useNativebanner":@YES
                };
                CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                aCMPBannerViewController.startPage = aRootPath;
                aCMPBannerViewController.pageParam = pageParam;
                aCMPBannerViewController.hideBannerNavBar = NO;
                aCMPBannerViewController.ignoreJsBackHandle = YES;
                [self pushViewController:aCMPBannerViewController];
            }
            return;
        }
        
        NSString *url = @"http://portal.v5.cmp/v/html/portalIndex.html";
        NSString *href = [url urlCFEncoded];
        href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = href;
        aCMPBannerViewController.hideBannerNavBar = NO;
        aCMPBannerViewController.backBarButtonItemHidden = NO;
        aCMPBannerViewController.statusBarStyle = 0;
        [self pushViewController:aCMPBannerViewController];
    }
    else if([attrItem.appID isEqualToString:kM3AppID_Contacts]||[attrItem.appID isEqualToString:@"57"]){//通讯录 可能是57或者62
        if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
            attrItem.appID = @"57";//新版通讯录id=57
            NSDictionary *aParam = @{
                @"options":@{
                    @"animated":@(1),
                    @"openWebview":@(1),
                    @"useNativebanner":@(0)
                },
                @"param":@{
                    @"fromPage":@"app"
                },
                @"url":@"http://search.m3.cmp/v1.0.0/layout/address-index.html"
            };
            NSString *url =  @"http://search.m3.cmp/v1.0.0/layout/address-index.html";
            url = [url appendHtmlUrlParam:@"useNativebanner" value:@"0"];
            NSString *href = [url urlCFEncoded];
            href = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.startPage = href;
//            aCMPBannerViewController.title = @"";
            aCMPBannerViewController.statusBarStyle = 0;
//            aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
            aCMPBannerViewController.hideBannerNavBar = YES;
            [self pushViewController:aCMPBannerViewController];
            //记录pushPage点击次数
            [[CMPTopScreenManager new] pushPageClickByParam:aParam];
        }
        else {
            CMPOfflineContactViewController *vc = [[CMPOfflineContactViewController alloc] init];
            vc.isShowBackButton = YES;
            [self pushViewController:vc];
        }
    }
    else if([attrItem.appID isEqualToString:kM3AppID_My]){//我的
        CMPBannerWebViewController *vc = (CMPBannerWebViewController *)[CMPPersonInfoUtils userSettingViewController];
        vc.hideBannerNavBar = NO;
        [self pushViewController:vc];
    }
    else{
        [self loadapp:attrItem.app ext:attrItem];
    }
    //记录点击数据
    CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
    [tabBarProvider appClick:attrItem.appID appName:attrItem.chTitle uniqueId:attrItem.appUniqueId];
}

- (void)loadapp:(NSDictionary *)argumentsMap ext:(id)ext{
    if (!argumentsMap) {
        return;
    }
    
    //记录扩展导航的点击
    NSMutableDictionary *mD = [NSMutableDictionary dictionaryWithDictionary:argumentsMap];
    [mD setValue:@(YES) forKey:@"fromExpandTab"];
    if ([ext isKindOfClass:CMPTabBarItemAttribute.class]) {
        CMPTabBarItemAttribute *itemAttr = ext;
        if (itemAttr.appKey) {
            [mD setValue:itemAttr.appKey forKey:@"appKey"];
        }
    }
    
    NSString *appType = [argumentsMap objectForKey:@"appType"];
    if (![appType isEqualToString:@"biz"]) {//如果是biz应用，则只记录pushPage
        [[CMPTopScreenManager new] loadAppClickByParam:mD];
    }
    NSString *entry = [argumentsMap objectForKey:@"entry"];
    NSString *parameters = [argumentsMap objectForKey:@"gotoParam"];
    NSInteger iOSStatusBarStyle = [[argumentsMap objectForKey:@"iOSStatusBarStyle"] integerValue];
    NSString *m3from = @"workbench";//[argumentsMap objectForKey:@"from"];
    NSNumber *isEncode = [argumentsMap objectForKey:@"isEncode"];
    
    // 清空内容区，在内容区展示新页面，仅在 iPad 且 openWebview为YES时生效，默认值为 NO
    BOOL pushPageInDetail = [[argumentsMap objectForKey:@"pushInDetailPad"] boolValue];
    // 清空内容区域，仅在iPad 且 openWebview为YES 且 pushInDetailPad为NO时生效，默认值为 YES
    BOOL clearDetailPage = [argumentsMap objectForKey:@"clearDetailPad"] ? [[argumentsMap objectForKey:@"clearDetailPad"] boolValue] : YES;
    
    if ([entry isKindOfClass:[NSString class]] && [NSString isNull:entry]) {
        entry = @"";
    }
    // 判断是否需要在新的webview打开
    BOOL isOpenNewWebview = [argumentsMap objectForKey:@"isOpenWebview"] ? false : true;
    BOOL isTailWebView = NO;
    
    // 判断是否超过多WebView阈值
    if ([CMPBannerWebViewController isWebViewMaxCount]) {
        isOpenNewWebview = NO;
        isTailWebView = YES;
    }
    
    // 判断是否为远程的h5 url地址
    if ([appType isEqualToString:@"integration_remote_url"]) {
        if (![entry isKindOfClass:[NSString class]]) {
            entry = @"";
        }
        
        // 映射到本地
        NSURL *entryURL = [NSURL URLWithString:entry];
        NSString *cachedPath = [CMPCachedUrlParser cachedPathWithUrl:entryURL];
        if (![NSString isNull:cachedPath]) {
            entry = cachedPath;
        }
        
        BOOL isEncodeUrl = isEncode ? isEncode.boolValue : YES ;
        if (isEncodeUrl) {
            entry = [entry urlCFEncoded];
        }
        
        if (![NSString isNull:m3from]) {
            entry = [entry appendHtmlUrlParam:@"m3from" value:m3from];
        }
        
        if (isOpenNewWebview) {
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.startPage = entry;
            aCMPBannerViewController.hideBannerNavBar = NO;
            aCMPBannerViewController.isShowBannerProgress = YES;
            aCMPBannerViewController.closeButtonHidden = NO;
            
            [self pushViewController:aCMPBannerViewController];
        } else {
            CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc]init];
            aController.isShowBannerProgress = YES;
            aController.closeButtonHidden = NO;
            aController.isTailWebView = isTailWebView;
            
            // 设置显示原生头部
            [aController showNavBarforWebView:@1];
            NSURL* url = [[NSURL alloc] initWithString:entry];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [aController.webViewEngine loadRequest:request];
            
            [self pushViewController:aController];
        }
    }
    // 判断是否为本地原生app
    else if ([appType isEqualToString:@"integration_native"]) {
        NSString *downloadUrl = nil;
        if ([entry isKindOfClass:[NSDictionary class]]) {
            downloadUrl = ((NSDictionary *)entry)[@"download"];
            entry = [(NSDictionary *)entry objectForKey:@"command"];
        }
        NSArray *aList = [entry componentsSeparatedByString:@"://"];
        NSString *prefix = entry;
        if (aList.count == 2) {
            prefix = [aList objectAtIndex:0];
            parameters = [aList objectAtIndex:1];
        }
        parameters = (NSString *)
        CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)parameters,
                                                                  NULL,
                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                  kCFStringEncodingUTF8));

        prefix = [NSString stringWithFormat:@"%@://%@", prefix, parameters];
        NSURL *appUrl = [NSURL URLWithString:prefix];
        if (![[UIApplication sharedApplication] openURL:appUrl]) {
            if (downloadUrl && [downloadUrl containsString:@"://"]) {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:SY_STRING(@"open_app_download_adress") message:downloadUrl cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
                    if (buttonIndex==1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    } else {
                        [self.selectedViewController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                [alert show];
            } else {
                CMPAlertView *alert = [[CMPAlertView alloc]initWithTitle:NULL message:[NSString stringWithFormat:SY_STRING(@"common_noAppDownloadAddress"),downloadUrl] cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:nil];
                [alert show];
            }
        }
    } else if ([appType isEqualToString:@"biz"]){
        if (!ext || ![ext isKindOfClass:CMPTabBarItemAttribute.class]) {
            return;
        }
        CMPTabBarItemAttribute *itemAttr = ext;
        CMPDBAppInfo *appInfo = [CMPAppManager appInfoWithAppId:@"52"
                                                        version:@"1.0.0"
                                                       serverId:kCMP_ServerID
                                                         owerId:kCMP_OwnerID];
        if (!appInfo.path) {
            return;
        }
        
        NSString *aRootPath = [CMPCachedResManager rootPathWithHost:appInfo.url_schemes version:@"1.0.0"];
        if (aRootPath) {
            NSString *indexPath = nil;
            NSString *entry = [NSString stringWithFormat:@"layout/m3-transit-page.html?id=%@", itemAttr.appKey];
            indexPath = [aRootPath stringByAppendingPathComponent:entry];
            indexPath = [@"file://" stringByAppendingString:indexPath];
            
            if ([NSString isNull:indexPath]) {
                NSLog(@"%@",SY_STRING(@"loadApp_fail"));
                return;
            }
            
            BOOL aUseNativebanner = NO;
            // 解析url参数
            NSDictionary *urlDict = [indexPath urlPropertyValue];
            NSString *useNativeBanner = [urlDict objectForKey:@"useNativebanner"];
            aUseNativebanner = [useNativeBanner boolValue];
            NSDictionary *pageParam = @{
//                @"param":@{@"appId":model.appId?:@"",
//                           @"gotoParams":model.gotoParam?:@""},
                @"url":indexPath
            };
            if (isOpenNewWebview) {
                CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                aCMPBannerViewController.startPage = indexPath;
                aCMPBannerViewController.pageParam = pageParam;
                aCMPBannerViewController.hideBannerNavBar = !aUseNativebanner;
                aCMPBannerViewController.statusBarStyle = iOSStatusBarStyle;
                aCMPBannerViewController.ignoreJsBackHandle = YES;
                
                [self pushViewController:aCMPBannerViewController];
            } else {
                CMPBannerWebViewController *aController =  (CMPBannerWebViewController *)self.selectedViewController;
                // 当前webview，需要入当前page堆栈
                [aController.pageStack addObject:pageParam];
                aController.isTailWebView = isTailWebView;
                // 设置显示原生头部
                NSNumber *showNumber = aUseNativebanner ? @1 : @0;
                [aController showNavBarforWebView:showNumber];
                NSURL* url = [[NSURL alloc] initWithString:indexPath];
                NSURLRequest* request = [NSURLRequest requestWithURL:url];
                [aController.webViewEngine loadRequest:request];
                
                [self pushViewController:aController];
            }
        }
    }
    else {
        NSString *host = [argumentsMap objectForKey:@"urlSchemes"];
        NSString *version = [argumentsMap objectForKey:@"version"];
        NSString *aRootPath = [CMPCachedResManager rootPathWithHost:host version:version];
        NSString *indexPath = nil;
        if (aRootPath) {
            NSString *aPath = aRootPath;
            NSString *manifestPath = [aPath stringByAppendingPathComponent:@"manifest.json"];
            NSString *JSONString = [NSString stringWithContentsOfFile:manifestPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *manifest = [JSONString JSONValue];
            NSString *entry = [[manifest objectForKey:@"entry"] objectForKey:@"phone"];
            indexPath = [aPath stringByAppendingPathComponent:entry];
            indexPath = [@"file://" stringByAppendingString:indexPath];
            if (![NSString isNull:m3from]) {
                indexPath = [indexPath appendHtmlUrlParam:@"m3from" value:m3from];
            }
            if (!manifest) {
                indexPath = nil;
            }
        }
        if ([NSString isNull:indexPath]) {
            NSLog(@"%@",SY_STRING(@"loadApp_fail"));
        }
        
        BOOL aUseNativebanner = NO;
        // 解析url参数
        NSDictionary *urlDict = [indexPath urlPropertyValue];
        NSString *useNativeBanner = [urlDict objectForKey:@"useNativebanner"];
        aUseNativebanner = [useNativeBanner boolValue];
        NSDictionary *pageParam = @{
            @"param":argumentsMap,
            @"url":indexPath
        };
        if (isOpenNewWebview) {
            CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
            aCMPBannerViewController.pageParam = pageParam;
            aCMPBannerViewController.startPage = indexPath;
            aCMPBannerViewController.hideBannerNavBar = !aUseNativebanner;
            aCMPBannerViewController.statusBarStyle = iOSStatusBarStyle;
            
            [self pushViewController:aCMPBannerViewController];
        } else {
            CMPBannerWebViewController *aController =  (CMPBannerWebViewController *)self.selectedViewController;
            // 当前webview，需要入当前page堆栈
            [aController.pageStack addObject:pageParam];
            aController.isTailWebView = isTailWebView;
            // 设置显示原生头部
            NSNumber *showNumber = aUseNativebanner ? @1 : @0;
            [aController showNavBarforWebView:showNumber];
            NSURL* url = [[NSURL alloc] initWithString:indexPath];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [aController.webViewEngine loadRequest:request];
            
            [self pushViewController:aController];
        }
    }
}

- (void)pushViewController:(UIViewController *)vc{
    if ([self.selectedViewController isKindOfClass:CMPNavigationController.class]) {
        CMPNavigationController *navi = (CMPNavigationController *)self.selectedViewController;
        [navi pushViewController:vc animated:YES];
    }else{
        CMPNavigationController *navi = [[CMPNavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:navi animated:YES completion:nil];
    }
    
}
#pragma mark - 重写父类的这两个方法，实现tabbarItem点击事件的处理
- (void)replaceSelectedViewController:(UIViewController *)viewController {
    [super replaceSelectedViewController:viewController];
    
    //这里做item点击处理
    //内存警告级别小于1时，证明未达到内存警告级别
    [self handleMemoryWarningWithViewController:viewController];
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    [super tabBar:tabBar didSelectItemAtIndex:index];
    
    if (self.itemAttrs.count>index) {
        //记录点击数据
        CMPTabBarItemAttribute *attrItem = self.itemAttrs[index];
        CMPTabBarProvider *tabBarProvider = [[CMPTabBarProvider alloc] init];
        [tabBarProvider appClick:attrItem.appID appName:attrItem.chTitle uniqueId:attrItem.appUniqueId];
    }
    
    CMPSplitViewController *splitViewController = (CMPSplitViewController *)self.viewControllers[index];
    if ([splitViewController isKindOfClass:[CMPSplitViewController class]]) {
        [splitViewController didSeleted];
    }
    
    //这里做item点击处理
    //内存警告级别小于1时，证明未达到内存警告级别
    [self handleMemoryWarningWithViewController:self.viewControllers[index]];
}

- (void)handleMemoryWarningWithViewController:(UIViewController *)viewController {
    //内存警告级别小于1时，证明未达到内存警告级别
//    int ml = OSMemoryNotificationCurrentLevel();
//    if (ml < 1) return;
//    
//    for (UIViewController *vc in self.viewControllers) {
//        if ([viewController isEqual: vc]) continue;
//        if ([vc isKindOfClass: [CMPBannerWebViewController class]]) {
//            CMPBannerWebViewController *tmpVc = (CMPBannerWebViewController *)vc;
//            
//        }
//        
//    }
}

/// 检测有没从外部分享文件过来的操作，有的话，就进行弹框分享
- (void)checkShareFromExternalApp {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    if (CMPCore.sharedInstance.hasSavedFileFromOtherApps && [userDefaults objectForKey:CMPSavedFileFromOtherAppsKey]) {
        NSDictionary *dic = [userDefaults objectForKey:CMPSavedFileFromOtherAppsKey];
        NSArray *filePaths = dic[@"path"];
        //显示分享界面
        [CMPShareManager.sharedManager showShareToInnerViewWithFilePaths:filePaths fromVC:[CMPCommonTool getCurrentShowViewController]];
        [userDefaults setObject:nil forKey:CMPSavedFileFromOtherAppsKey];
        CMPCore.sharedInstance.hasSavedFileFromOtherApps = NO;
    }
}

- (void)reloadTabBarClearView:(BOOL)isClearView {
    [CMPCore sharedInstance].showingTopScreen = NO;
    if (![[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        //1.8之前读配置文件m3TabConfig.json，不管它
        return;
    }
    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
    CMPLoginConfigInfoModel_2 *config = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];
    CMPTabBarAttribute *tabbarAttribute = config.tabBar.tabbarAttribute;
    NSArray *navBarList = [self sortTabbarItemAttributeList:config.tabBar.tabbarList];
    NSSet *delAppSet = [[NSSet alloc] initWithArray:[NSArray array]];
    navBarList = [self deleteNeedHiddenApps:delAppSet appList:navBarList];
    NSUInteger count = navBarList.count;
    if (count >1) {
        [navBarList enumerateObjectsUsingBlock:^(CMPTabBarItemAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.dataSource = CMPTabBarItemAttributeFromNetwork;
        }];
        [self setTabAttr:tabbarAttribute];
        [self setItemAttrs:navBarList clearView:isClearView];
        
        if (isClearView) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CMPWillReloadTabBarClearViewNotification object:nil];
            NSUInteger preSelectedIndex = self.selectedIndex;
            self.selectedIndex = preSelectedIndex;
            if (preSelectedIndex == 1000) {
                id selectedItem = self.tabBar.selectedItem;
                if ([selectedItem isKindOfClass:[UIButton class]]) {
                    [self.tabBar portraitDidSelected:selectedItem];
                } else {
                    __block RDVTabBarShortcutItem *selectedShortcutItem = selectedItem;
                    [self.tabBar.shortcutItems enumerateObjectsUsingBlock:^(RDVTabBarShortcutItem *shortcutItem, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (selectedShortcutItem.shortcutType == shortcutItem.shortcutType) {
                            selectedShortcutItem = shortcutItem;
                            *stop = YES;
                        }
                    }];
                    [self.tabBar shortcutDidSelected:selectedShortcutItem];
                }
            }
            [self dismissViewControllerAnimated:NO completion:nil];
            [self setTabBarHidden:NO animated:YES];
            [CMPShortcutHelper hide];
        }
    }
}

- (void)reloadTabBarIfNeed {
    [self reloadTabBarClearView:NO];
}

- (void)reloadTabBarAndReloadWebview {
    [self reloadTabBarClearView:YES];
}

@end
