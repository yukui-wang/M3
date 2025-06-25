//
//  CMPStartPageView.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/15.
//
//

#import "CMPStartPageView.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/JSONKit.h>
#import <CMPLib/UIColor+Hex.h>
#import "AppDelegate.h"
#import "CMPCommonManager.h"
#import <CMPLib/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/SOLocalization.h>

@interface CMPStartPageView ()

@property (nonatomic,strong)UIImageView *backgroundImgView;
@property (nonatomic,strong)UIView *backgroundAVLayerView;

@property (nonatomic,strong)AVPlayer *player;//
@property (nonatomic,strong)AVPlayerLayer *avLayer;//播放器播放图层

@end

@implementation CMPStartPageView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.hidden = YES;
        
        //OA-214126 M3-iOS端：iOS13.4瞩目会议，此时唤醒M3，会占用听筒，会议就听不到了(小致是关闭的)
        NSError *error;
        BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
        if (!success) {
             NSLog(@"%@", [error localizedDescription]);
        }

        [self loadCusView];
        // 转屏通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        // 视频播放结束 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)loadCusView
{
    [self removeAllSubviews];
    self.backgroundImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.backgroundImgView];
    
    self.backgroundAVLayerView = [[UIView alloc] init];
    [self addSubview:self.backgroundAVLayerView];
    [self.backgroundAVLayerView.layer addSublayer:self.avLayer];
    self.backgroundAVLayerView.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(self);
    }];
    
    [self.backgroundAVLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIScreen *mainScreen = [UIScreen mainScreen];
        CGFloat screenWidth = mainScreen.currentMode.size.width / mainScreen.scale;
        CGFloat width;
        if (INTERFACE_IS_PAD) {
            width = screenWidth * 0.5;
        } else {
            width = screenWidth;
        }
        CGFloat height = width * 2208 / 1242;
        make.center.equalTo(self);
        make.size.equalTo(CGSizeMake(width, height));
        
    }];
    
    self.backgroundAVLayerView.layoutSubviewsCallback = ^(UIView *superview) {
        weakSelf.avLayer.frame = superview.bounds;
    };
    
    UIImage *startPageImage = [self getStartPageImage];
    if (startPageImage) {
        self.backgroundImgView.image = startPageImage;
    } else {
        self.backgroundAVLayerView.hidden = NO;
    }
}

- (UIImage *)getStartPageImage {
    NSDictionary *aStartPageInfo = [[CMPCore sharedInstance].customStartPageSetting JSONValue];
     // 需要判断两个点：1、backgroundImage是否有值 2、启动页背景图片是否存在
     NSString *aStr = nil;
     if ([aStartPageInfo isKindOfClass:[NSDictionary class]]){
          aStr = [aStartPageInfo objectForKey:@"backgroundImage"];
     }
     UIImage *aImage = nil;
     if (![NSString isNull:aStr]) {
         aImage = [CMPCommonManager getStartPageBackgroundImage];
     }
     
     NSDictionary * moreBackgroundImage = aStartPageInfo[@"moreBackgroundImage"];
     if (moreBackgroundImage && [moreBackgroundImage isKindOfClass:[NSDictionary class]]) {
         NSDictionary *bgImageDic = nil;
         if (INTERFACE_IS_PAD) {
             bgImageDic = moreBackgroundImage[@"pad"];
         } else if (INTERFACE_IS_PHONE) {
             bgImageDic = moreBackgroundImage[@"phone"];
         }
         
         if ([bgImageDic count]) {
             if (INTERFACE_IS_PAD) {
                 if (InterfaceOrientationIsPortrait) {
                     aImage = [CMPCommonManager getStartPageBackgroundImage];
                 } else {
                     aImage = [CMPCommonManager getStartPageLandscapeBackgroundImage];
                 }
             } else {
                 aImage = [CMPCommonManager getStartPageBackgroundImage];
             }
         }
     }
    
//     if (!aImage) {
//         aImage = [self defaultBackgroundImage];
//     }
    return aImage;
}

//- (void)didChangeRotate:(NSNotification*)notice {
//    self.frame = [UIScreen mainScreen].bounds;
//    self.backgroundImgView.image = [self getStartPageImage];
//}

-(AVPlayerLayer *)avLayer {
    if (!_avLayer) {
        NSString *serverIdRegion = [[SOLocalization sharedLocalization] getRegionWithServerId:kCMP_ServerID inSupportRegions:[SOLocalization loacalSupportRegions]];
        NSString *region = ([serverIdRegion isEqualToString:SOLocalizationSimplifiedChinese] || [serverIdRegion isEqualToString:SOLocalizationTraditionalChinese]) ? @"ch" : @"en";
        NSString *avName = [NSString stringWithFormat:@"startPageDefault_av_%@",region];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"StartPageSources" ofType:@"bundle"]] URLForResource:avName withExtension:@"mp4"]];
         self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        _avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.player play];
    }
    return _avLayer;
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    [self rerunPlayVideo];
}

//视频重播
- (void)rerunPlayVideo{
    if (!self.player) {
        return;
    }
    NSInteger dragedSeconds = floorf(0);
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [self.player seekToTime:dragedCMTime];
    [self.player play];
}



- (UIImage *)defaultBackgroundImage
{
    NSString *imgName;
    
    if (iPhone5) {
        imgName = @"StartPageSources.bundle/startPageDefault_5";
    } else if (iPhone6) {
        imgName = @"StartPageSources.bundle/startPageDefault_6";
    } else if (iPhone6Plus) {
        imgName = @"StartPageSources.bundle/startPageDefault_6p";
    } else {
        imgName = @"StartPageSources.bundle/startPageDefault_x";
    }

    imgName = [NSString stringWithFormat:@"%@%@.png",imgName,SY_STRING(@"common_language")];
    return [UIImage imageNamed:imgName];
}

@end
