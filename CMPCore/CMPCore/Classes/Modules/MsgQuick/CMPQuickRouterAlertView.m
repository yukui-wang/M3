//
//  CMPQuickRouterAlertView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/10.
//

#import "CMPQuickRouterAlertView.h"
#import "CMPQuickRouterViewModel.h"
#import "CMPMsgQuickHandler.h"
#import "CMPAppViewItem.h"
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPCommonManager.h"
#import "CMPScanWebViewController.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPNavigationController.h>

#import "CMPMessageManager.h"
#import "CMPTabBarViewController.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPShortcutHelper.h"
#import <CMPLib/CMPSplitViewController.h>
#import "CMPTabBarWebViewController.h"
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/CMPCachedResManager.h>

@interface CMPQuickRouterAlertView()<CMPAppViewItemDelegate>
{
    UIButton *_ignoreBtn;
    UIButton *_timerBtn;
    UIScrollView *_appScrollV;
    UIVisualEffectView *_effectView;
    MSWeakTimer *_refreshTimer;
    int _duration;
}
@property (nonatomic,strong) CMPQuickRouterViewModel *viewModel;
@end

@implementation CMPQuickRouterAlertView

- (void)dealloc {
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor cmp_colorWithName:@"qk-main-bg"] set];
    
    UIBezierPath *radiusPath = [UIBezierPath bezierPathWithRoundedRect:_effectView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = radiusPath.CGPath;
    maskLayer.frame = self.bounds;
    _effectView.layer.mask = maskLayer;

}

-(void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    self.defaultDismissTime = 0;
    _duration = 3;
    
    UIBlurEffect * blur;
    if (@available(iOS 10.0, *)) {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    } else {
         blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
//    _effectView.backgroundColor = RGBACOLOR(240, 240, 240, 0.73);
    _effectView.alpha = 0.94;
    [self addSubview:_effectView];
    [_effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    CGFloat w = 0.5;
    if ([CMPThemeInterfaceStyleLight isEqualToString:[CMPThemeManager sharedManager].currentThemeInterfaceStyle]) {
        self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 20;
        self.layer.shadowOpacity = 0.5;
        w = 1;
    }
    _effectView.layer.borderColor = [UIColor cmp_colorWithName:@"qk-main-bg-border"].CGColor;
    _effectView.layer.borderWidth = w;
    _effectView.layer.cornerRadius = 20;
    
    _timerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timerBtn setTitle:[NSString stringWithFormat:@"%d %@",_duration,SY_STRING(@"GestureLogin_Skip_Confirm")] forState:UIControlStateNormal];
    [_timerBtn setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
    [_timerBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [_timerBtn addTarget:self action:@selector(_timerButtonAct:) forControlEvents:UIControlEventTouchUpInside];
//    [_timerBtn sizeToFit];
    _timerBtn.layer.cornerRadius = 10;
    _timerBtn.layer.borderWidth = 0.5;
    _timerBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_timerBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    [self addSubview:_timerBtn];
    [_timerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14);
        make.right.offset(-10);
        make.size.mas_equalTo(CGSizeMake(50, 21));
    }];
    
    _ignoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _ignoreBtn.selected = NO;
    [_ignoreBtn setTitle:@" 不再提示" forState:UIControlStateNormal];
    UIColor *themeColor = [CMPThemeManager sharedManager].themeColor;
    [_ignoreBtn setImage:[[UIImage imageNamed:@"picture_unselect_radio_icon"] cmp_imageWithTintColor:themeColor] forState:UIControlStateNormal];
    [_ignoreBtn setImage:[[UIImage imageNamed:@"login_view_btn_icon_selected"] cmp_imageWithTintColor:themeColor] forState:UIControlStateSelected];
    [_ignoreBtn addTarget:self action:@selector(_ignoreButtonAct:) forControlEvents:UIControlEventTouchUpInside];
    [_ignoreBtn setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:UIControlStateNormal];
    [_ignoreBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
//    [_ignoreBtn sizeToFit];
    [self addSubview:_ignoreBtn];
    [_ignoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_timerBtn);
        make.left.offset(20);
        make.width.greaterThanOrEqualTo(@65);
    }];
    
    _appScrollV = [[UIScrollView alloc] init];
    _appScrollV.backgroundColor = [UIColor clearColor];
    [self addSubview:_appScrollV];
    
    [self _refreshData];
    [self _startRefreshTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_otherControllerViewWillAppear:) name:@"kNotificationName_viewWillAppear" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dismiss) name:@"kNotificationName_willShowShortcutView" object:nil];
}

