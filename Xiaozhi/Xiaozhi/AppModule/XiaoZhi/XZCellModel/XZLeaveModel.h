//
//  XZLeaveModel.h
//  M3
//
//  Created by wujiansheng on 2017/12/29.
//

#import "XZCellModel.h"
@interface XZLeaveModel : XZCellModel
@property(nonatomic,copy)NSString *userName;//姓名
@property(nonatomic,copy)NSString *department;//部门
@property(nonatomic,copy)NSString *post;//岗位
@property(nonatomic,copy)NSString *startTime;//起始日期
@property(nonatomic,copy)NSString *endTime;//截止日期
@property(nonatomic,copy)NSString *timeNumber;//统计时间
@property(nonatomic,copy)NSString *leaveType;//请假类别
@property(nonatomic,copy)NSString *leaveReason;//请假事由
@property(nonatomic,copy)NSString *handleType;//请假事由

//cell相关
@property(nonatomic, assign)CGFloat reasonHeight;
@property(nonatomic, assign)CGFloat defaultHeight;
@property(nonatomic, assign)CGFloat spacing;
@property(nonatomic, retain)NSMutableAttributedString *timeAttStr;//请假事由
@property(nonatomic, assign)BOOL canOperate;//能否显示 发送 取消 修改
@property(nonatomic, copy) void (^sendLeaveBlock)(XZLeaveModel *model);
@property(nonatomic, copy) void (^modifyLeaveBlock)(XZLeaveModel *model);
@property(nonatomic, copy) void (^cancelLeaveBlock)(XZLeaveModel *model);
@property(nonatomic, copy)NSString *clickTitle;//点击title


@property(nonatomic,assign)BOOL isNewInterface;

- (void)handleUintResult:(NSDictionary *)dic;
- (NSString *)translationArebicStr:(NSString *)chineseStr;
- (NSDictionary *)paramsDic;

- (void)sendLeave;
- (void)cancelLeave;
- (void)modifyLeave;

@end
