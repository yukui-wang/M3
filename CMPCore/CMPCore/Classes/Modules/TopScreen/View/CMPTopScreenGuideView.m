//
//  CMPTopScreenGuideView.m
//  M3
//
//  Created by Shoujian Rao on 2024/1/12.
//

#import "CMPTopScreenGuideView.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPCore.h>
#import "CMPLoginConfigInfoModel.h"
#import "CMPHomeAlertManager.h"
#import "CMPGuideManager.h"

@interface CMPTopScreenGuideView()

@property (nonatomic,strong)UIImageView *topScreenIgv;
@property (nonatomic,strong)UIButton *nextBtn;

@property (nonatomic,strong)UIImageView *moreAppIgv;
@property (nonatomic,strong)UIButton *iseeBtn;

@property (nonatomic,copy)CMPTopScreenGuideViewDissmissBlock dissmissBlock;

@end
@implementation CMPTopScreenGuideView

+(void)showGuideInView:(UIView *)view isMsgPage:(BOOL)isMsgPage{
    if (!view) {
        return;
    }
    if (CMP_IPAD_MODE) {
        return;
    }
    BOOL topScreenShown = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultName_showTopScreenTipFlag];
    BOOL newCommonShown = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultName_showNewCommonGuideTipFlag];
    
//    BOOL topScreenShown = NO;//测试代码
//    BOOL newCommonShown = NO;//测试代码
    
    BOOL showTop = NO;
    BOOL showCommon = NO;
    
    if ([CMPTopScreenGuideView canShowNewCommon] && !newCommonShown) {//是否显示应用中心引导
        showCommon = YES;
    }
    if (isMsgPage && !topScreenShown) {
        showTop = YES;
    }
    
    //都弹过了，就不弹了
    if (!showTop && !showCommon) {
        return;
    }
    
    if (![CMPHomeAlertManager sharedInstance].hasPushedNewVersionTip) {
        [CMPHomeAlertManager sharedInstance].hasPushedNewVersionTip = YES;
        [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
            [CMPTopScreenGuideView showInView:view showTop:showTop showCommon:showCommon dissmiss:^{
                [[CMPHomeAlertManager sharedInstance] taskDone];
                [CMPHomeAlertManager sharedInstance].hasPushedNewVersionTip = NO;
            }];
        } priority:CMPHomeAlertPriorityTip];
    }
}

+(BOOL)canShowNewCommon{
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:[CMPCore sharedInstance].currentUser.configInfo];
    BOOL flag = !configInfo.portal.isShowCommonApp;
    if (flag) {
        return NO;
    }
    return YES;
}


+ (void)showInView:(UIView *)inView showTop:(BOOL)showTop showCommon:(BOOL)showCommon dissmiss:(CMPTopScreenGuideViewDissmissBlock)dismissBlock{
    CMPTopScreenGuideView *guideView = [[CMPTopScreenGuideView alloc]init];
    guideView.dissmissBlock = dismissBlock;
    [inView addSubview:guideView];
    [guideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(inView);
    }];
    [inView bringSubviewToFront:guideView];
    
    if (showTop && showCommon) {
        [guideView setupTopScreenAndCommon];//显示两步
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showTopScreenTipFlag];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showNewCommonGuideTipFlag];
    }else if (showTop) {
        [guideView setupTopScreen];//只显示负一屏
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showTopScreenTipFlag];
    }else if (showCommon){
        [guideView setupMoreAppView];//只显示应用中心
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showNewCommonGuideTipFlag];
    }else{
        //如果没有，就删除view
        [guideView removeFromSuperview];
        guideView = nil;
    }
    
}

- (void)showWithTop:(BOOL)showTop showCommon:(BOOL)showCommon{
    [self.superview bringSubviewToFront:self];
    if (showTop && showCommon) {
        [self setupTopScreenAndCommon];//显示两步
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showTopScreenTipFlag];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showNewCommonGuideTipFlag];
    }else if (showTop) {
        [self setupTopScreen];//只显示负一屏
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showTopScreenTipFlag];
    }else if (showCommon){
        [self setupMoreAppView];//只显示应用中心
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showNewCommonGuideTipFlag];
    }
}

- (BOOL)isEnLanguage{
    return [[CMPCore languageCode] containsString:kLanguageCode_En];
}

