//
//  CMPAreaCodeCell.m
//  M3
//
//  Created by zy on 2022/2/19.
//

#import "CMPAreaCodeCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPAreaCodeCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;


@end

@implementation CMPAreaCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setTitle:(NSString *)title desc:(NSString *)desc {
    self.titleLabel.text = title;
    self.descLabel.text = desc;
}

- (void)setupViews {
//    self.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(15, 0, 200, self.contentView.height);
    self.descLabel.frame = CGRectMake(self.contentView.width - 100 - 15, 0, 100, self.contentView.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FONTSYS(16);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];//[UIColor blackColor];
        _titleLabel.text = @"中华人民共和国";
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = FONTSYS(16);
        _descLabel.textAlignment = NSTextAlignmentRight;
        _descLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _descLabel.text = @"+86";
    }
    return _descLabel;
}

@end


@interface CMPAreaCodeHeader ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CMPAreaCodeHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
//    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F9FAFB"];
    self.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    self.contentView.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(15, 0, 200, self.contentView.height);
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FONTSYS(12);
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _titleLabel.text = SY_STRING(@"login_sms_area_code_hot_title");
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

@end
