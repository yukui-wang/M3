//
//  CMPAVPlayerViewController.m
//  CMPLib
//
//  Created by MacBook on 2019/12/20.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPAVPlayerViewController.h"
#import "LYAVPlayerView.h"
#import "CMPPopOverManager.h"
#import "CMPAVPlayerTransitionAnimation.h"

#import <CMPLib/SOSwizzle.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/YBIBUtilities.h>
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/UIDevice+TFDevice.h>
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPReviewImagesTool.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/CMPAppDelegate.h>
#import <CMPLib/NSObject+CMPHUDView.h>

static CGFloat const kCornerRadius = 4.f;
static CGFloat const kViewMargin = 14.f;
static CGFloat const kBottomBarH = 40.f;
static NSString * const kViewBgColor = @"#312c35";


@interface CMPAVPlayerViewController ()<LYVideoPlayerDelegate,UIViewControllerTransitioningDelegate>

/* 动画过渡转场 */
@property (nonatomic, strong) CMPAVPlayerTransitionAnimation *transitionAnimation;
/* 手势过渡转场 */
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;

/* 全屏view */
@property (strong, nonatomic) UIView *fullScreenView;
/* 视频播放view */
@property (strong, nonatomic) LYAVPlayerView *playerView;
/* 音乐播放封面 */
@property (strong, nonatomic) UIImageView *audioCoverImageView;
/* coverView用于控制的那些view的隐藏和显示 */
@property (strong, nonatomic) UIView *coverView;
/* 底部操作栏 */
@property (strong, nonatomic) UIView *bottomBar;
/* 底部操作栏全屏按钮 */
@property (strong, nonatomic) UIButton *fullScreenBtn;
/* 底部操作栏进度条 */
@property (strong, nonatomic) UISlider *slider;
/* 底部操作栏 时间label */
@property (strong, nonatomic) UILabel *currentTimeLabel;
/* 底部操作栏 总时长label */
@property (strong, nonatomic) UILabel *totalTimeLabel;
/* 关左上角闭按钮 */
@property (strong, nonatomic) UIButton *closeBtn;
/* 右上角相册按钮 */
@property (strong, nonatomic) UIButton *albumBtn;
/* 中间播放按钮 */
@property (strong, nonatomic) UIButton *playBtn;

/* controlTimer */
@property (strong, nonatomic) MSWeakTimer *controlTimer;
/* 倒计时，关闭控制区 */
@property (assign, nonatomic) int count;

@property (nonatomic, nullable, strong) UIView *playerSuperView;//记录播放器父视图
@property (nonatomic, assign) CGRect playerFrame;//记录播放器原始frame
@property (nonatomic, assign) BOOL isFullScreen;//记录是否全屏
/* 是否在图片/视频页面进行了删除操作 */
@property (assign, nonatomic) BOOL hasDoneDelted;

/* 显示vc相关 */
/* fromView */
@property (weak, nonatomic) UIView *fromView;

/**
 * 是否允许转向
 */
@property(nonatomic,assign)BOOL allowRotation;

@end


@implementation CMPAVPlayerViewController
#pragma mark - lazy loading

- (CMPAVPlayerTransitionAnimation *)transitionAnimation{
    
    if (!_transitionAnimation) {
        _transitionAnimation = [[CMPAVPlayerTransitionAnimation alloc] init];
        self.transitioningDelegate = self;
    }
    return _transitionAnimation;
}


/// 全屏view，用于横屏全屏的显示
- (UIView *)fullScreenView {
    if (!_fullScreenView) {
        _fullScreenView = [UIView.alloc initWithFrame:self.view.bounds];
        _fullScreenView.backgroundColor = UIColor.blackColor;
    }
    return _fullScreenView;
}

/// 音乐播放封面
- (UIImageView *)audioCoverImageView {
    if (!_audioCoverImageView) {
        _audioCoverImageView = [[UIImageView alloc] init];
        _audioCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _audioCoverImageView.frame = self.view.bounds;
        _audioCoverImageView.image = [UIImage imageNamed:@"audio_cover"];
    }
    return _audioCoverImageView;
}

