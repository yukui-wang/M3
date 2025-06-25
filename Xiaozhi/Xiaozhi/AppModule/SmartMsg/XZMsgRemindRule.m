//
//  XZMsgRemindRule.m
//  M3
//
//  Created by wujiansheng on 2018/9/25.
//

#import "XZMsgRemindRule.h"

@implementation XZMsgRemindRule

+ (XZMsgRemindRule *)remindRuleWithDic:(NSDictionary *)dic {
    XZMsgRemindRule *rule = [[XZMsgRemindRule alloc] init];
    rule.remindStep = [dic[@"remindStep"] integerValue]/1000;
    rule.startTime = dic[@"serviceStartTime"];
    rule.endTime = dic[@"serviceEndTime"];
    return rule;
}
@end
