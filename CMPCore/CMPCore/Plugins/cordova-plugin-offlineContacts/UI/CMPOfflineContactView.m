//
//  CMPOfflineContactView.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/3.
//
//

#import "CMPOfflineContactView.h"
#import <CMPLib/Masonry.h>

@interface CMPOfflineContactView()
@property (strong, nonatomic) UIView *whiteCoverView;
@property (copy, nonatomic) void(^tapRetryButtonBlock)(void);
@end

@implementation CMPOfflineContactView

- (void)setup
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc]init];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = FONTSYS(14);
        _infoLabel.backgroundColor = UIColorFromRGB(0x3aadfb);
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.hidden = YES;
        [self addSubview:_infoLabel];
    }
    if (!_errorLabel) {
        _errorLabel = [[UIView alloc] init];
        _errorLabel.backgroundColor = UIColorFromRGB(0xFB823A);
        _errorLabel.alpha = 0.8;
        _errorLabel.hidden = YES;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 11, 160, 14)];
        [_errorLabel addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = FONTSYS(14);
        label.textColor = [UIColor whiteColor];
        label.text = SY_STRING(@"contacts_downloadFail");
        [label sizeToFit];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 84 - 10, 6, 84, 25)];
        [button setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
        NSAttributedString *buttonTitle = [[NSAttributedString alloc]
                                           initWithString:SY_STRING(@"contacts_retry")
                                           attributes:@{NSFontAttributeName : FONTSYS(14),
                                                        NSForegroundColorAttributeName : UIColorFromRGB(0xE97936)}];
        [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        [button.layer setCornerRadius:6];
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(tapRetryButton) forControlEvents:UIControlEventTouchUpInside];
        [_errorLabel addSubview:button];
        [self addSubview:_errorLabel];
    }
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableview.backgroundColor = UIColorFromRGB(0xf4f4f4);
        _tableview.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        [self addSubview:_tableview];
    }
    if (!_spellBar) {
        _spellBar = [[CMPSpellBar alloc]initWithFrame:CGRectMake(self.width - 40, 100, 40, self.height - 140)];
        [self addSubview:_spellBar];
    }
}

- (void)customLayoutSubviews
{
    CGFloat y = 0;
    _infoLabel.frame = CGRectMake(0, y, self.width, 36);
    _errorLabel.frame = CGRectMake(0, y, self.width, 36);
    y = (_infoLabel.hidden && _errorLabel.hidden) ? 0 : 36;
    
    _tableview.frame = CGRectMake(0, y, self.width, self.height-y);
    _spellBar.frame = CGRectMake(self.width - 20, 20+y+20, 20, self.height - 40-20);
    
    if (!_infoLabel.hidden || !_errorLabel.hidden) {
        [_tableview setContentOffset:CGPointMake(0, 40) animated:NO];
    }
}

- (void)hideTableView {
    [self addSubview:self.whiteCoverView];
    [self.whiteCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)showTableView {
    [self.whiteCoverView removeFromSuperview];
}

- (UIView *)whiteCoverView {
    if (!_whiteCoverView) {
        _whiteCoverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_whiteCoverView setBackgroundColor:[UIColor whiteColor]];
    }
    return _whiteCoverView;
}

- (void)showInfoLabel:(NSString *)content {
    self.infoLabel.hidden = NO;
    self.errorLabel.hidden = YES;
    [self.infoLabel setText:content];
    [self customLayoutSubviews];
}

- (void)showErrorLabelClick:(void(^)(void))click {
    self.infoLabel.hidden = YES;
    self.errorLabel.hidden = NO;
    _tapRetryButtonBlock = click;
    [self customLayoutSubviews];
}

- (void)hideLabels {
    self.infoLabel.hidden = YES;
    self.errorLabel.hidden = YES;
    [self customLayoutSubviews];
}

- (void)tapRetryButton {
    if (_tapRetryButtonBlock) {
        _tapRetryButtonBlock();
    }
}

@end
