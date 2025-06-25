//
//  CMPRCTargetObject.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/28.
//
//

#import <CMPLib/CMPObject.h>
#import "CMPMessageObject.h"

@interface CMPRCTargetObject : CMPObject

@property(nonatomic, assign)CMPRCConversationType type;
@property(nonatomic, copy)NSString *targetId;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, weak)UINavigationController *navigationController;
@property(nonatomic, weak)RDVTabBarController *tabbar;
@property(nonatomic, copy)NSString *url;//仅h5用
@property(nonatomic, assign)long long locatedMessageSentTime;//进入页面时定位的消息的发送时间
@property(nonatomic, strong)CMPMessageObject *messageObject;

@end
