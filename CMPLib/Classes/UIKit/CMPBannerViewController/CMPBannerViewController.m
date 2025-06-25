//
//  SyBannerViewController.m
//  M1IPhone
//
//  Created by guoyl on 12-12-5.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kBannerBarHeight 44
#define kBackBarButtonItemTag 1000101020
#define kBackBarButtonTitle SY_STRING(@"common_return")

#import "UIButton+CMPButton.h"
#import "CMPBannerViewController.h"
#import "CMPBannerBackButton.h"
#import <CMPLib/UIImage+RTL.h>

@interface CMPBannerViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;

- (void)updateBannerView;

@end

@implementation CMPBannerViewController

- (void)backBarButtonAction:(id)sender
{
    // do back
    UIViewController *popViewController = [self.navigationController popViewControllerAnimated:YES];
    if (!popViewController) {
        if (self.navigationController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (BOOL)navigationBarHidden
{
    return YES;
}

- (void)setupNaviBar
{
    if (self.hideBannerNavBar) {
        _bannerNavigationBar.hidden = YES;
        return;
    }
    if (!_bannerNavigationBar) {
        CGRect mainFrame = [super mainFrame];
        CGRect f = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, [self bannerBarHeight]);
        _bannerNavigationBar = [[CMPBannerNavigationBar alloc] initWithFrame:f];
        __weak typeof(self) weakSelf = self;
        _bannerNavigationBar.bannerTitleClicked = ^{
            [weakSelf addH5Listener];
        };
        UIColor *aColor = [self bannerNavigationBarBackgroundColor];
        if (aColor) {
            [_bannerNavigationBar setBannerBackgroundColor:aColor];
        }
        [self.view addSubview:_bannerNavigationBar];
        [_bannerNavigationBar addBottomLine];
        _bannerNavigationBar.titleType = [self bannerTitleType];
        [self setupBannerButtons];
    }
    _bannerNavigationBar.hidden = NO;
}

- (void)setupBannerButtons {
}

- (CMPBannerTitleType)bannerTitleType {
    return CMPBannerTitleTypeCenter;
}

///取消按钮点击后，通知给H5
- (void)addH5Listener {
//    NSString *js = [NSString stringWithFormat:@"cmp.event.trigger('navigationTitleClicked', document, {message:'%@'})",@(YES)];
//    [self.commandDelegate evalJs:js];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = [self navigationBarHidden];
    [self setupNaviBar];
    self.backBarButtonItemHidden = _backBarButtonItemHidden;
    
    //添加滑动手势,处理导航栏隐藏问题
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:self.panGesture];
    self.panGesture.delegate = self;
    self.panGesture.enabled = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        //[self hiddenBarWhenLandscape];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        //[self hiddenBarWhenLandscape];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    } completion:nil];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

-(void)hiddenBarWhenLandscape{
    
    if (InterfaceOrientationIsPortrait) {
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        [self showNavBar:YES animated:NO];
    }else if (InterfaceOrientationIsLandscape) {
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        [self showNavBar:NO animated:NO];
    }
}

- (void)setPanGesturEnabled:(BOOL)enabled {
    self.panGesture.enabled = enabled;
}

- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated
{
    _hideBannerNavBar = !isShow;
    _statusBarView.hidden = !isShow;
    if (InterfaceOrientationIsLandscape) {
        _statusBarView.hidden = YES;
    }
    if (animated) {
        [self setupNaviBarAnimatedShowOrNot:isShow];
    }else{
        [self setupNaviBar];
        [self reLayoutSubViews];
    }
}

-(void)setupNaviBarAnimatedShowOrNot:(BOOL)isShow{
    
    CGRect mainFrame = [self mainFrame];
    static BOOL isAnimating = NO;
    if (isShow) {
        if (!isAnimating && _bannerNavigationBar.hidden){
            if (InterfaceOrientationIsPortrait) {
                _statusBarView.frame = CGRectMake(mainFrame.origin.x,-( [self bannerBarHeight] + [UIView staticStatusBarHeight]), mainFrame.size.width, [self bannerBarHeight] + [UIView staticStatusBarHeight]);
                _bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,-[self bannerBarHeight], mainFrame.size.width, [self bannerBarHeight]);
                [self updateBannerView];
                _bannerNavigationBar.hidden = NO;
                isAnimating = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    self.mainView.frame = mainFrame;
                    self->_statusBarView.frame = CGRectMake(mainFrame.origin.x,0, mainFrame.size.width, [UIView staticStatusBarHeight]);
                    self.bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,[UIView staticStatusBarHeight], mainFrame.size.width, [self bannerBarHeight]);
                    [self.mainView layoutIfNeeded];
                }completion:^(BOOL finished) {
                    isAnimating = NO;
                }];
            }else{
                _bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,-[self bannerBarHeight], mainFrame.size.width, [self bannerBarHeight]);
                [self updateBannerView];
                _bannerNavigationBar.hidden = NO;

                isAnimating = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    self.mainView.frame = mainFrame;
                    self.bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,0, mainFrame.size.width, [self bannerBarHeight]);
                    [self.mainView layoutIfNeeded];
                }completion:^(BOOL finished) {
                    isAnimating = NO;
                }];
            }
        }
    }else{
        if (!isAnimating && !_bannerNavigationBar.hidden) {
            isAnimating = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.mainView.frame = mainFrame;
                self.bannerNavigationBar.frame = CGRectMake(mainFrame.origin.x,-self->_bannerNavigationBar.frame.size.height, mainFrame.size.width, self->_bannerNavigationBar.frame.size.height);
                [self.mainView layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.bannerNavigationBar.hidden = YES;
                isAnimating = NO;
            }];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognize {
    
    CGPoint panPoint = [recognize translationInView:self.view];
    //隐藏导航栏
    if (panPoint.y <= -kBannerBarHeight) {
        [recognize setTranslation:CGPointMake(0, 0) inView:self.view];
        [self showNavBar:NO animated:YES];
    }else if (panPoint.y >= kBannerBarHeight){
        [recognize setTranslation:CGPointMake(0, 0) inView:self.view];
        [self showNavBar:YES animated:YES];
    }
}

- (CGFloat)bannerBarHeight
{
    if (self.hideBannerNavBar) {
        return 0.0f;
    }
    if (self.bannerTitleType == CMPBannerTitleTypeCenter) {
        return kBannerBarHeight;
    } else {
        return 60;
    }
}

- (CGRect)mainFrame
{
    CGRect mainFrame = [super mainFrame];
    if (!_hideBannerNavBar) {
        mainFrame.origin.y += self.bannerBarHeight;
        mainFrame.size.height -= self.bannerBarHeight;
    }
    return mainFrame;
}

- (void)layoutSubviewsWithFrame:(CGRect)frame
{
    CGRect f = [super mainFrame];
    _bannerNavigationBar.frame = CGRectMake(f.origin.x, f.origin.y, frame.size.width, [self bannerBarHeight]);
    [self updateBannerView];
}

- (void)updateBannerView
{
    [self.bannerNavigationBar autoLayout];
}

- (void)setTitle:(NSString *)title {
    _bannerViewTitle = title;
    [self.bannerNavigationBar updateBannerTitle:title];
    [self updateBannerView];
}

- (NSString *)title
{
    return _bannerViewTitle;
}

- (void)setBackBarButtonItemHidden:(BOOL)backBarButtonItemHidden
{
    _backBarButtonItemHidden = backBarButtonItemHidden;
    if (!self.bannerNavigationBar || self.bannerNavigationBar.hidden) {
        return;
    }
    if (!_backBarButtonItemHidden) {
        // 判断是否存在
        NSArray *aItems = self.bannerNavigationBar.leftBarButtonItems;
        NSInteger aBackButtonIndex = -1;
        for (NSInteger i = 0; i < aItems.count; i ++) {
            UIButton *aButton = [aItems objectAtIndex:i];
            if (aButton.tag == kBackBarButtonItemTag) {
                aBackButtonIndex = i;
            }
        }
        if (aBackButtonIndex >= 0) {
            return;
        }
        CMPBannerBackButton *aBackButton = nil;
        self.bannerNavigationBar.leftMargin = 0.0f;
        aBackButton = [CMPBannerBackButton buttonWithType:UIButtonTypeCustom];
        aBackButton.frame = CGRectMake(0, 0, 70, 44);
        NSString *imageName = nil;
        if (CMPFeatureSupportControl.isBannarBackButtonShowText) {
            imageName = @"banner_return";
        } else {
            imageName = @"banner_new_return";
        }
        UIImage *aImage = [[UIImage imageNamedAutoRTL:imageName] cmp_imageWithTintColor:[CMPThemeManager sharedManager].iconColor];
        [aBackButton setImage:aImage forState:UIControlStateNormal];
        //#3AADFB
        NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                                       NSForegroundColorAttributeName : [CMPThemeManager sharedManager].iconColor};
        NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:SY_STRING(@"common_back")
                                                                        attributes:attributeDic];
        
        if (!CMPCore.sharedInstance.serverIsLaterV8_0) {
            [aBackButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        }
        
        aBackButton.tag = kBackBarButtonItemTag;
        [aBackButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bannerNavigationBar insertLeftBarButtonItem:aBackButton atIndex:0];
    }
    else {
        // remove the backButton
        NSArray *aItems = self.bannerNavigationBar.leftBarButtonItems;
        NSInteger aBackButtonIndex = -1;
        for (NSInteger i = 0; i < aItems.count; i ++) {
            UIButton *aButton = [aItems objectAtIndex:i];
            if (aButton.tag == kBackBarButtonItemTag) {
                aBackButtonIndex = i;
            }
        }
        if (aBackButtonIndex >= 0) {
            [self.bannerNavigationBar removeLeftBarButtonItemAtIndex:aBackButtonIndex];
        }
    }
}

