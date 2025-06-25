//
//  CMPOcrInvoiceListCell.m
//  M3
//
//  Created by Shoujian Rao on 2022/2/17.
//

#import "CMPOcrInvoiceListCell.h"
#import <CMPLib/Masonry.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>
@interface CMPOcrInvoiceListCell ()

@property (nonatomic, strong) UIButton  *selectButton;//选择按钮

@property (nonatomic, strong) UIView    *backView;//背景容器
@property (nonatomic, strong) UIView          *separatorView;//主发票分隔线
@property (nonatomic, strong) UIImageView     *iconImage;//缩略图
@property (nonatomic, strong) UILabel         *titleLab;//名称
@property (nonatomic, strong) UILabel         *mainLab;//主 - 发票标识
@property (nonatomic, strong) UILabel         *moneyLab;//价格
@property (nonatomic, strong) UILabel         *confirmLab;//确认标识

@property (nonatomic, strong) UIStackView     *detailsStackView;//更多字段显示

@property (nonatomic, strong) MASConstraint * separatorHeightConstraint;
@property (nonatomic, strong) MASConstraint * selectBtnWidthConstraint;

@end
@implementation CMPOcrInvoiceListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self makeUI];
    }
    return self;
}

- (void)makeUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _separatorView = [[UIView alloc]init];
    _separatorView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self.contentView addSubview:_separatorView];
    
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_backView];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton setImage:[UIImage imageNamed:@"ocr_card_batch_manage_uncheck"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"ocr_card_batch_manage_checked"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_selectButton];
    
    _iconImage = [[UIImageView alloc] init];
    _iconImage.contentMode = UIViewContentModeScaleAspectFill;
    _iconImage.clipsToBounds = YES;
    _iconImage.layer.cornerRadius = 2.f;
    [_backView addSubview:_iconImage];
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
    _titleLab.text = @"发票名称";
    _titleLab.numberOfLines = 2;
    _titleLab.textColor = [UIColor blackColor];
    _titleLab.font = [UIFont systemFontOfSize:16];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    [_backView addSubview:_titleLab];
    
    _mainLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    _mainLab.text = @"主";
    _mainLab.textColor = [UIColor whiteColor];
    _mainLab.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _mainLab.font = [UIFont systemFontOfSize:10];
    _mainLab.layer.cornerRadius = 2.f;
    _mainLab.layer.masksToBounds = YES;
    _mainLab.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:_mainLab];
    
    _moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    _moneyLab.text = @"￥12100";
    _moneyLab.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    _moneyLab.textAlignment = NSTextAlignmentRight;
    _moneyLab.font = [UIFont boldSystemFontOfSize:16];
    [_backView addSubview:_moneyLab];
    
    _detailsStackView = [[UIStackView alloc]init];
    _detailsStackView.distribution = UIStackViewDistributionEqualSpacing;
    _detailsStackView.spacing = 0;
    _detailsStackView.axis = UILayoutConstraintAxisVertical;
    [_backView addSubview:_detailsStackView];
    
    _confirmLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    _confirmLab.text = @"未确认";
    _confirmLab.textColor = [UIColor cmp_specColorWithName:@"app-bgc5"];
    _confirmLab.backgroundColor = [[UIColor cmp_specColorWithName:@"warnmark-bgc"] colorWithAlphaComponent:0.1];
    _confirmLab.font = [UIFont systemFontOfSize:10];
    _confirmLab.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:_confirmLab];
}


- (void)makeConstraints{
    
    [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        self.separatorHeightConstraint = make.height.mas_equalTo(10);
    }];
    
    [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.selectBtnWidthConstraint = make.width.height.mas_equalTo(45);
        make.centerY.mas_equalTo(_iconImage.mas_centerY).offset(0);
        make.left.mas_equalTo(0);
    }];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(45);
        make.right.mas_equalTo(-14);
        make.top.equalTo(self.separatorView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(-10);
    }];
    
    [_iconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(14);
        make.width.height.mas_equalTo(50);
    }];
    
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImage.mas_top).offset(0);
        make.left.mas_equalTo(self.iconImage.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(self.moneyLab.mas_left).offset(-16);;
    }];
    
    [_mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLab.mas_right).offset(3);
        make.width.height.mas_equalTo(14);
        make.centerY.equalTo(self.titleLab).offset(0);
    }];
    
    [_moneyLab setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [_moneyLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.equalTo(self.titleLab.mas_centerY).offset(0);
        make.height.mas_equalTo(20);
    }];
    
    
    
}


- (void)selectButtonAction{
    
}

- (void)updateLastLabelConstraint:(BOOL)hide{
    NSLayoutConstraint *layoutConstraint = [self.separatorHeightConstraint valueForKey:@"layoutConstraint"];
    layoutConstraint.constant = hide?1:62;
}

@end
