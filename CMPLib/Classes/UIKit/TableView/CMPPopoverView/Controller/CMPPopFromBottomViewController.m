//
//  CMPPopFromBottomViewController.m
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import "CMPPopFromBottomViewController.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPCore.h>


static NSString * const kHideShowingViewKey = @"hideShowingViewKey";
CGFloat const CMPShowingViewTimeInterval = 0.3f;


@interface CMPPopFromBottomViewController ()<CAAnimationDelegate>

/* shareView是否在显示中 */
@property (assign, nonatomic) BOOL isShowingViewShowing;

@end

@implementation CMPPopFromBottomViewController


#pragma mark - life circle

- (void)dealloc {
    DDLogDebug(@"---%s----",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
    self.showingView.cmp_width = self.view.width;
    self.showingView.cmp_y = self.view.height;
    [self.view addSubview:self.showingView];
    self.showingView.userInteractionEnabled = YES;
    [self showShowingView];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isShowingViewShowing) {
        [self hideShowingView];
        if (self.viewClicked) self.viewClicked(YES);
    }else {
        [self showShowingView];
    }
}


#pragma mark - 显示隐藏shareView
- (void)showShowingView {
    self.isShowingViewShowing = YES;
    [self animationWithFromValue:(self.view.height + self.showingView.height/2.f) toValue:(self.view.height - self.showingView.height/2.f) key:nil];
}

- (void)hideShowingView {
    self.isShowingViewShowing = NO;
    [self animationWithFromValue:(self.view.height - self.showingView.height/2.f) toValue:(self.view.height + self.showingView.height/2.f) key:kHideShowingViewKey];
}

- (void)animationWithFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue key:(NSString *)key {
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnimation.duration = CMPShowingViewTimeInterval;//动画时间
    //动画起始值和终止值的设置
    moveAnimation.fromValue = @(fromValue);
    moveAnimation.toValue = @(toValue);
    //一个时间函数，表示它以怎么样的时间运行
    [moveAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    moveAnimation.repeatCount = 1;
    //这里如果设置了delegate的话，就记得要移除动画，否则会造成循环引用，因为这里的delegate是strong
    moveAnimation.delegate = self;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeBoth;
    //添加动画，后面有可以拿到这个动画的标识
    if (!key) {
        key = @"showingViewMoveAnimKey";
    }
    [self.showingView.layer addAnimation:moveAnimation forKey:key];
}


- (void)hideViewWithoutAnimation {
    if (self.viewClicked) self.viewClicked(NO);
}


- (void)viewWillLayoutSubviews {
    
    
    [super viewWillLayoutSubviews];
}

// 横竖屏将要切换会调用
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"横竖屏进行了切换size:%@",NSStringFromCGSize(size));
    // 延时一下 获得的高度才正确，要不然是转屏前的宽高
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           //横竖屏切换
           if (CMP_IPAD_MODE) {
               self.showingView.frame = CGRectMake(0, self.view.height - self.showingView.height, self.view.width, self.showingView.height);
               [self showShowingView];
           }
    });
}


#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) return;
    
    CAAnimation *anim1 = [self.showingView.layer animationForKey:kHideShowingViewKey];
    if (![anim isEqual:anim1]) {
        self.showingView.cmp_centerY = self.view.height - self.showingView.height/2.f;
    }else {
        //移除动画，以免造成循环引用
        [self.showingView.layer removeAllAnimations];
    }
}

@end
