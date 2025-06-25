//
//  XZSHForwardListObj.h
//  M3
//
//  Created by wujiansheng on 2019/1/11.
//

#import <CMPLib/CMPObject.h>

@interface XZSHForwardListObj : CMPObject

@property(nonatomic, copy)NSString *cellName;
@property(nonatomic, copy)NSString *cellId;

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *appId;
@property(nonatomic, copy)NSString *gotoUrl;
@property(nonatomic, retain)NSDictionary *gotoParams;


- (id)initWithDic:(NSDictionary *)dic;

+ (NSArray *)objsFormDic:(NSArray *)dataArray appID:(NSString *)appId;

@end

#pragma mark 转发协同对象
@interface XZSHForwardCollObj : XZSHForwardListObj

@property(nonatomic, copy)NSString *memberId;
@property(nonatomic, copy)NSString *memberName;
@property(nonatomic, copy)NSString *replyDisplay;
@property(nonatomic, copy)NSString *startDate;

@end
#pragma mark 转发任务对象
@interface XZSHForwardTaskObj : XZSHForwardListObj

@end

#pragma mark 转发会议对象
@interface XZSHForwardMeetingObj : XZSHForwardListObj

@end

#pragma mark 转发日程对象
@interface XZSHForwardCalObj : XZSHForwardListObj

@end


