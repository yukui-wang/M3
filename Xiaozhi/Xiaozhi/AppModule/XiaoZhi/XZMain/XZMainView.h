//
//  XZMainView.h
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBaseView.h"
#import "XZBottomBar.h"
#import "XZTextEditView.h"
#import "XZMemberTextView.h"
#import "XZMemberListView.h"
#import "XZViewDelegate.h"

typedef enum {
    mainViewInputType_speech = 0,
    mainViewInputType_text,
    mainViewInputType_member,
}mainViewInputType;



@protocol XZMainViewDelegate <NSObject>

- (void)mainViewKeyboardDidKeyboardHideFinish;

@end


@interface XZMainView : XZBaseView

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)XZBottomBar *bottomBar;//底部条
@property(nonatomic, retain)XZTextEditView *textEditView;//键盘输入
@property(nonatomic, retain)XZMemberTextView *memberInpitView;//选人输入界面

@property(nonatomic, assign)mainViewInputType viewType;//选人输入界面
@property(nonatomic, assign)BOOL isMultiChoosemMember;//选人是否多选
@property(nonatomic, assign)id<XZMainViewDelegate> delegate;//选人是否多选

- (void)addNotifications;
- (void)removeNotifications;
- (void)showBottomBarView;
- (void)hideBottomBarView;
- (void)showTextEditView;
- (void)hideTextEditView;
- (void)showMemberInputView;
- (void)hideMemberInputView;
- (void)restoreView;
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)clearInput;
- (BOOL)isInSpeechView;
- (void)scrollTableViewBottom;//table滚动到底部
@end