- (void)showLoadingViewWithText:(NSString *)aStr
{
    // disable right button
//    [_bannerNavigationBar coverRightViews:YES];
    [super showLoadingViewWithText:aStr];
}

- (void)hideLoadingView
{
//    [_bannerNavigationBar coverRightViews:NO];
    [super hideLoadingView];
}

- (NSString *)backBarButtonTitle
{
    return kBackBarButtonTitle;
}

- (UIColor *)bannerNavigationBarBackgroundColor
{
    return [UIColor cmp_colorWithName:@"white-bg1"];
}

- (BOOL)isOptimizationStatusBarForiOS7 {
    return !_hideBannerNavBar;
}

- (UIColor *)statusBarColorForiOS7
{
    return [UIColor cmp_colorWithName:@"white-bg1"];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}

-(BOOL)prefersStatusBarHidden{
    
    return NO;
}

- (UIButton *)bannerSearchButton
{
    UIButton *aSearchButton = [UIButton buttonWithImageName:@"banner_search" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [aSearchButton setImage:[UIImage imageNamed:@"banner_search_pre"]  forState:UIControlStateHighlighted];
    return aSearchButton;
}

- (UIButton *)bannerReturnButton
{
    UIButton *aBackButton = [UIButton buttonWithImageName:@"banner_return" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    [aBackButton setImage:[UIImage imageNamed:@"ic_banner_return.png"] forState:UIControlStateHighlighted];
    return aBackButton;
}

- (UIButton *)bannerCloseButton
{
    UIButton *aCloseButton = [UIButton buttonWithImageName:@"banner_close" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center];
    UIImage *preImage = [UIImage imageNamed:@"banner_close_pre"];
    if (preImage) {
        [aCloseButton setImage:preImage forState:UIControlStateHighlighted];
    }
    return aCloseButton;
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    NSString *title = self.title;
    if ([NSString isNull:title]) {
        title = [super currentPageScreenshotControlTitle];
    }
    return title;
}

@end

