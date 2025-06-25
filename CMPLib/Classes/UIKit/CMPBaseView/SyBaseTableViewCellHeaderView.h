//
//  SyBaseTableViewCellHeaderView.h
//  M1Core
//
//  Created by wujiansheng on 15/3/5.
//
//

//UITableViewStylePlain的headerView 固定

#import "CMPBaseView.h"

@interface SyBaseTableViewCellHeaderView : CMPBaseView
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) BOOL forFooter;
@end
