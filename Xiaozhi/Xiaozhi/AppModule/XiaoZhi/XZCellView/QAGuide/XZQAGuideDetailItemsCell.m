//
//  XZQAGuideDetailCell.m
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZQAGuideDetailItemsCell.h"

@implementation XZQAGuideDetailItemsCell

- (void)dealloc {
    self.clickTextBlock = nil;
    SY_RELEASE_SAFELY(_tLabel);
    [super dealloc];
}

- (void)setup {
    if (!_tLabel) {
        _tLabel = [[UILabel alloc] init];
        _tLabel.font = FONTSYS(16);
        _tLabel.backgroundColor = [UIColor clearColor];
        _tLabel.textColor = UIColorFromRGB(0x3aadfb);
        _tLabel.numberOfLines = 1;
        _tLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_tLabel];
        _tLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCell)];
        [_tLabel addGestureRecognizer:tap];
        SY_RELEASE_SAFELY(tap);

    }
    self.separatorHide = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)clickCell {
    if (self.clickTextBlock) {
        self.clickTextBlock(_tLabel.text);
    }
}
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_tLabel setFrame:CGRectMake(1, 1, self.width-1, self.height-2)];
}
@end
