//
//  SyOfflineFilesListView.m
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyOfflineFilesListView.h"

@implementation SyOfflineFilesListView

@synthesize offlineFilesTableView = _offlineFilesTableView;
@synthesize deleteButton = _deleteButton;
@synthesize isLongPress = _isLongPress;

- (void)dealloc
{
    SY_RELEASE_SAFELY(_offlineFilesTableView);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setup
{
    if (!_offlineFilesTableView) {
        _offlineFilesTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _offlineFilesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _offlineFilesTableView.backgroundColor = UIColorFromRGB(0xF8F9FB);

        [self addSubview:_offlineFilesTableView];
    }
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setImage:[UIImage imageNamed:@"ic_advice_disagree.png"] forState:UIControlStateNormal];
        _deleteButton.backgroundColor = UIColorFromRGB(0xF1F1F1);
        _deleteButton.frame = CGRectMake(0, 0, self.frame.size.width, 44);
        _deleteButton.hidden = YES;
        [self addSubview:_deleteButton];
        [_deleteButton setTitle:SY_STRING(@"common_delete") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    }
    
}

- (void)layoutSubviews
{
    CGFloat y = 0;
    CGFloat h = self.height - y;
    if (_isLongPress) {
        _offlineFilesTableView.frame = CGRectMake(0, y, self.width, h-42);
        y = _offlineFilesTableView.frame.size.height;
        _deleteButton.frame = CGRectMake(0, y, self.frame.size.width, 44);
        _deleteButton.hidden = NO;
        _offlineFilesTableView.allowsMultipleSelection = YES ;
        
    }else{
        _offlineFilesTableView.frame = CGRectMake(0, y, self.width, h);
        _deleteButton.hidden = YES;
        _offlineFilesTableView.allowsMultipleSelection = NO ;
    }
    
    UIView *nothingView = [self viewWithTag:1000001];
    nothingView.frame = _offlineFilesTableView.frame;
}


@end
