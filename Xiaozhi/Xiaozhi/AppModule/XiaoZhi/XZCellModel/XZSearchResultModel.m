//
//  XZSearchResultModel.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/4.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSearchResultModel.h"
#import "SPConstant.h"
#import "XZNewsItemModel.h"
@implementation XZSearchResultModel
- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZSearchResultCell";
        self.ideltifier = @"XZSearchResultCellModel";
        self.modelId = [NSString uuid];
    }
    return self;
}

- (CGFloat)cellHeight {
    NSMutableArray *heightArray = [NSMutableArray array];
    NSInteger height = 0;
    NSInteger fontHeight = FONTSYS(16).lineHeight+1;
    for (id item in self.items) {
        NSInteger itemHeight = 0;
        if ([item isKindOfClass: [XZNewsItemModel class]]) {
            XZNewsItemModel *aModel = item;
            NSString *content = aModel.content;
            CGSize s = [content sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(self.cellWidth-56, 100)];
            itemHeight = s.height > fontHeight ? 94 :72;
        }
        else if ([item isKindOfClass: NSClassFromString(@"SPWillDoneModel")]) {
            itemHeight = kOverdueModelHeight+1;
        }
        else if ([item isKindOfClass: NSClassFromString(@"SPWillDoneItemModel")]) {
            itemHeight = kWillDoneItemHeight+1;
        }
        else if ([item isKindOfClass: NSClassFromString(@"SPScheduleModel")]) {
            itemHeight = kScheduleModelHeight+1;
        }
        else if ([item isKindOfClass: NSClassFromString(@"XZSearchAppModel")]) {
            itemHeight = kWillDoneItemHeight+1;
        }
        
        height += itemHeight;
        [heightArray addObject:[NSString stringWithInt:itemHeight]];
        
    }
    self.itemHeightArray = heightArray;
    _cellHeight = 10+ height +(self.showMoreBtn ? 64:20);
    return _cellHeight;
}
@end
