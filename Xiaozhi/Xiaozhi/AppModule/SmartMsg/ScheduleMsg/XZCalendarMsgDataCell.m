//
//  XZCalendarMsgDataCell.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZCalendarMsgDataCell.h"
#import "XZCalendarMsgData.h"

@implementation XZCalendarMsgDataCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_timeLabel);

    [super dealloc];
}
- (void)setup {
    
    [super setup];

    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:FONTSYS(14)];
        [self addSubview:_timeLabel];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [super customLayoutSubviewsFrame:frame];
    [_timeLabel setFrame:CGRectMake(45, CGRectGetMaxY(_titleLabel.frame)+4, self.width-45, FONTSYS(14).lineHeight)];
}

- (void)setMsgData:(XZCalendarMsgData *)msgData {
    [super setMsgData:msgData];
    _titleLabel.text = msgData.content;
    _timeLabel.attributedText = msgData.timeStr;
}

@end
