//
//  XZLeaveCard.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/11.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZLeaveCard.h"

#import "XZLeaveModel.h"


@interface XZLeaveCardItem : XZBaseView {
    UILabel *_targetLable;
    UILabel *_valueLable;
}
@end


@implementation XZLeaveCardItem

- (void)setup {
    if (!_targetLable) {
        _targetLable = [[UILabel alloc] init];
        [_targetLable setFont:FONTSYS(14)];
        [_targetLable setTextColor:UIColorFromRGB(0x999999)];

        [self addSubview:_targetLable];
    }
    if (!_valueLable) {
        _valueLable = [[UILabel alloc] init];
        _valueLable.numberOfLines = 0;
        [_valueLable setFont:FONTSYS(14)];
        [_valueLable setTextColor:[UIColor blackColor]];

        [self addSubview:_valueLable];
    }
}

- (void)customLayoutSubviews {
    NSInteger height = _targetLable.font.lineHeight+1;
    [_targetLable setFrame:CGRectMake(14, 0, 60, height)];
    [_valueLable setFrame:CGRectMake(80, 0, self.width-94,self.height)];
}

- (void)showTarget:(NSString *)target value:(id)value valueLineBreakMode:(NSLineBreakMode)mode {
    _targetLable.text = target;
    if ([value isKindOfClass:[NSString class]]) {
        _valueLable.text = value;
        _valueLable.lineBreakMode = mode;
    }
    else {
        _valueLable.attributedText = value;
    }
}

@end

@interface XZLeaveCard (){
    UIView *_bkView;
    UILabel *_topView;
    XZLeaveCardItem *_beginTimeItem;
    XZLeaveCardItem *_endTimeItem;
    XZLeaveCardItem *_typeItem;
    XZLeaveCardItem *_reasonItem;
    XZLeaveCardItem *_numberItem;
    BOOL _selectBegin;
}
@property(nonatomic, strong)XZLeaveModel *model;

@end

@implementation XZLeaveCard


- (void)setup {
    [super setup];
    if(!_bkView) {
        _bkView = [[UIView alloc] init];
        _bkView.layer.cornerRadius = 10;
        _bkView.layer.masksToBounds = YES;
        _bkView.layer.borderWidth = 1;
        _bkView.layer.borderColor = UIColorFromRGB(0x0C002A).CGColor;
        _bkView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bkView];
    }
    if (!_topView) {
        _topView = [[UILabel alloc] init];
        _topView.font = FONTSYS(14);
        _topView.textColor = [UIColor whiteColor];
        _topView.backgroundColor = UIColorFromRGB(0x297FFB);
        _topView.text = @"请假单";
        _topView.textAlignment = NSTextAlignmentCenter;
        [_bkView addSubview:_topView];
    }

    if (!_beginTimeItem) {
        _beginTimeItem = [[XZLeaveCardItem alloc] init];
        [_bkView addSubview:_beginTimeItem];
    }
    if (!_endTimeItem) {
        _endTimeItem = [[XZLeaveCardItem alloc] init];
        [_bkView addSubview:_endTimeItem];
    }
    if (!_typeItem) {
        _typeItem = [[XZLeaveCardItem alloc] init];
        [_bkView addSubview:_typeItem];
    }
    if (!_reasonItem) {
        _reasonItem = [[XZLeaveCardItem alloc] init];
        [_bkView addSubview:_reasonItem];
    }
    if (!_numberItem) {
        _numberItem = [[XZLeaveCardItem alloc] init];
        [_bkView addSubview:_numberItem];
    }
}

- (void)customLayoutSubviews {
    
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    [_bkView setFrame:CGRectMake(14, 0, self.width-28, self.height)];
    [_topView setFrame:CGRectMake(0, 0, _bkView.width, 40)];
    
    CGFloat  y = 54;
    [_beginTimeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _beginTimeItem.height+model.spacing;
    
    [_endTimeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _endTimeItem.height+model.spacing;
    
    [_typeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _typeItem.height+model.spacing;
    
    [_reasonItem setFrame:CGRectMake(0, y, _bkView.width, model.reasonHeight)];
    y += _reasonItem.height+model.spacing;
    
    [_numberItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
}

- (void)sendLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model sendLeave];
}

- (void)cancelLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model cancelLeave];
}

- (void)modifyLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model modifyLeave];
}

- (void)setupWithModel:(XZLeaveModel *)model {
    self.model = model;
    [_beginTimeItem showTarget:@"起始日期" value:model.startTime valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_endTimeItem showTarget:@"截止日期" value:model.endTime valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_typeItem showTarget:@"请假类别" value:model.leaveType valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_reasonItem showTarget:@"具体事由" value:model.leaveReason valueLineBreakMode:NSLineBreakByWordWrapping];
    [_numberItem showTarget:@"统计天数" value:model.timeAttStr valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self customLayoutSubviews];
}

@end
