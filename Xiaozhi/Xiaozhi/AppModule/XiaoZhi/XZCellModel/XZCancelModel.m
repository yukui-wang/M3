//
//  XZCancelModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCancelModel.h"
#import "XZCancelCard.h"

@implementation XZCancelModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZCancelCell";
        self.ideltifier = @"XZCancelModel";
        self.modelId = [NSString uuid];
    }
    return self;
}

- (CGFloat)cellHeight{
    return [XZCancelCard viewHeight]+20;
}

@end
