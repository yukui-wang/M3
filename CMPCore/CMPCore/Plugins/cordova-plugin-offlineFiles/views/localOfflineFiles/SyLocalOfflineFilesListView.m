//
//  SyLocalOfflineFilesListView.m
//  M1Core
//
//  Created by chenquanwei on 14-3-14.
//
//

#import "SyLocalOfflineFilesListView.h"

@implementation SyLocalOfflineFilesListView

@synthesize offlineFilesTableView = _offlineFilesTableView;


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
        _offlineFilesTableView.backgroundColor = UIColorFromRGB(0xf4f4f4);
        [self addSubview:_offlineFilesTableView];
    }
    
}

- (void)layoutSubviews
{
    CGFloat y = 0;
    CGFloat h = self.height - y;
    _offlineFilesTableView.frame = CGRectMake(0, y, self.width, h);
    UIView *nothingView = [_offlineFilesTableView viewWithTag:1000001];
    if (nothingView) {
        nothingView.frame = _offlineFilesTableView.bounds;
    }
    //    _collectionView.frame = CGRectMake(0, y, self.width, h); // 不能重新设置frame
}

@end
