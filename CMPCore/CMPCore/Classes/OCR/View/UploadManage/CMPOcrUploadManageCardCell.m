//
//  CMPOcrUploadManageCardCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import "CMPOcrUploadManageCardCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
@implementation CMPOcrUploadManageCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textColor = UIColor.blackColor;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = @"选择报销包";
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ocr_card_default_arrow_right"]];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(16);
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        _packageNameLabel = [[UILabel alloc]init];
        _packageNameLabel.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
        _packageNameLabel.font = [UIFont systemFontOfSize:16];
        _packageNameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_packageNameLabel];
        [_packageNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.right.mas_equalTo(icon.mas_left).offset(-4);
            make.left.mas_equalTo(titleLabel.mas_right).offset(5);
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

@end