/// 播放view，用于播放视频
- (LYAVPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [LYAVPlayerView.alloc initWithFrame:self.view.bounds];
        _playerView.delegate = self;
        _playerView.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerView;
}

/// coverview，用于点击屏幕时显示隐藏操作按钮等
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView.alloc initWithFrame:self.view.bounds];
        _coverView.backgroundColor = UIColor.clearColor;
    }
    return _coverView;
}

/// 最下面时间、快进等views
- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [UIView.alloc initWithFrame:CGRectMake(kViewMargin, self.view.height - kBottomBarH - kViewMargin, self.view.width - 2.f*kViewMargin, kBottomBarH)];
        if (YBIBUtilities.isIphoneX) {
            _bottomBar.cmp_y -= 20.f;
        }
        _bottomBar.backgroundColor = [UIColor colorWithHexString:kViewBgColor];
        [_bottomBar cmp_setCornerRadius:kCornerRadius];
    }
    return _bottomBar;
}

/// 当前时间
- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        NSString *tmpStr = @"666:60:60";
        CGFloat width = [tmpStr sizeWithFontSize:[UIFont systemFontOfSize:12.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 8.f;
        _currentTimeLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 0, width, self.bottomBar.height)];
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.f];
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

/// 横竖屏切换按钮
- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton.alloc initWithFrame:CGRectMake(self.bottomBar.width - 40.f, 0, 40.f, self.bottomBar.height)];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"video_fullscreen_btn"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"video_play_portrait"] forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

/// 总共播放时间
- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        NSString *tmpStr = @"666:60:60";
        CGFloat width = [tmpStr sizeWithFontSize:[UIFont systemFontOfSize:12.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 8.f;
        _totalTimeLabel = [UILabel.alloc initWithFrame:CGRectMake(CGRectGetMinX(self.fullScreenBtn.frame) - width, 0, width, self.bottomBar.height)];
        _totalTimeLabel.textColor = [UIColor colorWithHexString:@"#cbc8c7"];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = @"00:00";
    }
    return _totalTimeLabel;
}

/// 播放进度条
- (UISlider *)slider {
    if (!_slider) {
        CGFloat x = CGRectGetMaxX(self.currentTimeLabel.frame);
        CGFloat width = CGRectGetMinX(self.totalTimeLabel.frame) - x;
        _slider = [UISlider.alloc initWithFrame:CGRectMake(x, 0, width, self.bottomBar.height)];
        _slider.tintColor = UIColor.whiteColor;
        _slider.minimumTrackTintColor = UIColor.whiteColor;
        _slider.maximumTrackTintColor = UIColor.whiteColor;
        [_slider setThumbImage:[UIImage imageNamed:@"video_slider_btn"] forState:UIControlStateNormal];
        [_slider setContinuous:YES];
        [_slider addTarget:self action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _slider;
}

/// 最中间的播放按钮
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, 50.f, 50.f)];
        _playBtn.center = self.view.center;
        [_playBtn setImage:[UIImage imageNamed:@"video_play_btn"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"video_pause_btn"] forState:UIControlStateSelected];
        _playBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [_playBtn cmp_setRoundView];
        [_playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

/// 关闭按钮，点击即退出播放界面
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        CGFloat y = 25.f;
        if (YBIBUtilities.isIphoneX) {
            y += 44.f;
        }
        _closeBtn = [UIButton.alloc initWithFrame:CGRectMake(kViewMargin, y, 40.f, 40.f)];
        [_closeBtn setImage:[UIImage imageNamed:@"video_close_btn"] forState:UIControlStateNormal];
        _closeBtn.backgroundColor = [UIColor colorWithHexString:kViewBgColor];
        [_closeBtn addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn cmp_setCornerRadius:kCornerRadius];
    }
    return _closeBtn;
}

