//
//  CMPScheduleManager.h
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import <Foundation/Foundation.h>

@interface CMPScheduleManager : NSObject

+ (CMPScheduleManager*)sharedManager;

- (void)forceSync; // 强制同步
- (void)startSync;
- (void)stopSync;

- (NSDictionary *)readConfig;
- (void)writeConfig:(NSDictionary *)config;

@end
