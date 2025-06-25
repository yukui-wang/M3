//
//  XZStatisticsMsg.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZStatisticsMsg.h"

@implementation XZStatisticsMsg
- (void)dealloc {
    self.gotoParams = nil;
    self.sendNum = nil;
    self.handNum = nil;
    self.shareNum = nil;
    self.avgHandleTime = nil;
    self.processRank = nil;
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.gotoParams = msg[@"gotoParams"];
        self.sendNum = [SPTools stringValue:msg forKey:@"sendNum"];
        self.handNum = [SPTools stringValue:msg forKey:@"handNum"];
        self.shareNum = [SPTools stringValue:msg forKey:@"shareNum"];
        self.avgHandleTime = [SPTools stringValue:msg forKey:@"avgHandleTime"];
        self.processRank = [SPTools stringValue:msg forKey:@"processRank"];
        if ([NSString isNull:self.title]) {
            self.title = @"工作统计";
        }
    }
    return self;
}

@end
