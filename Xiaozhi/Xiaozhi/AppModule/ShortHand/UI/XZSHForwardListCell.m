//
//  XZSHForwardListCell.m
//  M3
//
//  Created by wujiansheng on 2019/1/9.
//

#import "XZSHForwardListCell.h"
#import "CMPOfflineContactFaceview.h"


@implementation XZSHForwardListCell

- (void)dealloc {
    self.data = nil;
    [super dealloc];
}

- (void)setup {

    [self setDefualtBkView];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

}

@end


@interface XZSHForwardCollCell () {
    CMPOfflineContactFaceview *_faceView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_replyLabel;
    UIImageView *_statueView;
}
@end

#pragma mark 转发协同
@implementation XZSHForwardCollCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_faceView);
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_replyLabel);
    SY_RELEASE_SAFELY(_statueView);

    [super dealloc];
}

- (void)setData:(XZSHForwardCollObj *)data {
    [super setData:data];
    _titleLabel.text = data.title;
    _timeLabel.text = data.startDate;
    _replyLabel.text = data.replyDisplay;
    _faceView.memberId = data.memberId;
}

- (void)setup {
    [super setup];
    if (!_faceView) {
        _faceView = [[CMPOfflineContactFaceview alloc] init];
        _faceView.layer.cornerRadius = 40/2;
        _faceView.layer.masksToBounds = YES;
        [self addSubview:_faceView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = FONTSYS(16);
        [self addSubview:_titleLabel];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = FONTSYS(12);
        [self addSubview:_timeLabel];
    }
    if (!_replyLabel) {
        _replyLabel = [[UILabel alloc] init];
        _replyLabel.backgroundColor = [UIColor clearColor];
        _replyLabel.textColor = [UIColor grayColor];
        _replyLabel.font = FONTSYS(12);
        [self addSubview:_replyLabel];
    }
    if (!_statueView) {
        _statueView = [[UIImageView alloc] init];
        _statueView.backgroundColor = [UIColor redColor];
        [self addSubview:_statueView];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_faceView setFrame:CGRectMake(10, 10, 40, 40)];
    CGFloat x = CGRectGetMaxX(_faceView.frame)+10;
    CGFloat y = 10;
    [_titleLabel setFrame:CGRectMake(x, y, self.width-x-10, _titleLabel.font.lineHeight+1)];
    y += _titleLabel.height+10;
    [_timeLabel setFrame:CGRectMake(x, y, self.width-x-10, _timeLabel.font.lineHeight+1)];
    y += _timeLabel.height+10;
    [_replyLabel setFrame:CGRectMake(x, y, self.width-x-10, _replyLabel.font.lineHeight+1)];
    [_statueView setFrame:CGRectMake(self.width-50, self.height-50, 50, 50)];
}

- (void)loadFaceImage{
    [_faceView loadImage];
}


@end


#pragma mark 转发任务
@implementation XZSHForwardTaskCell

- (void)dealloc {
    [super dealloc];
}

- (void)setData:(XZSHForwardTaskObj *)data {
    [super setData:data];
}

- (void)setup {
    [super setup];
}

@end

#pragma mark 转发会议对象
@implementation XZSHForwardMeetingCell

- (void)dealloc {
    [super dealloc];
}
- (void)setData:(XZSHForwardMeetingObj *)data {
    [super setData:data];
}

- (void)setup {
    [super setup];
}


@end

#pragma mark 转发日程
@implementation XZSHForwardCalCell

- (void)dealloc {
    [super dealloc];
}

- (void)setData:(XZSHForwardCalObj *)data {
    [super setData:data];
}

- (void)setup {
    [super setup];
}

@end
