//
//  XZShortHandDetailView.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandDetailView.h"

@interface XZShortHandDetailView () {
    UILabel *_dateLabel;
}
@end

@implementation XZShortHandDetailView

- (void)dealloc {
    self.titleView = nil;
    self.contentView = nil;
    self.data = nil;
    self.editBtn = nil;
    self.forwardBtn = nil;
    SY_RELEASE_SAFELY(_dateLabel);
    [super dealloc];
}

- (void)setup {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor blackColor];
        _dateLabel.font = FONTSYS(16);
        [self addSubview:_dateLabel];
    }
    if (!_titleView) {
        _titleView = [[UITextField alloc] init];
        _titleView.font = FONTSYS(18);
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"标题" attributes:[NSDictionary dictionaryWithObjectsAndKeys:FONTSYS(18),NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil]];
        _titleView.attributedPlaceholder = str;
        SY_RELEASE_SAFELY(str);
        
        [self addSubview:_titleView];
    }
    if (!_contentView) {
        _contentView = [[UITextView alloc] init];
        _contentView.font = FONTSYS(16);
        [self addSubview:_contentView];
    }
    if (!self.editBtn) {
        self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_edit_close.png"] forState:UIControlStateNormal];
        [self.editBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_edit_close.png"] forState:UIControlStateSelected];
        [self addSubview:self.editBtn];
    }
    if (!self.forwardBtn) {
        self.forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.forwardBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_fly.png"] forState:UIControlStateNormal];
        [self.forwardBtn setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_fly.png"] forState:UIControlStateSelected];
        [self addSubview:self.forwardBtn];
    }
    self.backgroundColor = [UIColor whiteColor];
}

- (void)customLayoutSubviews {
    [_dateLabel setFrame:CGRectMake(15, 0, self.width-30, 40)];
    [_titleView setFrame:CGRectMake(15, CGRectGetMaxY(_dateLabel.frame)+10, self.width-30, 40)];
    [_contentView setFrame:CGRectMake(15, CGRectGetMaxY(_titleView.frame)+10, self.width-30, self.height-(CGRectGetMaxY(_titleView.frame)+10))];
    [self.forwardBtn setFrame:CGRectMake(self.width -80, self.height-80, 60, 60)];
    [self.editBtn setFrame:CGRectMake(self.forwardBtn.originX -80, self.height-80, 60, 60)];
}

- (void)setData:(XZShortHandObj *)data {
    SY_RELEASE_SAFELY(_data)
    _data = [data retain];
    _titleView.text = _data.title;
    _contentView.text = _data.content;
    _dateLabel.text = _data.createDate;
    // 1：已转协同；6：已转会议；11：已转日程；30：已转任务
}

@end