- (void)setupBackgroundColor{
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
}

- (void)setupTopScreenAndCommon {
    [self setupBackgroundColor];
    //负一屏背景图
    _topScreenIgv = [[UIImageView alloc]init];
    CGFloat imageW = 375.0;
    CGFloat imageH = 236.0;
    CGFloat h = (UIScreen.mainScreen.bounds.size.width * imageH)/imageW;
    [self addSubview:_topScreenIgv];
    [_topScreenIgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(h);
    }];
    NSString *imageName = [self isEnLanguage]?@"top_screen_guide_slidesurprise_en":@"top_screen_guide_slidesurprise_ch";
    _topScreenIgv.image = [UIImage imageNamed:imageName];
    
    //下一步按钮背景图
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_nextBtn];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-188);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(36);
    }];
    NSString *btnImageName = [self isEnLanguage]?@"top_screen_guide_next_en":@"top_screen_guide_next_ch";
    [_nextBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:(UIControlStateNormal)];
    [_nextBtn addTarget:self action:@selector(setupMoreAppView) forControlEvents:(UIControlEventTouchUpInside)];
    
    //标记已展示过
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_showTopScreenTipFlag];
}

- (void)setupMoreAppView {
    [self setupBackgroundColor];
    //负一屏背景图
    _topScreenIgv.hidden = YES;
    //下一步按钮背景图
    _nextBtn.hidden = YES;
    
    //更多应用背景图
    _moreAppIgv = [[UIImageView alloc]init];
    CGFloat h = ((UIScreen.mainScreen.bounds.size.width-17-18) * 155)/340.0;
    [self addSubview:_moreAppIgv];
    [_moreAppIgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CMP_STATUSBAR_HEIGHT + 44);//statusBar + navibar
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-18);
        make.height.mas_equalTo(h);
    }];
    NSString *imageName = [self isEnLanguage]?@"top_screen_guide_moreapp_en":@"top_screen_guide_moreapp_ch";
    _moreAppIgv.image = [UIImage imageNamed:imageName];
    
    //我知道了按钮
    _iseeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _iseeBtn.tag = 110;
    [self addSubview:_iseeBtn];
    [_iseeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-188);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(36);
    }];
    [_iseeBtn setBackgroundImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
    NSString *btnImageName = [self isEnLanguage]?@"top_screen_guide_isee_en":@"top_screen_guide_isee_ch";
    [_iseeBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:(UIControlStateNormal)];
    
    [_iseeBtn addTarget:self action:@selector(dismiss:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [CMPGuideManager sharedInstance].showingCommonGuidePage = YES;

}

- (void)setupTopScreen{
    [self setupBackgroundColor];
    //负一屏背景图
    _topScreenIgv = [[UIImageView alloc]init];
    CGFloat imageW = 375.0;
    CGFloat imageH = 236.0;
    CGFloat h = (UIScreen.mainScreen.bounds.size.width * imageH)/imageW;
    [self addSubview:_topScreenIgv];
    [_topScreenIgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(h);
    }];
    NSString *imageName = [self isEnLanguage]?@"top_screen_guide_slidesurprise_en":@"top_screen_guide_slidesurprise_ch";
    _topScreenIgv.image = [UIImage imageNamed:imageName];
    
    //我知道了按钮
    _iseeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_iseeBtn];
    [_iseeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-188);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(36);
    }];
    [_iseeBtn setBackgroundImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
    NSString *btnImageName = [self isEnLanguage]?@"top_screen_guide_isee_en":@"top_screen_guide_isee_ch";
    [_iseeBtn setBackgroundImage:[UIImage imageNamed:btnImageName] forState:(UIControlStateNormal)];
    
    [_iseeBtn addTarget:self action:@selector(dismiss:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)dismiss:(UIButton *)btn{
    [self removeFromSuperview];
    if (self.dissmissBlock) {
        self.dissmissBlock();
    }
    if (btn.tag == 110) {
        [CMPGuideManager sharedInstance].showingCommonGuidePage = NO;
        if ([CMPGuideManager sharedInstance].waitTapIknowButtonCompletion) {
            [CMPGuideManager sharedInstance].waitTapIknowButtonCompletion();
            [CMPGuideManager sharedInstance].waitTapIknowButtonCompletion = nil;
        }
    }
    

}


@end
