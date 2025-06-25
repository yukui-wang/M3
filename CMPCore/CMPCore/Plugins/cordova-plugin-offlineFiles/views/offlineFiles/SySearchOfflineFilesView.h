//
//  SySearchOfflineFilesView.h
//  M1IPhone
//
//  Created by chenquanwei on 14-3-11.
//  Copyright (c) 2014年 北京致远协创软件有限公司. All rights reserved.
//

#import <CMPLib/CMPBaseView.h>
#import "SySearchOfflineFilesItem.h"

@interface SySearchOfflineFilesView : CMPBaseView
{
    SySearchOfflineFilesItem *_searchItem;
    UITableView* _searchTableView;
    NSInteger _pickerAttributive;
    UIView *_bottomTopLineView;
}
@property(nonatomic, retain) SySearchOfflineFilesItem *searchItem;
@property(nonatomic, retain) UITableView* searchTableView;
@property(nonatomic, retain)UIButton *deleteButton;
@property(nonatomic, assign)BOOL    isLongPress;
- (void)showSearchTableView;
- (void)hiddenSearchTableView;
- (void)hiddenDatePicker;//显示时间选择器
- (void)showStartTimeDatePickerView;//隐藏时间选择器
- (void)showEndTimeDatePickerView;
- (void)showDatePicker;
@end
