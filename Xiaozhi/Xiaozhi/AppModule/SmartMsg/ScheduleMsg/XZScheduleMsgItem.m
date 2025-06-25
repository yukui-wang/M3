//
//  XZScheduleMsgItem.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#define kMsgDataType_calendar @"calendar"
#define kMsgDataType_taskManage @"taskManage"
#define kMsgDataType_meeting @"meeting"

#import "XZScheduleMsgItem.h"
#import "XZCalendarMsgData.h"
#import "XZTaskMsgData.h"
#import "XZMeetingMsgData.h"

@implementation XZScheduleMsgItem
- (void)dealloc {
    SY_RELEASE_SAFELY(_type);
    SY_RELEASE_SAFELY(_items);
    SY_RELEASE_SAFELY(_showInfo);
    SY_RELEASE_SAFELY(_color);
    [super dealloc];
}

- (NSString *)stringValue:(NSString *)vaule {
    if ([vaule isKindOfClass:[NSString class]]) {
        return vaule;
    }
    return @"";
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super init]) {
        self.type = [self stringValue:msg[@"type"]];
        NSArray *items = msg[@"items"];
        if (![items isKindOfClass:[NSArray class]]) {
            items = [NSArray array];
        }
        NSMutableArray *result = [NSMutableArray array];
        if ([self.type isEqualToString:kMsgDataType_calendar]) {
            self.showInfo = @"日程";// [NSString stringWithFormat:@"%ld个日程",items.count];
            self.color = UIColorFromRGB(0x0192F7);
        }
        else if ([self.type isEqualToString:kMsgDataType_taskManage]) {
            self.showInfo = @"任务";//[NSString stringWithFormat:@"%ld个任务",items.count];
            self.color = UIColorFromRGB(0xFFC851);
        }
        else if ([self.type isEqualToString:kMsgDataType_meeting]) {
            self.showInfo = @"会议";// [NSString stringWithFormat:@"%ld个会议",items.count];
            self.color = UIColorFromRGB(0xFF4659);
        }
        for ( NSDictionary *dic in items) {
            if ([self.type isEqualToString:kMsgDataType_calendar]) {
                XZCalendarMsgData *item = [[XZCalendarMsgData alloc] initWithMsg:dic];
                [result addObject:item];
                SY_RELEASE_SAFELY(item);
            }
            else if ([self.type isEqualToString:kMsgDataType_taskManage]) {
                XZTaskMsgData *item = [[XZTaskMsgData alloc] initWithMsg:dic];
                [result addObject:item];
                SY_RELEASE_SAFELY(item);
            }
            else if ([self.type isEqualToString:kMsgDataType_meeting]) {
                XZMeetingMsgData *item = [[XZMeetingMsgData alloc] initWithMsg:dic];
                [result addObject:item];
                SY_RELEASE_SAFELY(item);
            }
        }
        self.items = [NSArray arrayWithArray:result];
    }
    return self;
}
@end
