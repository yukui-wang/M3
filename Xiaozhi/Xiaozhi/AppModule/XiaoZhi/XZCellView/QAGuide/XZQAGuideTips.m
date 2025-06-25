//
//  XZQAGuideTips.m
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZQAGuideTips.h"

@implementation XZQAGuideTips

- (id)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
        self.tips = result[@"tips"];
        self.tipsSetName = result[@"tipsSetName"];
    }
    return self;
}
- (BOOL)showMore {
    return self.tips.count > 2;
}
@end
