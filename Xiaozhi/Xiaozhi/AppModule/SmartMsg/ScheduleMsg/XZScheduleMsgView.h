//
//  XZSchedule.h
//  M3
//
//  Created by wujiansheng on 2018/9/7.
//  工作安排消息

#import "XZBaseMsgView.h"

@interface XZScheduleMsgView : XZBaseMsgView<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
}

@end
