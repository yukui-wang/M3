//
//  CMPOcrInvoiceSelectedAlertCell.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

#import "CMPOcrInvoiceSelectedAlertCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/CMPThemeManager.h>

@interface CMPOcrInvoiceSelectedAlertItemCell ()

@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UILabel *money;

@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UIButton *deleteButton;

@end

@implementation CMPOcrInvoiceSelectedAlertItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setImage:[UIImage imageNamed:@"ocr_card_circle_close"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.nameLabel.text = @"未知";
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.nameLabel];

    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.dateLabel.text = @"2021年11月29日";
    self.dateLabel.textColor = [UIColor grayColor];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.dateLabel];

    self.money = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.money.text = @"￥0";
    self.money.textColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    self.money.textAlignment = NSTextAlignmentRight;
    self.money.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.money];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(35);
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(9);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
    }];
    
    [self.money mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
        make.leading.mas_equalTo(self.money.mas_trailing).offset(5);
    }];

}

- (void)setItem:(CMPOcrInvoiceItemModel *)item {
    _item = item;
    self.nameLabel.text = item.modelName?:@"未知";
    self.dateLabel.text = item.createDateDisplay;
    self.money.text = [NSString stringWithFormat:@"¥%@",item.total];
    self.deleteButton.hidden = item.mainDeputyTag == 2;
}

- (void)deleteAction {
    if (RES_OK(@selector(invoiceSelectedAlertCellDelete:))) {
        [self.delegate invoiceSelectedAlertCellDelete:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
