//
//  CMPShowShutterImgView.m
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPShowShutterImgView.h"
#import "LYAVPlayerView.h"
#import "CMPAVPlayerViewController.h"

#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPCAAnimation.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPFileManager.h>


@interface CMPShowShutterImgView()<LYVideoPlayerDelegate>

/* imgView */
@property (strong, nonatomic) UIImageView *imgView;
/* bottomView */
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *retakeBtn;
@property (strong, nonatomic) UIButton *useBtn;

/* playerView */
@property (strong, nonatomic) LYAVPlayerView *playerView;


@end

@implementation CMPShowShutterImgView
#pragma mark - lazy loading

/// 播放视频view
- (LYAVPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[LYAVPlayerView alloc] init];
           //先获取视频的宽高比
        //   CGFloat scale =[self.playerView getVideoScale:[NSURL URLWithString:VideoURL]];
        _playerView.frame = self.imgView.bounds;
        _playerView.layer.masksToBounds = YES;
        _playerView.delegate = self;
    }
    return _playerView;
}

/// 底部操作view
- (UIView *)bottomView {
    if (!_bottomView) {
        CGFloat height = 120.f;
        _bottomView = [UIView.alloc initWithFrame:CGRectMake(0, self.height - height, self.width, height)];
        _bottomView.backgroundColor = UIColor.blackColor;
        
        UIButton *retakeBtn = [UIButton.alloc initWithFrame:CGRectMake(15.f, 0, 100.f, 26.f)];
        retakeBtn.cmp_centerY = _bottomView.cmp_height/2.f;
        [retakeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        NSString *retakeTitle = SY_STRING(@"video_component_retake_title");
        CGFloat retakeBtnW = [retakeTitle sizeWithFontSize:[UIFont systemFontOfSize:18.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 6.f;
        retakeBtn.cmp_width = retakeBtnW;
        [retakeBtn setTitle:retakeTitle forState:UIControlStateNormal];
        [_bottomView addSubview:retakeBtn];
        [retakeBtn addTarget:self action:@selector(retakeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.retakeBtn = retakeBtn;
        
        UIButton *useBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, 100.f, 26.f)];
        useBtn.cmp_centerY = retakeBtn.cmp_centerY;
        [useBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        NSString *useTitle = SY_STRING(@"video_component_use_title");
        CGFloat useBtnW = [useTitle sizeWithFontSize:[UIFont systemFontOfSize:18.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 6.f;
        [useBtn setTitle:useTitle forState:UIControlStateNormal];
        useBtn.cmp_width = useBtnW;
        useBtn.cmp_x = _bottomView.width - 15.f - useBtnW;
        [_bottomView addSubview:useBtn];
        [useBtn addTarget:self action:@selector(useBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.useBtn = useBtn;
    }
    return _bottomView;
}

/// 显示图片的view
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView.alloc initWithFrame:CGRectMake(0, 60.f, self.width, self.height - 60.f - self.bottomView.height)];
        _imgView.backgroundColor = UIColor.clearColor;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.layer.masksToBounds = YES;
        if (_image) {
            _imgView.image = _image;
        }
        
        if (_videoUrl) {

           //先获取视频的宽高比
           [self.imgView addSubview:self.playerView];
           [self.playerView setURL:_videoUrl];
           [self.playerView play];
        }
    }
    return _imgView;
}

#pragma mark - initialise views
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bottomView];
        [self addSubview:self.imgView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = 120.f;
    self.bottomView.frame = CGRectMake(0, self.height - height, self.width, height);
    
    self.retakeBtn.frame = CGRectMake(15.f, 0, 100.f, 26.f);
    self.retakeBtn.cmp_centerY = _bottomView.cmp_height/2.f;
    NSString *retakeTitle = SY_STRING(@"video_component_retake_title");
    CGFloat retakeBtnW = [retakeTitle sizeWithFontSize:[UIFont systemFontOfSize:18.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 6.f;
    self.retakeBtn.cmp_width = retakeBtnW;
    
    self.useBtn.frame = CGRectMake(0, 0, 100.f, 26.f);
    self.useBtn.cmp_centerY = self.retakeBtn.cmp_centerY;
    NSString *useTitle = SY_STRING(@"video_component_use_title");
    CGFloat useBtnW = [useTitle sizeWithFontSize:[UIFont systemFontOfSize:18.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width + 6.f;
    [self.useBtn setTitle:useTitle forState:UIControlStateNormal];
    self.useBtn.cmp_width = useBtnW;
    self.useBtn.cmp_x = _bottomView.width - 15.f - useBtnW;
    
    _imgView.frame = CGRectMake(0, 60.f, self.width, self.height - 60.f - self.bottomView.height);
    _playerView.frame = self.imgView.bounds;
}

#pragma mark - 外部设置属性setter
- (void)setImage:(UIImage *)image {
    _image = image.copy;
    if (image) {
        self.imgView.image = image;
    }
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl.copy;
    if (videoUrl) {
        //先获取视频的宽高比
        [self.imgView addSubview:self.playerView];
        [self.playerView setURL:videoUrl];
        [self.playerView play];
    }
}

#pragma mark - 按钮点击

/// 重拍按钮点击
- (void)retakeBtnClicked {
    CMPFuncLog;
    if (self.videoUrl) {
        
        if ([[NSFileManager defaultManager] removeItemAtPath:self.videoUrl.path error:nil]) {
            CMPLog(@"zl----删除拍摄视频文件成功-----");
        }else {
            CMPLog(@"zl----删除拍摄视频文件失败-----");
        }
    }
    ///清空设置的属性
    self.image = nil;
    self.videoUrl = nil;
    self.imgView.image = nil;
    [self.playerView setURL:nil];
    
    [self removeFromSuperview];
    [self.playerView stop];
    [self.playerView removeFromSuperview];
    if (_retakeClicked) {
        _retakeClicked();
    }
}

/// 使用按钮点击
- (void)useBtnClicked {
    CMPFuncLog;
    if (_useClicked) {
        [self usePhoto];
    }
}

- (void)usePhoto {
    NSString *videoUrl = self.videoUrl.absoluteString;
    __block NSDictionary *videoInfo = nil;
    if (videoUrl) {
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD cmp_showProgressHUDWithText:SY_STRING(@"video_compress")];
        
        [CMPCommonTool convertVideoQuailtyWithInputURL:self.videoUrl.copy completeHandler:^(NSString *outputUrl) {
            [MBProgressHUD cmp_hideProgressHUD];
            [weakSelf removeFromSuperview];
            NSData *videoData = [NSData dataWithContentsOfFile:[outputUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
            videoInfo = @{@"videoUrl" : outputUrl,
                          @"videoSize" : NSStringFromCGSize([CMPCommonTool getVideoSizeWithUrl:outputUrl]),
                          @"videoTime" : @([CMPCommonTool getVideoTimeByUrlString:outputUrl]),
                          @"fileSize" : @(videoData.length)
            };
            weakSelf.useClicked(weakSelf.image.copy,videoInfo);
        }];
        
        
    }else {
        self.useClicked(_image.copy,videoInfo);
        [self removeFromSuperview];
    }
}

#pragma mark- ----LYVideoPlayerDelegate------  播放视频view代理方法
// 可播放／播放中
- (void)videoPlayerIsReadyToPlayVideo:(LYAVPlayerView *)playerView{
    
    CMPLog(@"可播放");
    
}

//播放完毕
- (void)videoPlayerDidReachEnd:(LYAVPlayerView *)playerView{
    
     CMPLog(@"播放完毕");
    
    [self.playerView setURL:_videoUrl];
    [self.playerView play];
    
}
//当前播放时间
- (void)videoPlayer:(LYAVPlayerView *)playerView timeDidChange:(CGFloat )time{
    
}


//duration 当前缓冲的长度
- (void)videoPlayer:(LYAVPlayerView *)playerView loadedTimeRangeDidChange:(CGFloat )duration{
    
    CMPLog(@"当前缓冲的长度%f",duration);
    
}

//进行跳转后没数据 即播放卡顿
- (void)videoPlayerPlaybackBufferEmpty:(LYAVPlayerView *)playerView{
    
     CMPLog(@"卡顿了");
    
}

// 进行跳转后有数据 能够继续播放
- (void)videoPlayerPlaybackLikelyToKeepUp:(LYAVPlayerView *)playerView{
    
     CMPLog(@"能够继续播放");
    
}

//加载失败
- (void)videoPlayer:(LYAVPlayerView *)playerView didFailWithError:(NSError *)error{
    
     CMPLog(@"加载失败");
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_viewClicked) {
        _viewClicked(self.videoUrl);
    }
}

@end
