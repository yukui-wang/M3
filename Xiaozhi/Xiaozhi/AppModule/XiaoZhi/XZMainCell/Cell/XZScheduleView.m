//
//  XZScheduleView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/6.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZScheduleView.h"
#import "SPScheduleModel.h"

@interface XZScheduleViewCell :CMPBaseView {
    UILabel *_contentLabel;
    UILabel *_timeLabel;
}
@property(nonatomic, strong)NSMutableArray *itemArray;
@property(nonatomic, strong)UIView *line;
@property(nonatomic, strong)SPScheduleModel *model;

@end


@implementation XZScheduleViewCell
- (void)setup {
    
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setFont:FONTSYS(16)];
        [_contentLabel setTextColor:[UIColor blackColor]];
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:FONTSYS(14)];
        [_timeLabel setTextColor:UIColorFromRGB(0x666666)];
        [self addSubview:_timeLabel];
    }
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xe4e4e4);
        [self addSubview:_line];
    }
}

- (void)setupWithModel:(SPScheduleModel *)model {
    self.model = model;
    [_contentLabel setText:model.tilte];
    [_timeLabel setText:model.time];
    [self customLayoutSubviews];
}

- (void)customLayoutSubviews {
    CGSize s = [_contentLabel sizeThatFits:CGSizeMake(self.width-40, _contentLabel.font.lineHeight*2)];
    NSInteger height = s.height+1;
    [_contentLabel setFrame:CGRectMake(20, 20, self.width-40, height)];
    height = _timeLabel.font.lineHeight+1;
    [_timeLabel setFrame:CGRectMake(20, CGRectGetMaxY(_contentLabel.frame)+4, self.width-40, height)];
    CGRect r = self.frame;
    r.size.height = CGRectGetMaxY(_timeLabel.frame)+20;
    self.frame = r;
    [_line setFrame:CGRectMake(0, self.height-1, self.width, 1)];
}

@end


@interface XZScheduleView () {
    UILabel *_contentLabel;
    UIView *_cardView;
}
@property(nonatomic, strong)NSMutableArray *itemArray;
@property(nonatomic, strong)XZScheduleModel *model;
@end


@implementation XZScheduleView
- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [[NSMutableArray alloc] init];
    }
    return _itemArray;
}

- (void)setup {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setFont:FONTSYS(20)];
        [_contentLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_contentLabel];
    }
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 8;
        _cardView.layer.masksToBounds = YES;
        [self addSubview:_cardView];
    }
}

- (void)setupWithModel:(XZScheduleModel *)model {
    self.model = model;
    _contentLabel.text = model.content;
    for (UIView *view in self.itemArray) {
        [view removeFromSuperview];
    }
    [self.itemArray removeAllObjects];
    CGFloat y = 0;
    CGRect r = CGRectMake(14, CGRectGetMaxY(_contentLabel.frame)+10, self.width-28, 10);
    [_cardView setFrame:r];
    for (SPScheduleModel *scheduleModel in model.showItems) {
        XZScheduleViewCell *view = [[XZScheduleViewCell alloc] initWithFrame:CGRectMake(0, y, _cardView.width, 20)];
        [view setupWithModel:scheduleModel];
        [self.itemArray addObject:view];
        [_cardView addSubview:view];
        y += view.height;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickItems:)];
        [view addGestureRecognizer:tap];
    }
    XZScheduleViewCell *view = [self.itemArray lastObject];
    view.line.hidden = YES;
    [self customLayoutSubviews];
  
    r = self.frame;
    r.size.height = CGRectGetMaxY(_cardView.frame)+10;
    self.frame = r;
}

- (void)customLayoutSubviews {
    NSInteger height = _contentLabel.font.lineHeight+1;
    [_contentLabel setFrame:CGRectMake(14, 10, self.width-28, height)];
    CGFloat y = 0;
    CGRect r = CGRectMake(14, CGRectGetMaxY(_contentLabel.frame)+10, self.width-28, y);
    [_cardView setFrame:r];
    for (XZScheduleViewCell *view in self.itemArray) {
        CGRect r = view.frame;
        r.size.width = _cardView.width;
        r.origin.y = y;
        view.frame = r;
        y += view.height;
    }
    r.size.height = y;
    [_cardView setFrame:r];
}

- (void)clickItems:(UITapGestureRecognizer *)gesture {
    XZScheduleViewCell *view = (XZScheduleViewCell *)gesture.view;
    if (self.model.clickBlock) {
        self.model.clickBlock(view.model);
    }
}

@end
