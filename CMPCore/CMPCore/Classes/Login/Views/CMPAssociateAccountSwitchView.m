//
//  CMPAssociateAccountSwitchView.m
//  M3
//
//  Created by CRMO on 2018/6/19.
//

#import "CMPAssociateAccountSwitchView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/SyNothingView.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPAssociateAccountSwitchView()
@property(nonatomic ,strong)SyNothingView *nothingView;
@end

@implementation CMPAssociateAccountSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        [_tableView setBackgroundColor:[UIColor cmp_colorWithName:@"p-bg"]];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return _tableView;
}

- (void)showNothingView:(BOOL)show {
    if (show) {
        if (!_nothingView) {
            _nothingView = [[SyNothingView alloc] initWithFrame:self.bounds];
        }
        [_nothingView removeFromSuperview];
        [self addSubview:_nothingView];
    }
    else {
        [_nothingView removeFromSuperview];
    }
}

@end