/// 图片/视频 按钮，点击进入图片/视频页面
- (UIButton *)albumBtn {
    if (!_albumBtn) {
        _albumBtn = [UIButton.alloc initWithFrame:CGRectMake(self.view.width - 40.f - kViewMargin, 0, 40.f, 40.f)];
        _albumBtn.cmp_centerY = self.closeBtn.cmp_centerY;
        [_albumBtn setImage:[UIImage imageNamed:@"video_album_btn"] forState:UIControlStateNormal];
        _albumBtn.backgroundColor = [UIColor colorWithHexString:kViewBgColor];
        [_albumBtn cmp_setCornerRadius:kCornerRadius];
        [_albumBtn addTarget:self action:@selector(albumClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumBtn;
}

#pragma mark - life circle

#pragma mark - 通知相关

- (void)addNotis {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(delteSelectedRcImgModelsPicNoti:) name:CMPDelteSelectedRcImgModelsPicNoti object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    self.hasDoneDelted = NO;
}

- (void)delteSelectedRcImgModelsPicNoti:(NSNotification *)noti {
    self.hasDoneDelted = YES;
}

//- (void)applicationDidBecomeActive:(NSNotification *)notification{
//    [self play];
//}

- (void)applicationWillResignActive:(NSNotification *)notification{
    [self pause];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitionAnimation.transitionType = CMPAVPlayerTransitionTypePresent;
        //设置了这个属性之后，在present转场动画处理时，转场前的视图fromVC的view一直都在管理转场动画视图的容器containerView中，会被转场后,后加入到containerView中视图toVC的View遮住，类似于入栈出栈的原理；如果没有设置的话，present转场时，fromVC.view就会先出栈从containerView移除，然后toVC.View入栈，那之后再进行disMiss转场返回时，需要重新把fromVC.view加入containerView中。
        //在push转场动画处理时,设置这个属性是没有效果的，也就是没用的。
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)dealloc{
    CMPFuncLog;
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotis];
    [self configViews];
    [self play];
    [self addGestures];
    [self fireTimer];
    if (self.autoSave && !self.isOnlinePlay) {
        [self saveVideo];
    }
    if (self.palyType == CMPAVPlayerPalyTypeVideo) {
        self.allowRotation = YES;
    } else {
        self.allowRotation = NO;
    }
    
    [MBProgressHUD cmp_showProgressHUD];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.allowRotation = self.isFromControllerAllowRotation;
}

/// 设置views
- (void)configViews {
    [self.view addSubview:self.fullScreenView];
//    [self.fullScreenView addSubview:self.edgePanView];
    [self.fullScreenView addSubview:self.playerView];
    if (self.palyType == CMPAVPlayerPalyTypeAudio) {
        [self.fullScreenView addSubview:self.audioCoverImageView];
    }
    
    [self.fullScreenView addSubview:self.coverView];
    
    
    [self.bottomBar addSubview:self.currentTimeLabel];
    if (self.palyType == CMPAVPlayerPalyTypeVideo) {
        [self.bottomBar addSubview:self.fullScreenBtn];
    }
    [self.bottomBar addSubview:self.totalTimeLabel];
    [self.bottomBar addSubview:self.slider];
    
    [self.coverView addSubview:self.bottomBar];
    [self.coverView addSubview:self.playBtn];
    [self.coverView addSubview:self.closeBtn];
    [self.coverView addSubview:self.albumBtn];
    
    self.albumBtn.hidden = !(self.showAlbumBtn && !self.isOnlinePlay);
    if (self.palyType == CMPAVPlayerPalyTypeAudio && [NSString isNotNull:self.audioCoverImageUrlStr]) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithPathString:self.audioCoverImageUrlStr] options:SDWebImageDownloaderHandleCookies|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (finished && !error) {
                [self.audioCoverImageView setImage:image];
            }
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.hasDoneDelted) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

/// view消失的时候，停止播放
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.playBtn.selected = YES;
    [self playBtnClicked:self.playBtn];
}


