//
//  XZLeaveCardCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/11.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZLeaveCardCell.h"
#import "XZLeaveCard.h"
#import "XZLeaveModel.h"
@interface XZLeaveCardCell () {
    XZLeaveCard *_cardView;
}
@end

@implementation XZLeaveCardCell


- (void)setup {
    [super setup];
    if (!_cardView) {
        _cardView = [[XZLeaveCard alloc] init];
        [self addSubview:_cardView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(XZLeaveModel *)model {
    [super setModel:model];
    [_cardView setupWithModel:model];
    [self customLayoutSubviewsFrame:self.bounds];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_cardView setFrame:CGRectMake(0, 10, self.width, self.height-20)];
}


@end
