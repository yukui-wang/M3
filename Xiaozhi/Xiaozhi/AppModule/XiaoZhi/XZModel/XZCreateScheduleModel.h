//
//  XZCreateScheduleModel.h
//  M3
//
//  Created by wujiansheng on 2018/8/8.
//

#import "XZCreateModel.h"

@interface XZCreateScheduleModel : XZCreateModel
@property(nonatomic, copy)NSString *beginDate;//时间戳 ms
@property(nonatomic, copy)NSString *endDate;//时间戳 ms
@property(nonatomic, copy)NSString *shareType;//1.私人事件4.公开给他人
@property(nonatomic, copy)NSString *from;//此处写死是robot,代表来自小致

- (id)initWithUnitResult:(NSDictionary *)dic;
@end
