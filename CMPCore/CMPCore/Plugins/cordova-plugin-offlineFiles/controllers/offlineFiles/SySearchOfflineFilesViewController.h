//
//  SySearchOfflineFilesViewController.h
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/CMPBannerViewController.h>
#import "SySearchOfflineFilesView.h"
#import "SyOfflineFilesViewCell.h"



@protocol SySearchOfflineFilesViewControllerDelegate;
@interface SySearchOfflineFilesViewController : CMPBannerViewController
<UITextFieldDelegate,SyOfflineFilesViewCellDelegate>
{
    
    SySearchOfflineFilesView *_searchOfflineFilesView;
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
@property (nonatomic, assign)id<SySearchOfflineFilesViewControllerDelegate> returnDelegate;
@end

@protocol SySearchOfflineFilesViewControllerDelegate <NSObject>

- (void)searchOfflineFilesViewControllerDidReturn:(SySearchOfflineFilesViewController *)aViewController;

@end
