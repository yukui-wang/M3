
//
//  SPTimer.m
//  Project
//
//  Created by zeb on 2017/3/1.
//  Copyright © 2017年 zeb. All rights reserved.
//

#import "SPTimer.h"
@interface SPTimer () {
    BOOL _showOrNot;
}
@property (nonatomic, strong, readwrite) NSMutableArray *scheduleArray;
@end

@implementation SPTimer

+ (instancetype)sharedInstance {
    static SPTimer *sptimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sptimer = [[SPTimer alloc] init];
    });
    return sptimer;
}

- (instancetype)init {
    if (self = [super init]) {
        _scheduleArray = [[NSMutableArray alloc] init];
        /*SNotification g干掉，在xzmiancontroller 统一处理*/
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refershTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
        _showOrNot = YES;
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(toggleShowRobotAssistiveTouchOnPageSwitch:)
//                                                     name:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch
//                                                   object:nil];
    }
    return self;
}

- (void)refershTimer {
    if (_showOrNot) {
        [_scheduleArray enumerateObjectsUsingBlock:^(SPTimerScheduleItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj refershTimer];
        }];
    };
}
//- (void)toggleShowRobotAssistiveTouchOnPageSwitch:(NSNotification *)notification {
//    _showOrNot = [notification.object boolValue];
//}
+ (void)addTimeSechedule:(SPTimerScheduleItem *)schedule {
    [schedule refershTimer];
    [[SPTimer sharedInstance].scheduleArray addObject:schedule];
}

+ (void)removeTimerSechedule:(SPTimerScheduleItem *)schedule {
    [schedule clearTimer];
    if ([[SPTimer sharedInstance].scheduleArray containsObject:schedule]) {
        [[SPTimer sharedInstance].scheduleArray removeObject:schedule];
    }
}

+ (void)removeAllSechedule {
    [[SPTimer sharedInstance].scheduleArray enumerateObjectsUsingBlock:^(SPTimerScheduleItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj clearTimer];
        [[SPTimer sharedInstance].scheduleArray removeObject:obj];
    }];
}

@end


@implementation SPTimerScheduleItem
/*
- (void)refershTimer {
    [self clearTimer];
    //现在时间
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";

    NSTimeInterval startInterval = [[formatter dateFromString:[formatter stringFromDate:currentDate]] timeIntervalSinceDate:[formatter dateFromString:_startTime]];
    NSTimeInterval endInterval = [[formatter dateFromString:[formatter stringFromDate:currentDate]] timeIntervalSinceDate:[formatter dateFromString:_endTime]];
    NSTimeInterval end_startInterval = [[formatter dateFromString:_endTime] timeIntervalSinceDate:[formatter dateFromString:_startTime]];
    
    NSTimeInterval second = [[[currentDate description] substringWithRange:NSMakeRange(17, 2)] intValue];
    //已经开始
    //判断 末尾0代表开始时间小于结束时间 1代表开始时间大于结束时间
    BOOL centerRange0 = end_startInterval > 0 && startInterval >=0 && endInterval < 0;
    BOOL centerRange1 = end_startInterval < 0 && startInterval && (startInterval >= 0 || endInterval < 0);
    BOOL centerRange = centerRange0 || centerRange1;
    
    if (centerRange && _onAction) {
        _onAction();
    } else if (!centerRange && _offAction) {
        _offAction();
    }
    
    
    if (startInterval >= 0) {
        startInterval = 24*3600 - startInterval;
    }
    startInterval = fabs(startInterval);
    startInterval -= second;
    if (startInterval > 0) {
        _onTimer = [NSTimer scheduledTimerWithTimeInterval:startInterval target:self selector:@selector(onTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_onTimer forMode:NSRunLoopCommonModes];
    }
    
    if (endInterval >= 0) {
        endInterval = 24*3600 - endInterval;
    }
    endInterval = fabs(endInterval);
    endInterval -= second;
    if (endInterval > 0) {
        _offTimer = [NSTimer scheduledTimerWithTimeInterval:endInterval target:self selector:@selector(offTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_offTimer forMode:NSRunLoopCommonModes];
    }
}
*/
- (NSInteger)timeIntervalForTime:(NSString *)time {
    NSArray *array = [time componentsSeparatedByString:@":"];
    NSInteger interval = 0;
    if (array.count > 0) {
        NSInteger h = [array[0] integerValue];
        NSInteger m = 0;
        if (array.count >1) {
            m = [array[1] integerValue];
        }
        NSInteger s = 0;
        if (array.count >2) {
            s = [array[2] integerValue];
        }
        interval = h*60*60+m*60+s;
    }
    return interval;
}

- (void)refershTimer {
    [self clearTimer];
    //现在时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *currentStr = [formatter stringFromDate:[NSDate date]];
    
    NSInteger startTemp = [self timeIntervalForTime:self.startTime];
    NSInteger endTemp = [self timeIntervalForTime:self.endTime];
    NSInteger currentInterval = [self timeIntervalForTime:currentStr];
    NSInteger startInterval = MIN(startTemp, endTemp);
    NSInteger endInterval = MAX(startTemp, endTemp);
    
    if (endInterval <= currentInterval) {
        //结束时间小于当前时间
        if (self.offAction) {
            self.offAction();
        }
    }
    else if (currentInterval >= startInterval && currentInterval < endInterval) {
        //当前时间在开始、结束之间
        if (self.onAction) {
            self.onAction();
        }
        NSInteger timeInterval = endInterval-currentInterval;
        self.offTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(offTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.offTimer forMode:NSRunLoopCommonModes];
    }
    else {
        //当前时间在开始之前
        if (self.offAction) {
            self.offAction();
        }
        NSInteger onInterval = startInterval-currentInterval;
        self.onTimer = [NSTimer scheduledTimerWithTimeInterval:onInterval target:self selector:@selector(onTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.onTimer forMode:NSRunLoopCommonModes];
        
        NSInteger offInterval = endInterval-currentInterval;
        self.offTimer = [NSTimer scheduledTimerWithTimeInterval:offInterval target:self selector:@selector(offTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.offTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)onTimerAction:(NSTimer*)timer {
    [self.onTimer invalidate];
    self.onTimer = nil;
    if (self.onAction) {
        self.onAction();
    }
}

- (void)offTimerAction:(NSTimer*)timer {
    [self.offTimer invalidate];
    self.offTimer = nil;
    if (self.offAction) {
        self.offAction();
    }
}

- (void)clearTimer {
    [self.onTimer invalidate];
    self.onTimer = nil;
    [self.offTimer invalidate];
    self.offTimer = nil;
}
@end
