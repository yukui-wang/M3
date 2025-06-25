//
//  SyOfflineFilesListView.h
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/CMPBaseView.h>

@interface SyOfflineFilesListView : CMPBaseView

@property(nonatomic, retain)UITableView *offlineFilesTableView;
@property(nonatomic, readonly)UIButton *deleteButton;
@property(nonatomic, assign)BOOL    isLongPress;
@end
