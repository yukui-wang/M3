//
//  XZMeetingMsgDataCell.m
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import "XZMeetingMsgDataCell.h"
#import "XZMeetingMsgData.h"


@implementation XZMeetingMsgDataCell
- (void)dealloc {
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_roomLabel);
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
    if (!_roomLabel) {
        _roomLabel = [[UILabel alloc] init];
        [_roomLabel setBackgroundColor:[UIColor clearColor]];
        [_roomLabel setFont:FONTSYS(14)];
        [self addSubview:_roomLabel];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [super customLayoutSubviewsFrame:frame];
    [_timeLabel setFrame:CGRectMake(45, CGRectGetMaxY(_titleLabel.frame)+4, self.width-45, FONTSYS(14).lineHeight)];
    [_roomLabel setFrame:CGRectMake(45, CGRectGetMaxY(_timeLabel.frame)+4, self.width-45, FONTSYS(14).lineHeight)];
}

- (void)setMsgData:(XZMeetingMsgData *)msgData {
    [super setMsgData:msgData];
    _titleLabel.text = msgData.content;
    _timeLabel.attributedText = msgData.timeStr;
    _roomLabel.attributedText = msgData.meetingRoomStr;
}

@end
