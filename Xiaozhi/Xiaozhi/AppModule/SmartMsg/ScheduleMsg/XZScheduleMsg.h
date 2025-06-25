//
//  XZScheduleMsg.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  工作安排消息

#import "XZBaseMsg.h"
#import "XZScheduleMsgItem.h"

@interface XZScheduleMsg : XZBaseMsg
@property(nonatomic, retain)NSArray<XZScheduleMsgItem *> *datalist;
@end
