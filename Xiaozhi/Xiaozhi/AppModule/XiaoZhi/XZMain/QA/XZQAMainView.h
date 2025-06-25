//
//  XZQAMainView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseView.h>
#import "XZQABottomBar.h"
#import "XZQABottomCoverView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZQAMainView : CMPBaseView
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)UIScrollView *keyWordsView;

@property(nonatomic, strong)XZQABottomBar *bottomBar;
@property(nonatomic, strong)XZQABottomCoverView *bottomBarCoverView;

- (void)showKeyWords:(NSArray *)keyWords;
- (void)scrollTableViewBottom;
@end

NS_ASSUME_NONNULL_END
