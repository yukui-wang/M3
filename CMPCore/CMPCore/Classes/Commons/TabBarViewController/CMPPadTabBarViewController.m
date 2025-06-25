//
//  CMPPadTabBarViewController.m
//  M3
//
//  Created by CRMO on 2019/5/23.
//

#import "CMPPadTabBarViewController.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPEmptyViewController.h>
#import <CMPLib/CMPPersonInfoUtils.h>
#import "CMPTabBarItemAttribute.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPDBAppInfo.h>
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/CMPConstant.h>
#import "CMPTabBarAttribute.h"
#import "CMPOfflineContactViewController.h"
#import <CMPLib/CMPNavigationController.h>
#import "CMPMessageListViewController.h"
#import <CMPLib/CMPDataProvider.h>
#import "AppDelegate.h"
#import "CMPMessageManager.h"
#import <CMPLib/RDVTabBarItem+WebCache.h>
#import <CMPLib/CMPGlobleManager.h>
#import "UITabBar+badge.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPPrivilegeManager.h"
#import "CMPCheckUpdateManager.h"
#import "CMPTabBarWebViewController.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSObject+FBKVOController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPLoginUpdateConfigProvider.h"
#import "CMPShortcutHelper.h"
#import "M3LoginManager.h"
#import "CMPCommonManager.h"
#import <CMPLib/SDWebImageManager.h>
#import "CMPNavigationPlugin.h"
#import <CMPLib/CMPServerVersionUtils.h>
@interface CMPPadTabBarViewController ()


@end

@implementation CMPPadTabBarViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    self.orientation = RDVTabBarVertical;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserIcon) name:kNotificationName_ChangeIcon object:nil];
}

#pragma mark-
#pragma mark 继承

- (UIViewController *)itemViewControllerWithRoot:(UIViewController *)rootVc appID:(NSString *)appID {
    if ([appID isEqualToString:kM3AppID_My] ||
        [appID isEqualToString:kM3AppID_Shortcut]) { // iPad上 我的 快捷菜单 不展示在底导航
        return nil;
    }
    CMPSplitViewController *splitViewController = [CMPSplitViewController splitWithMasterVc:rootVc delegate:nil];
    return splitViewController;
}

- (void)setupPortaitAntShortcuts {
    [self setPortait:[UIImage imageNamed:@"guesture.bundle/ic_def_person.png"]];
    NSString *imageUrl = [CMPCore memberIconUrlWithId:[CMPCore sharedInstance].userID];
    [[SDWebImageManager sharedManager].imageDownloader setValue:[CMPCore sharedInstance].token forHTTPHeaderField:@"ltoken"];
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageRetryFailed|SDWebImageRefreshCached|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!error) {
            [self setPortait:image];
        }
    }];
    
    __weak __typeof(self)weakSelf = self;
    
    NSMutableArray *items = [NSMutableArray array];
    
    // 常用应用
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    if (configInfo.portal.isShowCommonApp) {
        UIImage *selectImage = [[UIImage imageNamed:[CMPFeatureSupportControl bannerAppIcon]] cmp_imageWithTintColor:CMPThemeManager.sharedManager.themeColor];
        UIImage *unselectImage = [[UIImage imageNamed:[CMPFeatureSupportControl bannerAppIcon]] cmp_imageWithTintColor:[UIColor grayColor]];
        self.commonAppItem =
        [[RDVTabBarShortcutItem alloc] initWithUnselectImage:unselectImage selectedImage:selectImage canSelect:YES didClick:^{
            CMPTabBarWebViewController *tab = [[CMPTabBarWebViewController alloc] init];
            tab.startPageUrl = kM3CommonAppUrl;
            tab.hideBannerNavBar = NO;
            tab.viewDidAppearCallBack = ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_TabbarChildViewControllerDidAppear object:nil];
            };
            CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:tab delegate:nil];
            [weakSelf replaceSelectedViewController:splitVc];
            
