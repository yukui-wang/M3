//
//  CMPRCGroupNotificationView.h
//  CMPCore
//
//  Created by CRMO on 2017/8/7.
//
//

#import <CMPLib/CMPBaseView.h>

@interface CMPRCGroupNotificationView : CMPBaseView

@property(nonatomic ,strong)UITableView *tableView;

- (void)showNothingView:(BOOL)show;

@end
