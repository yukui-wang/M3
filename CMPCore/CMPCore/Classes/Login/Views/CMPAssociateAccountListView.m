//
//  CMPAssociateAccountListView.m
//  M3
//
//  Created by CRMO on 2018/6/11.
//

#import "CMPAssociateAccountListView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/SyNothingView.h>
#import <CMPLib/Masonry.h>

@interface CMPAssociateAccountListView()
@property(nonatomic ,strong)SyNothingView *nothingView;
@end

@implementation CMPAssociateAccountListView

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
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        [_tableView setBackgroundColor:[UIColor cmp_colorWithName:@"p-bg"]];
    }
    return _tableView;
}

- (void)showNothingView:(BOOL)show {
    if (show) {
        if (!_nothingView) {
            _nothingView = [[SyNothingView alloc] init];
        }
        [_nothingView removeFromSuperview];
        [self addSubview:_nothingView];
        [_nothingView customLayoutSubviews];
    }
    else {
        [_nothingView removeFromSuperview];
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.nothingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(self);
    }];
    [super updateConstraints];
}

@end
