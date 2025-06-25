//
//  XZOptionMemberModel.h
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZCellModel.h"
#import "XZTextInfoModel.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import "XZOptionMemberParam.h"
@interface XZOptionMemberModel : XZCellModel {
    BOOL _isNewCell;
}

//重名人员信息相关
@property (nonatomic, retain)XZOptionMemberParam *param;

//cell相关
@property (nonatomic, assign) ChatCellType chatCellType;
@property (nonatomic, assign) CGFloat lableWidth;
@property (nonatomic, assign) CGFloat lableHeight;
@property (nonatomic, retain) NSArray *showInfoList;
@property (nonatomic, retain) XZTextInfoModel *textInfo;
@property(nonatomic, assign)BOOL canOperate;//能否显示 发送 取消 修改
//选中人员确认事件
@property (nonatomic, copy) void (^didChoosedMembersBlock)(NSArray *members, BOOL showName);
//点击更多打开h5选人界面
@property (nonatomic, copy) void (^showMoreBlock)(NSArray *selectedMembers ,BOOL isMultipleSelection);

@property (nonatomic, copy) void (^clickTextBlock)(NSString *text);
@property (nonatomic, copy) void (^clickOKButtonBlock)(void);

@end
