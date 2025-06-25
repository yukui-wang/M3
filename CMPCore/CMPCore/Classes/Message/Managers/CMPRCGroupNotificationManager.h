//
//  CMPRCGroupNotificationManager.h
//  CMPCore
//
//  Created by CRMO on 2017/8/3.
//
//

#import <Foundation/Foundation.h>

#import "CMPRCGroupNotificationObject.h"

@class FMDatabaseQueue;

@interface CMPRCGroupNotificationManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dataQueue;

- (void)createSqlite;

/**
 获取消息列表
 */
- (void)getNotificationList:(void (^)(NSArray *))completion;
/**
 获取最新的一条消息
 
 @return 最新的一条消息
 */
- (void)getLatestNotification:(void (^)(CMPRCGroupNotificationObject *))completion;

/**
 往数据库中存入一条消息
 */
- (void)insertNotifications:(NSArray *)notifications;

/**
 把所有通知标记为已读
 */
- (void)readAllNotifications;

/**
 把指定时间之前的read设置为1

 @param timestamp 时间戳
 */
- (void)readNotificationBefore:(long long)timestamp;

/**
 从数据库中删除一条消息
 */
- (void)deleteNotification:(CMPRCGroupNotificationObject *)notification;

/**
 将所有通知的hide设置为1
 */
- (void)deleteAllNotification;

@end
