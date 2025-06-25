//
//  CMPBannerHeadViewController.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/28.
//
//

#import "CMPBannerHeadViewController.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPFaceImageManager.h>
#import <CMPLib/CMPPersonInfoUtils.h>
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPNetworkTipView.h"
#import <CMPLib/AFNetworkReachabilityManager.h>
#import "CMPAppsDownloadProgressView.h"
#import "CMPCheckUpdateManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPBannerHeadViewController ()
{
    UIImageView *_headImgView;
    BOOL isShow;
}
@end

@implementation CMPBannerHeadViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CMPFaceImageManager sharedInstance] clearData];
    
    SY_RELEASE_SAFELY(_headImgView);
    SY_RELEASE_SAFELY(_networkTipView);
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bannerNavigationBar.leftViewsMargin = 0.0;
    self.bannerNavigationBar.rightViewsMargin = 0.0;
    self.bannerNavigationBar.leftMargin = 15.0f;
    self.bannerNavigationBar.rightMargin = 5.0f;
    [self.bannerNavigationBar setLeftBarButtonItems:[NSArray array]];
    if (![CMPCore sharedInstance].hasMyInTabBar && ![[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        [self updateUserIcon]; // 更新人员头
        // 监听人员头像更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserIcon) name:kNotificationName_ChangeIcon object:nil];
    }
    // 监听网络事件
    [self updateNetWorkTipViewStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNotificationName_NetworkStatusChange object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateNetWorkTipViewStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isShow = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isShow = YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.viewLoaded) {
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self updateNetWorkTipViewStatus];
        }];
    }

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

//更新头像
- (void)updateUserIcon
{
    CGFloat boarderWidth = kMacro_UserHeadIconBoarderWidth,backViewWidth = 36;
    if(!_headImgView){
        _headImgView = [[UIImageView alloc] init];
        _headImgView.layer.cornerRadius = (backViewWidth-boarderWidth*2)/2;
        _headImgView.layer.masksToBounds = YES;
        _headImgView.frame = CGRectMake(11, 5, backViewWidth-boarderWidth*2, backViewWidth-boarderWidth*2);
        _headImgView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        _headImgView.userInteractionEnabled = YES;
        _headImgView.image = [UIImage imageNamed:@"guesture.bundle/ic_def_person.png"];
        UITapGestureRecognizer *aGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpSettingPage:)];
        
        [_headImgView addGestureRecognizer:aGes];
        [self.bannerNavigationBar addSubview:_headImgView];
        [aGes release];
        
        UIView *backView = [[UIView alloc]init];
        backView.layer.cornerRadius = backViewWidth/2;
        backView.layer.masksToBounds = YES;
        backView.frame = CGRectMake(0, 0, backViewWidth, backViewWidth);
        backView.backgroundColor = UIColorFromRGB(0xd4d4d4);
        backView.center = _headImgView.center;
        [self.bannerNavigationBar insertSubview:backView belowSubview:_headImgView];
        [backView release];
    }
    [[CMPFaceImageManager sharedInstance] fetchfaceImageWithMemberId:[CMPCore sharedInstance].userID complete:^(UIImage *image) {
        //截取图片 
        CGFloat imageWidth = CGImageGetWidth(image.CGImage), imageHeight = CGImageGetHeight(image.CGImage);
        UIImage *img = nil;
        if (imageWidth !=imageHeight ) {
            CGFloat _w = (imageWidth<=imageHeight) ? imageWidth:imageHeight;
            CGRect r = CGRectMake(imageWidth/2-_w/2, imageHeight/2-_w/2, _w, _w);
            img = [UIImage imageWithClipImage:image inRect:r];
        }
        else {
            img = image;
        }
        _headImgView.image = img;
    } cache:NO];
}

- (void)jumpSettingPage:(id)sender
{
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]) {
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    [CMPPersonInfoUtils jumpUserSettingFrom:self];
}

- (void)networkChanged:(NSNotification *)notification
{
    [self updateNetWorkTipViewStatus];
}

// 更新网络提示状态
- (void)updateNetWorkTipViewStatus
{
    if ([CMPCore sharedInstance].showingTopScreen) {
        return;//负一屏下拉的时候不更新UI
    }
    if (![self canShowNetworkTip] ||
        ![CMPCore sharedInstance].serverIsLaterV1_8_0 ||
        !isShow) {
        [self willUpdateNetworkTip:NO];
        [self didUpdateNetworkTip:NO];
        return;
    }
    
    NSString *aStr = nil;
    if (![CMPCommonManager reachableServer]) {
        aStr = SY_STRING(@"Common_Server_CannotConnect");
    }
    if (![CMPCommonManager reachableNetwork]) {
        aStr = SY_STRING(@"Common_Network_Unavailable");
    }
    
    [self willUpdateNetworkTip:[NSString isNotNull:aStr]];
    
    if (aStr) {
        CGRect f = [super mainFrame];
        if (!_networkTipView) {
            _networkTipView = [[CMPNetworkTipView alloc] initWithFrame:CGRectMake(0, f.origin.y, f.size.width, 40) andTip:aStr];
            [self.view addSubview:_networkTipView];
        }
//        _networkTipView.tipInfoLbl.text = aStr;
    }
    else {
        if (_networkTipView) {
            [_networkTipView removeFromSuperview];
            [_networkTipView release];
            _networkTipView = nil;
        }
    }
    self.mainView.frame = [self mainFrame];
    [self didUpdateNetworkTip:[NSString isNotNull:aStr]];
}

- (CGRect)mainFrame {
    CGRect f = [super mainFrame];
    if (_networkTipView && !_networkTipView.hidden) {
        if ([CMPCore sharedInstance].topScreenBeginShow) {
            
        }else{
            f.origin.y += 40;
            f.size.height -= 40;
        }
    }
    return f;
}

- (BOOL)canShowNetworkTip {
    return YES;
}

- (void)didUpdateNetworkTip:(BOOL)isShow {
}

- (void)willUpdateNetworkTip:(BOOL)isShow {
}

//- (CGFloat)otherTipViewHeight {
//    return 0;
//}

@end
