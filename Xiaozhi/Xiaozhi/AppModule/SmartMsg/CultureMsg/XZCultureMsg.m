//
//  XZCultureMsg.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZCultureMsg.h"

@implementation XZCultureMsg
- (void)dealloc {
    SY_RELEASE_SAFELY(_imgUrl);
    SY_RELEASE_SAFELY(_content);
    SY_RELEASE_SAFELY(_gotoParams);

    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.imgUrl = [SPTools stringValue:msg forKey:@"imgUrl"];
        self.content = [SPTools stringValue:msg forKey:@"content"];
        self.gotoParams = msg[@"gotoParams"];
    }
    return self;
}

@end
