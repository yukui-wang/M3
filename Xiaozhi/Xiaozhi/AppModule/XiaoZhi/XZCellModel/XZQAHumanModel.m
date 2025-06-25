//
//  XZQAHumanModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/10.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAHumanModel.h"

@implementation XZQAHumanModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZQAHumanCell";
        self.ideltifier = @"XZQAHumanModel";
    }
    return self;
}


- (CGFloat)cellHeight {
//    NSMutableArray *heightArray = [NSMutableArray array];
//    NSInteger height = 0;
//    NSInteger fontHeight = FONTSYS(16).lineHeight+1;
    CGSize s = [self.content sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(273-26, 100000)];
    NSInteger height = s.height+1;
    NSInteger width = s.width+1;
    self.bubbleSize = CGSizeMake(MAX(width+26, 41),MAX(height+20, 42));//42为背景图片最小宽度
    return self.bubbleSize.height+20+ (self.showAnimation ?50:0);
}

@end
