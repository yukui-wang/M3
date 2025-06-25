//
//  XZShortHandListCell.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandListCell.h"
#import "XZSHForwardView.h"


@interface XZShortHandListCell () {
    UILabel *_titleLabel;
    UILabel *_contentLabel;
    UILabel *_dateLabel;
    UIButton *_forwardBtn;
    UIButton *_deleteBtn;
    NSMutableArray *_forwardBtns;//能穿透
}
@end

@implementation XZShortHandListCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_data);
    self.forwardBlock = nil;
    self.deleteBlock = nil;
    self.showForwardListBlock = nil;
    SY_RELEASE_SAFELY(_titleLabel)
    SY_RELEASE_SAFELY(_contentLabel)
    SY_RELEASE_SAFELY(_dateLabel)
    SY_RELEASE_SAFELY(_forwardBtns)
    [super dealloc];
}

- (void)setup {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = FONTSYS(16);
        [self addSubview:_titleLabel];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.font = FONTSYS(16);
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor blackColor];
        _dateLabel.font = FONTSYS(16);
        [self addSubview:_dateLabel];
    }
    if (!_forwardBtn && [XZSHForwardView canShortHandleForward]) {
        _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_forwardBtn setImage:[UIImage imageNamed:@"XZShortHand.bundle/"] forState:UIControlStateNormal];
        [_forwardBtn setTitle:@"转发" forState:UIControlStateNormal];
        [_forwardBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_forwardBtn addTarget:self action:@selector(forwardBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardBtn];
    }
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_deleteBtn setImage:[UIImage imageNamed:@"XZShortHand.bundle/"] forState:UIControlStateNormal];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBtn];
    }
    [self setDefualtBkView];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    CGFloat left = 10;
    [_titleLabel setFrame:CGRectMake(left, 10, self.width-left*2, _titleLabel.font.lineHeight)];
    [_contentLabel setFrame:CGRectMake(left, CGRectGetMaxY(_titleLabel.frame)+10, self.width-left*2, 50)];
    [_dateLabel setFrame:CGRectMake(left, CGRectGetMaxY(_contentLabel.frame)+10, self.width-left*2, _dateLabel.font.lineHeight)];
    [_forwardBtn setFrame:CGRectMake(left, CGRectGetMaxY(_dateLabel.frame)+10, 80, 20)];
    [_deleteBtn setFrame:CGRectMake(CGRectGetMaxX(_forwardBtn.frame)+10, CGRectGetMaxY(_dateLabel.frame)+10, 80, 20)];
    [self layoutForwardBtns];
}


- (UIButton *)buttonWithTitle:(NSString *)title selector:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    button.titleLabel.font = FONTSYS(12);
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setData:(XZShortHandObj *)data {
    SY_RELEASE_SAFELY(_data)
    _data = [data retain];
    _titleLabel.text = _data.title;
    _contentLabel.text = _data.content;
    _dateLabel.text = _data.createDate;
   // 1：已转协同；6：已转会议；11：已转日程；30：已转任务
    
    for (UIView *aview in _forwardBtns) {
        [aview removeFromSuperview];
    }
    [_forwardBtns removeAllObjects];
    if (!_forwardBtns) {
        _forwardBtns = [[NSMutableArray alloc] init];
    }
    if (data.forwardApps.count > 0) {
        if([data.forwardApps containsObject:@"1"]) {
            UIButton *collBtn = [self buttonWithTitle:@"已转协同" selector:@selector(showForwardCollList)];
            [self addSubview:collBtn];
            [_forwardBtns addObject:collBtn];
        }
        if([data.forwardApps containsObject:@"6"]) {
            UIButton *meetBtn = [self buttonWithTitle:@"已转会议" selector:@selector(showForwardMeetingList)];
            [self addSubview:meetBtn];
            [_forwardBtns addObject:meetBtn];
        }
        if([data.forwardApps containsObject:@"30"]) {
            UIButton *meetingBtn = [self buttonWithTitle:@"已转任务" selector:@selector(showForwardTaskList)];
            [self addSubview:meetingBtn];
            [_forwardBtns addObject:meetingBtn];
        }
        if([data.forwardApps containsObject:@"11"]) {
            UIButton *calBtn = [self buttonWithTitle:@"已转日程" selector:@selector(showForwardCalList)];
            [self addSubview:calBtn];
            [_forwardBtns addObject:calBtn];
        }
    }
    else {
        UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [customBtn setTitle:@"备忘" forState:UIControlStateNormal];
        [customBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self addSubview:customBtn];
        [_forwardBtns addObject:customBtn];

    }
    [self layoutForwardBtns];
}

- (void)layoutForwardBtns {
    CGFloat btnWidth = 80;
    CGFloat btnHeight = _deleteBtn.height;
    if (_forwardBtns.count == 1) {
        UIButton *btn = _forwardBtns[0];
        [btn setFrame:CGRectMake(self.width-10-btnWidth, _deleteBtn.originY, btnWidth, btnHeight)];
    }
    else if (_forwardBtns.count > 1) {
        UIButton *btn1 = _forwardBtns[0];
        [btn1 setFrame:CGRectMake(self.width-10-btnWidth*2-10, _deleteBtn.originY, btnWidth, btnHeight)];
        UIButton *btn2 = _forwardBtns[1];
        [btn2 setFrame:CGRectMake(self.width-10-btnWidth, _deleteBtn.originY, btnWidth, btnHeight)];

        if (_forwardBtns.count > 2) {
            UIButton *btn3 = _forwardBtns[2];
            [btn3 setFrame:CGRectMake(self.width-10-btnWidth*2-10, _deleteBtn.originY+10+btnHeight, btnWidth, btnHeight)];
        }
        if (_forwardBtns.count > 3) {
            UIButton *btn4 = _forwardBtns[3];
            [btn4 setFrame:CGRectMake(self.width-10-btnWidth, _deleteBtn.originY+10+btnHeight, btnWidth, btnHeight)];
        }
    }
}

- (void)forwardBtnClick {
    if (self.forwardBlock) {
        self.forwardBlock(_data);
    }
}

- (void)deleteBtnClick {
    if (self.deleteBlock) {
        self.deleteBlock(_data);
    }
}

- (void)showForwardCollList {
    if (self.showForwardListBlock) {
        self.showForwardListBlock(_data,@"1",@"已转流程");
    }
}

- (void)showForwardMeetingList {
    if (self.showForwardListBlock) {
        self.showForwardListBlock(_data,@"6",@"已转会议");
    }
}

- (void)showForwardTaskList {
    if (self.showForwardListBlock) {
        self.showForwardListBlock(_data,@"30",@"已转任务");
    }
}

- (void)showForwardCalList {
    if (self.showForwardListBlock) {
        self.showForwardListBlock(_data,@"11",@"已转日程");
    }
}


@end
