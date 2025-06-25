//
//  CMPWiFiClockInViewController.m
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import "CMPWiFiClockInViewController.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/MSWeakTimer.h>
#import <CMPLib/CMPWiFiUtil.h>
#import "CMPWiFiClockInProvider.h"
#import <CMPLib/NSObject+CMPHUDView.h>

static const CGFloat clockInViewHeight = 196;

@interface CMPWiFiClockInViewController ()

@property (strong, nonatomic) MSWeakTimer *refreshTimer; // 刷新时间计时器
//@property (strong, nonatomic) AFNetworkReachabilityManager *networkReachability;

@end

@implementation CMPWiFiClockInViewController

- (void)dealloc {
    [_refreshTimer invalidate];
    _refreshTimer = nil;
//    [_networkReachability stopMonitoring];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    // 开始时间刷新
    [self _startRefreshTime];
    // 监听网络状态变化
//    [self _startNetWorkMonitoring];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _showClockInView];
}

- (void)_setupViews {
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    self.clockInView = [[CMPWiFiClockInView alloc] init];
    [self.view addSubview:self.clockInView];
    [self.clockInView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(-clockInViewHeight);
        make.leading.trailing.equalTo(self.view).inset(10);
        make.height.equalTo(clockInViewHeight);
    }];
    [self.clockInView.clockInButton addTarget:self
                                       action:@selector(tapClockIn)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.clockInView.closeButton addTarget:self
                                     action:@selector(tapClose)
                           forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化WiFi信息
    [self _refreshWifiName];
    // 初始化时间
    [self _refreshTime];
    // 初始化上班时间
    NSString *clockInTime = self.clockInSetting.clockInTime;
    self.clockInView.workTimeLabel.text = [NSString stringWithFormat:@"%@ %@", SY_STRING(@"WiFiClockIn_clockInTime"), clockInTime];
}

#pragma mark-
#pragma mark 点击事件

- (void)tapClockIn {
    NSDictionary *wifiInfo = [CMPWiFiUtil connectedWifiInfo];
    NSString *ssid = wifiInfo[CMPWiFiInfoKeySSID];
    NSString *bssid = wifiInfo[CMPWiFiInfoKeyBSSID];
    
    if (![self.clockInSetting isConnectedWiFiLegal:bssid]) {
        // WiFi不合法，隐藏打卡界面
        [self cmp_showHUDWithText:SY_STRING(@"WiFiClockIn_illegal")];
        DDLogDebug(@"zl---[%s]:当前连接WiFi不合法，隐藏打卡界面", __FUNCTION__);
//        [self _hideClockInView];
        return;
    }
    
    [self.clockInView.clockInButton updateState:CMPWiFiClockInButtonStateLoading];
    
    __weak __typeof(self)weakSelf = self;
    [self.provider clockInWithSSID:ssid bssid:bssid clockInTime:self.clockInSetting.clockInTime success:^(CMPWiFiClockInResponse * _Nonnull response) {
        if ([response.code isEqualToString:@"200"]) {
            DDLogDebug(@"zl---[%s],WiFi打卡成功", __FUNCTION__);
            [weakSelf.clockInView.clockInButton updateState:CMPWiFiClockInButtonStateSuccess];
        } else {
            [weakSelf cmp_showHUDWithText:response.message];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf _hideClockInView];
        });
    } fail:^(NSError * _Nonnull error) {
        DDLogDebug(@"zl---[%s],WiFi打卡失败：%@", __FUNCTION__, error);
        [weakSelf.clockInView.clockInButton updateState:CMPWiFiClockInButtonStateInit];
        [weakSelf cmp_showHUDWithText:error.domain];
    }];
}

- (void)tapClose {
    [self _hideClockInView];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.clockInView];
//    // 点击空白处，隐藏窗口
//    if (touchPoint.y > self.clockInView.cmp_height) {
//        [self _hideClockInView];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

#pragma mark-
#pragma mark UI刷新

/**
 开启刷新时间计时器
 */
- (void)_startRefreshTime {
    [self.refreshTimer invalidate];
    self.refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(_refreshTime)
                                                           userInfo:nil
                                                            repeats:YES
                                                      dispatchQueue:dispatch_get_main_queue()];
}

/**
 刷新时间
 */
- (void)_refreshTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    self.clockInView.timeLabel.text = timeStr;
//    [formatter setDateFormat:@"yyyy年MM月dd日"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    self.clockInView.dateLabel.text = dateStr;
}

/**
 开启网络监听
 */
//- (void)_startNetWorkMonitoring {
//    self.networkReachability = [AFNetworkReachabilityManager manager];
//    __weak __typeof(self)weakSelf = self;
//    [self.networkReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        [weakSelf _refreshWifiName];
//    }];
//    [self.networkReachability startMonitoring];
//}

- (void)_refreshWifiName {
    NSDictionary *wifiInfo = [CMPWiFiUtil connectedWifiInfo];
    NSString *bssid = wifiInfo[CMPWiFiInfoKeyBSSID];
    
    if (![self.clockInSetting isConnectedWiFiLegal:bssid]) {
        // WiFi不合法，隐藏打卡界面
        DDLogDebug(@"zl---[%s]:当前连接WiFi不合法，隐藏打卡界面", __FUNCTION__);
        [self _hideClockInView];
    } else {
        NSDictionary *wifiInfo = [CMPWiFiUtil connectedWifiInfo];
        self.clockInView.wifiNameLabel.text = wifiInfo[CMPWiFiInfoKeySSID];
    }
}

- (void)_showClockInView {
    [UIView animateWithDuration:1 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self.clockInView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.topMargin.equalTo(10);
        }];
        [self.view layoutIfNeeded];
    }];
}

- (void)_hideClockInView {
    [UIView animateWithDuration:1 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self.clockInView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.topMargin.equalTo(-clockInViewHeight);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.didDismiss) {
            self.didDismiss();
            self.didDismiss = nil;
        }
    }];
}

@end
