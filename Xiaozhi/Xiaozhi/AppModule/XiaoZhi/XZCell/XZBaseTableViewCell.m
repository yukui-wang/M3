//
//  XZBaseTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//

#import "XZBaseTableViewCell.h"

@implementation XZBaseTableViewCell
@synthesize model = _model;
- (void)dealloc
{
    SY_RELEASE_SAFELY(_model);
    [super dealloc];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorHide = YES;
    [self setBkViewColor:UIColorFromRGB(0xf3f5f7)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
