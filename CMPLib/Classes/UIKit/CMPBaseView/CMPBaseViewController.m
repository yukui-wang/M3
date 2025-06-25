//
//  CMPBaseViewController.m
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define kControllerSuffix @"Controller"

#import "CMPBaseViewController.h"
#import "NSString+CMPString.h"
#import "CMPURLProtocol.h"
#import "CMPAppDelegate.h"
#import "NSObject+CMPHUDView.h"
#import "RDVTabBarController.h"

@interface CMPBaseViewController () {
    NSInteger _showLoadingViewCounter; // 显示加载窗体计算
}

@property (nonatomic, assign)CGSize viewSize;
@property (nonatomic, assign)CGSize preViewSize;

- (CGFloat)navigationBarHeight; // 获取navigationbar高度

@end

@implementation CMPBaseViewController
@synthesize param = _param;
@synthesize mainView = _mainView;
@synthesize shouldHandleFrame = _shouldHandleFrame;
@synthesize modalParentController = _modalParentController;
@synthesize mainFrame = _mainFrame;
@synthesize cModalViewController = _modalViewController;

- (void)dealloc 
{
    [_param release];
    _param = nil;
    
    [_mainView release];
    _mainView = nil;
    
    [_modalParentController release];
    _modalParentController = nil;
    
    [_modalViewController.view removeFromSuperview];
    [_modalViewController release];
    _modalViewController = nil;
	
	[_statusBarView release];
	_statusBarView = nil;
        
    [super dealloc];
}

- (id)init 
{
    self = [super init];
    if (self) {
        self.shouldHandleFrame = YES;
    }
    return self;
}

- (BOOL)navigationBarHidden
{
    return YES;
}

- (CGFloat)navigationBarHeight 
{
    BOOL aHidden = [self navigationBarHidden];
    if (aHidden) {
        return 0.0f;
    }
    UINavigationBar *aBar = self.navigationController.navigationBar;
    return aBar.originY + aBar.height;
}

- (CGRect)mainFrame
{
    CGRect frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
    CGFloat height = frame.size.height;
    
    frame.size.height = height;
    
    if ([self isOptimizationStatusBarForiOS7] && ![UIApplication sharedApplication].statusBarHidden) {
        frame.origin.y = [UIView staticStatusBarHeight];
        frame.size.height -= [UIView staticStatusBarHeight];
    }
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        if (@available(iOS 11.0, *)) {
            if (INTERFACE_IS_PHONE && [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0f) {
                frame.origin.x = frame.origin.x + 44;
                frame.size.width = frame.size.width - 44 * 2;
            }
        }
    }
    
    return frame;
}

- (void)loadView
{
    [super loadView];
    self.viewSize = self.view.bounds.size;
	CGRect frame = [self mainFrame];
    if (!_mainView) {
        NSString *aClassName = NSStringFromClass([self class]);
        aClassName = [aClassName replaceCharacter:kControllerSuffix withString:@""];
        Class aClass = NSClassFromString(aClassName);
        CMPBaseView *aView = [(CMPBaseView *)[aClass alloc] initWithFrame:frame];
        if ([aView respondsToSelector:@selector(setViewController:)]) {
            [aView setViewController:self];
        }
        self.mainView = aView;
        [aView release];
    }
    if (self.mainView) {
        [self.mainView removeFromSuperview];
        //self.mainView.frame = frame;
        [self.view addSubview:self.mainView];
    }
	
	if ([self isOptimizationStatusBarForiOS7]) {
		if (!_statusBarView) {
			_statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, [UIView staticStatusBarHeight])];
			_statusBarView.backgroundColor = [self statusBarColorForiOS7];
			[self.view addSubview:_statusBarView];
		}
	}
	
    [self setup];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self hiddenStatusBarWhenLandscape];
    [self updateRotaion];
}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    self.viewSize = self.view.frame.size;
    if (!CGSizeEqualToSize(self.preViewSize, self.viewSize) && [self isViewControllerVisable]) {
        [self reLayoutSubViews];
    }
    self.preViewSize = self.view.frame.size;
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    self.viewSize = size;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
        
        // [self hiddenStatusBarWhenLandscape];
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];

}

- (void)setup
{
    // todo
}

- (void)setupStatusBarViewBackground:(UIColor *)color
{
    _statusBarView.backgroundColor =color;
}

- (UIView *)statusBarView {
    return _statusBarView;
}

- (void)reLayoutSubViews
{
    //         NSLog(@"转屏后调入");
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect mainViewFrame = [self mainFrame];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        
        [self layoutSubviewsForPortraitWithFrame:mainViewFrame];
        [self layoutSubviewsWithFrame:mainViewFrame];
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        [self layoutSubviewsForLandscapeWithFrame:mainViewFrame];
        [self layoutSubviewsWithFrame:mainViewFrame];
    }
    
    _mainView.frame = mainViewFrame;
    _statusBarView.frame = CGRectMake(mainViewFrame.origin.x, 0, mainViewFrame.size.width, [UIView staticStatusBarHeight]);
   
}



- (void)layoutSubviewsForPortraitWithFrame:(CGRect)frame
{
    
}

- (void)layoutSubviewsForLandscapeWithFrame:(CGRect)frame
{
    
}

- (void)layoutSubviewsWithFrame:(CGRect)frame 
{
    
}

- (UIView *)loadingShowInView {
    return self.view;
}

- (void)showLoadingViewWithText:(NSString *)aStr {
    UIView *view = [self loadingShowInView];
//    CGFloat yOffset = (view.height- self.view.height)/2;
//    [self cmp_showProgressHUDInView:view yOffset:yOffset];
    [self cmp_showProgressHUDWithText:aStr inView:view];
}

- (void)showLoadingView
{
    [self showLoadingViewWithText:SY_STRING(@"common_table_loading")];
}

- (void)hideLoadingView
{
    if (_showLoadingViewCounter > 0) {
        _showLoadingViewCounter --;
    }
    if (_showLoadingViewCounter <= 0) {
        [self cmp_hideProgressHUD];
    }
}

- (void)hideLoadingViewWithoutCount {
    _showLoadingViewCounter = 0;
    [self cmp_hideProgressHUD];
}

- (void)showToastWithText:(NSString *)text {
    [self cmp_showHUDWithText:text inView:self.view];
}

// 是否优化状态栏为iOS7
- (BOOL)isOptimizationStatusBarForiOS7 {
	if ((self.isInPopoverController || self.preferredContentSize.width != 0 || self.preferredContentSize.height != 0) && INTERFACE_IS_PAD) {
		return NO;
	}
	return NO;
}

- (UIColor *)statusBarColorForiOS7
{
	return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
}

-(void)hiddenStatusBarWhenLandscape{
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        
        
    }
}

- (void)setAllowRotation:(BOOL)allowRotation
{
    _allowRotation = allowRotation;
    [self updateRotaion];
}

- (void)updateRotaion
{
    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    aAppDelegate.allowRotation = _allowRotation;
    if (!aAppDelegate.allowRotation) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
}
//用于iPad模式下，右侧界面返回到空界面
- (void)cmp_didClearDetailViewController {
    
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return NSStringFromClass(self.class);
}

@end
