//
//  XZLeaveTypesModel.m
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZLeaveTypesModel.h"

@implementation XZLeaveTypesModel

- (void)dealloc {
    self.clickTypeBlock = nil;
    self.leaveTypes = nil;
    self.showItems = nil;
    self.selectType = nil;
}

- (id)init {
    if (self = [super init]) {
        self.cellClass = @"XZLeaveTypesCell";
        self.ideltifier = @"XZLeaveTypesCell";
        self.canOperate = YES;
    }
    return self;
}
- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        self.showItems = nil;
        NSMutableArray *array = [NSMutableArray array];
        CGFloat maxWidth = self.scellWidth -24-20;
        CGFloat x = 12, y = 0;
        UIFont *font = FONTSYS(14);
        NSInteger height = 30;
        for (NSString *leaveType in self.leaveTypes ) {
            CGSize s = [leaveType sizeWithFontSize:font defaultSize:CGSizeMake(maxWidth, 100)];
            NSInteger width = s.width+1+20;
            if (x + width > self.scellWidth) {
                x = 12;
                y  += height+8;
            }
            NSString *frame = NSStringFromCGRect(CGRectMake(x, y, width, height));
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:frame,@"frame",leaveType,@"title", nil];
            [array addObject:dic];
            x += width+10;
        }
        self.showItems = array;
        _cellHeight =  y +height + kXZCellSpace;
    }
    return _cellHeight;
}
- (void)disableOperate {
    self.canOperate = NO;
}

@end
