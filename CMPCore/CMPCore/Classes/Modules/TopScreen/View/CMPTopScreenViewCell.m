//
//  CMPTopScreenViewCell.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import "CMPTopScreenViewCell.h"
#import <CMPLib/Masonry.h>

@interface CMPTopScreenViewCell ()

@end
@implementation CMPTopScreenViewCell

//height 56
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        
        //mask
        UIView *mask = [[UIView alloc]initWithFrame:CGRectMake(0, 6, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        mask.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.2];
        mask.layer.cornerRadius = 6.f;
        [self.contentView addSubview:mask];
        [mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(6);
            make.bottom.mas_equalTo(-6);
        }];
        
        // 图标
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, (self.contentView.frame.size.height - 32)/2.0, 32, 32)];
//        self.iconImageView.backgroundColor = UIColor.greenColor;
        self.iconImageView.layer.cornerRadius = 16.f;
        self.iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconImageView];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.width.height.mas_equalTo(32);
            make.centerY.equalTo(self);
        }];
        
        // 关闭按钮
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"top_screen_close"] forState:(UIControlStateNormal)];
//        self.closeButton.frame = CGRectMake(self.contentView.frame.size.width - 44, 0, 44, 44);
        [self.contentView addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.width.height.mas_equalTo(44);
            make.centerY.equalTo(self);
        }];
        [self.closeButton addTarget:self action:@selector(closeBtnBlock:) forControlEvents:(UIControlEventTouchUpInside)];
        
        // 标题
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, (self.contentView.frame.size.height - 20)/2.0, self.contentView.frame.size.width - 54-60, 20)];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        self.nameLabel.textColor = UIColor.whiteColor;
        [self.contentView addSubview:self.nameLabel];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(54);
            make.right.mas_equalTo(self.closeButton.mas_left);
            make.centerY.equalTo(self);
        }];
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)closeBtnBlock:(id)sender{
    if (_closeBtnClickBlock) {
        _closeBtnClickBlock();
    }
}

@end
