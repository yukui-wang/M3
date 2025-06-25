//
//  XZShortHandObj.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandObj.h"
#import "SPTools.h"
@implementation XZShortHandObj

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.shId = [SPTools longLongValue:dic forKey:@"id"];
        self.title = [SPTools stringValue:dic forKey:@"title"];
        self.content = [SPTools stringValue:dic forKey:@"content"];
        long long createDate = [SPTools longLongValue:dic forKey:@"createDate"];
        if (createDate == 0 ) {
            self.createDate = [SPTools stringValue:dic forKey:@"createDate"];
        }
        else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:createDate/1000];
            NSDateFormatter *formt = [[[NSDateFormatter alloc] init] autorelease];
            [formt setDateFormat:@"yyyy-MM-dd HH:mm"];
            self.createDate = [formt stringFromDate:date];
        }
        self.forwardApps = [SPTools arrayValue:dic forKey:@"forwardApps"];
    }
    return self;
}

@end
