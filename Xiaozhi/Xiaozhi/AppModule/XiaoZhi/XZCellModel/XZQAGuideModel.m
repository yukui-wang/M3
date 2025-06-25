//
//  XZQAGuideModel.m
//  M3
//
//  Created by wujiansheng on 2018/10/22.
//

#import "XZQAGuideModel.h"
#import "XZTextTapModel.h"
#import "XZQAGuideTips.h"

@implementation XZQAGuideModel

- (void)dealloc{
    self.moreBtnClickAction = nil;
    self.clickTextBlock = nil;
    self.tipsSet = nil;
}

- (id)initWithQuestions:(NSArray *)array {
    if (self = [super init]) {
        self.cellClass =  @"XZQAGuideCell";
        self.ideltifier = [NSString stringWithFormat:@"XZQAGuideModel%u",arc4random_uniform(99999)];
        self.chatCellType = ChatCellTypeRobotMessage;
        self.tipsSet = array;
    }
    return self;
}

- (CGFloat)heightForGuideInfo {
    NSMutableArray *array = [NSMutableArray array];
    NSInteger height = 0;
    for (XZQAGuideTips *tips in self.tipsSet) {
        if (tips.tips.count > 0) {
            NSInteger count = tips.tips.count;
            count = count >1 ? 2:1;
            height += count *kXZQAGuideCellHeight;
            [array addObject:tips];
        }
    }
    height += kXZQAGuideCellHeaderHeight * array.count + kXZQAGuideCellFooterHeight *(array.count -1);
    self.tipsSet = array;
    return height;
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        self.lableWidth = self.scellWidth-144;
        NSInteger height = 46*2;
        height += [self heightForGuideInfo];
        height += kXZCellSpace;
        NSInteger max = [UIScreen mainScreen].bounds.size.height/2;
        _cellHeight = MIN(height, max);
    }
    return _cellHeight;
}

@end
