//
//  XZBaseMsgDataCell.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZBaseMsgDataCell.h"

@implementation XZBaseMsgDataCell
- (void)dealloc {
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_msgData);
    [super dealloc];
}

- (void)setup {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
//        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setFont:kMsgDataContentFont];

        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
//    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.separatorHide = YES;
    [self setSelectBkViewColor:UIColorFromRGB(0xEEEEEE)];
    [self setBkViewColor:[UIColor whiteColor]];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    NSInteger h = kMsgDataContentFont.lineHeight+1;
    CGSize s = [_titleLabel.text sizeWithFontSize:_titleLabel.font defaultSize:CGSizeMake(self.width-55, 1000)];
    if (s.height > h) {
        h = kMsgDataContentFont.lineHeight *2+1;
    }
    [_titleLabel setFrame:CGRectMake(45, 8, self.width-55, h)];
}

@end
