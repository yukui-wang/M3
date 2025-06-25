//
//  XZMsgSwitchInfo.m
//  M3
//
//  Created by wujiansheng on 2018/9/25.
//

#import "XZMsgSwitchInfo.h"
#import "XZBaseMsg.h"
#define kInfoKey_mainSwitch @"infoKey_mainSwitch"
#define kInfoKey_cultureSwitch @"infoKey_cultureSwitch"
#define kInfoKey_statisticsSwitch @"infoKey_statisticsSwitch"
#define kInfoKey_arrangeSwitch @"infoKey_arrangeSwitch"
#define kInfoKey_chartSwitch @"infoKey_chartSwitch"


@implementation XZMsgSwitchInfo

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.mainSwitch forKey:kInfoKey_mainSwitch];
    [aCoder encodeBool:self.cultureSwitch forKey:kInfoKey_cultureSwitch];
    [aCoder encodeBool:self.statisticsSwitch forKey:kInfoKey_statisticsSwitch];
    [aCoder encodeBool:self.arrangeSwitch forKey:kInfoKey_arrangeSwitch];
    [aCoder encodeBool:self.chartSwitch forKey:kInfoKey_chartSwitch];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mainSwitch = [aDecoder decodeBoolForKey:kInfoKey_mainSwitch];
        self.cultureSwitch = [aDecoder decodeBoolForKey:kInfoKey_cultureSwitch];
        self.statisticsSwitch = [aDecoder decodeBoolForKey:kInfoKey_statisticsSwitch];
        self.arrangeSwitch = [aDecoder decodeBoolForKey:kInfoKey_arrangeSwitch];
        self.chartSwitch = [aDecoder decodeBoolForKey:kInfoKey_chartSwitch];
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        self.mainSwitch = YES;
        self.cultureSwitch = YES;
        self.statisticsSwitch = YES;
        self.arrangeSwitch = YES;
        self.chartSwitch = YES;
    }
    return self;
}

- (NSArray *)msgTypeList {
    NSMutableArray *array = [NSMutableArray array];
    if (self.arrangeSwitch) {
        [array addObject:kXZBaseMsgType_arrange];
    }
    if (self.cultureSwitch) {
        [array addObject:kXZBaseMsgType_culture];
    }
    if (self.statisticsSwitch) {
        [array addObject:kXZBaseMsgType_statistics];
    }
    if (self.chartSwitch) {
        [array addObject:kXZBaseMsgType_chart];
    }
    return array;
}
- (NSArray *)allMsgTypeList {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:kXZBaseMsgType_arrange];
    [array addObject:kXZBaseMsgType_culture];
    [array addObject:kXZBaseMsgType_statistics];
    [array addObject:kXZBaseMsgType_chart];
    return array;
}
@end
