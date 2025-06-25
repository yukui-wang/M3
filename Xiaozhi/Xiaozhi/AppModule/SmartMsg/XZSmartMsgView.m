//
//  XZSmartMsgView.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZSmartMsgView.h"

#import "XZScheduleMsg.h"
#import "XZBusinessMsg.h"
#import "XZStatisticsMsg.h"
#import "XZCultureMsg.h"
#import "XZScheduleMsgView.h"
#import "XZBusinessMsgView.h"
#import "XZStatisticsMsgView.h"
#import "XZCultureMsgView.h"
//#import "AppDelegate.h"
#import "XZCore.h"
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPAlertView.h>

@implementation XZSmartMsgView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    self.needDismissBlock = nil;
    self.needSpeakBlock = nil;
    self.needStopSpeakBlock = nil;
    [_voiceButton removeFromSuperview];
    _voiceButton = nil;
    [_closeButton removeFromSuperview];
    _closeButton = nil;
    [_shadeView removeFromSuperview];
    SY_RELEASE_SAFELY(_shadeView);
    
    for (UIView *view in _msgViewArray) {
        [view removeFromSuperview];
    }
    [_msgViewArray removeAllObjects];
    SY_RELEASE_SAFELY(_msgViewArray);
    
    [_scrollView removeFromSuperview];
    SY_RELEASE_SAFELY(_scrollView);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}
- (void)deviceOrientationDidChange {
    [self layoutViews];
}

- (void)setup {
    
    if (!_shadeView) {
        //遮罩层
        _shadeView = [[UIView alloc] init];
        _shadeView.backgroundColor = [UIColor blackColor];
        _shadeView.alpha = 0.5;
    }
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled=YES;
        [self addSubview:_scrollView];
    }
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xC6CEE9);
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xA2B0CD);
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageControl];
    }
    _voiceOn = [[XZCore sharedInstance] msgViewCanSpeak];
    if (!_voiceButton) {
        _voiceButton = [self buttonWithImage:[self voiceImgName] action:@selector(voiceButtonClick)];
    }
    
    if (!_closeButton) {
        _closeButton = [self buttonWithImage:@"msgView.bundle/view_close.png" action:@selector(closeButtonClick)];
    }

    [_voiceButton setFrame:CGRectMake((_shadeView.width-100)/3, _shadeView.height-80, 42, 42)];
    [_closeButton setFrame:CGRectMake(_shadeView.width-50-_voiceButton.originX, _shadeView.height-80, 42, 42)];
    
    CGPoint c = _closeButton.center;
    c.x = _closeButton.originX-_voiceButton.width/2;
    _voiceButton.center = c;
    _voiceButton.layer.cornerRadius = _voiceButton.width/2;
    _closeButton.layer.cornerRadius = _closeButton.width/2;

}


- (UIButton *)buttonWithImage:(NSString *)imageName action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 42, 42)];
    button.layer.cornerRadius = button.width/2;
    button.layer.masksToBounds = YES;
    button.backgroundColor = UIColorFromRGB(0x444444);
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)customLayoutSubviews {
    if (_msgViewArray.count < 1) {
        return;
    }
    [_pageControl setFrame:CGRectMake(20, self.height-28, self.width-40, 28)];
    [_scrollView setFrame:CGRectMake(0, 0, self.width, IS_PHONE_Landscape ? self.height : _pageControl.originY)];
    _scrollView.contentSize = CGSizeMake(_scrollView.width *_msgViewArray.count, _scrollView.height);
    for (NSInteger i = 0 ; i < _msgViewArray.count; i ++) {
        UIView *view = [_msgViewArray objectAtIndex:i];
        [view setFrame:CGRectMake(_scrollView.width*i, 0, _scrollView.width, _scrollView.height)];
    }
}

- (NSString *)voiceImgName {
    NSString *imageName = !_voiceOn ? @"msgView.bundle/voice_on.png" : @"msgView.bundle/voice_off.png";
    return imageName;
}

- (void)voiceButtonClick {
    __weak typeof(self) weakSelf = self;

    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        [weakSelf handleVoiceButtonClick];
    } falseCompletion:^{
        NSString *boundName = [[NSBundle mainBundle]
                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"请在设备的“设置-隐私-麦克风”选项中允许“%@”访问你的麦克风",boundName];
        CMPAlertView * alert = [[CMPAlertView alloc] initWithTitle:@"麦克风不可用" message:message cancelButtonTitle:@"取消" otherButtonTitles:[NSArray arrayWithObject:@"去设置"] callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        [alert show];
        SY_RELEASE_SAFELY(alert)
    }];
}

