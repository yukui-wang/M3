//
//  CMPFocusMenuCell.m
//  M3
//
//  Created by Shoujian Rao on 2024/1/20.
//

#import "CMPFocusMenuCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIColor+Hex.h>
@interface CMPFocusMenuCell()



@end

@implementation CMPFocusMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (CMPThemeManager.sharedManager.isDisplayDrak) {
            self.backgroundColor = [UIColor colorWithHexString:@"#191919"];
        }else{
            self.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
        }
        
        // 创建标题Label
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12-18-2);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        // 创建图标ImageView
        self.iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.width.height.mas_equalTo(18);
            make.centerY.mas_equalTo(self.contentView);
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
