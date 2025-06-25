//
//  XZWebViewModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZWebViewModel.h"

@implementation XZWebViewModel

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZWebViewTableViewCell";
        self.ideltifier = @"XZWebViewModel_text0";
        self.modelId = [NSString uuid];
        self.showInHistory = YES;
        self.canDisappear = YES;
    }
    return self;
}
- (id)initForQA {
    if (self = [super init]) {
        self.cellClass = @"XZQAWebViewCell";
        self.ideltifier = [NSString stringWithFormat:@"XZWebViewModelQA_%@",[NSString uuid]];
        self.showInHistory = YES;
        self.canDisappear = YES;
    }
    return self;
}

- (CGFloat)cellHeight {
    return MAX(10, self.webviewHeight)+ 20;
}

@end
