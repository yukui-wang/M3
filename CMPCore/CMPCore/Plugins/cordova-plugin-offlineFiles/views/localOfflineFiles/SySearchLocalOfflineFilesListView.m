//
//  SySearchLocalOfflineFilesListView.m
//  M1Core
//
//  Created by chenquanwei on 14-3-16.
//
//

#define kStartTimePicker   1
#define kEndTimePicker     2

#import "SySearchLocalOfflineFilesListView.h"

@implementation SySearchLocalOfflineFilesListView
@synthesize searchItem = _searchItem;
@synthesize searchTableView = _searchTableView;

- (void)setup
{
    if (!_searchItem) {
        _searchItem = [[SySearchLocalOfflineFilesItem alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        _searchItem.keyTextField.returnKeyType = UIReturnKeySearch;
        _searchItem.userInteractionEnabled = YES;
        [self addSubview:_searchItem];
    }
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, self.height - 40)];
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.hidden = YES;        
        [self addSubview:_searchTableView];
    }
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)showSearchTableView
{
    _searchTableView.hidden = NO;
}

- (void)hiddenSearchTableView
{
    _searchTableView.hidden = YES;
}
- (void)customLayoutSubviews
{
    [_searchItem setFrame:CGRectMake(0, 0, self.width, 40)];
    [_searchTableView setFrame:CGRectMake(0, 40, self.width, self.height - 40)];
}
- (void)dealloc
{
    SY_RELEASE_SAFELY(_searchItem);
    SY_RELEASE_SAFELY(_searchTableView);
    [super dealloc];
}

@end
