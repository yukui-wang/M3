//
//  XZMainCellModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZMainCellModel.h"

@implementation XZMainCellModel


- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZMainCell";
        self.ideltifier = @"XZMainCellModelindex";
    }
    return self;
}

+ (XZMainCellModel *)robotSpeak:(NSString *)content{
    XZMainCellModel *model = [[XZMainCellModel alloc] init];
    model.content = content;
    model.contentColor = [UIColor whiteColor];
    model.textAlignment = NSTextAlignmentLeft;
    return model;
}

+ (XZMainCellModel *)humenSpeak:(NSString *)content alignment:(NSTextAlignment) textAlignment {
    XZMainCellModel *model = [[XZMainCellModel alloc] init];
    model.content = content;
    model.contentColor = [UIColor colorWithWhite:1 alpha:0.5];
    model.textAlignment = textAlignment;
    return model;
}

- (CGFloat)cellHeight {
    CGSize s = [self.content sizeWithFontSize:kMainCellFont defaultSize:CGSizeMake(self.cellWidth -40, MAXFLOAT)];
    NSInteger height = s.height +20;
    return height;
}

@end
