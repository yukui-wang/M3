//
//  XZScheduleModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/6.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZScheduleModel.h"

@implementation XZScheduleModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZScheduleCell";
        self.ideltifier = @"XZScheduleModel";
        self.modelId = [NSString uuid];
    }
    return self;
}
- (CGFloat)cellHeight {
    return self.viewHeight+20;
}
@end
