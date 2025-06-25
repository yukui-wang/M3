//
//  XZTaskMsgData.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZTaskMsgData.h"

@implementation XZTaskMsgData
- (void)dealloc {
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.ideltifier = @"XZTaskMsgData";
        self.cellClass = @"XZTaskMsgDataCell";
        
    }
    return self;
}

@end
