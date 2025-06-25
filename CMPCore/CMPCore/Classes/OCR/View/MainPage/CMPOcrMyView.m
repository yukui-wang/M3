//
//  CMPOcrMyView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/12/29.
//

#import "CMPOcrMyView.h"
@implementation CMPOcrMyView

- (void)layoutSubviews{
    [super layoutSubviews];
    _cardCategoryView.viewController = self.viewController;
}

- (void)setup{

    UIView *headerView = UIView.new;
//    headerView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    headerView.frame = CGRectMake(0, 0, self.bounds.size.width, 85);
    _cardCategoryView = [[CMPOcrCardCategoryView alloc] initWithHeaderView:headerView];
    _cardCategoryView.fromPage = 1;
    _cardCategoryView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [_cardCategoryView setMainTableBackgroundColor:[UIColor cmp_specColorWithName:@"p-bg"]];
    [self addSubview:_cardCategoryView];
    
    [_cardCategoryView setHeaderOffset:85];
    
    [_cardCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.offset(-50);
    }];
    
    UILabel *aLb = [[UILabel alloc] init];
    aLb.font = [UIFont systemFontOfSize:16];
    aLb.textColor = [UIColor blackColor];
    aLb.text = @"报销历史";
    [aLb sizeToFit];
    [self addSubview:aLb];
    [aLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15);
        make.left.offset(20);
    }];
}

@end
