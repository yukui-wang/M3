//
//  SyBaseTableViewCellHeaderView.m
//  M1Core
//
//  Created by wujiansheng on 15/3/5.
//
//

#import "SyBaseTableViewCellHeaderView.h"

@implementation SyBaseTableViewCellHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  UIColorFromRGB(0xefeff4);
        self.forFooter = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    CGRect sectionRect = [self.tableView rectForSection:self.section];
    CGRect newFrame = self.forFooter ?CGRectMake(CGRectGetMaxX(frame), CGRectGetMaxY(sectionRect), CGRectGetWidth(frame), CGRectGetHeight(frame)): CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(sectionRect), CGRectGetWidth(frame), CGRectGetHeight(frame));
    [super setFrame:newFrame];
}

@end
