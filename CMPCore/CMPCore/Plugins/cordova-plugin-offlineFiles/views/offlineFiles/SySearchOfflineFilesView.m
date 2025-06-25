//
//  SySearchOfflineFilesView.m
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//
#define kStartTimePicker   1
#define kEndTimePicker     2
#import "SySearchOfflineFilesView.h"

@implementation SySearchOfflineFilesView

@synthesize searchItem = _searchItem;
@synthesize searchTableView = _searchTableView;
@synthesize deleteButton = _deleteButton;
@synthesize isLongPress = _isLongPress;

- (void)setup
{
    if (!_searchItem) {
        _searchItem = [[SySearchOfflineFilesItem alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _searchItem.keyTextField.returnKeyType = UIReturnKeySearch;
        _searchItem.userInteractionEnabled = YES;
        
        [self addSubview:_searchItem];
    }
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.height - 44)];
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.hidden = YES;
        [self addSubview:_searchTableView];
    }
    
   
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setImage:[UIImage imageNamed:@"ic_advice_disagree.png"] forState:UIControlStateNormal];
        _deleteButton.backgroundColor = UIColorFromRGB(0xe7ecf2);;
        _deleteButton.frame = CGRectMake(0, 0, self.frame.size.width, 44);
        _deleteButton.hidden = YES;
        [self addSubview:_deleteButton];
        [_deleteButton setTitle:SY_STRING(@"common_delete") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    }
    if (!_bottomTopLineView) {
        _bottomTopLineView = [[UIView alloc] init];
        _bottomTopLineView.backgroundColor = UIColorFromRGB(0xbec8cf);
        [_deleteButton addSubview:_bottomTopLineView];
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



- (void)layoutSubviews
{
    CGFloat y = 0;
    CGFloat h = self.height - y;
    _searchItem.frame = CGRectMake(0, 0, self.width, 44);

    if (_isLongPress) {
        _searchTableView.frame = CGRectMake(0, y, self.width, h-42);
        y = _searchTableView.frame.size.height;
        _deleteButton.frame = CGRectMake(0, y, self.frame.size.width, 44);
        _deleteButton.hidden = NO;
        _searchTableView.allowsMultipleSelection = YES ;
        
    }else{
        y = _searchItem.height;
        h = self.height - y;
        _searchTableView.frame = CGRectMake(0, y, self.width, h);
        _deleteButton.hidden = YES;
        _searchTableView.allowsMultipleSelection = NO ;
    }
    _bottomTopLineView.frame = CGRectMake(0, 0, self.width, 0.5);
    
    UIView *nothingView = [self viewWithTag:1000001];
    nothingView.frame = CGRectMake(0, -y, self.cmp_width, self.cmp_height);
}

- (void)dealloc
{
    SY_RELEASE_SAFELY(_searchItem);
    SY_RELEASE_SAFELY(_searchTableView);
    SY_RELEASE_SAFELY(_bottomTopLineView);
    _deleteButton = nil;
    [super dealloc];
}
@end
