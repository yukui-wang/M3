//
//  XZBaseMsg.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#define kXZBaseMsgType_arrange @"arrange"//工作安排
#define kXZBaseMsgType_culture @"culture"//文化信息
#define kXZBaseMsgType_statistics @"statistics" //统计数据
#define kXZBaseMsgType_chart @"chart"//业务数据 图表

#import <Foundation/Foundation.h>
#import "SPTools.h"
#import <CMPLib/CMPConstant.h>

@interface XZBaseMsg : NSObject
@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *subTitle;
@property(nonatomic, copy)NSString *createDate;
@property(nonatomic, copy)NSString *remarks;
- (id)initWithMsg:(NSDictionary *)msg;
+ (NSArray *)msgArrayWithDataList:(NSArray *)dataList;
@end
