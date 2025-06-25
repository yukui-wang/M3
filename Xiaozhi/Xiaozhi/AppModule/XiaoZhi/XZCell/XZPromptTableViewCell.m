//
//  XZPromptTableViewCell.m
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//

#import "XZPromptTableViewCell.h"
#import "XZPromptModel.h"
@interface XZPromptTableViewCell() {
    UILabel *_promptLabel;
    UIView *_promptBG;
}
@end
@implementation XZPromptTableViewCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_promptLabel);
    SY_RELEASE_SAFELY(_promptBG);
    [super dealloc];
}

- (void)setup {
    [super setup];
   
    if (!_promptBG) {
        _promptBG = [[UIView alloc] init];
        _promptBG.backgroundColor = UIColorFromRGB(0xbec1c3);
        _promptBG.layer.cornerRadius = 8;
        [self addSubview:_promptBG];
        
    }
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = [UIFont systemFontOfSize:14];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.numberOfLines = 0;
        [_promptBG addSubview:_promptLabel];
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame{
    XZPromptModel *model = (XZPromptModel *)self.model;
    [_promptLabel setFrame:CGRectMake(10, 4, model.lableWidht, model.lableheight)];
    [_promptBG setFrame:CGRectMake((self.width- model.lableWidht)/2-10, 0, model.lableWidht+20, model.lableheight+8)];
}

- (void)setModel:(XZPromptModel *)model {
    [super setModel:model];
    _promptLabel.text = model.prompt;
    [self customLayoutSubviewsFrame:self.bounds];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


@end