/// 适配界面，横竖屏切换后的界面显示
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.fullScreenView.frame = self.view.bounds;
    self.coverView.frame = self.fullScreenView.bounds;
    self.playerView.frame = self.fullScreenView.bounds;
    self.bottomBar.frame = CGRectMake(kViewMargin, self.view.height - kBottomBarH - kViewMargin, self.view.width - 2.f*kViewMargin, kBottomBarH);
    
    if (self.palyType == CMPAVPlayerPalyTypeAudio) {
        self.audioCoverImageView.frame = self.view.bounds;
    }
    
    if (!self.fullScreenBtn.selected && YBIBUtilities.isIphoneX) {
        self.bottomBar.cmp_y -= 20.f;
    }
    
    self.currentTimeLabel.cmp_x = 0;
    self.currentTimeLabel.cmp_y = 0;
    
    self.fullScreenBtn.frame = CGRectMake(self.bottomBar.width - 40.f, 0, 40.f, self.bottomBar.height);
    
    if (self.palyType == CMPAVPlayerPalyTypeVideo) {
        self.totalTimeLabel.cmp_x = CGRectGetMinX(self.fullScreenBtn.frame) - self.totalTimeLabel.width;
    } else {
        self.totalTimeLabel.cmp_x = self.bottomBar.cmp_width - self.totalTimeLabel.width;
    }
        
    self.totalTimeLabel.cmp_y = 0;
    
    CGFloat x = CGRectGetMaxX(self.currentTimeLabel.frame);
    CGFloat width = CGRectGetMinX(self.totalTimeLabel.frame) - x;
    self.slider.frame = CGRectMake(x, 0, width, self.bottomBar.height);
    
    self.playBtn.center = self.view.center;
    
    CGFloat y = 25.f;
    if (!self.fullScreenBtn.selected && YBIBUtilities.isIphoneX) {
        y += 30.f;
    }
    
    
    self.closeBtn.frame = CGRectMake(kViewMargin, y, 40.f, 40.f);
    
    self.albumBtn.frame = CGRectMake(self.view.width - 40.f - kViewMargin, 0, 40.f, 40.f);
    self.albumBtn.cmp_centerY = self.closeBtn.cmp_centerY;
}

- (void)setShowAlbumBtn:(BOOL)showAlbumBtn {
    _showAlbumBtn = showAlbumBtn;
    _albumBtn.hidden = !(showAlbumBtn && !self.isOnlinePlay);
}

#pragma mark - 播放相关

/// 播放
- (void)play {
    if ([self.playerView getCurrentPlayTime] == [self.playerView getTotalPlayTime]) {
        if (_url) {
            [self.playerView setURL:_url];
        }
        if (_urlString) {
            [self.playerView setURL: [NSURL URLWithString:_urlString]];
        }
    }
    
    [self.playerView play];
    
    self.playBtn.selected = YES;
}

/// 暂停
- (void)pause {
    [self.playerView pause];
    self.playBtn.selected = NO;
}

/// 停止
- (void)stop {
    [self.playerView stop];
    self.playBtn.selected = NO;
}

#pragma mark - 手势相关

- (void)addGestures {
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrClicked)];
    [self.fullScreenView addGestureRecognizer:tapGr];
    
    if (!self.isOnlinePlay) {
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGr:)];
        [self.view addGestureRecognizer:gr];
    }
    
    [self addScreenEdgePanGestureRecognizer:self.view edges:UIRectEdgeLeft];
}


