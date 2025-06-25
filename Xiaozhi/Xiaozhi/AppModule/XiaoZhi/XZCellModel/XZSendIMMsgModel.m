//
//  XZSendIMMsgModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSendIMMsgModel.h"

@implementation XZSendIMMsgModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZSendIMMsgCell";
        self.ideltifier = @"XZSendIMMsgModel";
        self.modelId = [NSString uuid];
    }
    return self;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        NSInteger width = [self scellWidth]-(100+70);
        NSInteger hegit = 1000;
        CGSize size = [self.content sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width, hegit)];
        width = size.width+1;
        hegit = size.height+1;
        self.contentSize = CGSizeMake(width, hegit);
        _cellHeight = hegit+81+18+20;
    }
    return _cellHeight;
}

@end
