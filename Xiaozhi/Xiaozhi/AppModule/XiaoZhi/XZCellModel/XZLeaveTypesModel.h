//
//  XZLeaveTypesModel.h
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZCellModel.h"

@interface XZLeaveTypesModel : XZCellModel
@property(nonatomic, retain)NSArray *leaveTypes;
@property(nonatomic, retain)NSArray *showItems;//contain:title、frame
@property(nonatomic, copy)NSString *selectType;//contain:title、frame

@property(nonatomic, assign)BOOL canOperate;//能否选择请假类型
@property (nonatomic, copy) void (^clickTypeBlock)(NSString *leaveType);

@end
