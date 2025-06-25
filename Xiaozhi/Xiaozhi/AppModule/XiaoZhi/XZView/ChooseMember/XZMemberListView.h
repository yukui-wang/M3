//
//  XZMemberListView.h
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZBaseView.h"
#import <CMPLib/CMPOfflineContactMember.h>
#import "XZViewDelegate.h"


@protocol XZMemberListViewDelegate <NSObject>
- (void)memberListViewDidSelectMember:(CMPOfflineContactMember *)member;
@end

@interface XZMemberListView : XZBaseView

@property(nonatomic,assign)id<XZMemberListViewDelegate> delegate;
@property(nonatomic,assign)BOOL isShow;

- (void)showMembers:(NSArray *)array;

@end


