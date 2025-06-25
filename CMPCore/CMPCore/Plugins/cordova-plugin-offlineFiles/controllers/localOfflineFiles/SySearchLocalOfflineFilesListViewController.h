//
//  SySearchLocalOfflineFilesListViewController.h
//  M1Core
//
//  Created by chenquanwei on 14-3-16.
//
//
#import <CMPLib/CMPBannerViewController.h>
#import "SySearchLocalOfflineFilesListView.h"
#import "SyLocalOfflineFilesListViewController.h"
#import "SyLocalOfflineFilesListViewCell.h"

@protocol SySearchLocalOfflineFilesListViewControllerDelegate <NSObject>

- (void)searchLocalOfflineFilesListViewControllerDidSelectValue;

@end

@protocol SyLocalOfflineFilesListViewControllerDelegate;

@interface SySearchLocalOfflineFilesListViewController : CMPBannerViewController<UITextFieldDelegate,SyLocalOfflineFilesListViewCellDelegate>
{
    
    SySearchLocalOfflineFilesListView *_searchOfflineFilesView;
    NSMutableArray *_searchList;// 列表数据
    NSInteger _affairState; // 协同类型
    NSInteger _searchMethod; // 搜索类型 人名、时间、标题/1标题 2发起人 3发起时间
    NSInteger _startIndex; // 开始索引
    NSArray *_titles;
    NSInteger _pageIndex; // 页索引
    NSInteger _pageType; // 列表获取方式
    NSInteger _totalCount;
    BOOL _canRequest;
}

@property(nonatomic, assign)NSInteger spaceType;
@property (nonatomic, assign)long long typeID; //
@property (nonatomic, assign)id <SyLocalOfflineFilesListViewControllerDelegate >delegate;
@property (nonatomic, assign)id <SySearchLocalOfflineFilesListViewControllerDelegate >searchDelegate;

@property (nonatomic, assign) NSInteger maxFileSize;//图片大小限制，默认5M

@end


