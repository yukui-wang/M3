//
//  CMPTimeCalEvent.h
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import <Foundation/Foundation.h>
/*
 title			String		标题（任务/公文的标题）
 beginDate		Long		开始时间(时间戳)
 endDate			Long		开始时间（时间戳。注：当type为公文或者协同时，这个字段表示截止日期）
 type			String		类型(模块:plan/task/meeting/event/collaboration/edoc)
 typeName		String		类型（模块:计划、任务、会议、日程事件、协同、公文）
 createUserId	String		发起人/创建人的Id
 createUserName	String		发起人/创建人的姓名
 id				Long		模块对应的Id
 */
@interface CMPTimeCalEvent : NSObject
@property(nonatomic, assign)long long     timeCalEventID;       //事件ID
@property(nonatomic, copy)NSString        *subject;             //标题
@property(nonatomic, copy)NSString        *beginDate;           //开始时间
@property(nonatomic, copy)NSString        *endDate;             //结束时间
@property(nonatomic, copy)NSString        *type;                //类型
@property(nonatomic, copy)NSString        *status;              //状态 用户区分。已完成是否已经置灰了
@property(nonatomic, assign)long long     alarmDate;            //提醒时间（获得提前多少时间提醒，以分钟为单位）
@property(nonatomic, assign)BOOL          hasAttachments;       //是否有附件
@property(nonatomic, assign)NSInteger     signifyType;          //重要紧急程度
@property(nonatomic, copy)NSString        *senderName;          //发起人姓名
@property(nonatomic, assign)BOOL          addedEvent;           //是否为新增

@end
