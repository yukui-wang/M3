//
//  CMPMessageListView.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/26.
//
//

#import <CMPLib/CMPBaseView.h>

@interface CMPMessageListView : CMPBaseView
@property(nonatomic ,retain)UITableView *tableView;
//修改iPhone，消息在首页因为底导航隐藏、显示导致的前后界面不一致，列表自动向上滚动，ipad无该问题
@property(nonatomic ,assign)BOOL lockFrame;
-(void)refreshQuickRouterView;
@end
