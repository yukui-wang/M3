//
//  CMPScheduleEventRcord.h
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import <Foundation/Foundation.h>
@class CMPTimeCalEvent;

@interface CMPScheduleEventRcord : NSObject
@property(nonatomic, copy)NSString       *scheduleLocalID;//本地日程id
@property(nonatomic, copy)NSString       *serverIdentifier;//服务器id
@property(nonatomic, copy)NSString       *userID;//用户id
@property(nonatomic, copy)NSString       *syncDate;//同步时间

@property(nonatomic, copy)NSString        *timeCalEventID; //日程/会议/任务/协同/公文 的ID
@property(nonatomic, copy)NSString        *subject;//标题
@property(nonatomic, copy)NSString        *beginDate;//开始日期
@property(nonatomic, copy)NSString        *endDate;//结束日期
@property(nonatomic, copy)NSString        *type;//类型 doc/collaboration 日程/会议/任务/计划/协同/公文
@property(nonatomic, copy)NSString        *status;// 是否已完成
@property(nonatomic, copy)NSString        *account;//协同、会议发起人 公文：发起单位或者来文单位
@property(nonatomic, copy)NSString        *alarmDate;//提醒时间（获得提前多少时间提醒，以分钟为单位）
@property(nonatomic, copy)NSString        *address;//地点（会议）
@property(nonatomic, copy)NSString        *hasRemindFlag;//是否有提醒时间 "yes" or "no"
@property(nonatomic, assign)NSInteger     repeatType;//重复类型
@property(nonatomic, copy)NSString        *addedEvent;//是否是新增的事件，是，新增/否，修改"yes" or "no"
@property(nonatomic, copy)NSString    *extend1;
@property(nonatomic, copy)NSString    *extend2;
@property(nonatomic, copy)NSString    *extend3;
@property(nonatomic, copy)NSString    *extend4;
@property(nonatomic, copy)NSString    *extend5;
@property(nonatomic, copy)NSString    *extend6;
@property(nonatomic, copy)NSString    *extend7;
@property(nonatomic, copy)NSString    *extend8;
@property(nonatomic, copy)NSString    *extend9;
@property(nonatomic, copy)NSString    *extend10;
- (id)initWithMTimeCalEvent:(CMPTimeCalEvent *)mTimeCalEvent;

@end
