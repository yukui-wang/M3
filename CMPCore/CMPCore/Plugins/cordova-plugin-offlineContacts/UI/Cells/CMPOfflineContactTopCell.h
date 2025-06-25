//
//  CMPOfflineContactSearchCell.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import <CMPLib/CMPBaseTableViewCell.h>

@interface CMPOfflineContactTopCell : CMPBaseTableViewCell
@property(nonatomic, retain)UIButton *orgButton;
@property(nonatomic, retain)UIButton *teamButton;
@property(nonatomic, retain)UIButton *groupButton;
@property(nonatomic, retain)UIButton *contactsButton;//常用联系人
@property(nonatomic, retain)UIButton *relatedButton;//关联人员

- (void)setupAZView;//现实A-Z界面
- (void)setupFrequentView;//现实最近联系人界面

+ (CGFloat)cellHeight;

@end
