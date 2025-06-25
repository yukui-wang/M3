//
//  XZNewsItem.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/7/17.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZNewsItem.h"
#import "XZNewsItemModel.h"

@interface XZNewsItem () {
    UILabel *_infoLabel;
    UILabel *_dateLabel;
    UIView *_separatorLine;
}

@end

@implementation XZNewsItem

- (void)setup {

    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }

    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:12];
        _infoLabel.textColor = UIColorFromRGB(0x999999999);
        [self addSubview:_infoLabel];
    }
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = UIColorFromRGB(0xeeeff3);
        [self addSubview:_separatorLine];
    }
    [self addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchUpInsideAction:(id)sender {
    [_touchTarget performSelector:_touchAction withObject:self afterDelay:0];
}


- (void)customLayoutSubviews {
    [_contentLabel setFrame:CGRectMake(14, 10, self.width-28, self.height-44)];
    [_infoLabel setFrame:CGRectMake(14, CGRectGetMaxY(_contentLabel.frame)+4, self.width-28, _infoLabel.font.lineHeight)];
    [_separatorLine setFrame:CGRectMake(0, self.height-1, self.width, 1)];
}

+ (XZNewsItem *)itemWithModel:(XZNewsItemModel *)model {
    NSInteger height = kWillDoneItemHeight+1;
    XZNewsItem *cell = [[XZNewsItem alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [cell setupWithModel:model];
    return cell;
}

- (void)setupWithModel:(XZNewsItemModel *)model {
    _contentLabel.text = model.content;
    _infoLabel.text = [NSString stringWithFormat:@"%@  %@",model.initiator,model.creatDate];
    _separatorLine.hidden = model.isLast;
}

@end
