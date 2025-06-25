//
//  XZGuidePageCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePageCell.h"

@interface XZGuidePageCell () {
    UIImageView *_imgView;
    UILabel *_titleLabel;
    UILabel *_subLabel;
    UIImageView *_pushImgView;
    CGFloat _topMarg;
}
@end

@implementation XZGuidePageCell

- (void)setup {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imgView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = FONTSYS(16);
        [self addSubview:_titleLabel];
    }
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _subLabel.font = FONTSYS(14);
        [self addSubview:_subLabel];
    }
    if (!_pushImgView) {
        _pushImgView = [[UIImageView alloc] init];
        _pushImgView.backgroundColor = [UIColor clearColor];
        _pushImgView.image = XZ_IMAGE(@"xz_guide_next.png");
        [self addSubview:_pushImgView];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupPageItem:(XZGuidePageItem *)item isTop:(CGFloat)isTop{
    _topMarg = isTop ? 5 :0;
    NSString *icon = [NSString stringWithFormat:@"xz_guideIcon_%@.png",item.themeIcon];
    _imgView.image = XZ_IMAGE(icon);
    _titleLabel.text = item.title;
    _subLabel.text = item.subTitle;
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat height = [XZGuidePageCell cellHeight];
    [_imgView setFrame:CGRectMake(20, height/2-22+_topMarg, 44, 44)];
    NSInteger tHeight = _titleLabel.font.lineHeight+1;
    NSInteger sHeight = _subLabel.font.lineHeight+1;
    CGFloat y = (height- tHeight-sHeight-2)/2+_topMarg;
    [_titleLabel setFrame:CGRectMake(74, y, self.width-84, tHeight)];
    y += _titleLabel.height+2;
    [_subLabel setFrame:CGRectMake(74, y, self.width-84, sHeight)];
    [_pushImgView setFrame:CGRectMake(self.width-38, self.height/2-7, 8, 14)];
}

+ (CGFloat)cellHeight {
    return 74;//70;
}

@end
