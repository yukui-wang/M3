//
//  XZMsgRemindRule.h
//  M3
//
//  Created by wujiansheng on 2018/9/25.
//

#import <CMPLib/CMPObject.h>

@interface XZMsgRemindRule : CMPObject

@property(nonatomic,assign)NSInteger remindStep;//单位已转换成秒
@property(nonatomic,copy)NSString *startTime;
@property(nonatomic,copy)NSString *endTime;
+ (XZMsgRemindRule *)remindRuleWithDic:(NSDictionary *)dic;
@end
