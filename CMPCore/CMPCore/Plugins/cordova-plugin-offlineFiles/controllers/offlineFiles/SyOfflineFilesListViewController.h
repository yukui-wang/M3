//
//  SyOfflineFilesListViewController.h
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import "SyOfflineFilesListView.h"
#import "SySearchOfflineFilesViewController.h"
#import <CMPLib/CMPBannerViewController.h>
#import "SyOfflineFilesViewCell.h"

@interface SyOfflineFilesListViewController : CMPBannerViewController<UITableViewDataSource,UITableViewDelegate,SyOfflineFilesViewCellDelegate>
{
    SyOfflineFilesListView *_offlineFilesListView;
}

@property(nonatomic, copy) NSString *bannerTitle;

@end
