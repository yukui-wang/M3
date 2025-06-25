//
//  XZCancelCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCancelCell.h"
#import "XZCancelCard.h"
@interface XZCancelCell () {
    XZCancelCard *_cancelCard;
}

@end


@implementation XZCancelCell

- (void)setup {
    [super setup];
    if (!_cancelCard) {
        _cancelCard = [[XZCancelCard alloc] init];
        [_cancelCard setFrame:CGRectMake(20, 10, 262, [XZCancelCard viewHeight])];
        [self addSubview:_cancelCard];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_cancelCard setFrame:CGRectMake(14, 10, self.width-28, [XZCancelCard viewHeight])];
}
@end
