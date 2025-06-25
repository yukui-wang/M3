//
//  CMPMessageListViewController+TopScreen.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/27.
//

#import "CMPMessageListViewController+TopScreen.h"
#import <CMPLib/UIColor+Hex.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPCheckUpdateManager.h"

#define kTag_PanTopScreenLabel      111001
#define kTag_CornerMaskView         111002
#define kTag_botSafeAreaMaskView    111003
#define kTag_botMaskView            111004

@implementation CMPMessageListViewController (TopScreen)

- (void)addPanGuestureToView:(UIView *)view{
    //pan手势-负一屏
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [view addGestureRecognizer:pan];
    pan.delegate = self;
}

- (void)initTopScreenView{
    if (self.topScreenView) {
        return;
    }
    
    self.topScreenView = [[CMPTopScreenView alloc]initWithVC:self frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 100)];
    [self.view addSubview:self.topScreenView];//添加负一屏
    [self.view sendSubviewToBack:self.topScreenView];
    
    __weak typeof(self) weakSelf = self;
    self.topScreenView.pushSearchBlock = ^{
        [weakSelf topScreenPushSearchView];
    };
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    //下拉要作为底导航首页才能触发
    if (self.navigationController.viewControllers.count>1) {
        return;
    }
    //下载应用包也不能下拉
    if (![[CMPCheckUpdateManager sharedManager] canShowApp]){
        [self cmp_showHUDWithText:SY_STRING(@"UpdatePackage_updating")];
        return;
    }
    
    CGPoint p = [g translationInView:self.view];
    
    switch (g.state) {
        case UIGestureRecognizerStateBegan:{
            [self updateTopScreenState:0 currentY:p.y];
            self.hasVibrated = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat y = p.y - p.y * 0.6;//增加阻力
            [self.topScreenView showMask:YES];
            [self.topScreenView changeMask:y];
            [self updateTopScreenState:1 currentY:y];
            CGFloat deltaY = p.y - self.panOriginY;
            if (deltaY>200) {//震动
                [self vibrate];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            [self resumeViewAnimate:YES];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            CGFloat deltaY = p.y - self.panOriginY;
            if (deltaY>200) {//滑开
                [self updateTopScreenState:2 currentY:p.y];
            }else{//还原
                [self updateTopScreenState:3 currentY:p.y];
            }
        }
            break;
        default: break;
    }
}

//滑动开始=0、滑动中=1、滑开=2、还原=3
- (void)updateTopScreenState:(NSInteger)state currentY:(CGFloat)currentY{
    if (currentY < 0) {
        [self resumeViewAnimate:YES];
        return;
    }
    if (state == 0) {//滑动开始
        [self.topScreenView handlePermisson:NO];
        [CMPCore sharedInstance].topScreenBeginShow = YES;
        //禁止导航栏按钮点击
        [self.bannerNavigationBar.rightBarButtonItems enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = NO;
        }];
        
        self.weakListView.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
//        self.needRefreshMsg = NO;//拖拽的时候不刷新消息
        
        [self initTopScreenView];//初始化topScreen
        
        self.panOriginY = currentY;//触摸时view的Y
        self.panOriginYArr = [NSMutableArray new];//触摸时subView的Y
        
        //此时subViews包含topScreenView
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.panOriginYArr addObject:@(view.frame.origin.y)];//记录subview最原始的y值
        }];
        
        //状态栏
        UIView *statusBarView = [self statusBarView];
        UIView *v = [statusBarView viewWithTag:kTag_PanTopScreenLabel];
        if (!v) {
            CGFloat h = IS_IPHONE_X_LATER?27:0;
            //占位提示语
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, -35+h, statusBarView.frame.size.width-40, 34)];
            titleLabel.text = SY_STRING(@"slide_to_top_screen");//@"下滑到二楼查看最近足迹";
            titleLabel.tag = kTag_PanTopScreenLabel;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.numberOfLines = 2;
            titleLabel.textColor = [UIColor colorWithHexString:@"#D4D4D4"];
            titleLabel.font = [UIFont systemFontOfSize:12];
            [statusBarView addSubview:titleLabel];
            //遮挡圆角层
            UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, h, statusBarView.frame.size.width, 50)];
            v.tag = kTag_CornerMaskView;
            v.layer.cornerRadius = 20.f;
            v.backgroundColor = self.bannerNavigationBar.backgroundColor;
            [statusBarView addSubview:v];
        }
        
    }else if (state == 1) {//滑动中
        [self setupStatusBarViewBackground:UIColor.clearColor];//状态栏背景色透明
        
        if (!self.rdv_tabBarController.isTabBarHidden && currentY>0) {
            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
            self.weakListView.tableView.scrollEnabled = NO;
        }
        
        [self updateViewY:currentY animate:NO completion:nil];
    }else if (state == 2) {//滑开，end
        [self.topScreenView handlePermisson:YES];
        [self.topScreenView showMask:NO];
        
        UIView *tipView = [self.view viewWithTag:kTag_PanTopScreenLabel];
        [tipView removeFromSuperview];
        
        CGFloat botHeight = CMP_STATUSBAR_HEIGHT + 60 + CMP_SafeBottomMargin_height;
        CGFloat h = IS_IPHONE_X_LATER?27:0;
        
        //滑到底部最大Y值
        CGFloat maxY = UIScreen.mainScreen.bounds.size.height - botHeight;
        
        //把列表变为透明(解决滑到底部被遮挡会闪一下的问题)
        self.weakListView.tableView.alpha = 1.0;
        [UIView animateWithDuration:0.25 animations:^{
            self.weakListView.tableView.alpha = 0;
        }];
        
        [self updateViewY:maxY animate:YES completion:^{
            //遮挡table和线  36高度
            if (IS_IPHONE_X_LATER) {
                if (![self.view viewWithTag:kTag_botSafeAreaMaskView]) {
                    UIView *botPlaceView = [[UIView alloc]initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-36, UIScreen.mainScreen.bounds.size.width, 36)];
                    botPlaceView.backgroundColor = self.bannerNavigationBar.backgroundColor;
                    botPlaceView.tag = kTag_botSafeAreaMaskView;
                    [self.view addSubview:botPlaceView];
                }
            }
            
            //加层蒙版，点击后还原
            if (![self.view viewWithTag:kTag_botMaskView]) {
                UIView *shadow = [[UIView alloc]initWithFrame:CGRectMake(0, maxY+h, UIScreen.mainScreen.bounds.size.width, botHeight+50)];
                shadow.tag = kTag_botMaskView;
                shadow.layer.cornerRadius = 20.f;
                shadow.backgroundColor = [[UIColor colorWithHexString:@"#D4D4D4"] colorWithAlphaComponent:0.6];
                [self.view addSubview:shadow];
                //点击恢复
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
                tap.numberOfTapsRequired = 1;
                [shadow addGestureRecognizer:tap];
                //上滑恢复
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan1:)];
                [shadow addGestureRecognizer:pan];
                pan.delegate = self;
            }
            
