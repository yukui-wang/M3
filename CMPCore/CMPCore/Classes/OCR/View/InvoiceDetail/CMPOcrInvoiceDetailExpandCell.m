//
//  CMPOcrInvoiceDetailExpandCell.m
//  M3
//
//  Created by Shoujian Rao on 2022/1/13.
//

#import "CMPOcrInvoiceDetailExpandCell.h"
#import <CMPLib/Masonry.h>
#import "CustomDefine.h"
#import <CMPLib/CMPThemeManager.h>
@interface CMPOcrInvoiceDetailExpandCell()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) MASConstraint * offsetYConstraint;

@end

@implementation CMPOcrInvoiceDetailExpandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIStackView *stack = [[UIStackView alloc]init];
        [self.contentView addSubview:stack];
        [stack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            self.offsetYConstraint = make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(20);
            make.top.offset((56-20)/2);
            make.bottom.offset(-(56-20)/2);
        }];
        stack.axis = UILayoutConstraintAxisHorizontal;
        
        self.label = [[UILabel alloc]init];
        self.label.text = @"更多";
        self.label.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];//desc-fc
        self.label.font = [UIFont systemFontOfSize:14];
        [stack addArrangedSubview:self.label];
        
        self.icon = [UIImageView new];
        self.icon.contentMode = UIViewContentModeScaleAspectFit;
        self.icon.image = [UIImage imageNamed:@"ocr_card_unexpand"];
        [stack addArrangedSubview:self.icon];
        
    }
    return self;
}
- (void)updateOffsetYConstraint:(CGFloat)offsetY{
    NSLayoutConstraint *layoutConstraint = [self.offsetYConstraint valueForKey:@"layoutConstraint"];
    layoutConstraint.constant = offsetY;
}

- (void)setExpand:(BOOL)expand{
    _expand = expand;
    self.label.text = _expand?@"收起":@"更多";
    self.icon.image = _expand?[UIImage imageNamed:@"ocr_card_expanded"]:[UIImage imageNamed:@"ocr_card_unexpand"];
}

@end
