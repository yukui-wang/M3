//
//  XZQAGuideDetailModel.m
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZQAGuideDetailModel.h"
#import "XZQAGuideModel.h"
@implementation XZQAGuideDetailModel

- (void)dealloc {
    self.clickTextBlock = nil;
    self.tips = nil;
    self.title = nil;
    self.HeightArray = nil;
}

- (id)init {
    if (self = [super init]) {
        self.cellClass =  @"XZQAGuideDetailCell";
        self.ideltifier = [NSString stringWithFormat:@"XZQAGuideDetailCell_%u",arc4random_uniform(99999)];
        self.chatCellType = ChatCellTypeRobotMessage;
    }
    return self;
}

- (CGFloat)heightForGuideInfo {
    
    NSInteger total = 0;
    NSInteger fontHeight = FONTSYS(16).lineHeight+1;
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *string in _tips.tips) {
        CGSize s = [string sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(self.lableWidth, 2000)];
        NSInteger height = s.height+1;
        height = kXZQAGuideCellHeight - fontHeight+height;
        total += height;
        [array addObject:[NSNumber numberWithInteger:height]];
    }
    self.HeightArray = array;
    
    return total;
    
}

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        self.lableWidth = self.scellWidth-144;
        self.title = [NSString stringWithFormat:@"你可以问我“%@”相关问题哦",self.tips.tipsSetName];
        CGSize s = [self.title sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(self.lableWidth, 2000)];
        NSInteger titleHeight = s.height+1;
        self.titleHeight = titleHeight;
        NSInteger height = 8;
        height += self.titleHeight;
        height += 8;
        height += [self heightForGuideInfo];
        height += 9;
        height += kXZCellSpace;
      
        NSInteger max = [UIScreen mainScreen].bounds.size.height/2;
        _cellHeight = MIN(height, max);
    }
    return _cellHeight;
}

@end
