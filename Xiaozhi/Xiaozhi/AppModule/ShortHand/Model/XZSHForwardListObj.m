//
//  XZSHForwardListObj.m
//  M3
//
//  Created by wujiansheng on 2019/1/11.
//

#import "XZSHForwardListObj.h"
#import "SPTools.h"

@implementation XZSHForwardListObj

- (void)dealloc {
    self.cellName = nil;
    self.cellId = nil;
    self.title = nil;
    self.appId = nil;
    self.gotoUrl = nil;
    self.gotoParams = nil;

    [super dealloc];
}

- (id)initWithDic:(NSDictionary *)dic  {
    if (self = [super init]) {
        self.title = [SPTools stringValue:dic forKey:@"title"];
        self.appId = [SPTools stringValue:dic forKey:@"appId"];
        self.gotoUrl = [SPTools stringValue:dic forKey:@"gotoUrl"];
        self.gotoParams = [SPTools dicValue:dic forKey:@"gotoParams"];

    }
    return self;
}

+ (NSArray *)objsFormDic:(NSArray *)dataArray appID:(NSString *)appId {
    NSString *className = nil;
    if ([appId isEqualToString:@"1"]) {
        className = @"XZSHForwardCollObj";
    }
    else if ([appId isEqualToString:@"30"]){
        className = @"XZSHForwardTaskObj";
    }
    else if ([appId isEqualToString:@"6"]){
        className = @"XZSHForwardMeetingObj";
    }
    else if ([appId isEqualToString:@"11"]){
        className = @"XZSHForwardCalObj";
    }
    else {
        return [NSArray array];
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in dataArray) {
        XZSHForwardListObj *obj = [[[NSClassFromString(className) alloc] initWithDic:item] autorelease];
        [array addObject:obj];
    }
    return array;
}

@end

#pragma mark 转发协同对象
@implementation XZSHForwardCollObj

- (void)dealloc {
    self.memberId = nil;
    self.memberName = nil;
    self.replyDisplay = nil;
    self.startDate = nil;
    [super dealloc];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.cellName = @"XZSHForwardCollCell";
        self.cellId = @"XZSHForwardCollCellId";

        self.memberId = [SPTools stringValue:dic forKey:@"memberId"];
        self.memberName = [SPTools stringValue:dic forKey:@"memberName"];
        self.replyDisplay = [SPTools stringValue:dic forKey:@"replyDisplay"];
        self.startDate = [SPTools stringValue:dic forKey:@"startDate"];
    }
    return self;
}

@end

#pragma mark 转发任务对象
@implementation XZSHForwardTaskObj

- (void)dealloc {
    [super dealloc];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.cellName = @"XZSHForwardTaskCell";
        self.cellId = @"XZSHForwardTaskCellId";
    }
    return self;
}

@end

#pragma mark 转发会议对象
@implementation XZSHForwardMeetingObj

- (void)dealloc {
    [super dealloc];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.cellName = @"XZSHForwardMeetingCell";
        self.cellId = @"XZSHForwardMeetingCellId";
    }
    return self;
}

@end

#pragma mark 转发日程对象
@implementation XZSHForwardCalObj

- (void)dealloc {
    [super dealloc];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.cellName = @"XZSHForwardCalCell";
        self.cellId = @"XZSHForwardCalCellId";
    }
    return self;
}

@end
