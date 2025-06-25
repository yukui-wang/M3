//
//  XZMainView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#import "XZRecorderWave.h"
#import "XZBottomView.h"
#import "XZSubSearchView.h"
#import "XZPreFrequentView.h"
#import "XZTextEditView.h"
#import "XZRippleView.h"
#import "XZMemberTextView.h"
#import "XZMemberListView.h"
#import "XZViewDelegate.h"

@interface XZPreMainView : XZBaseView

@property(nonatomic, retain)UIImageView *logoView;//顶部头像
@property(nonatomic, retain)UITableView *tableView;
@property (nonatomic, assign)id<XZViewDelegate> delegate;
@property(nonatomic, retain)UIButton *speakButton;

- (void)showLogoView:(BOOL)show;
- (void)addNotifications;
- (void)removeNotifications;
- (void)scrollTableViewBottom;//table滚动到底部
- (void)showWaveView;
- (void)showWaveViewAnalysis;
- (void)hideWaveView;
- (void)clearInput;
//查找小项
- (void)showSearchItemsView;
- (void)hideSearchItemsView;
// 选人界面
- (void)showMemberView:(BOOL)multi;
- (void)showFrequentView:(BOOL)multi members:(NSArray *)members;
- (void)hideMemberView;
//还原界面
- (void)restoreView;
- (void)showKeyboard;
- (void)hideKeyboard;
- (BOOL)keyboardIsShow;
- (BOOL)isInSpeechView;

@end




