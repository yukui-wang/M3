//
//  XZGuideSubPageView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZGuidePageItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface XZGuideSubPageView : XZBaseView

@property(nonatomic, strong)UIButton *backBtn;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIView *topLine;
@property(nonatomic, strong)UIView *bottomLine;

- (id)initWithFrame:(CGRect)frame pageItem:(XZGuidePageItem *)pageItem;

@end

NS_ASSUME_NONNULL_END