-(void)_refreshData
{
    __weak typeof(self) wSelf = self;
    [self.viewModel fetchQuickItemsWithResult:^(NSArray<CMPAppModel *> * _Nonnull appList, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            [wSelf _reloadApps];
        }
    }];
}

-(void)_reloadApps
{
    _effectView.frame = self.bounds;
    if (_appScrollV && self.viewModel.sortedAppList) {
        [_appScrollV removeAllSubviews];
        NSInteger theme = 1;
        if ([CMPThemeInterfaceStyleDark isEqualToString:[CMPThemeManager sharedManager].currentThemeInterfaceStyle]) {
            theme = 2;
        }
        CGSize selfSize = self.bounds.size;
        CGFloat leftSpa = 20,bottomSpa = 24-10,scrollHeight = 70+20;
        _appScrollV.frame = CGRectMake(leftSpa, selfSize.height-bottomSpa-scrollHeight, selfSize.width-leftSpa*2, scrollHeight);
        CGFloat scrollWidth = _appScrollV.frame.size.width;
        NSArray *_tempArr = self.viewModel.sortedAppList;
        for (int i=0; i<=_tempArr.count-1; i++) {
            CMPAppModel *appModel = _tempArr[i];
            CMPAppViewItem *appView = [[CMPAppViewItem alloc] init];
            appView.delegate = self;
            [appView setModel:appModel];
            [appView updateTheme:theme];
            [_appScrollV addSubview:appView];
            appView.frame = CGRectMake(0, 0, 46+20, scrollHeight);
            appView.center = CGPointMake(scrollWidth*(i+1)/(_tempArr.count+1), scrollHeight/2);
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self _reloadApps];
}

-(void)_timerButtonAct:(UIButton *)sender
{
    [self _dismiss];
}

-(void)_ignoreButtonAct:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [CMPMsgQuickHandler updateActWithIfNeverTip:sender.selected];
}

- (void)_startRefreshTime {
    if (_refreshTimer) [_refreshTimer invalidate];
    _refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(_refreshTime)
                                                           userInfo:nil
                                                            repeats:YES
                                                      dispatchQueue:dispatch_get_main_queue()];
}

-(void)_refreshTime
{
    [_timerBtn setTitle:[NSString stringWithFormat:@"%d %@",_duration,SY_STRING(@"GestureLogin_Skip_Confirm")] forState:UIControlStateNormal];
    if (_duration <= 0) {
        [self _dismiss];
        return;
    }
    _duration -= 1;
}

