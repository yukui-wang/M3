//
//  XZMainCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZMainCell.h"
#import "XZMainCellModel.h"

@interface XZMainCell() {
    UILabel *_contentLabel;
}
@end

@implementation XZMainCell

- (void)setup {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = kMainCellFont;
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setModel:(XZMainCellModel *)model {
    [super setModel:model];
    _contentLabel.text = model.content;
    _contentLabel.textAlignment = model.textAlignment;
    _contentLabel.textColor = model.contentColor;
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat height = self.height;
    [_contentLabel setFrame:CGRectMake(20, 10, self.width-40, height-20)];
}

@end
