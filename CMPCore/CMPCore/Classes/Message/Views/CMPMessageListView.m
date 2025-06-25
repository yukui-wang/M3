//
//  CMPMessageListView.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/26.
//
//

#import "CMPMessageListView.h"
#import "CMPQuickRouterView.h"
#import <CMPLib/CMPServerVersionUtils.h>
@interface CMPMessageListView () {
    CMPQuickRouterView *_quickRouterView;
}
@end


@implementation CMPMessageListView

-(void)dealloc
{
    SY_RELEASE_SAFELY(_tableView);
    _quickRouterView = nil;
    [super dealloc];
}

- (void)setup
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //_tableView.separatorColor = UIColorFromRGB(0xe7e7e7);
        [self addSubview:_tableView];
    }
}

- (void)customLayoutSubviews
{
    if(self.lockFrame) {
        return;
    }
    [_tableView setFrame:self.bounds];
    UIView *nothingView = [self viewWithTag:1000001];
    nothingView.frame = _tableView.frame;
}

-(void)refreshQuickRouterView
{
    if (![CMPServerVersionUtils serverIsLaterV8_2]) return;
    if (!_quickRouterView) {
        _quickRouterView = [[CMPQuickRouterView alloc] initWithBundleTableView:_tableView frame:CGRectMake(0, 0, self.width, 46)];
    }
    if (!_quickRouterView.viewController) _quickRouterView.viewController = _viewController;
    [_quickRouterView refreshData];
}

@end