-(void)cmpAppViewItem:(CMPAppViewItem *)appView didAction:(NSInteger)action model:(CMPAppModel *)model ext:(id)ext
{
    if (!model) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self _dismiss];
        
        if ([model isScanCodeApp]) {
            CMPScanWebViewController *aCMPBannerViewController = [[CMPScanWebViewController alloc] init];
            aCMPBannerViewController.startPage = @"http://commons.m3.cmp/v1.0.0/m3-scan-page.html";
            aCMPBannerViewController.hideBannerNavBar = YES;
            aCMPBannerViewController.backBarButtonItemHidden = YES;

            UIViewController *vv = [CMPCommonTool getCurrentShowViewController];
            CMPNavigationController *naviVC = [[CMPNavigationController alloc] initWithRootViewController:aCMPBannerViewController];
            [vv presentViewController:naviVC animated:YES completion:^{
            }];
            return;
        }
        
        NSString *aRootPath = [CMPCachedResManager rootPathWithHost:@"application.m3.cmp" version:@"1.0.0"];
        if (!aRootPath) {
            return;
        }
        NSString *url = nil;
        NSString *entry = [NSString stringWithFormat:@"layout/m3-transit-page.html?id=%@&from=m3quick", model.appId];
        url = [aRootPath stringByAppendingPathComponent:entry];
        url = [@"file://" stringByAppendingString:url];

        UIViewController *vc = [CMPCommonTool getCurrentShowViewController];
        NSString *appID = model.appId;
        CMPTabBarViewController *tabBar = [vc rdv_tabBarController];
        NSInteger indexOfAppID = [CMPQuickRouterAlertView indexOfTabBar:tabBar withAppId:appID];
        
        CMPBannerWebViewController *bannerWebViewVc = [[CMPBannerWebViewController alloc] init];
        NSString *urlStr = [url urlCFEncoded];
        bannerWebViewVc.startPage = urlStr;
        NSDictionary *params = @{@"url":url,
                                 @"param":@{@"appId":model.appId?:@"",
                                            @"gotoParams":model.gotoParam?:@""}};
        bannerWebViewVc.pageParam = params;
        bannerWebViewVc.hideBannerNavBar = NO;
        
        if (CMP_IPAD_MODE) {
            [vc cmp_clearDetailViewController];
            
            if (indexOfAppID != -1) {
                
                [tabBar setSelectedIndex:indexOfAppID];

                CMPSplitViewController *splitVc = (CMPSplitViewController *)tabBar.selectedViewController;

                bannerWebViewVc.closeButtonHidden = YES;

                UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                if ((orientation == UIDeviceOrientationPortrait ||
                     orientation == UIDeviceOrientationPortraitUpsideDown)) { // splitVc.masterStackSize == 0 页签没有初始化过
                    splitVc.detailNavigation.viewControllers = @[bannerWebViewVc];
                    splitVc.masterStackSize = 1;
                } else {
                    splitVc.masterNavigation.viewControllers = @[bannerWebViewVc];
                }
                
            } else {
                // 切换到常用应用
//                [tabBar openCommonApp];
                
                // 在首页上push中间页面
                CMPSplitViewController *splitVc = (CMPSplitViewController *)tabBar.selectedViewController;

                UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                if ((orientation == UIDeviceOrientationPortrait ||
                     orientation == UIDeviceOrientationPortraitUpsideDown)) {
                    [splitVc.detailNavigation popToRootViewControllerAnimated:NO];
                    [splitVc.detailNavigation pushViewController:bannerWebViewVc animated:NO];
                    splitVc.masterStackSize = 2;
                } else {
                    [splitVc.masterNavigation popToRootViewControllerAnimated:NO];
                    [splitVc.masterNavigation pushViewController:bannerWebViewVc animated:NO];
                    [splitVc clearDetailViewController];
                }
            }
            
        }else{
            
            if (indexOfAppID != -1) {
                [tabBar setSelectedIndex:indexOfAppID];
                
                CMPNavigationController *selectedVc = tabBar.selectedViewController;
                [selectedVc popToRootViewControllerAnimated:NO];
                [selectedVc pushViewController:bannerWebViewVc animated:YES];
                
            }else{
                CMPNavigationController *selectedVc = tabBar.selectedViewController;
                [selectedVc popToRootViewControllerAnimated:NO];
                
//                CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
//                vc.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kM3CommonAppUrl]];
//                vc.hideBannerNavBar = NO;
//                vc.backBarButtonItemHidden = NO;
//                [selectedVc pushViewController:vc animated:NO];
                
                [selectedVc pushViewController:bannerWebViewVc animated:YES];
            }
        }
    });
}

+ (NSInteger)indexOfTabBar:(CMPTabBarViewController *)tabBar withAppId:(NSString *)appID {
    NSUInteger index = -1;
    for (int i = 0; i < tabBar.tabBar.items.count; ++i) {
        RDVTabBarItem *item = tabBar.tabBar.items[i];
        NSInteger tag = item.tag - CMPTabBarItemTag;
        if (tag == [appID integerValue] ||
            ([appID isEqualToString:@"61"] && (tag == 55))) { // 消息配置到底导航，消息 AppID为55，新建致信聊天需要切换到消息页签
            index = i;
            break;
        }
    }
    return index;
}

-(void)_dismiss
{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(cmpWindowAlertBaseView:didAct:ext:)]) {
        [self.baseDelegate cmpWindowAlertBaseView:self didAct:CMPWindowAlertBaseViewActionDismiss ext:nil];
    }
}

-(void)_otherControllerViewWillAppear:(NSNotification *)noti
{
    UIViewController *vc = noti.object;
    if (vc) {
        if (vc.navigationController && vc.navigationController.viewControllers.count > 1) {
            [self _dismiss];
            return;
        }
        if (vc.presentingViewController) {
            [self _dismiss];
            return;
        }
        if (vc.parentViewController) {
            [self _dismiss];
            return;
        }
    }
}

-(CGFloat)defaultHeight
{
    return 148;
}

-(CMPDirection)defaultShowDirection
{
    return CMPDirection_Bottom;
}

-(CMPDirection)defaultDismissDirection
{
    return CMPDirection_Bottom;
}

-(CMPQuickRouterViewModel *)viewModel
{
    if(!_viewModel) {
        _viewModel = [[CMPQuickRouterViewModel alloc] init];
    }
    return _viewModel;
}

@end
