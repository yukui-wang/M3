//
//  XZGuidePageSubItem.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePageSubItem.h"
#import "SPTools.h"

@implementation XZGuidePageSubItem

- (id)initWithDic:(NSDictionary *)result {
    if (self = [super init]) {
        self.title = [SPTools stringValue:result forKey:@"title"];
        self.words = [SPTools arrayValue:result forKey:@"words"];
    }
    return self;
}

@end
