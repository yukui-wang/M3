//
//  XZLeaveErrorModel.h
//  M3
//
//  Created by wujiansheng on 2018/1/9.
//

#import "XZCellModel.h"

@interface XZLeaveErrorModel : XZCellModel
//请假错误信息相关
@property (nonatomic, copy) NSString *templateId;
@property (nonatomic, copy) NSString *formData;
@property (nonatomic, copy) NSString *sendOnload;
//cell相关
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
@property (nonatomic, copy) NSString *contentInfo;
@property(nonatomic, assign)BOOL canOperate;//能否显示 发送 取消 修改
@property(nonatomic, assign)BOOL showClickTitle;//能否显示 发送 取消 修改
@property (nonatomic, copy) void (^showLeaveBlock)(XZLeaveErrorModel *model);
@property (nonatomic, copy) void (^cancelBlock)(XZLeaveErrorModel *model);

- (void)showLeave;
- (void)cancel;
@end
