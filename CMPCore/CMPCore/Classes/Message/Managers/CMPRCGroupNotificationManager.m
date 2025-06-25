//
//  CMPRCGroupNotificationManager.m
//  CMPCore
//
//  Created by CRMO on 2017/8/3.
//
//

#import "CMPRCGroupNotificationManager.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDateHelper.h>


@interface CMPRCGroupNotificationManager()

@end


@implementation CMPRCGroupNotificationManager

#pragma mark -
#pragma mark -Init

- (void)dealloc {
    [_dataQueue release];
    _dataQueue = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark -数据接口

- (void)getNotificationList:(void (^)(NSArray *))completion {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray *array = [NSMutableArray array];
        FMResultSet *set = [db executeQuery:[CMPRCGroupNotificationManager listSql]];
        while ([set next]) {
            CMPRCGroupNotificationObject *object = [[CMPRCGroupNotificationObject alloc] init];
            object.sId = [set stringForColumn:@"sId"];
            object.mId = [set stringForColumn:@"mId"];
            object.targetId = [set stringForColumn:@"targetId"];
            object.receiveTime = [set stringForColumn:@"receiveTime"];
            object.content = [set stringForColumn:@"content"];
            object.iconUrl = [set stringForColumn:@"iconUrl"];
            object.operatorUserId = [set stringForColumn:@"operatorUserId"];
            object.data = [set stringForColumn:@"data"];
            object.msgId = [set stringForColumn:@"msgId"];
            object.operation = [set stringForColumn:@"operation"];
            object.extra1 = [set stringForColumn:@"extra1"];
            object.extra2 = [set stringForColumn:@"extra2"];
            object.extra3 = [set stringForColumn:@"extra3"];
            object.extra4 = [set stringForColumn:@"extra4"];
            object.extra5 = [set stringForColumn:@"extra5"];
            object.extra6 = [set stringForColumn:@"extra6"];
            object.extra7 = [set stringForColumn:@"extra7"];
            object.extra8 = [set stringForColumn:@"extra8"];
            object.extra9 = [set stringForColumn:@"extra9"];
            object.extra10 = [set stringForColumn:@"extra10"];
            object.extra11 = [set stringForColumn:@"extra11"];
            object.extra12 = [set stringForColumn:@"extra12"];
            object.extra13 = [set stringForColumn:@"extra13"];
            object.extra14 = [set stringForColumn:@"extra14"];
            object.extra15 = [set stringForColumn:@"extra15"];
            [array addObject:object];
            [object release];
            object = nil;
        }
        completion(array);
    }];
}

- (void)getLatestNotification:(void (^)(CMPRCGroupNotificationObject *))completion {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        CMPRCGroupNotificationObject *object = [[CMPRCGroupNotificationObject alloc] init];
        FMResultSet *set = [db executeQuery:[CMPRCGroupNotificationManager listSqlDesc]];
        if ([set next]) {
            object.sId = [set stringForColumn:@"sId"];
            object.mId = [set stringForColumn:@"mId"];
            object.targetId = [set stringForColumn:@"targetId"];
            object.receiveTime = [set stringForColumn:@"receiveTime"];
            object.content = [set stringForColumn:@"content"];
            object.iconUrl = [set stringForColumn:@"iconUrl"];
            object.operatorUserId = [set stringForColumn:@"operatorUserId"];
            object.data = [set stringForColumn:@"data"];
            object.msgId = [set stringForColumn:@"msgId"];
            object.operation = [set stringForColumn:@"operation"];
            object.extra1 = [set stringForColumn:@"extra1"];
            object.extra2 = [set stringForColumn:@"extra2"];
            object.extra3 = [set stringForColumn:@"extra3"];
            object.extra4 = [set stringForColumn:@"extra4"];
            object.extra5 = [set stringForColumn:@"extra5"];
            object.extra6 = [set stringForColumn:@"extra6"];
            object.extra7 = [set stringForColumn:@"extra7"];
            object.extra8 = [set stringForColumn:@"extra8"];
            object.extra9 = [set stringForColumn:@"extra9"];
            object.extra10 = [set stringForColumn:@"extra10"];
            object.extra11 = [set stringForColumn:@"extra11"];
            object.extra12 = [set stringForColumn:@"extra12"];
            object.extra13 = [set stringForColumn:@"extra13"];
            object.extra14 = [set stringForColumn:@"extra14"];
            object.extra15 = [set stringForColumn:@"extra15"];
        }
        [set close];
        completion(object);
        [object release];
        object = nil;
    }];
}

