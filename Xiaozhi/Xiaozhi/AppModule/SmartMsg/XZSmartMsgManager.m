//
//  XZSmartMsgManager.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSmartMsgManager.h"
#import <CMPLib/CMPConstant.h>
#import "XZCore.h"
#import "XZMainProjectBridge.h"
#import "SPTools.h"
#import <CMPLib/CMPDevicePermissionHelper.h>
#import "XZM3RequestManager.h"

@implementation XZSmartMsgManager

+ (instancetype)sharedInstance{
    static XZSmartMsgManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XZSmartMsgManager alloc] init];
    });
    return instance;
}


#pragma mark smart  msg

- (void)startShowSmartMsg {
    self.canShowMsgView = YES;
    self.isLogout = NO;
    [self performSelector:@selector(showSmartMsg) withObject:nil afterDelay:1];
}

- (void)needSearchSmartMsg:(NSString *)date inController:(UIViewController *)viewController {
    self.viewController = viewController;
    [self needSearchSmartMsg:date];
}

- (void)userLogout {
    self.canShowMsgView = NO;
    self.isLogout = YES;
    if (self.msgTimer && [self.msgTimer isValid]) {
        [self.msgTimer invalidate];
    }
    self.msgTimer = nil;
    self.viewController = nil;
    
    [_msgView dismiss];
    [self.msgView removeFromSuperview];
    self.msgView  = nil;
    
    self.robotSpeakBlock = nil;
    self.stopSpeakBlock = nil;
    self.showSpeechRobotBlock = nil;
    self.handleBeforeRequestBlock = nil;
    self.willShowMsgViewBlock = nil;
    self.enterSleepBlock = nil;
    self.handleErrorBlock = nil;
}

- (void)addListenToTabbarControllerShow {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSmartMsg) name:kNotificationName_TabbarChildViewControllerDidAppear object:nil];
}

