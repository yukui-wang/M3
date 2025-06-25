//
//  XZWillDoneItem.m
//  M3
//
//  Created by wujiansheng on 2017/11/10.
//

#import "XZWillDoneItem.h"
#import <CMPLib/CMPConstant.h>

@interface XZWillDoneItem () {
    UILabel *_infoLabel;
    UILabel *_dateLabel;
    BOOL _alignmentLeft;

}
@end

@implementation XZWillDoneItem

- (void)setup {
    [super setup];
    _alignmentLeft = NO;
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:11];
        _infoLabel.textColor = UIColorFromRGB(0x006ff1);
        [self addSubview:_infoLabel];
    }
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:11];
        _dateLabel.textColor = UIColorFromRGB(0x006ff1);
        [self addSubview:_dateLabel];
    }
}

- (void)customLayoutSubviews{
    [super customLayoutSubviews];
    CGFloat y = 10;
    CGFloat maxWidth = _dotImageView.hidden ? self.width -5 : _dotImageView.originX-5;
    [_contentLabel setFrame:CGRectMake(12, y, maxWidth-10, FONTSYS(16).lineHeight)];
    y += 5+_contentLabel.height;
    CGFloat x = _alignmentLeft ? 12 : 34;
    maxWidth -= x;
    UIFont *font = _infoLabel.font;
    CGFloat infoWidth = [_infoLabel.text sizeWithFontSize:font defaultSize:CGSizeMake(maxWidth, 50)].width;
    CGFloat dateWidth = [_dateLabel.text sizeWithFontSize:font defaultSize:CGSizeMake(maxWidth, 50)].width;
    infoWidth = MIN(infoWidth, maxWidth - dateWidth-5);
    [_infoLabel setFrame:CGRectMake(x, y, infoWidth, font.lineHeight)];
    x +=_infoLabel.width+5;
    [_dateLabel setFrame:CGRectMake(x, y, dateWidth, font.lineHeight)];
}

+ (XZWillDoneItem *)itemWithModel:(SPWillDoneItemModel *)model {
    NSInteger height = kWillDoneItemHeight+1;
    XZWillDoneItem *cell = [[XZWillDoneItem alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [cell setupWithModel:model];
    return cell;
}

- (void)setupWithModel:(SPWillDoneItemModel*)model {
    _contentLabel.text = model.content;
    _infoLabel.text = [NSString stringWithFormat:@"%@",model.initiator];
    _dateLabel.text = [NSString stringWithFormat:@"%@",model.creatDate];
    if (!model.showDot) {
        _dotImageView.hidden = YES;
    }
    if (_alignmentLeft != model.alignmentLeft) {
        _alignmentLeft = model.alignmentLeft;
        [self customLayoutSubviews];
    }
}


@end
