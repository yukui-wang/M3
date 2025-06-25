//
//  XZBaseMsgView.m
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//

#import "XZBaseMsgView.h"

#import "XZScheduleMsg.h"
#import "XZBusinessMsg.h"
#import "XZStatisticsMsg.h"
#import "XZCultureMsg.h"

#import "XZScheduleMsgView.h"
#import "XZBusinessMsgView.h"
#import "XZStatisticsMsgView.h"
#import "XZCultureMsgView.h"
@implementation XZBaseMsgView

- (void)dealloc {
    self.needOnOffBlock = nil;
    self.willOpenViewBlock = nil;
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_msg);
    [super dealloc];
}

- (id)initWithMsg:(XZBaseMsg *)msg {
    if (self = [super init]) {
        self.msg = msg;
        _titleLabel.text = msg.title;
    }
    return self;
}

- (void)loadView {
    
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 1.0;
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:UIColorFromRGB(0x1F85EC)];
        [_titleLabel setFont:FONTSYS(24)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
    }
}

- (void)setIsFirst:(BOOL)isFirst {
    _isFirst = isFirst;
    if (_isFirst) {
        if (!_firstButton) {
            _onoff = NO;
            _firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_firstButton addTarget:self  action:@selector(firstButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [_firstButton setTitle:@"下次不显示" forState:UIControlStateNormal];
            [_firstButton setTitleColor:UIColorFromRGB(0xA8A8A8) forState:UIControlStateNormal];
            _firstButton.titleLabel.font = FONTSYS(12);
            [_firstButton setBackgroundColor:[UIColor clearColor]];
            [_firstButton setImage:[UIImage imageNamed:@"msgView.bundle/next_hide.png"] forState:UIControlStateNormal];

            [self addSubview:_firstButton];
            [self customLayoutSubviews];
        }
    }
}

- (void)customLayoutSubviews {
    
    [_firstButton setFrame:CGRectMake(self.width-100, 16+2, 80, 29)];
    CGFloat width = _firstButton&& !_firstButton.hidden ? (_firstButton.originX -20):self.width-40;
    CGFloat height = 33;
    CGFloat lineH = _titleLabel.font.lineHeight;
    
    CGSize s = [_titleLabel.text sizeWithFontSize:_titleLabel.font defaultSize:CGSizeMake(width, lineH*2+1)];
    if (s.height >height) {
        height = s.height;
    }
    [_titleLabel setFrame:CGRectMake(20, 16, width, height)];
}

- (void)firstButtonAction {
    _onoff = !_onoff;
    NSString *imgName = _onoff ? @"msgView.bundle/next_show.png":@"msgView.bundle/next_hide.png";
    [_firstButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];

    if (self.needOnOffBlock) {
        //传非是应为，该按钮和智能消息开关是反的
        self.needOnOffBlock(!_onoff);
    }
}

+ (XZBaseMsgView *)viewWithMsg:(XZBaseMsg *)msg {
    XZBaseMsgView *view = nil;
    if ([msg isKindOfClass:[XZScheduleMsg class]]) {
        view = [[[XZScheduleMsgView alloc] initWithMsg:msg] autorelease];
    }
    else if ([msg isKindOfClass:[XZBusinessMsg class]]) {
        view = [[[XZBusinessMsgView alloc] initWithMsg:msg] autorelease];
    }
    else if ([msg isKindOfClass:[XZStatisticsMsg class]]) {
        view = [[[XZStatisticsMsgView alloc] initWithMsg:msg] autorelease];
    }
    else if ([msg isKindOfClass:[XZCultureMsg class]]) {
        view = [[[XZCultureMsgView alloc] initWithMsg:msg] autorelease];
    }
    return view;
}

@end

