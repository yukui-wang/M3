//
//  XZLeaveErrorCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/9.
//

#import "XZLeaveErrorCell.h"
#import "XZLeaveErrorModel.h"

@interface XZLeaveErrorCell() {
    UILabel *_contentLabel;
}

@property(nonatomic, retain)UIButton *showButton;
@property(nonatomic, retain)UIButton *cancelButton;

@end

@implementation XZLeaveErrorCell

- (void)dealloc {
    self.showButton = nil;
    self.cancelButton = nil;
    SY_RELEASE_SAFELY(_contentLabel);
    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = FONTSYS(16);
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 0;
        [_contentBGView addSubview:_contentLabel];
    }
}
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZLeaveErrorModel *model = (XZLeaveErrorModel *)self.model;
    [_iconView setFrame:CGRectMake(12, 0, 36, 36)];
    [_contentBGView setFrame:CGRectMake(54, 0, model.lableWidth +31, model.canOperate?self.height-kXZCellSpace-40: self.height-kXZCellSpace)];
    _iconView.image = XZ_IMAGE(@"xz_icon_cell.png");
    _contentBGView.image = [XZ_IMAGE(@"xz_chat_robot.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 24, 19, 18)];
    [_contentLabel setFrame:CGRectMake(18, 10, model.lableWidth, _contentBGView.height-20)];
    [self.showButton setFrame:CGRectMake(60, CGRectGetMaxY(_contentBGView.frame)+10, 70, 32)];
    [self.cancelButton setFrame:CGRectMake(CGRectGetMaxX(self.showButton.frame)+10, CGRectGetMaxY(_contentBGView.frame)+10, 70, 32)];

}

- (void)setModel:(XZLeaveErrorModel *)model {
    [super setModel:model];
    [_contentLabel setText:model.contentInfo];
    if (model.canOperate) {
        if (!self.showButton) {
            self.showButton = [self buttonWithTitle:model.buttonTitle];
            self.showButton.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
            [self.showButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.showButton setBackgroundColor:UIColorFromRGB(0x006ff1)];
            [self.showButton addTarget:self action:@selector(showLeave:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.showButton];
        }
        if (!self.cancelButton) {
            self.cancelButton = [self buttonWithTitle:@"取消"];
            [self.cancelButton addTarget:self action:@selector(cancelLeave:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.cancelButton];
        }
    }
    else {
        [self removeButtons];
    }
    [self customLayoutSubviewsFrame:self.frame];
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

- (void)removeButtons{
    [self.showButton removeFromSuperview];
    self.showButton = nil;
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;

}

- (void)showLeave:(id)sender {
    XZLeaveErrorModel *model = (XZLeaveErrorModel *)self.model;
    model.showClickTitle = YES;
    [model showLeave];
    [self removeButtons];
}
- (void)cancelLeave:(id)sender {
    XZLeaveErrorModel *model = (XZLeaveErrorModel *)self.model;
    model.showClickTitle = YES;
    [model cancel];
    [self removeButtons];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
