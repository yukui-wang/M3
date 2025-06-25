//
//  CMPQuickRouterItemView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/3/10.
//

#import "CMPQuickRouterItemView.h"

@implementation CMPQuickRouterItemView

-(void)setup
{
    [super setup];
    
    UIView *contentV = [self viewWithTag:111];
    if (contentV) {
        [contentV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.offset(2);
            make.bottom.right.offset(-2);
        }];
    }
    self.iconBgView.hidden = YES;
    self.titleLabel.numberOfLines = 1;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.left.mas_greaterThanOrEqualTo(20+5);
        make.right.mas_lessThanOrEqualTo(-(20+5));
    }];
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.right.equalTo(self.titleLabel.mas_left).offset(-5);
    }];
    [self.badgeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.equalTo(self.titleLabel.mas_right).offset(5);
    }];
}

-(void)setModel:(CMPAppModel *)model
{
    [super setModel:model];
    if (model.unread) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.right.mas_lessThanOrEqualTo(-(20+5));
        }];
    }else{
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(12);
            make.right.mas_lessThanOrEqualTo(-0);
        }];
    }
}

@end
