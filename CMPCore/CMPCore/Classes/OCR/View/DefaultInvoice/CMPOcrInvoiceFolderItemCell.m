//
//  CMPOcrInvoiceFolderItemCell.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import "CMPOcrInvoiceFolderItemCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
@interface CMPOcrInvoiceFolderItemCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, assign) BOOL currentSelect;

@end

@implementation CMPOcrInvoiceFolderItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.masksToBounds = true;
    self.currentSelect = NO;
    [self refreshNameLabelStyle];
}

- (void)setSelected:(BOOL)selected {
    self.currentSelect = selected;
    [self refreshNameLabelStyle];
}

- (void)setCreateFolder:(BOOL)createFolder {
    _createFolder = createFolder;
    [self refreshNameLabelStyle];
}

- (void)refreshNameLabelStyle {
    
    UIColor *blue = [UIColor cmp_specColorWithName:@"theme-bdc"];
    UIColor *gray = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    UIColor *backgroundColor = self.createFolder ? [UIColor whiteColor] : (self.currentSelect ? blue : gray);
    
    self.bgView.backgroundColor = backgroundColor;
    self.nameLabel.backgroundColor = UIColor.clearColor;
    self.nameLabel.textColor = self.createFolder ? blue : (self.currentSelect ? [UIColor whiteColor] : [[UIColor blackColor] colorWithAlphaComponent:0.8]);
    self.bgView.layer.borderColor = self.createFolder ? blue.CGColor : backgroundColor.CGColor;
    self.bgView.layer.borderWidth = self.createFolder ? 1 : 0;
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.nameLabel.text = title;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.layer.cornerRadius = self.contentView.height/2;
}

@end

@interface CMPOcrInvoiceFolderHeaderCell ()

@property (nonatomic, strong) UILabel       *titleLabel;


@end

@implementation CMPOcrInvoiceFolderHeaderCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.titleLabel];
    self.backgroundColor = UIColor.whiteColor;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(self);
    }];
    [self addSubview:self.descLabel];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.height.mas_equalTo(self);
    }];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)remakeTitleConstraint{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(self);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
        _descLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _descLabel;
}

@end
