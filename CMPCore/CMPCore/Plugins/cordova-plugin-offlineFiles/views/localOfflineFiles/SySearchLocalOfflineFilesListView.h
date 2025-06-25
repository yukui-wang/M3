//
//  SySearchLocalOfflineFilesListView.h
//  M1Core
//
//  Created by chenquanwei on 14-3-16.
//
//
#import <CMPLib/CMPBaseView.h>
#import "SySearchLocalOfflineFilesItem.h"

@interface SySearchLocalOfflineFilesListView :CMPBaseView
{
    SySearchLocalOfflineFilesItem *_searchItem;
    UITableView* _searchTableView;
    NSInteger _pickerAttributive;
}
@property(nonatomic, retain) SySearchLocalOfflineFilesItem *searchItem;
@property(nonatomic, retain) UITableView* searchTableView;
- (void)showSearchTableView;
- (void)hiddenSearchTableView;
@end
