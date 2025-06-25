//
//  XZCalendarMsgData.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZCalendarMsgData.h"

@implementation XZCalendarMsgData
- (void)dealloc {
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.ideltifier = @"XZCalendarMsgData";
        self.cellClass = @"XZCalendarMsgDataCell";
    }
    return self;
}

@end
