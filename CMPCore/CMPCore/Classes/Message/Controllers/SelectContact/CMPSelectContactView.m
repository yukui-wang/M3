//
//  CMPSelectContactView.m
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import "CMPSelectContactView.h"
#import <CMPLib/CMPThemeManager.h>


@implementation CMPSelectContactView

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
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
		[self addSubview:_tableView];
	}
}

- (void)customLayoutSubviews
{
	[_tableView setFrame:self.bounds];
}

@end
