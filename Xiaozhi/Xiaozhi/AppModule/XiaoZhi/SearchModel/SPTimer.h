//
//  SPTimer.h
//  Project
//
//  Created by zeb on 2017/3/1.
//  Copyright © 2017年 zeb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTimerScheduleItem;
@interface SPTimer : NSObject

/**
 [SPTimerScheduleItem,SPTimerScheduleItem..]
 */
@property (nonatomic, strong, readonly) NSMutableArray *scheduleArray;
@property (nonatomic, assign) BOOL showOrNot;

+ (instancetype)sharedInstance;
- (void)refershTimer;
/**
 定时开启 如08：00-14：00 内做什么 否则  做什么

 @param schedule <#schedule description#>
 */
+ (void)addTimeSechedule:(SPTimerScheduleItem *)schedule;

+ (void)removeTimerSechedule:(SPTimerScheduleItem *)schedule;

+ (void)removeAllSechedule;
@end


/**
 定时类 几点到几点 干什么
 */
@interface SPTimerScheduleItem : NSObject

/**
 开始时间 08：00
 */
@property (nonatomic, copy) NSString *startTime;

/**
 开启动作
 */
@property (nonatomic, copy) void (^onAction)(void);

/**
 开启定时器
 */
@property (nonatomic, strong) NSTimer *onTimer;

/**
 结束时间 23：00
 */
@property (nonatomic, copy) NSString *endTime;

/**
 结束动作
 */
@property (nonatomic, copy) void (^offAction)(void);
/**
 结束定时器
 */
@property (nonatomic, strong) NSTimer *offTimer;

- (void)refershTimer;
- (void)clearTimer;
@end
