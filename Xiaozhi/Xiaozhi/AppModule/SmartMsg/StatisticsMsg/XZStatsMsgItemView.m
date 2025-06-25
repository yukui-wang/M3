//
//  XZStatisticsMsgItemView.m
//  M3
//
//  Created by wujiansheng on 2018/9/18.
//

#import "XZStatsMsgItemView.h"

@implementation XZStatsMsgItemView

- (void)dealloc {
    SY_RELEASE_SAFELY(_countLabel);
    SY_RELEASE_SAFELY(_contentLabel);
    [super dealloc];
}

- (id)initWithCount:(NSString *)count content:(NSString *)content {
    if (self = [super initWithFrame:CGRectZero]) {
        [_countLabel setText:count];
        [_contentLabel setText:content];
    }
    return self;
}

- (void)layoutCount:(NSString *)count content:(NSString *)content {
    [_countLabel setText:count];
    [_contentLabel setText:content];
}

- (void)setup {
    self.backgroundColor = UIColorFromRGB(0xE4F2F8);
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        [_countLabel setBackgroundColor:[UIColor clearColor]];
        [_countLabel setTextColor:UIColorFromRGB(0x52565C)];
        [_countLabel setFont:FONTSYS(34)];
        [_countLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_countLabel];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setTextColor:UIColorFromRGB(0x8998BB)];
        [_contentLabel setFont:FONTSYS(13)];
        [_contentLabel setTextAlignment:NSTextAlignmentCenter];
        _contentLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_contentLabel];
    }
}

- (void)customLayoutSubviews {
    NSInteger y = 0;
    NSInteger countH = _countLabel.font.lineHeight+1;
    NSInteger contentH = _contentLabel.font.lineHeight+1;
    y = (self.height-countH-contentH-3)/2;
    [_countLabel setFrame:CGRectMake(0, y, self.width, countH)];
    y += _countLabel.height+3;
    [_contentLabel setFrame:CGRectMake(0, y, self.width, contentH)];
}

@end
