//
//  XZGuidePageView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZGuideSubPageView.h"


@interface XZGuidePageView : XZBaseView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIView *bkView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIView *topLine;
@property(nonatomic, strong)UIView *bottomLine;
@property(nonatomic, strong)XZGuideSubPageView *subPageView;
@property(nonatomic, copy)void(^shouldDismissBlock)(void);
@property(nonatomic, copy)void(^clickTextBlock)(NSString *text);

- (void)removeSubPageView;
- (void)layoutSubviewsFrame;
@end
