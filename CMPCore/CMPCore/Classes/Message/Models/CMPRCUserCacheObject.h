//
//  CMPRCUserCacheObject.h
//  CMPCore
//
//  缓存跨单位人员信息
//
//  Created by CRMO on 2017/8/22.
//
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>

@class RCConversation;

@interface CMPRCUserCacheObject : CMPObject

/** ServerId **/
@property (nonatomic, copy) NSString *sId;
/** UserId **/
@property (nonatomic, copy) NSString *mId;
/** 群聊的Id **/
@property (nonatomic, copy) NSString *groupId;
/** 聊天的类型 **/
@property (nonatomic, assign) NSUInteger type;
/** 缓存的用户ID **/
@property (nonatomic, copy) NSString *userId;
/** 缓存的用户名字 **/
@property (nonatomic, copy) NSString *name;
/** 缓存更新的时间时间 **/
@property (nonatomic, copy) NSString *updateTime;

@property (nonatomic, copy) NSString *extra1;
@property (nonatomic, copy) NSString *extra2;
@property (nonatomic, copy) NSString *extra3;
@property (nonatomic, copy) NSString *extra4;
@property (nonatomic, copy) NSString *extra5;
@property (nonatomic, copy) NSString *extra6;
@property (nonatomic, copy) NSString *extra7;
@property (nonatomic, copy) NSString *extra8;
@property (nonatomic, copy) NSString *extra9;
@property (nonatomic, copy) NSString *extra10;
@property (nonatomic, copy) NSString *extra11;
@property (nonatomic, copy) NSString *extra12;
@property (nonatomic, copy) NSString *extra13;
@property (nonatomic, copy) NSString *extra14;
@property (nonatomic, copy) NSString *extra15;

- (instancetype)initWithRCConversation:(RCConversation *)conversation;

@end
