//
//  XZScheduleMsg.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZScheduleMsg.h"

@implementation XZScheduleMsg

- (void)dealloc {
    SY_RELEASE_SAFELY(_datalist);
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        NSArray *dataList = msg[@"dataList"];
        NSMutableArray *result = [NSMutableArray array];
        for ( NSDictionary *dic in dataList) {
            XZScheduleMsgItem *item = [[XZScheduleMsgItem alloc] initWithMsg:dic];
            [result addObject:item];
            SY_RELEASE_SAFELY(item);
        }
        self.datalist = [NSArray arrayWithArray:result];
        if ([NSString isNull:self.title]) {
            self.title = @"工作安排";
        }
    }
    return self;
}

@end

