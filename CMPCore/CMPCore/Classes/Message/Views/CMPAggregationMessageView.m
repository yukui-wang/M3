//
//  CMPAggregationMessageView.m
//  M3
//
//  Created by CRMO on 2018/1/8.
//

#import "CMPAggregationMessageView.h"

@implementation CMPAggregationMessageView

-(void)dealloc
{
    SY_RELEASE_SAFELY(_tableView);
    [super dealloc];
}

- (void)setup
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf4f4f4);
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
}

- (void)customLayoutSubviews
{
    [_tableView setFrame:self.bounds];
    UIView *nothingView = [self viewWithTag:1000001];
    nothingView.frame = _tableView.frame;
}

@end