- (void)addScreenEdgePanGestureRecognizer:(UIView *)view edges:(UIRectEdge)edges{
    UIScreenEdgePanGestureRecognizer * edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGesture:)]; // viewController和SecondViewController的手势都由self管理
    edgePan.edges = edges;
    [view addGestureRecognizer:edgePan];
}
/// 右划手势返回功能
- (void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)edgePan {
    CGPoint translation = [edgePan translationInView:edgePan.view];
    CGFloat progress = 0;
//    CGPoint velocity = [edgePan velocityInView:edgePan.view];
    
    //左右滑动的百分比
    progress = translation.x / (self.view.width);
    progress = fabs(progress);
    
    if(edgePan.state == UIGestureRecognizerStateBegan){
        [self pause];
        self.percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        if(edgePan.edges == UIRectEdgeRight){
            // present，避免重复，直接调用点击方法
        }else if(edgePan.edges == UIRectEdgeLeft){
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }else if(edgePan.state == UIGestureRecognizerStateChanged){
        [self.percentDrivenTransition updateInteractiveTransition:progress];
    }else if(edgePan.state == UIGestureRecognizerStateCancelled || edgePan.state == UIGestureRecognizerStateEnded){
        if(progress > 0.2f){
            [_percentDrivenTransition finishInteractiveTransition];
        }else{
            [_percentDrivenTransition cancelInteractiveTransition];
            [self play];
        }
        _percentDrivenTransition = nil;
    }
}


/// 显示隐藏coverview
- (void)tapGrClicked {
    [self reFireTimer];
    [self showControlView:!self.coverView.alpha];
    
    // 刷新状态栏 隐藏=YES,显示=NO; Animation:动画效果
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
}


- (void)longPressGr:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        CMPFuncLog;
//        BOOL isUc = self.showAlbumBtn;
//        if (self.palyType == CMPAVPlayerPalyTypeAudio) {
//            if (self.msgModel) {
//                isUc = YES;
//            }else {
//                isUc = NO;
//            }
//        }
        BOOL isUc =  [CMPStringConst fromTypeIsUC:self.fromType];
        [CMPPopOverManager.sharedManager showVideoSelectViewWithModel:self.msgModel url:self.url.absoluteString vc:self from:self.from fromType:self.fromType fileId:self.fileId canNotShare:self.canNotShare canNotCollect:self.canNotCollect canNotSave:self.canNotSave isUc:isUc fileName:self.fileName.copy];
    }
}

- (BOOL)prefersStatusBarHidden {
    return !self.coverView.alpha;
}


#pragma mark - 保存视频

- (void)saveVideo
{
    NSString *urlString = self.urlString;
    if ([NSString isNull:urlString]) {
        urlString = [self.url.absoluteString urlEncoding];
    }
    NSString *path = [urlString stringByReplacingOccurrencesOfString:@"file://" withString:@""];

    CMPFile *aFile = [[CMPFile alloc] init];
    aFile.filePath = path;
    aFile.fileID = self.fileId;
    aFile.fileName = self.fileName;
    aFile.from = self.from;
    aFile.fromType = self.fromType;
    aFile.origin = self.fileId;
    [CMPFileManager.defaultManager saveFile:aFile];
}


#pragma mark - 按钮点击

/// 播放按钮点击
- (void)playBtnClicked:(UIButton *)btn {
    [self reFireTimer];
    if (!btn.selected) {
        [self play];
    }else {
        [self pause];
    }
}

/// 横竖屏切换按点击
- (void)fullScreenClicked:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    if (btn.selected) {//如果是全屏，点击按钮进入小屏状态
        [UIDevice switchNewOrientationIncludingIPad:UIInterfaceOrientationLandscapeRight];
    } else {//不是全屏，点击按钮进入全屏状态
        [UIDevice switchNewOrientationIncludingIPad:UIInterfaceOrientationPortrait];
    }
    
    if (self.playBtn.selected) {
        [self play];
    }
}

/// 关闭按钮点击
- (void)closeClicked {
    CMPFuncLog;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumClicked {
    CMPFuncLog;
    [CMPReviewImagesTool showPicListViewControllerWithDataModelArray:self.mediaUrlArr rcImgModels:self.rcImgModels canSave:!self.canNotSave];
}

/// 进度条值改变响应事件
- (void)sliderValueDidChanged:(UISlider *)slider {
    CMPFuncLog;
    CGFloat totalTime = [self.playerView getTotalPlayTime];
    CGFloat currentTime = slider.value*totalTime;
    
    self.totalTimeLabel.text = [self getTimeStringWithTime:totalTime];
    self.currentTimeLabel.text = [self getTimeStringWithTime:currentTime];
    
    [self.playerView seekToTime:currentTime];
    [self play];
    
    [self reFireTimer];
}

#pragma mark - 定时器相关

/// 重启定时器
- (void)reFireTimer {
    [self invalidateTimer];
    [self fireTimer];
}

/// 启动定时器
- (void)fireTimer {
    self.count = 3;
    self.controlTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.controlTimer fire];
}

/// 停止定时器
- (void)invalidateTimer {
    [self.controlTimer invalidate];
    self.controlTimer = nil;
}

