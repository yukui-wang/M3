//
//  XZBaseMsg.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//


#import "XZBaseMsg.h"
#import "XZScheduleMsg.h"
#import "XZBusinessMsg.h"
#import "XZStatisticsMsg.h"
#import "XZCultureMsg.h"

@implementation XZBaseMsg

- (void)dealloc {
    SY_RELEASE_SAFELY(_type);
    SY_RELEASE_SAFELY(_title);
    SY_RELEASE_SAFELY(_subTitle);
    SY_RELEASE_SAFELY(_createDate);
    SY_RELEASE_SAFELY(_remarks);

    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super init]) {
        self.type = [SPTools stringValue:msg forKey:@"type"];
        self.title = [SPTools stringValue:msg forKey:@"title"];
        self.subTitle = [SPTools stringValue:msg forKey:@"subTitle"];
        self.createDate = [SPTools stringValue:msg forKey:@"createDate"];
        self.remarks = [SPTools stringValue:msg forKey:@"remarks"];
    }
    return self;
}

+ (NSArray *)msgArrayWithDataList:(NSArray *)dataList {
    NSMutableArray *array = [NSMutableArray array];
    if (!dataList || dataList.count == 0) {
        return array;
    }
    for (NSInteger i = 0 ; i<dataList.count; i++) {
        NSDictionary *msgDic = dataList[i];
        NSString *type = msgDic[@"type"];
        if ([type isEqualToString:kXZBaseMsgType_arrange]) {
            XZScheduleMsg *msg = [[XZScheduleMsg alloc] initWithMsg:msgDic];
            [array addObject:msg];
            SY_RELEASE_SAFELY(msg);
        }
        else if ([type isEqualToString:kXZBaseMsgType_culture]) {
            XZCultureMsg *msg = [[XZCultureMsg alloc] initWithMsg:msgDic];
            [array addObject:msg];
            SY_RELEASE_SAFELY(msg);
        }
        else if ([type isEqualToString:kXZBaseMsgType_statistics]) {
            XZStatisticsMsg *msg = [[XZStatisticsMsg alloc] initWithMsg:msgDic];
            [array addObject:msg];
            SY_RELEASE_SAFELY(msg);
        }
        else if ([type isEqualToString:kXZBaseMsgType_chart]) {
            XZBusinessMsg *msg = [[XZBusinessMsg alloc] initWithMsg:msgDic];
            [array addObject:msg];
            SY_RELEASE_SAFELY(msg);
        }
    }
    return array;
}

@end
