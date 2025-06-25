//
//  CMPOfflineContactView.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/3.
//
//

#import <CMPLib/CMPBaseView.h>
#import "CMPSpellBar.h"

@interface CMPOfflineContactView : CMPBaseView
@property(nonatomic,retain)UILabel *infoLabel;
@property(nonatomic,retain)UIView *errorLabel;
@property(nonatomic,retain)UITableView *tableview;
@property(nonatomic,retain)CMPSpellBar *spellBar;
@property(nonatomic,retain)UISearchBar *searchBar;

/**
 覆盖一层纯白的View，遮挡内容
 在点击搜索条后调用
 */
- (void)hideTableView;

/**
 隐藏纯白覆盖层
 */
- (void)showTableView;

/**
 展示提示框

 @param content 提示框显示内容
 */
- (void)showInfoLabel:(NSString *)content;

/**
 展示通讯录下载失败提示

 @param click 点击重试回调
 */
- (void)showErrorLabelClick:(void(^)(void))click;

/**
 隐藏所有顶部提示框
 */
- (void)hideLabels;

@end
