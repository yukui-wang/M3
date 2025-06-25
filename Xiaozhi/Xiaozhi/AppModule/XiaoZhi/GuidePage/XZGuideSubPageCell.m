//
//  XZGuideSubPageCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuideSubPageCell.h"

@interface XZGuideSubPageCell() {
    UILabel *_titleLabel;
    BOOL _isHeader;
}

@end

@implementation XZGuideSubPageCell

- (void)setup {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _titleLabel.font = FONTSYS(16);
        [self addSubview:_titleLabel];
    }
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupText:(NSString *)text {
    _titleLabel.text = text;
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _isHeader = NO;
}

- (void)setupTextForHeader:(NSString *)text {
    _titleLabel.text = text;
    _titleLabel.textColor = [UIColor whiteColor];
    _isHeader = YES;
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    if (_isHeader) {
        [_titleLabel setFrame:CGRectMake(20, 19, self.width-84, 22)];
    }
    else {
        [_titleLabel setFrame:CGRectMake(20, 8, self.width-84, 22)];
    }
}

+ (CGFloat)cellHeight {
    return 36;
}

+ (CGFloat)headerCellHeight {
    return 47;
}

@end

