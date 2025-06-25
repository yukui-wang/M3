//
//  RCReeditMessageManager.m
//  RongIMKit
//
//  Created by 孙浩 on 2019/12/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCReeditMessageManager.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"

NSString *const RCKitNeedUpdateRecallStatusNotification = @"RCKitNeedUpdateRecallStatusNotification";

@interface RCReeditMessageManager ()

@property (nonatomic, strong) RCTSMutableDictionary *reeditMessageDurationDict;
@property (nonatomic, strong) NSTimer *reeditTimer;

@end

@implementation RCReeditMessageManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static RCReeditMessageManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[RCReeditMessageManager alloc] init];
        manager.reeditMessageDurationDict = [[RCTSMutableDictionary alloc] init];
    });
    return manager;
}

- (void)addReeditDuration:(long long)duration messageId:(long)messageId {
    NSString *messageIdString = [NSString stringWithFormat:@"%@", @(messageId)];
    [self.reeditMessageDurationDict setObject:@(duration) forKey:messageIdString];
    dispatch_main_async_safe(^{
        if (!self.reeditTimer) {
            self.reeditTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(timerAction)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    });
}

- (void)timerAction {
    if (self.reeditMessageDurationDict.allKeys.count == 0) {
        [self invalidateTimer];
        return;
    }
    for (NSString *key in self.reeditMessageDurationDict.allKeys) {
        long long duration = [self.reeditMessageDurationDict[key] longLongValue];
        if (duration >= [RCIM sharedRCIM].reeditDuration * 1000) {
            [self removeReeditDuration:key];
        } else {
            duration += 1000;
            [self.reeditMessageDurationDict setObject:@(duration) forKey:key];
        }
    }
}

- (void)removeReeditDuration:(NSString *)key {
    [self.reeditMessageDurationDict removeObjectForKey:key];
    NSInteger messageId = [key integerValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:RCKitNeedUpdateRecallStatusNotification
                                                        object:@{
                                                            @"messageId" : @(messageId)
                                                        }];
}

- (void)resetAndInvalidateTimer {
    [self.reeditMessageDurationDict removeAllObjects];
    [self invalidateTimer];
}

- (void)invalidateTimer {
    dispatch_main_async_safe(^{
        if (self.reeditTimer) {
            if (self.reeditTimer.valid) {
                [self.reeditTimer invalidate];
            }
            self.reeditTimer = nil;
        }
    });
}
@end
