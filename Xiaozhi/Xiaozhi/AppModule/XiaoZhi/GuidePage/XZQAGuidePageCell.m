//
//  XZQAGuidePageCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAGuidePageCell.h"

@implementation XZQAGuidePageCell
- (void)setup {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorFromRGB(0x297FFB);
        _titleLabel.font = FONTSYS(16);
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGSize s = [_titleLabel sizeThatFits:CGSizeMake(self.width-40, self.height)];
    [_titleLabel setFrame:CGRectMake(20, 8, self.width-40, s.height)];
}

+ (CGFloat)cellHeightForText:(NSString *)text width:(CGFloat)width {
    CGSize s = [text sizeWithFontSize:FONTSYS(16) defaultSize:CGSizeMake(width-40, 100)];
    NSInteger height = 16 +s.height +1;
    return height;

}
@end
