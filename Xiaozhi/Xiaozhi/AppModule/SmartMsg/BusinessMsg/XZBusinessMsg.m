//
//  XZBusinessMsg.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZBusinessMsg.h"

@implementation XZBusinessMsg

- (void)dealloc {
    SY_RELEASE_SAFELY(_loadUrl);
    SY_RELEASE_SAFELY(_content);
    SY_RELEASE_SAFELY(_gotoParams);
    [super dealloc];
}

- (id)initWithMsg:(NSDictionary *)msg {
    if (self = [super initWithMsg:msg]) {
        self.loadUrl = [SPTools stringValue:msg forKey:@"loadUrl"];
        self.content = [SPTools stringValue:msg forKey:@"content"];
        self.gotoParams = msg[@"gotoParams"];
    }
    return self;
}

@end
