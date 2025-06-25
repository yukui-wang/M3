//
//  XZLeaveTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/2.
//

#import "XZLeaveTableViewCell.h"
#import "XZLeaveModel.h"
#import "XZLeaveItem.h"
@interface XZLeaveTableViewCell (){
    UIView *_bkView;
    UILabel *_topView;
    XZLeaveItem *_departItem;
    XZLeaveItem *_nameItem;
    XZLeaveItem *_postItem;
    XZLeaveItem *_beginTimeItem;
    XZLeaveItem *_endTimeItem;
    XZLeaveItem *_typeItem;
    XZLeaveItem *_reasonItem;
    XZLeaveItem *_numberItem;
    BOOL _selectBegin;
}
@property(nonatomic, retain)UIButton *sendButton;
@property(nonatomic, retain)UIButton *cancelButton;
@property(nonatomic, retain)UIButton *modifyButton;
@end

@implementation XZLeaveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc {

    SY_RELEASE_SAFELY(_bkView);
    SY_RELEASE_SAFELY(_topView);
    SY_RELEASE_SAFELY(_departItem);
    SY_RELEASE_SAFELY(_nameItem);
    SY_RELEASE_SAFELY(_postItem);
    SY_RELEASE_SAFELY(_beginTimeItem);
    SY_RELEASE_SAFELY(_endTimeItem);
    SY_RELEASE_SAFELY(_typeItem);
    SY_RELEASE_SAFELY(_reasonItem);
    SY_RELEASE_SAFELY(_numberItem);
    self.sendButton = nil;
    self.cancelButton = nil;
    self.modifyButton = nil;

    [super dealloc];
}

- (void)setup {
    [super setup];
    if(!_bkView) {
        _bkView = [[UIView alloc] init];
        _bkView.layer.cornerRadius = 12;
        _bkView.layer.masksToBounds = YES;
        _bkView.layer.borderWidth = 1;
        _bkView.layer.borderColor = UIColorFromRGB(0x9ecafb).CGColor;
        _bkView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bkView];
    }
    if (!_topView) {
        _topView = [[UILabel alloc] init];
        _topView.font = FONTSYS(16);
        _topView.textColor = [UIColor whiteColor];
        _topView.backgroundColor = UIColorFromRGB(0x3AADFB);
        _topView.text = @"请假单";
        _topView.textAlignment = NSTextAlignmentCenter;
        [_bkView addSubview:_topView];

    }
    if (!_departItem) {
        _departItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_departItem];
    }
    if (!_nameItem) {
        _nameItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_nameItem];
    }
    if (!_postItem) {
        _postItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_postItem];
    }
    if (!_beginTimeItem) {
        _beginTimeItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_beginTimeItem];
    }
    if (!_endTimeItem) {
        _endTimeItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_endTimeItem];
    }
    if (!_typeItem) {
        _typeItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_typeItem];
    }
    if (!_reasonItem) {
        _reasonItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_reasonItem];
    }
    if (!_numberItem) {
        _numberItem = [[XZLeaveItem alloc] init];
        [_bkView addSubview:_numberItem];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)Title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:Title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 12;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColorFromRGB(0xbcbac1).CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    return button;
}

- (void)setModel:(XZLeaveModel *)model{
    [super setModel:model];
    [_departItem showTarget:@"部门" value:model.department valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_nameItem showTarget:@"姓名" value:model.userName valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_postItem showTarget:@"岗位" value:model.post valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_beginTimeItem showTarget:@"起始日期" value:model.startTime valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_endTimeItem showTarget:@"截止日期" value:model.endTime valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_typeItem showTarget:@"请假类别" value:model.leaveType valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_reasonItem showTarget:@"具体事由" value:model.leaveReason valueLineBreakMode:NSLineBreakByWordWrapping];
    [_numberItem showTarget:@"统计天数" value:model.timeAttStr valueLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    if (model.canOperate) {
        if (!self.sendButton) {
            self.sendButton = [self buttonWithTitle:@"发送"];
            self.sendButton.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
            [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.sendButton setBackgroundColor:UIColorFromRGB(0x3AADFB)];
            [self.sendButton addTarget:self action:@selector(sendLeave:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.sendButton];
        }
        if (!self.cancelButton) {
            self.cancelButton = [self buttonWithTitle:@"取消"];
            [self.cancelButton addTarget:self action:@selector(cancelLeave:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.cancelButton];
        }
        if (!self.modifyButton) {
            self.modifyButton = [self buttonWithTitle:@"修改"];
            [self.modifyButton addTarget:self action:@selector(modifyLeave:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.modifyButton];
        }
    }
    else {
        [self removeButtons];
    }
    
    [self customLayoutSubviewsFrame:self.frame];
}


- (void)customLayoutSubviewsFrame:(CGRect)frame {
    
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    [_bkView setFrame:CGRectMake(12, 0, model.scellWidth-24, model.canOperate?self.height-kXZCellSpace-42:self.height-kXZCellSpace)];
    [_topView setFrame:CGRectMake(0, 0, _bkView.width, 30)];

    CGFloat  y = 40;
    [_departItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _departItem.height+model.spacing;
   
    [_nameItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _nameItem.height+model.spacing;
    
    [_postItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _postItem.height+model.spacing;
    
    [_beginTimeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _beginTimeItem.height+model.spacing;
    
    [_endTimeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _endTimeItem.height+model.spacing;
    
    [_typeItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    y += _typeItem.height+model.spacing;
    
    [_reasonItem setFrame:CGRectMake(0, y, _bkView.width, model.reasonHeight)];
    y += _reasonItem.height+model.spacing;
    
    [_numberItem setFrame:CGRectMake(0, y, _bkView.width, model.defaultHeight)];
    
    y = CGRectGetMaxY(_bkView.frame)+10;
    [self.sendButton setFrame:CGRectMake(12, y, 70, 32)];
    [self.cancelButton setFrame:CGRectMake(CGRectGetMaxX(self.sendButton.frame)+10, y, 70, 32)];
    [self.modifyButton setFrame:CGRectMake(CGRectGetMaxX(self.cancelButton.frame)+10, y, 70, 32)];
}

- (void)removeButtons{
    [self.sendButton removeFromSuperview];
    self.sendButton = nil;
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;
    [self.modifyButton removeFromSuperview];
    self.modifyButton = nil;
}
- (void)sendLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model sendLeave];
   
    [self removeButtons];
}

- (void)cancelLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model cancelLeave];
   
    [self removeButtons];
}

- (void)modifyLeave:(UIButton *)sender {
    XZLeaveModel *model = (XZLeaveModel *)self.model;
    model.clickTitle = sender.titleLabel.text;
    [model modifyLeave];
   
    [self removeButtons];
}
@end