- (void)insertNotifications:(NSArray *)notifications {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        for (CMPRCGroupNotificationObject *notification in notifications) {
            NSUInteger count = [db intForQuery:[CMPRCGroupNotificationManager queryCountSql:notification]];
            if (count == 0) {
                [db executeUpdate:[CMPRCGroupNotificationManager insertSql:notification]];
            }
        }
    }];
}

- (void)readAllNotifications {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCGroupNotificationManager readSql]];
    }];
}

- (void)readNotificationBefore:(long long)timestamp {
    if (timestamp <= 0) {
        return;
    }
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCGroupNotificationManager readSql:timestamp]];
    }];
}

- (void)deleteNotification:(CMPRCGroupNotificationObject *)notification {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCGroupNotificationManager deleteSql:notification]];
    }];
}

- (void)deleteAllNotification {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCGroupNotificationManager deleteAllSql]];
    }];
}

#pragma mark -
#pragma mark -数据库操作

- (void)createSqlite {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCGroupNotificationManager createSql]];
    }];
}


/**
 创建表SQL
 */
+ (NSString *)createSql {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS [TB_GROUP_NOTIFACATION] (\
    [sId] TEXT, \
    [mId] TEXT,\
    [targetId] TEXT,\
    [receiveTime] TEXT, \
    [content] TEXT, \
    [iconUrl] TEXT, \
    [hide] INTEGER, \
    [read] INTEGER, \
    [operatorUserId] TEXT, \
    [data] TEXT, \
    [msgId] TEXT, \
    [operation] TEXT, \
    [extra1] TEXT, \
    [extra2] TEXT, \
    [extra3] TEXT, \
    [extra4] TEXT, \
    [extra5] TEXT, \
    [extra6] TEXT, \
    [extra7] TEXT, \
    [extra8] TEXT, \
    [extra9] TEXT, \
    [extra10] TEXT, \
    [extra11] TEXT, \
    [extra12] TEXT, \
    [extra13] TEXT, \
    [extra14] TEXT, \
    [extra15] TEXT)";
    return sql;
}

+ (NSString *)listSql {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM TB_GROUP_NOTIFACATION WHERE sId = '%@' and mId = '%@' and hide = 0 ORDER BY receiveTime", [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    return sql;
}

+ (NSString *)listSqlDesc {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM TB_GROUP_NOTIFACATION WHERE sId = '%@' and mId = '%@' and hide = 0 ORDER BY receiveTime DESC", [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    return sql;
}

+ (NSString *)queryCountSql:(CMPRCGroupNotificationObject *)notification {
    NSString *condition = [NSString stringWithFormat:@"sId = '%@' and mId = '%@' and msgId = '%@'",\
                           notification.sId, notification.mId, notification.msgId];
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_GROUP_NOTIFACATION \
                     WHERE %@", condition];
    return sql;
}

+ (NSString *)insertSql:(CMPRCGroupNotificationObject *)notification {
    NSString *value = [NSString stringWithFormat:@"'%@', '%@', '%@', '%@', '%@', '%@', 0, 0, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@'", notification.sId, notification.mId, notification.targetId, notification.receiveTime, notification.content, notification.iconUrl, notification.operatorUserId, notification.data, notification.msgId, notification.operation, notification.extra1, notification.extra2, notification.extra3, notification.extra4, notification.extra5, notification.extra6, notification.extra7, notification.extra8, notification.extra9, notification.extra10, notification.extra11, notification.extra12, notification.extra13, notification.extra14, notification.extra15];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO TB_GROUP_NOTIFACATION \
                     (sId,mId,targetId,receiveTime,content,iconUrl,hide,read,operatorUserId,data,\
                     msgId,operation,extra1,extra2,extra3,extra4,extra5,extra6,extra7,extra8,extra9,extra10,extra11,extra12,extra13,extra14,extra15)\
                     VALUES (%@)", value];
    return sql;
}

+ (NSString *)deleteSql:(CMPRCGroupNotificationObject *)notification {
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_GROUP_NOTIFACATION SET hide = 1 WHERE sId = '%@' AND mId = '%@' AND msgId = '%@'", notification.sId, notification.mId, notification.msgId];
    return sql;
}

+ (NSString *)readSql {
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_GROUP_NOTIFACATION SET read = 1 WHERE sId = '%@' AND mId = '%@'", [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    return sql;
}

+ (NSString *)readSql:(long long)timestamp {
    NSString *time = [CMPDateHelper dateStrFromLongLong:timestamp];
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_GROUP_NOTIFACATION SET read = 1 WHERE sId = '%@' AND mId = '%@' AND receiveTime <= '%@'", [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,time];
    return sql;
}

+ (NSString *)deleteAllSql {
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_GROUP_NOTIFACATION SET hide = 1 WHERE sId = '%@' AND mId = '%@'", [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    return sql;
}

@end