/// 定时器响应方法
- (void)countDown {
    CMPFuncLog;
    if (self.count < 1) {
        [self invalidateTimer];
        [self showControlView:NO];
        // 刷新状态栏 隐藏=YES,显示=NO; Animation:动画效果
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }else {
        self.count--;
    }
    
}

- (void)showControlView:(BOOL)isShow {
    [UIView animateWithDuration:0.3f animations:^{
        self.coverView.alpha = isShow;
    }];
}

#pragma mark - LYVideoPlayerDelegate，播放view的代理回调方法

// 可播放／播放中
- (void)videoPlayerIsReadyToPlayVideo:(LYAVPlayerView *)playerView {
    [MBProgressHUD cmp_hideProgressHUD];
    [self setSliderProgress];
}

//当前播放时间
- (void)videoPlayer:(LYAVPlayerView *)playerView timeDidChange:(CGFloat)time {
    [self setSliderProgress];
    
    CGFloat totalTime = [playerView getTotalPlayTime];
    if (totalTime - time < 1.f) {
        self.playBtn.selected = NO;
        [self.slider setValue:1.f animated:YES];
    }
    
}
//duration 当前缓冲的长度
- (void)videoPlayer:(LYAVPlayerView *)playerView loadedTimeRangeDidChange:(CGFloat)duration {
    
}
//进行跳转后没数据 即播放卡顿
- (void)videoPlayerPlaybackBufferEmpty:(LYAVPlayerView *)playerView {
    [MBProgressHUD cmp_hideProgressHUD];
}
// 进行跳转后有数据 能够继续播放
- (void)videoPlayerPlaybackLikelyToKeepUp:(LYAVPlayerView *)playerView {
    
}
//加载失败
- (void)videoPlayer:(LYAVPlayerView *)playerView didFailWithError:(NSError *)error {
    [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"video_component_data_loading_failed")];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 秒转时间字符串

- (NSString *)getTimeStringWithTime:(CGFloat)time {
    NSInteger intTime = (NSInteger)time;
    int second = [self getSecondWithTime:intTime];
    int minute = [self getMinuteWithTime:intTime];
    int hour = [self getHourWithTime:time];
    
    NSString *timeString = @"00:00";
    if (hour) {
        timeString = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }else {
        timeString = [NSString stringWithFormat:@"%d:%02d:%02d",hour,minute,second];
    }
    
    return timeString;
}

- (int)getSecondWithTime:(NSInteger)time {
    
    if (time/3600 < 24) {
        return time%60;
    }
    return 0;
}

- (int)getMinuteWithTime:(NSInteger)time {
    
    if (time/3600 < 24) {
        return (int)(time/60);
    }
    return 0;
}

- (int)getHourWithTime:(NSInteger)time {
    return (int)(time/3600);
}

#pragma mark 设置进度条

- (void)setSliderProgress {
    CGFloat totalTime = [self.playerView getTotalPlayTime];
    CGFloat currTime = [self.playerView getCurrentPlayTime];
    [self.slider setValue:currTime/totalTime animated:YES];
    
    self.totalTimeLabel.text = [self getTimeStringWithTime:totalTime];
    self.currentTimeLabel.text = [self getTimeStringWithTime:currTime];
}

#pragma mark - 显示vc

- (void)showFromVc:(UIViewController *)fromVc fromView:(UIView *)fromView {
    self.fromView = fromView;
    [fromVc presentViewController:self animated:NO completion:^{
        
    }];
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



#pragma mark -- UIViewControllerTransitioningDelegate

//返回一个处理present动画过渡的对象
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transitionAnimation.transitionType = CMPAVPlayerTransitionTypePresent;
    return self.transitionAnimation;
}
//返回一个处理dismiss动画过渡的对象
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //这里我们初始化dismissType
    self.transitionAnimation.transitionType = CMPAVPlayerTransitionTypeDissmiss;
    return self.transitionAnimation;
}

//返回一个处理dismiss手势过渡的对象
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return _percentDrivenTransition;
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return SY_STRING(@"screeenshot_page_title_AVPlayer");
}

@end








