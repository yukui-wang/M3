//
//  CMPRCGroupNotificationView.m
//  CMPCore
//
//  Created by CRMO on 2017/8/7.
//
//

#import "CMPRCGroupNotificationView.h"
#import <CMPLib/SyNothingView.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPRCGroupNotificationView()

@property(nonatomic ,strong)SyNothingView *nothingView;

@end

@implementation CMPRCGroupNotificationView

- (void)dealloc {
    SY_RELEASE_SAFELY(_nothingView);
    SY_RELEASE_SAFELY(_tableView);
    [super dealloc];
}

- (void)setup {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor cmp_colorWithName:@"liactive-bgc"];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
}

- (void)customLayoutSubviews {
    [_tableView setFrame:self.bounds];
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
        SY_RELEASE_SAFELY(_nothingView);
    }
}

@end
