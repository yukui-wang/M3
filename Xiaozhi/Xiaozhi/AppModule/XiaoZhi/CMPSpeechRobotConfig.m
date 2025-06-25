//
//  CMPSpeechRobotConfig.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/20.
//
//

#import "CMPSpeechRobotConfig.h"

#define kConfigKey_isOnoff     @"configKey_isOnoff"
#define kConfigKey_isOnShow    @"configKey_isOnShow"
#define kConfigKey_isAutoAwake @"configKey_isAutoAwake"
#define kConfigKey_startTime   @"configKey_startTime"
#define kConfigKey_endTime     @"configKey_endTime"

@implementation CMPSpeechRobotConfig

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.isOnOff forKey:kConfigKey_isOnoff];
    [aCoder encodeBool:self.isOnShow forKey:kConfigKey_isOnShow];
    [aCoder encodeBool:self.isAutoAwake forKey:kConfigKey_isAutoAwake];
    [aCoder encodeObject:self.startTime forKey:kConfigKey_startTime];
    [aCoder encodeObject:self.endTime forKey:kConfigKey_endTime];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.isOnOff = [aDecoder decodeBoolForKey:kConfigKey_isOnoff];
        self.isOnShow = [aDecoder decodeBoolForKey:kConfigKey_isOnShow];
        self.isAutoAwake = [aDecoder decodeBoolForKey:kConfigKey_isAutoAwake];
        self.startTime = [aDecoder decodeObjectForKey:kConfigKey_startTime];
        self.endTime = [aDecoder decodeObjectForKey:kConfigKey_endTime];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.isOnOff = YES;
        self.isOnShow = YES;
        self.isAutoAwake = YES;
        self.startTime = @"00:00";
        self.endTime = @"23:59";
    }
    return self;
}

@end
