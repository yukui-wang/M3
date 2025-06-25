//
//  CustomIconTiltleTableViewCell.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/7.
//

#import "CustomIconTiltleTableViewCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>

@implementation CustomIconTiltleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //icon
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 17, 16, 16)];
        [self.contentView addSubview:self.iconImageView];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.height.mas_equalTo(16);
            make.centerY.mas_equalTo(self);
        }];
        
        //status
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.contentView.frame.size.width - 40, 50)];
        self.statusLabel.font = [UIFont systemFontOfSize:14];
        self.statusLabel.textColor = [UIColor clearColor];
        [self.contentView addSubview:self.statusLabel];
        
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.bottom.mas_equalTo(0);
        }];
        
        //名称
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.contentView.frame.size.width - 40, 50)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        
        self.titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40);
            make.top.bottom.mas_equalTo(0);
        }];
        
        
        
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
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
