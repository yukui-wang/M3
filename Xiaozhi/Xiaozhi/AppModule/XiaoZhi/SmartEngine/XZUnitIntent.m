//
//  XZUnitIntent.m
//  M3
//
//  Created by wujiansheng on 2018/12/27.
//

#import "XZUnitIntent.h"
#import "SPTools.h"
@implementation XZUnitIntent

- (id)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
        self.intentName = [SPTools stringValue:result forKey:@"intentName"];
        self.text = [SPTools stringValue:result forKey:@"text"];
        self.display = [SPTools boolValue:result forKey:@"display"];
        self.appIds = [SPTools arrayValue:result forKey:@"appIds"];
    }
    return self;
}

@end
