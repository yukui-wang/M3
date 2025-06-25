//
//  CMPSelectMultipleContactView.m
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import "CMPSelectMultipleContactView.h"
#import <CMPLib/CMPThemeManager.h>


@implementation CMPSelectMultipleContactView

-(void)dealloc
{
	SY_RELEASE_SAFELY(_tableView);
	[super dealloc];
}

- (void)setup
{
	if (!_tableView) {
		_tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
		_tableView.backgroundColor = [UIColor cmp_colorWithName:@"gray-bgc"];
		_tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.showsHorizontalScrollIndicator = NO;
//        _tableView.tableFooterView = UIView.new;
        
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
		[self addSubview:_tableView];
	}
}

- (void)customLayoutSubviews
{
    CGRect frame = self.bounds;
    frame.size.height = frame.size.height;
    frame.origin.y = 0;
	[_tableView setFrame:frame];
}

@end
