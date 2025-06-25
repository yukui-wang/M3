//
//  XZGuidePageItem.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePageItem.h"
#import "SPTools.h"

@implementation XZGuidePageItem

- (id)initWithDic:(NSDictionary *)result {
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        self.title = [SPTools stringValue:result forKey:@"title"];
        self.subTitle = [SPTools stringValue:result forKey:@"subTitle"];
        self.themeIcon = [SPTools stringValue:result forKey:@"themeIcon"];
        NSArray *subheads = [SPTools arrayValue:result forKey:@"subheads"];
        for (NSDictionary *dic in subheads) {
            XZGuidePageSubItem *item = [[XZGuidePageSubItem alloc] initWithDic:dic];
            [array addObject:item];
        }
        self.subheads = array;
    }
    return self;
}

@end