- (void)handleVoiceButtonClick {
    _voiceOn = !_voiceOn;
    [[XZCore sharedInstance] setupMsgViewCanSpeak:_voiceOn];
    UIImage *image = [[UIImage imageNamed:[self voiceImgName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_voiceButton setImage:image forState:UIControlStateNormal];
    for (XZBaseMsgView *view in _msgViewArray) {
        view.hasSpeaked = !_voiceOn;
    }
    if (_voiceOn) {
        [self currentShowViewAtIndex:_pageControl.currentPage];
    }
    else {
        if (self.needStopSpeakBlock) {
            self.needStopSpeakBlock();
        }
    }
}

- (void)closeButtonClick {
    if (self.needDismissBlock) {
        self.needDismissBlock();
    }
}

- (void)setupMsgArray:(NSArray *)msgArray {
    [self layoutMsgView:msgArray];
}

- (void)layoutMsgView:(NSArray *)msgArray {
    NSArray *array = [XZBaseMsg msgArrayWithDataList:msgArray];
    if (!_msgViewArray) {
        _msgViewArray = [[NSMutableArray alloc] init];
    }
    for (XZBaseMsg *obj in array) {
        XZBaseMsgView *view = [XZBaseMsgView viewWithMsg:obj];
        if (view) {
            view.isFirst = _isfirst;
            view.hasSpeaked = !_voiceOn;
            [_scrollView addSubview:view];
            [_msgViewArray addObject:view];
            _isfirst = NO;
            view.needOnOffBlock = ^(BOOL onoff) {
               [[XZCore sharedInstance] setupMsgSwitchInfoWithMainSwitch:onoff];
            };
            __weak typeof(self) weakSelf = self;
            view.willOpenViewBlock = ^{
                weakSelf.needStopSpeakBlock();
            };
        }
    }
    [self customLayoutSubviews];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = _msgViewArray.count;
    _pageControl.hidden = _msgViewArray.count > 1 ? NO:YES;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger width = _scrollView.width;
    NSInteger currentX = scrollView.contentOffset.x;
    NSInteger index = currentX/width;
    _pageControl.currentPage = index;
    [self currentShowViewAtIndex:index];
}

- (void)currentShowViewAtIndex:(NSInteger)index {

    if (self.needStopSpeakBlock) {
        self.needStopSpeakBlock();
    }
//    if (index+1 < _msgViewArray.count && index+1 >= 0) {
//        XZBaseMsgView *view = [_msgViewArray objectAtIndex:index+1];
//        [view loadView];
//    }
//    if (index-1 < _msgViewArray.count && index-1 >= 0) {
//        XZBaseMsgView *view = [_msgViewArray objectAtIndex:index-1];
//        [view loadView];
//    }
   
    if (index < _msgViewArray.count && index >= 0) {
        XZBaseMsgView *view = [_msgViewArray objectAtIndex:index];
        [view loadView];
        if (!view.hasSpeaked && self.needSpeakBlock) {
            self.needSpeakBlock(view.msg.remarks);
        }
        view.hasSpeaked = YES;
    }
}


- (void)showInView:(UIView *)view  {
    
    [view addSubview:_shadeView];
    [view bringSubviewToFront:_shadeView];
    [view addSubview:self];
    [view bringSubviewToFront:self];
   
    [view addSubview:_voiceButton];
    [view addSubview:_closeButton];
   
    [self layoutViews];
   
    //OA-160088 M3智能提醒：IOS端，报表数据显示提醒，但是未显示报表的图表数据
    [self currentShowViewAtIndex:0];

}

- (void)layoutViews {
    UIView *view = _shadeView.superview;
    if (!view) {
        return;
    }
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        _shadeView.frame = CGRectMake(0, 0, MAX(view.height, view.width), MIN(view.height, view.width));
    }
    else {
        _shadeView.frame = CGRectMake(0, 0, MIN(view.height, view.width), MAX(view.height, view.width));
    }

    CGFloat y =  _shadeView.height*0.13;
    CGFloat bh =  _shadeView.height*0.17;
    if (_shadeView.height < 600)  {
        //for iphone5s  iphone5 iphoneSE
        y = 60;
        bh = y +26;
    }
    if (IS_PHONE_Landscape) {
        y = 20;
        bh = 82;
    }
    NSInteger x =_shadeView.width*0.04;
    if (x < 17) {
        x = 17;
    }
    [self setFrame:CGRectMake(x, floor(y), _shadeView.width-2*x, _shadeView.height-floor(y)-floor(bh))];
    CGPoint c = CGPointMake(_shadeView.width/3, (CGRectGetMaxY(self.frame) +_shadeView.height )/2);
    _voiceButton.center = c;
    c.x = _shadeView.width *2/3;
    _closeButton.center = c;
    
    [_scrollView setContentOffset:CGPointMake(_pageControl.currentPage *_scrollView.width, 0)];

}


- (void)dismiss {
    if (self.needStopSpeakBlock) {
        self.needStopSpeakBlock();
    }
    [_shadeView removeFromSuperview];
    [_voiceButton removeFromSuperview];
    _voiceButton = nil;
    [_closeButton removeFromSuperview];
    _closeButton = nil;
}

@end
