//
//  XZViewDelegate.h
//  M3
//
//  Created by wujiansheng on 2017/11/25.
//

#import <Foundation/Foundation.h>

@class XZMainView;
@class XZTextEditView;
@class XZSubSearchView;
@class XZPreFrequentView;
@class XZMemberTextView;
@class XZMemberListView;
@class CMPOfflineContactMember;
@class XZRippleView;

@protocol XZViewDelegate <NSObject>

@optional
//主界面
- (void)speakButtonClickedWithMainView:(UIView *)view;
- (void)keyboardButtonClickedWithMainView:(UIView *)view;
- (void)mainView:(XZMainView *)view finishInputText:(NSString *)text;
- (void)showHelpViewWithMainView:(UIView *)view;

- (void)view:(UIView *)view needShowMessage:(NSString *)string;

//键盘输入
- (void)textEditView:(XZTextEditView *)view finishInputText:(NSString *)text;
//搜索可选项
- (void)subSearchView:(XZSubSearchView *)view clickText:(NSString *)text;
//常用联系人
- (void)frequentView:(XZPreFrequentView *)view didFinishSelectMember:(NSArray *)members;
- (void)frequentView:(XZPreFrequentView *)view showSelectMemberView:(BOOL)isMultiSelect;
//人员输入界面
- (void)memberTextView:(XZMemberTextView *)view didSelectMembers:(NSArray *)members string:(NSString *)string;
//水波纹
- (void)rippleViewDidClick:(XZRippleView *)view;


@end