//            CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
//            vc.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kM3CommonAppUrl]];
//            vc.hideBannerNavBar = NO;
//            vc.backBarButtonItemHidden = YES;
//            vc.titleType = CMPBannerTitleTypeLeft;
//            CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:vc delegate:nil];
//            [weakSelf replaceSelectedViewController:splitVc];
        }];
        [items addObject:self.commonAppItem];
    }
    
    // 全文检索
    UIImage *selectImage = [[UIImage imageNamed:@"banner_search"] cmp_imageWithTintColor:CMPThemeManager.sharedManager.themeColor];
    UIImage *unselectImage = [[UIImage imageNamed:@"banner_search"] cmp_imageWithTintColor:[UIColor grayColor]];
    
    RDVTabBarShortcutItem *searchItem =
    [[RDVTabBarShortcutItem alloc] initWithUnselectImage:unselectImage selectedImage:selectImage canSelect:YES didClick:^{
        NSMutableArray *mItemArr = [NSMutableArray arrayWithArray:weakSelf.itemAttrs];
        CMPTabBarItemAttribute *tmpAttr = nil;
        for (CMPTabBarItemAttribute *attr in mItemArr) {
            if ([attr.appID isEqualToString:kM3AppID_My]) {
                tmpAttr = attr;
                break;
            }
        }
        [mItemArr removeObject:tmpAttr];
        
        NSInteger idx = weakSelf.selectedIndex;
        weakSelf.lastSelectIndex = idx;
        BOOL isMessageTab = NO;
        BOOL isTodoTab = NO;
        if (mItemArr.count>idx) {
            CMPTabBarItemAttribute *attr = [mItemArr objectAtIndex:idx];
            if ([attr.appID isEqualToString:kM3AppID_Message]) {
                isMessageTab = YES;
            }else if ([attr.appID isEqualToString:kM3AppID_Todo]) {
                isTodoTab = YES;
            }
        }
        
        CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
        NSString *aStr;
        //致信插件
        BOOL zhixin = [CMPMessageManager sharedManager].hasZhiXinPermissionAndServerAvailable;
        //全文检索
        BOOL index = [CMPPrivilegeManager getCurrentUserPrivilege].hasIndexPlugin;
        if ([CMPServerVersionUtils serverIsLaterV8_3]) {
            if (zhixin) {
                if (isMessageTab) {//1、消息
                    aStr = kM3FullSearchUrl_180;
                    aStr = [aStr stringByAppendingFormat:@"?messageSearch=true&isPadRoot=1"];
                }else if (isTodoTab){//2、待办
                    aStr = kM3FullSearchUrl_180;
                    aStr = [aStr stringByAppendingFormat:@"?messageSearch=false&isPadRoot=1"];
                }else{//3、其他
                    if (index) {
                        aStr = kM3FullSearchUrl_830;
                        aStr = [aStr stringByAppendingString:@"?isPadRoot=1"];
                    }else{
                        aStr = kM3AllSearchUrl_180;
                        aStr = [aStr stringByAppendingFormat:@"?isPadRoot=1"];
                    }
                }
            }else{
                if (isMessageTab) {//1、消息
                    if (index) {
                        aStr = kM3FullSearchUrl_830;
                        aStr = [aStr stringByAppendingString:@"?isPadRoot=1"];
                    }else{
                        aStr = kM3AllSearchUrl_180;
                        aStr = [aStr stringByAppendingFormat:@"?isPadRoot=1"];
                    }
                }else if (isTodoTab){//2、待办
                    aStr = kM3FullSearchUrl_180;
                    aStr = [aStr stringByAppendingFormat:@"?messageSearch=false&isPadRoot=1"];
                }else{//3、其他
                    if (index) {
                        aStr = kM3FullSearchUrl_830;
                        aStr = [aStr stringByAppendingString:@"?isPadRoot=1"];
                    }else{                        
                        aStr = kM3AllSearchUrl_180;
                        aStr = [aStr stringByAppendingFormat:@"?isPadRoot=1"];
                    }
                }
            }
            
        }else {
            //老版本
            if (index) {
                aStr = kM3FullSearchUrl_180;
            }else{
                aStr = kM3AllSearchUrl_180;
            }
            aStr = [aStr stringByAppendingString:@"?isPadRoot=1"];
        }
        
        vc.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
        CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:vc delegate:nil];
        [weakSelf replaceSelectedViewController:splitVc];
    }];
    searchItem.shortcutType = RDVTabBarShortcutType_AllSearch;
    [items addObject:searchItem];
    
    // 快捷菜单
    selectImage = [[UIImage imageNamed:@"msg_shape"] cmp_imageWithTintColor:CMPThemeManager.sharedManager.themeColor];
    unselectImage = [[UIImage imageNamed:@"msg_shape"] cmp_imageWithTintColor:[UIColor grayColor]];
    RDVTabBarShortcutItem *shapeItem = [[RDVTabBarShortcutItem alloc] initWithUnselectImage:unselectImage selectedImage:selectImage canSelect:NO didClick:^{
        [CMPShortcutHelper showInViewController:weakSelf];
    }];
    [items addObject:shapeItem];
    
    [self setShortcuts:[items copy]];
}

- (void)updateUserIcon {
    __weak typeof(self) weakself = self;
    [CMPCommonManager updateMemberIconInfo];
    [CMPCommonManager getUserHeadImageComplete:^(UIImage *image) {
        [weakself setPortait:image];
    } cache:NO];
    /*
   [[SDWebImageManager sharedManager].imageDownloader setValue:[CMPCore sharedInstance].token forHTTPHeaderField:@"ltoken"];
   [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageRetryFailed|SDWebImageRefreshCached|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
       if (!error) {
           [self setPortait:image];
       }
   }];
     */
}

#pragma mark-
#pragma mark RDVTabBarControllerDelegate

- (void)tabBarController:(RDVTabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    if (self.selectedIndex<10) {
        self.lastSelectIndex = self.selectedIndex;
    }
    [viewController.cmp_splitViewController updateStackAnimation:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_padTabbarDidSelect" object:nil];
}

//小致的逻辑
- (void)openAllSearchPage4Xiaoz:(NSDictionary *)params {
    RDVTabBarShortcutItem *currentItem = (RDVTabBarShortcutItem *)self.tabBar.selectedItem;
    NSArray *items = self.tabBar.shortcutItems;
    for (RDVTabBarShortcutItem *item in items) {
        if (item.shortcutType == RDVTabBarShortcutType_AllSearch) {
            self.tabBar.selectedItem = item;
            break;
        }
    }

    
    CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = params[@"url"];
    aStr = [aStr appendHtmlUrlParam:@"isPadRoot" value:@"1"];
    vc.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    CMPSplitViewController *splitVc = [CMPSplitViewController splitWithMasterVc:vc delegate:nil];
    [self replaceSelectedViewController:splitVc];

}

@end
