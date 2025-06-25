//
//  CMPWiFiClockInHelper.m
//  M3
//
//  Created by CRMO on 2019/1/21.
//

#import "CMPWiFiClockInHelper.h"
#import "CMPWiFiClockInProvider.h"
#import <CMPLib/CMPWiFiUtil.h>
#import <CMPLib/EGOCache.h>
#import "CMPWiFiClockInViewController.h"
#import "CMPHomeAlertManager.h"

@interface CMPWiFiClockInHelper()

@property (strong, nonatomic) CMPWiFiClockInProvider *provider;
@property (strong, nonatomic) UIWindow *window;

@end

@implementation CMPWiFiClockInHelper

/**
 判断条件：
 1. 服务器返回的isShow为true
 2. 连接上服务器设置的WiFi
 3. 当天没有弹出过快捷打卡（存储在设备中，换设备还是会弹出）
 */
- (void)showWiFiClockIn {
    [[CMPHomeAlertManager sharedInstance] pushTaskWithShowBlock:^{
        [self _showWiFiClockIn];
    } priority:CMPHomeAlertPriorityWiFiClockIn];
}

- (void)_showWiFiClockIn {
    __weak __typeof(self)weakSelf = self;
    [self.provider requestClockInSettingSuccess:^(CMPWiFiClockInSettingResponse * _Nonnull response) {
        BOOL needClockIn = response.needClockIn;
        NSDictionary *wifiInfo = [CMPWiFiUtil connectedWifiInfo];
        NSString *bssid = wifiInfo[CMPWiFiInfoKeyBSSID];
        BOOL isConnectedWiFiLegal = [response isConnectedWiFiLegal:bssid];
        BOOL isShowedWiFiClockIn = [weakSelf _showedState];
        
        if (!needClockIn ||
            !isConnectedWiFiLegal ||
            isShowedWiFiClockIn) {
            [[CMPHomeAlertManager sharedInstance] taskDone];
            DDLogDebug(@"zl---[%s],需要展示打卡：%d, 连接合法WiFi：%d，是否展示过打卡：%d", __FUNCTION__, needClockIn, isConnectedWiFiLegal, isShowedWiFiClockIn);
            return;
        }
        
        [weakSelf _showWiFiClockInView:response];
        [CMPWiFiClockInHelper _saveShowedState];
    } fail:^(NSError * _Nonnull error) {
        DDLogDebug(@"zl---[%s],请求打卡设置失败", __FUNCTION__);
    }];
}

/**
 展示WiFi打卡页面
 */
- (void)_showWiFiClockInView:(CMPWiFiClockInSettingResponse *)clockInSetting {
    CMPWiFiClockInViewController *vc = [[CMPWiFiClockInViewController alloc] init];
    __weak __typeof(self)weakSelf = self;
    __weak CMPWiFiClockInViewController *weakVc = vc;
    vc.clockInSetting = clockInSetting;
    vc.provider = self.provider;
    vc.didDismiss = ^{
        weakSelf.window.rootViewController = nil;
        weakSelf.window.hidden = YES;
        weakSelf.window = nil;
        [[CMPHomeAlertManager sharedInstance] taskDone];
        weakVc.didDismiss = nil;
        weakSelf.provider = nil;
        DDLogDebug(@"zl---[%s],WiFi打卡隐藏", __FUNCTION__);
    };
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = vc;
    _window.windowLevel = UIWindowLevelAlert;
    [_window makeKeyAndVisible];
    DDLogDebug(@"zl---[%s],展示WiFi打卡", __FUNCTION__);
}

#pragma mark-
#pragma mark WiFi提醒时间持久化

/**
 保存今天已经弹出过标识
 */
+ (void)_saveShowedState {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *key = _showedStateKey();
    [[EGOCache globalCache] setString:dateStr forKey:key];
}

/**
 判断今天是否已经弹出来过
 */
- (BOOL)_showedState {
    NSString *key = _showedStateKey();
    NSString *lastShowedDate = [[EGOCache globalCache] stringForKey:key];
    if ([NSString isNull:lastShowedDate]) {
        return NO;
    }
    DDLogDebug(@"zl---[%s],上次打卡时间:%@", __FUNCTION__, lastShowedDate);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    if ([lastShowedDate isEqualToString:dateStr]) {
        return YES;
    } else {
        return NO;
    }
}

NSString *_showedStateKey() {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_CMPWiFiClockInHelperStateKey", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, [CMPCore sharedInstance].currentUser.accountID];
    return key;
}

#pragma mark-
#pragma mark Getter

- (CMPWiFiClockInProvider *)provider {
    if (!_provider) {
        _provider = [[CMPWiFiClockInProvider alloc] init];
    }
    return _provider;
}

@end
