//
//  XZScheduleCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/6.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZScheduleCell.h"
#import "XZScheduleView.h"
@interface XZScheduleCell () {
    XZScheduleView *_scheduleView;
}

@end


@implementation XZScheduleCell

- (void)setup {
    [super setup];
    if (!_scheduleView) {
        _scheduleView = [[XZScheduleView alloc] init];
        [self addSubview:_scheduleView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(XZScheduleModel *)model {
    [super setModel:model];
    [_scheduleView setupWithModel:model];
    [self customLayoutSubviewsFrame:self.bounds];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_scheduleView setFrame:CGRectMake(0, 10, self.width, self.height-20)];
}

@end
