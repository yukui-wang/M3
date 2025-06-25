//
//  CMPSelectGroupMultipleView.m
//  M3
//
//  Created by Shoujian Rao on 2023/9/4.
//

#import "CMPSelectGroupMultipleView.h"

@implementation CMPSelectGroupMultipleView

- (void)setup
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor cmp_colorWithName:@"gray-bgc"];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_tableView];
    }
}

- (void)customLayoutSubviews
{
    [_tableView setFrame:self.bounds];
//    CGRect frame = self.bounds;
//    frame.size.height = frame.size.height;
//    frame.origin.y = 0;
//    [_tableView setFrame:frame];
}

@end
