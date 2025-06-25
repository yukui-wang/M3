//
//  XZMsgSwitchInfo.h
//  M3
//
//  Created by wujiansheng on 2018/9/25.
//

#import <CMPLib/CMPObject.h>

@interface XZMsgSwitchInfo : CMPObject
@property(nonatomic,assign)BOOL mainSwitch;//总开关
@property(nonatomic,assign)BOOL cultureSwitch;//文化信息开关
@property(nonatomic,assign)BOOL statisticsSwitch;//统计数据开关
@property(nonatomic,assign)BOOL arrangeSwitch;//工作安排开关
@property(nonatomic,assign)BOOL chartSwitch; //报表开关
- (NSArray *)msgTypeList;
- (NSArray *)allMsgTypeList;
@end
