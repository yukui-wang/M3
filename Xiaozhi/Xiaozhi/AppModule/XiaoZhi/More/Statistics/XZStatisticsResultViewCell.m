//
//  XZStatisticsResultViewCell.m
//  M3
//
//  Created by wujiansheng on 2018/2/28.
//

#import "XZStatisticsResultViewCell.h"
#import "SPConstant.h"

@interface XZStatisticsResultViewCell () {
    UIImageView *_imgView;
    UILabel *_contentLabel;
    UIImageView  *_dotImageView;
}
@end


@implementation XZStatisticsResultViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    self.model = nil;
    SY_RELEASE_SAFELY(_imgView);
    SY_RELEASE_SAFELY(_contentLabel);
    SY_RELEASE_SAFELY(_dotImageView);

    [super dealloc];
}
- (void)setup {
    [self setBkViewColor:UIColorFromRGB(0xffffff)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setSeparatorColor:UIColorFromRGB(0xdedede)];
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = XZ_IMAGE(@"xz_statistics.png");
        [self addSubview:_imgView];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = UIColorFromRGB(0x2c2c2c);
        _contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentLabel];
    }
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc] init];
        _dotImageView.image = XZ_IMAGE(@"xz_statistics_push.png");
        [self addSubview:_dotImageView];
    }
}
- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [_imgView setFrame:CGRectMake(20, self.height/2-11, 32, 32)];
    [_contentLabel setFrame:CGRectMake(74, 1, self.width-74-32, self.height-2)];
    [_dotImageView setFrame:CGRectMake(self.width-32, self.height/2-8, 16, 16)];
}

- (void)setModel:(NSDictionary *)model {
    _model = model;
    _contentLabel.text = model[@"title"];
}
@end