//            //点击恢复
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//            tap.numberOfTapsRequired = 1;
//            [self.bannerNavigationBar addGestureRecognizer:tap];
//            //上滑恢复
//            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan1:)];
//            [self.bannerNavigationBar addGestureRecognizer:pan];
//            pan.delegate = self;
        }];
        
        //隐藏小智
        [self hideXiaozhi:YES];
        
        //刷新数据
        [self.topScreenView loadData];
        
        self.topScreenShow = YES;
        [CMPCore sharedInstance].showingTopScreen = YES;
    }else if (state == 3) {//还原
        [self.topScreenView handlePermisson:YES];
        [self.topScreenView showMask:NO];
        [self resumeViewAnimate:YES];
    }
}

- (void)vibrate{
    if (self.hasVibrated) {
        return;
    }
    self.hasVibrated = YES;
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator prepare];
    [generator impactOccurred];
}

- (void)resumeViewAnimate:(BOOL)animate{
    self.topScreenShow = NO;
    [CMPCore sharedInstance].topScreenBeginShow = NO;
    [CMPCore sharedInstance].showingTopScreen = NO;
    
    self.weakListView.tableView.scrollEnabled = YES;
    [self.rdv_tabBarController setTabBarHidden:NO];
//    self.needRefreshMsg = YES;
    
    [self updateViewY:0 animate:animate completion:nil];
    
    //恢复列表显示
    self.weakListView.tableView.alpha = 1.0;
    
    //删除加的view
    [[self.view viewWithTag:kTag_botMaskView] removeFromSuperview];
    [[self.view viewWithTag:kTag_botSafeAreaMaskView] removeFromSuperview];
    [[self.view viewWithTag:kTag_CornerMaskView] removeFromSuperview];
    [[self.view viewWithTag:kTag_PanTopScreenLabel] removeFromSuperview];
    
    //恢复statusBar原有状态
    [self setupStatusBarViewBackground:self.bannerNavigationBar.backgroundColor];
    //恢复导航栏按钮点击
    [self.bannerNavigationBar.rightBarButtonItems enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
    }];
    
    [self hideXiaozhi:NO];
}

- (void)updateViewY:(CGFloat)y animate:(BOOL)animate completion:(void(^)(void))completion{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqual:self.topScreenView]) {
            if (idx<self.panOriginYArr.count) {
                CGFloat originY = [[self.panOriginYArr objectAtIndex:idx] floatValue];
                CGRect f = obj.frame;
                if (y>=0) {
                    f.origin.y = originY + y;
                    if (animate) {//动画
                        [UIView animateWithDuration:0.25 animations:^{
                            obj.frame = f;
                        } completion:^(BOOL finished) {
                            if (completion) {
                                completion();
                            }
                        }];
                    }else{
                        obj.frame = f;
                    }
                }
            }
        }
    }];
}

- (void)tapAction:(UIGestureRecognizer *)recognizer{
    if (!self.topScreenShow) {
        return;
    }
    [self resumeViewAnimate:YES];
}
- (void)handlePan1:(UIPanGestureRecognizer *)g {
    if (!self.topScreenShow) {
        return;
    }
    CGPoint translation = [g translationInView:g.view];
    if (translation.y<0) {//上拉
        CGPoint velocity = [g velocityInView:g.view];
        CGFloat distance = sqrt(pow(translation.x, 2) + pow(translation.y, 2));
        CGFloat speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
        if ( distance > 15 && speed > 800) { // 你可以根据需要调整这个速度阈值
            [self resumeViewAnimate:YES];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.weakListView.tableView.contentOffset.y<=0) {
        return YES;
    }
    return NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self.weakListView.tableView];
        return fabs(velocity.y) > fabs(velocity.x);
    }
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (IS_IPHONE && scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

- (void)hideXiaozhi:(BOOL)hide{
    //小致图标会被遮住
    UIView *view = [self.view viewWithTag:kViewTag_XiaozIcon];
    if (view) {
        view.hidden = hide;
    }
}

@end

