//
//  CMPOcrPickPackageCell.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import "CMPOcrPickPackageCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPOcrPickPackageCell()

@property (nonatomic, strong) UIImageView *checkIgv;
@property(nonatomic, strong) MASConstraint * lastLabelWidthConstraint;

@end

@implementation CMPOcrPickPackageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _label = [[UILabel alloc]init];
        _label.textColor = [UIColor cmp_specColorWithName:@"main-fc"];
        _label.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.equalTo(self).offset(0);
        }];
        [_label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        _lastLabel = [[UILabel alloc]init];
        _lastLabel.textColor = [UIColor cmp_specColorWithName:@"sup-fc1"];
        _lastLabel.font = [UIFont systemFontOfSize:16];
        _lastLabel.text = @"(上一次)";
        [self.contentView addSubview:_lastLabel];
        [_lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_label.mas_right).offset(2);
            make.centerY.equalTo(self).offset(0);
            self.lastLabelWidthConstraint = make.width.mas_equalTo(62);
            make.right.mas_lessThanOrEqualTo(-60);
        }];
        
        _checkIgv = [UIImageView new];
        [self.contentView addSubview:_checkIgv];
        [_checkIgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(0);
            make.right.mas_equalTo(-20);
            make.width.height.mas_equalTo(20);
        }];
        _checkIgv.image = [UIImage imageNamed:@"ocr_card_batch_manage_uncheck"];
    }
    return self;
}

- (void)selectRow:(BOOL)selected{
    if (selected) {
        _checkIgv.image = [UIImage imageNamed:@"ocr_card_batch_manage_checked"];
    }else{
        _checkIgv.image = [UIImage imageNamed:@"ocr_card_batch_manage_uncheck"];
    }
}
    
- (void)updateLastLabelConstraint:(BOOL)hide{
    NSLayoutConstraint *layoutConstraint = [self.lastLabelWidthConstraint valueForKey:@"layoutConstraint"];
    layoutConstraint.constant = hide?1:62;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
