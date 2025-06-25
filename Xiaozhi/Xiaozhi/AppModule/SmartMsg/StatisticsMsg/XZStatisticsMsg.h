//
//  XZStatisticsMsg.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  统计消息 工作统计

#import "XZBaseMsg.h"

@interface XZStatisticsMsg : XZBaseMsg
@property(nonatomic, retain)NSDictionary *gotoParams;
@property(nonatomic, copy)NSString *sendNum;//发协同数
@property(nonatomic, copy)NSString *handNum;//处理协同数
@property(nonatomic, copy)NSString *shareNum;//知识贡献数
@property(nonatomic, copy)NSString *avgHandleTime;//处理时效
@property(nonatomic, copy)NSString *processRank;//单位排名

@end