- (void)showSmartMsg {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_TabbarChildViewControllerDidAppear object:nil];
    
    if (self.isLogout) {
        return;
    }
    XZMsgSwitchInfo *msgSwitchInfo = [[XZCore sharedInstance] msgSwitchInfo];
    if (!msgSwitchInfo.mainSwitch) {
        //智能消息总开关关闭了
        return;
    }
    if ([msgSwitchInfo msgTypeList].count == 0) {
        //智能消息 没有消息种类
        return;
    }
    CMPSpeechRobotConfig *config = [XZCore sharedInstance].robotConfig;
    if (!config.isOnOff) {
        //语音机器人没有打开，不显示智能消息
        return;
    }
    
    XZMsgRemindRule *msgRemindRule = [[XZCore sharedInstance] msgRemindRule];
    if (!msgRemindRule) {
        //没有轮询规则，不查询
        return;
    }
    
    //格式化轮询时间端
    NSString *startDateStr = [msgRemindRule startTime];
    NSString *endDateStr = [msgRemindRule endTime];
    NSInteger remindStep = [msgRemindRule remindStep];
    NSArray *beginArray = [startDateStr componentsSeparatedByString:@":"];
    NSInteger bh = 0;//开始 小时
    NSInteger bm = 0;//开始 分
    if (beginArray.count >= 2) {
        bh = [[beginArray objectAtIndex:0] integerValue];
        bm = [[beginArray objectAtIndex:1] integerValue];
    }
    else {
        return;
    }
    NSArray *endArray = [endDateStr componentsSeparatedByString:@":"];
    NSInteger eh = 0;//结束 小时
    NSInteger em = 0;//结束 分
    if (endArray.count >= 2) {
        eh = [[endArray objectAtIndex:0] integerValue];
        em = [[endArray objectAtIndex:1] integerValue];
    }
    else {
        return;
    }
    
    NSString *loaclTime = [[XZCore sharedInstance] msgRemindPreTime];
    NSDateFormatter *formt = [[NSDateFormatter alloc] init];
    formt.timeZone = [NSTimeZone systemTimeZone];
    [formt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [formt stringFromDate: [NSDate date]];
    
    NSString *beginStr = [NSString stringWithFormat:@"%@ %02ld:%02ld:00",[currentDateStr substringToIndex:10],(long)bh,(long)bm];
    NSString *endStr = [NSString stringWithFormat:@"%@ %02ld:%02ld:00",[currentDateStr substringToIndex:10],(long)eh,(long)em];
    NSDate *currentDate = [formt dateFromString:currentDateStr];
    NSDate *preDate = [formt dateFromString:loaclTime];
    NSDate *beginDate = [formt dateFromString:beginStr];
    NSDate *endDate = [formt dateFromString:endStr];
    
    NSTimeInterval beginInterval = [currentDate timeIntervalSinceDate:beginDate];
    NSTimeInterval endInterval = [currentDate timeIntervalSinceDate:endDate];
    NSTimeInterval preInterval = [currentDate timeIntervalSinceDate:preDate];
    if (beginInterval <0 ||endInterval >0 ) {
        //不在时间端
        return;
    }
    if (preInterval >= remindStep) {
        //上一次时间距离现在大于等于 轮询时间间隔 需要查消息
        if ([self canShowSmartMsg]) {
            //不在底导航界面，不显示
            [self requestSmartMsg];
            [[XZCore sharedInstance] updateMsgRemindPreTime:currentDateStr];
        }
       
        if (self.msgTimer && [self.msgTimer isValid]) {
            [self.msgTimer invalidate];
        }
        self.msgTimer = nil;
        self.msgTimer=[NSTimer scheduledTimerWithTimeInterval:remindStep target:self selector:@selector(showSmartMsg) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.msgTimer forMode:NSRunLoopCommonModes];
    }
    else {
        //退出账号要关掉timer
        NSInteger second = remindStep-preInterval;
        if (self.msgTimer && [self.msgTimer isValid]) {
            [self.msgTimer invalidate];
        }
        self.msgTimer = nil;
        self.msgTimer=[NSTimer scheduledTimerWithTimeInterval:second target:self selector:@selector(showSmartMsg) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.msgTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)showMsg:(NSArray *)dataList showInfo:(BOOL)showInfo {
    if (self.isLogout || !self.canShowMsgView) {
        return;
    }
    [self enterSleep:YES];
    if (!dataList || dataList.count == 0) {
        if(showInfo) {
            NSString *str = @"很抱歉，没能找到该天的工作提醒";
            [self robotSpeak:str speakContent:str];
        }
        return;
    }
    if(showInfo) {
        [self robotSpeak:@"好的" speakContent:@""];
    }
    if (self.viewController) {
        [self showMsg:dataList view:self.viewController.view isFirst:NO completion:nil];
    }
    else {
        __weak typeof(self) weakSelf = self;
        [XZMainProjectBridge homeAlertManagerPushTask:^{
            UITabBarController *viewController = [SPTools tabBarController];
            UIView *view = viewController.view;
            BOOL isFirst = [[XZCore sharedInstance] msgIsFirst];
            [weakSelf showMsg:dataList view:view isFirst:isFirst completion:^{
                [XZMainProjectBridge homeAlertManagerTaskDone];
            } ];
        } priority:1];
    }
}

- (void)showMsg:(NSArray *)dataList view:(UIView *)aview isFirst:(BOOL)isFirst completion:(void (^)(void))completionBlock{
    if (self.isLogout) {
        return;
    }
    [self closeMsg];
    _msgView = [[XZSmartMsgView alloc] init];
    _msgView.isfirst = isFirst;
    __weak typeof(self) weakSelf = self;
    _msgView.needDismissBlock = ^{
        [weakSelf showSpeechRobot];
        [weakSelf closeMsg];
        if (completionBlock) {
            completionBlock();
        }
    };
    _msgView.needSpeakBlock = ^(NSString *string) {
        [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
            [weakSelf robotSpeak:nil speakContent:string];
        } falseCompletion:^{
        }];
    };
    _msgView.needStopSpeakBlock = ^{
        [weakSelf stopSpeak];
    };
    [_msgView setupMsgArray:dataList];
    [_msgView showInView:aview];

    [self willShowMsgView];
}

- (void)closeMsg {
    if (self.viewController) {
        [self showSpeechRobot];
    }
    [_msgView dismiss];
    [self.msgView removeFromSuperview];
    self.msgView  = nil;
}

- (BOOL)canShowSmartMsg {
    if (!self.canShowMsgView) {
        return NO;
    }
    if (_msgView) {
        //已经显示了，就不再显示了，下一次在显示
        return NO;
    }
    UITabBarController *tabarcontroller = [SPTools tabBarController];
    if (tabarcontroller.presentedViewController) {
        return NO;
    }
    UINavigationController *nav = (UINavigationController *)tabarcontroller.selectedViewController;
    if (![nav isKindOfClass:[UINavigationController class]]) {
        // ipad  CMPSplitViewController
        return YES;
    }
    if (nav.viewControllers.count >1) {
        return NO;
    }
    UIViewController *vc1 = [nav.viewControllers firstObject];
    if (vc1.presentedViewController) {
        return NO;
    }
    return YES;
}


- (void)requestSmartMsg {
    self.viewController = nil;
    [self closeMsg];
    NSArray *array = [[[XZCore sharedInstance] msgSwitchInfo] msgTypeList];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messageTypeList", nil];
    [self requestSmartMsgWithParams:param showInfo:NO];
}

- (void)needSearchSmartMsg:(NSString *)date {
    XZMsgRemindRule *msgRemindRule = [[XZCore sharedInstance] msgRemindRule];
    if (!msgRemindRule) {
        //没有轮询规则，不查询 需要提示一下  todo
        [self robotSpeak:@"对不起，系统后台升级后才能支持该功能哦" speakContent:@"对不起，系统后台升级后才能支持该功能哦"];
        return;
    }
    NSMutableDictionary *searchParams = [NSMutableDictionary dictionary];
    [searchParams setObject:date forKey:@"startDate"];
    [searchParams setObject:date forKey:@"endDate"];
    NSArray *array = [[[XZCore sharedInstance] msgSwitchInfo] allMsgTypeList];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messageTypeList",searchParams,@"searchParams", nil];
    [self requestSmartMsgWithParams:param showInfo:YES];
}

- (void)requestSmartMsgWithParams:(NSDictionary *)param showInfo:(BOOL)showInfo{
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSmartMsgUrl];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:param success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *result = [response JSONValue];
        [weakSelf showMsg:result[@"data"] showInfo:showInfo];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        if (showInfo) {
            [weakSelf handleRequestError:error];
        }
    }];
}

- (void)robotSpeak:(NSString *)word speakContent:(NSString *)content {
    if (self.robotSpeakBlock) {
        self.robotSpeakBlock(word, content);
    }
}

- (void)stopSpeak {
    if (self.stopSpeakBlock) {
        self.stopSpeakBlock();
    }
}

- (void)showSpeechRobot {
    _msgView.hidden = YES;
    if (self.showSpeechRobotBlock) {
        self.showSpeechRobotBlock();
    }
}

- (void)handleBeforeRequest {
    if (self.handleBeforeRequestBlock) {
        self.handleBeforeRequestBlock();
    }
}

- (void)willShowMsgView {
    if (self.willShowMsgViewBlock) {
        self.willShowMsgViewBlock();
    }
}

- (void)enterSleep:(BOOL)sleep {
    if (self.enterSleepBlock) {
        self.enterSleepBlock(sleep);
    }
}

- (void)handleRequestError:(NSError *)error {
    if (self.handleErrorBlock) {
        self.handleErrorBlock(error);
    }
}

@end
