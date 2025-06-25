//
//  XZInterfaceCell.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "XZWebViewModel.h"
#import "XZFrequentView.h"

@interface XZInterfaceCell : CMPBaseTableViewCell
@property(nonatomic,strong)UIButton *editButton;
@property(nonatomic,assign)CGFloat cellHeight;

@property(nonatomic,copy) void(^cardViewChangeHeight)(void);
@property(nonatomic,copy) void(^interfaceCellClickTextBlock)(NSString *);

@property(nonatomic, retain)XZFrequentView *frequentView;//常用联系人

- (void)showGuideView;
- (void)appendHumenText:(NSString *)text;
- (void)showHumenText:(NSString *)text;
- (void)showRobotText:(NSString *)text;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)showWebViewWithModel:(XZWebViewModel *)model;
- (void)robotSpeakWithModels:(NSArray *)models;
- (void)showCreateAppCardWithAppName:(NSString *)name infoList:(NSArray *)infoList;
- (void)hideCreateAppCard;
- (void)showButtons:(NSArray *)array;
//常用联系人
- (void)showFrequentViewWithMembers:(NSArray *)members multi:(BOOL)multi;
- (void)hideFrequentView;
- (void)showOptionIntents:(NSArray *)array;

- (NSArray *)cellModels;
- (void)clearData;
- (void)clearCreateCard;
- (NSString *)humenText;
@end
