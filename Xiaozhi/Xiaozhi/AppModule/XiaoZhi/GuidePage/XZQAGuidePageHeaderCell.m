//
//  XZQAGuidePageHeader.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAGuidePageHeaderCell.h"
#import "SPConstant.h"

@implementation XZQAGuidePageHeaderCell

- (void)setup {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = FONTSYS(16);
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
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

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGSize s = [_titleLabel sizeThatFits:CGSizeMake(self.width-50, self.height)];
    [_titleLabel setFrame:CGRectMake(20, 20, self.width-50, s.height)];
    [_pushImgView setFrame:CGRectMake(self.width-23, self.height/2-7, 8, 14)];
    _pushImgView.center = CGPointMake(_pushImgView.center.x, _titleLabel.center.y);
}

+ (CGFloat)cellHeightForText:(NSString *)text width:(CGFloat)width {
    CGSize s = [text sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width-50, 100)];
    NSInteger height = 27 +s.height +1;
    return height;

}
@end
