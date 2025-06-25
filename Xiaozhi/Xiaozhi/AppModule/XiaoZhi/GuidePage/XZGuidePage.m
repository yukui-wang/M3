//
//  XZGuidePage.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePage.h"

@implementation XZGuidePage

- (id)initWithArray:(NSArray *)result {
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dic in result) {
            XZGuidePageItem *item = [[XZGuidePageItem alloc] initWithDic:dic];
            [array addObject:item];
        }
        self.pages = array;
    }
    return self;
}

+ (XZGuidePage *)guidePageWithArray:(NSArray *)result {
    XZGuidePage *page = [[XZGuidePage alloc] initWithArray:result];
    return page;
}

@end
