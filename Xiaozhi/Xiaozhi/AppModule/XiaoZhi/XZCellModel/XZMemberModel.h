//
//  XZMemberModel.h
//  M3
//
//  Created by wujiansheng on 2018/1/3.
//

#import "XZCellModel.h"
#import <CMPLib/CMPOfflineContactMember.h>
@interface XZMemberModel : XZCellModel
@property(nonatomic, retain)CMPOfflineContactMember *member;
@property(nonatomic, assign)BOOL canOperate;//能否显示 打电话、发短信 、发协同、发消息
@property(nonatomic, assign)BOOL hasPhone;//能否显示 打电话、发短信
@property(nonatomic, assign)BOOL canColl;//能否发协同
@property(nonatomic, assign)BOOL canIM;//能否发IM消息
@property (nonatomic, copy) void (^clickButtonBlock)(NSString *title);
@property (nonatomic, copy) void (^callBlock)(NSString *phone);
@property (nonatomic, copy) void (^sendSMSBlock)(NSString *phone);
@property (nonatomic, copy) void (^sendCollBlock)(CMPOfflineContactMember *member);
@property (nonatomic, copy) void (^sendIMMessageBlock)(CMPOfflineContactMember *member);

- (void)call;
- (void)sendMessage;
- (void)sendColl;
- (void)sendIMMessage;

@end
