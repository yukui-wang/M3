//
//  CMPMessageDbProvider.m
//  M3
//
//  Created by CRMO on 2018/1/4.
//

#import "CMPMessageDbProvider.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPV5MessageSetting.h"
#import "CMPLoginConfigInfoModel.h"
#import "CMPChatManager.h"
#import <CMPLib/FMDatabaseQueueFactory.h>
#import <CMPLib/CMPServerVersionUtils.h>

#define kTopTag_Top 1
#define kTopTag_NotTop 0

NSString * const kLocalMessageDBName = @"localMessage.db";

@interface CMPMessageDbProvider()
@end

@implementation CMPMessageDbProvider

- (void)dealloc {
    if (_dataQueue) {
        [_dataQueue close];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self dataQueue];
    }
    return self;
}

- (void)messageDidUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_DBMessageDidUpdate object:nil];
    });
}

#pragma mark-
#pragma mark 消息列表

- (void)messageListWithCondition:(CMPMessageDbFilterCondition *)condition cmpletion:(MessageListCompletion)completion {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT DISTINCT * FROM TB_MESSAGE where sId = '%@' and mId = '%@' and hide = 0",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    if (condition) {
        [sql appendString:[condition conditionStr]];
    }
    [sql appendString:[CMPMessageDbProvider sortCondition]];
    [self queryMessageListFromDbWithSql:sql completion:completion];
}

- (void)messageListWithoutAggregationCompletion:(MessageListCompletion)completion {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT DISTINCT * FROM TB_MESSAGE where sId = '%@' and mId = '%@' and hide = 0 and (extra1 = '' or extra1 = '(null)')",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    if (![CMPChatManager sharedManager].isShowlittleBroad) {
        [sql appendFormat:@" and  cId != '%@'",kMessageType_MassNotificationMessage];
    }
    [sql appendString:[CMPMessageDbProvider sortCondition]];
    [self queryMessageListFromDbWithSql:sql completion:completion];
}

- (void)messageList:(MessageListCompletion)completion {
//    if ([CMPCore sharedInstance].hasPermissionForZhixin) {
//         [self messageListWithCondition:nil cmpletion:completion];
//    } else {
//        CMPMessageDbFilterCondition *condition = [[CMPMessageDbFilterCondition alloc] init];
//        [condition exceptKey:@"cId" values:@[[CMPCore sharedInstance].userID,kMessageType_MassNotificationMessage]];
//        [self messageListWithCondition:condition cmpletion:completion];
//    }
    
    [self messageListWithCondition:nil cmpletion:completion];
}

-(void)allMessageList:(MessageListCompletion)completion
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT DISTINCT * FROM TB_MESSAGE where sId = '%@' and mId = '%@' and hide = 0",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    [sql appendString:[CMPMessageDbProvider sortCondition]];
    [self queryMessageListFromDbWithSql:sql completion:completion];
}

- (void)messageListWithAggregationType:(CMPMessageType)type completion:(MessageListCompletion)completion {
    CMPMessageDbFilterCondition *condition = [[CMPMessageDbFilterCondition alloc] init];
    NSString *cID = [CMPMessageObject cIDWithMessageType:type];
    [condition containKey:@"extra1" values:@[cID]];
    [self messageListWithCondition:condition cmpletion:completion];
}

- (void)queryMessageListFromDbWithSql:(NSString *)sql completion:(MessageListCompletion)completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray *array = [NSMutableArray array];
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            CMPMessageObject *object = [CMPMessageObject yy_modelWithDictionary:[set resultDictionary]];
            [array addObject:object];
        }
        completion(array);
    }];
}

+ (NSString *)sortCondition {
    return @" ORDER BY topSort , createTime DESC";
}

- (void)messageWithMsgID:(NSString *)messageID completion:(void(^)(CMPMessageObject *message))completion {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND cId = '%@'  AND msgId = '%@'",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID, kMessageType_SmartMessage, messageID];
    [self queryMessageListFromDbWithSql:sql completion:^(NSArray<CMPMessageObject *> *messages) {
        if (completion) {
            completion([messages lastObject]);
        }
    }];
}

- (CMPMessageObject *)messageWithAppID:(NSString *)appID {
    __block CMPMessageObject *message = nil;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set =  [db executeQuery:@"SELECT * FROM TB_MESSAGE WHERE sId = ? AND mId = ? AND cId = ?",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        if ([set next]) {
            message = [CMPMessageObject yy_modelWithDictionary:[set resultDictionary]];
        }
        [set close];
    }];
    return message;
}

- (void)readSmartMessageWithMsgID:(NSString *)msgID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE TB_MESSAGE SET extra3 = ? WHERE sId = ? AND mId = ? AND cId = ?", msgID, [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID, kMessageType_SmartMessage];
        [weakself updateAppMessage:db];
    }];
}

#pragma mark-
#pragma mark 消息操作

- (void)saveMessages:(NSArray<CMPMessageObject *> *)messages isChat:(BOOL)isChat {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        BOOL isRollBack = false;
        BOOL update  = NO;
        @try {
            if (!isChat) {
                // 先清空消息
                NSString *clearAllSql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@', unreadCount = 0, msgId = '', gotoParams = '', senderName = '', senderFaceUrl = '', hide = 1 where sId = '%@' and mId = '%@' and type = 0", kMsg_NoMessage, [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
                
                if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
                    NSString *deleteAppMessage = [NSString stringWithFormat:@"DELETE FROM TB_MESSAGE where sId = '%@' and mId = '%@' and type = 100", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID];
                    [db executeUpdate:deleteAppMessage];
                } else if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
                    // 7.0SP4版本默认置顶消息：领导、跟踪、@
                    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
                    CMPLoginConfigInfoModel_2 *newConfig = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];
                    // 7.1新增字段hideLeaderMessage，yes就隐藏领导消息
                    if (newConfig.config.hideLeaderMessage) {
                        clearAllSql = [clearAllSql stringByAppendingString:@" and cId != 'track' and cId != 'at_me'"];
                    } else {
                        clearAllSql = [clearAllSql stringByAppendingString:@" and cId != 'leadership' and cId != 'track' and cId != 'at_me'"];
                    }
                } else {
                    // 7.0SP4之前版本默认置顶消息：领导
                    clearAllSql = [clearAllSql stringByAppendingString:@" and cId != 'leadership'"];
                }
                
                // 将领导消息，跟踪消息，@消息置为暂无消息
                NSString *clearNewMessageSql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@', unreadCount = 0, msgId = '', gotoParams = '', senderName = '', senderFaceUrl = '' where sId = '%@' and mId = '%@' and (cId = 'leadership' or cId = 'track' or cId = 'at_me')", kMsg_NoMessage, [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
                
                if (![CMPCore sharedInstance].serverIsLaterV1_8_0) {
                    if ([NSString isNull:[CMPCore sharedInstance].messageIdentifier]) {
                        [db executeUpdate:clearAllSql];
                        [db executeUpdate:clearNewMessageSql];
                    }
                } else {
                    [db executeUpdate:clearAllSql];
                    [db executeUpdate:clearNewMessageSql];
                }
            }
            
            for (CMPMessageObject *obj in messages) {
                [obj handleForSql]; // 处理特殊字符
                // 如果是群系统消息，判断是否是最新的消息，最新的消息才更新数据库
                if (obj.type == CMPMessageTypeRCGroupNotification) {
                    NSString *unreadCountSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_GROUP_NOTIFACATION  WHERE sId = '%@' and mId = '%@' and read = 0 and hide = 0", obj.sId, [CMPCore sharedInstance].userID];
                    NSInteger unreadCount = [db intForQuery:unreadCountSql];
                    obj.unreadCount = unreadCount;
                    
                    NSString *sql = [NSString stringWithFormat:@"SELECT createTime FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND type = 4", obj.sId, [CMPCore sharedInstance].userID];
                    NSString *latestCreateTime = [db stringForQuery:sql];
                    if (![NSString isNull:latestCreateTime]) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                        NSDate *latestReceiveDate = [dateFormat dateFromString:latestCreateTime];
                        NSDate *receiveDate = [dateFormat dateFromString:obj.createTime];
                        dateFormat = nil;
                        NSComparisonResult result = [receiveDate compare:latestReceiveDate];
                        if (result != NSOrderedDescending) {
                            continue;
                        }
                    }
                }
                
                NSUInteger count = [db intForQuery:[weakself transformToCountString:obj]];
                if (count > 0) {
                    NSInteger msgIdCount = [db intForQuery:[weakself transformToMsgIdCountString:obj]];
                    if (msgIdCount == 0) {
                        update  = YES;
                    }
                    [weakself updateMessage:obj db:db];
                } else {
                    // 消息第一次进来，设置消息默认排序
                    [self updateDefaultSort:obj];
                    obj.extra1 = @"";
                    obj.extra2 = @"1"; // 默认免打扰关闭
                    [db executeUpdate:[weakself transformToInsertString:obj]];
                    update = YES;
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        }
        @finally {
            if (!isRollBack) {
                [db commit];
                if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
                    [weakself updateAppMessage:db];
                    [weakself messageDidUpdate];
                } else {
                    if (update) {
                        [weakself messageDidUpdate];
                    }
                }
            }
        }
    }];
}

// 预置置顶、排序
- (void)updateDefaultSort:(CMPMessageObject *)obj {
    if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        return;
    }
    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
//        if ([obj.cId isEqualToString:kMessageType_SmartMessage]) { // 智能消息
//            obj.topSort = -20;
//            obj.isTop = YES;
//        }
        if ([obj.cId isEqualToString:kMessageType_LeadershipMessage]) { // 领导消息
            obj.topSort = -20;
            obj.isTop = YES;
            if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
                obj.iconUrl = @"image:msg_leader_new:5544444";
            }
        } else if ([obj.cId isEqualToString:kMessageType_TrackMessage]) { // 跟踪消息
            obj.topSort = -18;
            obj.isTop = YES;
            if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
                obj.iconUrl = @"image:msg_track_new:5544444";
            }
        } else if ([obj.cId isEqualToString:kMessageType_MentionMessage]) { // @我的消息
            obj.topSort = -19;
            obj.isTop = YES;
            if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
                obj.iconUrl = @"image:msg_mention_new:11983133";
            }
        }
    } else {
        if ([obj.cId integerValue] == 1) {
            obj.topSort = -13;
            obj.isTop = YES;
        }
        else if ([obj.cId integerValue] == 4) {
            obj.topSort = -12;
            obj.isTop = YES;
        }
        else if ([obj.cId integerValue] == 7) {
            obj.topSort = -11;
            obj.isTop = YES;
        }
        else if ([obj.cId integerValue] == 6) {
            obj.topSort = -10;
            obj.isTop = YES;
        }
    }
}

- (void)deleteMessageWithCondition:(CMPMessageDbFilterCondition *)condition completion:(DeleteMessagesCompletion)completion {
    __weak typeof(self) weakself = self;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@', unreadCount = 0, msgId = '', gotoParams = '', senderName = '', senderFaceUrl = '' where sId = '%@' and mId = '%@'", kMsg_NoMessage, [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    [sql appendString:[condition conditionStr]];
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
//        [weakself messageDidUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}

- (void)deleteV5MessageOnly {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@', unreadCount = 0, msgId = '', gotoParams = '', senderName = '', senderFaceUrl = '', hide = 1 where sId = '%@' and mId = '%@' and type = 0", kMsg_NoMessage, [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)readMessageWithAppID:(NSString *)appID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET unreadCount = 0, hasUnreadMentioned = 0 WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)deleteMessageWithAppID:(NSString *)appID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET hide = 1 WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
//        [weakself messageDidUpdate];
    }];
}

- (void)clearMessageWithAppID:(NSString *)appID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@' , unreadCount = 0 WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ",kMsg_NoMessage, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

//置顶 or 取消
- (void)topMessage:(CMPMessageObject *)obj {
    NSInteger isTop = obj.isTop ? 1:0;
    NSInteger topSort =  obj.isTop ? -[[NSDate date] timeIntervalSince1970] * 1000:kTopSort_Default;
    NSString *valueStr = [NSString stringWithFormat:@"topSort = %ld, isTop = %ld",(long)topSort,(long)isTop];
    NSString *condition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@' and type = %ld",obj.cId,[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,(long)obj.type];
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET  %@ WHERE %@",valueStr,condition];
    
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
        [weakself messageDidUpdate];
    }];
}

- (void)remindMessage:(CMPMessageObject *)obj {
    NSString *remind = obj.extra2;
    NSString *appID = obj.cId;
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSUInteger count = [db intForQuery:[weakself transformToCountString:obj]];
        if (count > 0) {
          NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra2 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@'", remind, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
          [db executeUpdate:sql];
        } else {
           obj.sId = [CMPCore sharedInstance].serverID;
           [db executeUpdate:[weakself transformToInsertString:obj hide:YES]];
        }
    
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)appIDsOfAppMessage:(void(^)(NSArray *IDs))completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT cId FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' AND hide = 0",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
        FMResultSet *set = [db executeQuery:sql];
        NSMutableArray *array = [NSMutableArray array];
        while ([set next]) {
            NSString *cId = [set stringForColumn:@"cId"];
            [array addObject:cId];
        }
        completion(array);
    }];
}

- (void)updateWithMessageSettings:(NSArray<CMPV5MessageSetting *> *)settingList {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        for (CMPV5MessageSetting *setting in settingList) {
            NSString *appID = setting.appId;
            long long top = [setting.top longLongValue];
            long long sort = [NSString isNull:setting.topTime] ? kTopSort_Default : -[setting.topTime longLongValue];
            NSString *parent = setting.parent;
            if ([NSString isNull:parent]) {
                parent = @"";
            }
            NSString *remind = setting.remind;
            if ([NSString isNull:remind]) {
                remind = @"1"; // 消息免打扰默认关闭
            }
            
            NSString *sql = nil;
            if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
                sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET topSort = %ld, isTop = %ld, extra1 = '%@', extra2 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ",(long)sort, (long)top, parent, remind, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
            } else {
                sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra1 = '%@', extra2 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", parent, remind, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
            }
            [db executeUpdate:sql];
            
            //V5-60644 同一账号安卓上应用消息设置开启了部分应用消息免打扰，登录到ios设备后设置没有生效
            CMPMessageObject *obj = [[CMPMessageObject alloc] init];
            obj.cId = appID;
            obj.extra2 = remind;
            NSUInteger count = [db intForQuery:[weakself transformToCountString:obj]];
            if (count <= 0) {
                //如果没有数据，则存一次
                obj.sId = [CMPCore sharedInstance].serverID;
                [db executeUpdate:[weakself transformToInsertString:obj hide:YES]];
            }

        }
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)getTopStatusWithAppID:(NSString *)appID completion:(void(^)(BOOL isTop))completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT isTop FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND cId = '%@'",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        FMResultSet *set = [db executeQuery:sql];
        BOOL isTop = NO;
        if ([set next]) {
            int top = [set intForColumn:@"isTop"];
            if (top == 1) {
                isTop = YES;
            }
        }
        [set close];
        if (completion) {
            completion(isTop);
        }
    }];
}

- (void)getParentWithAppID:(NSString *)appID completion:(void(^)(NSString *parent))completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT extra1 FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND cId = '%@'",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        FMResultSet *set = [db executeQuery:sql];
        NSString *parent = nil;
        if ([set next]) {
            parent = [set stringForColumn:@"extra1"];
        }
        [set close];
        if (completion) {
            completion(parent);
        }
    }];
}

- (void)getSortWithAppID:(NSString *)appID completion:(void(^)(NSString *sort))completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT topSort FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND cId = '%@'",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        FMResultSet *set = [db executeQuery:sql];
        NSString *sort = nil;
        if ([set next]) {
            sort = [set stringForColumn:@"topSort"];
        }
        [set close];
        if (completion) {
            completion(sort);
        }
    }];
}

- (BOOL)getRemindWithAppID:(NSString *)appID {
    __block BOOL remind = NO;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT extra2 FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND cId = '%@'",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        FMResultSet *set = [db executeQuery:sql];
        remind = YES;
        if ([set next]) {
            NSString *remindStr = [set stringForColumn:@"extra2"];
            if ([remindStr isEqualToString:@"0"]) {
                remind = NO;
            }
        }
        [set close];
    }];
    
    return remind;
}

- (void)updateMessageExtraDataString:(CMPMessageObject *)obj {
    NSString *extraDataString = obj.extra15;
    NSString *appID = obj.cId;
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra15 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", extraDataString, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)updateMessageExtraDataString14:(NSDictionary *)val {
    if (!val || val.count == 0) {
        return;
    }
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        for (NSString *cid in val.allKeys) {
            NSString *extraDataString = val[cid];
            if ([extraDataString isKindOfClass:NSDictionary.class]) {
                extraDataString = [extraDataString JSONRepresentation];
            }
            NSString *appID = cid;
            NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra14 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", extraDataString, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
            [db executeUpdate:sql];
        }
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

#pragma mark-
#pragma mark 消息聚合

/**
 更新应用消息
 */
- (void)updateAppMessage:(FMDatabase *)db {
    if (![CMPCore sharedInstance].serverIsLaterV1_8_0 ||
        [CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        return;
    }
    
    CMPMessageObject *appMessage = [[CMPMessageObject alloc] init];
    NSString *lastV5MessageSql = [NSString stringWithFormat:@"SELECT * FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' AND hide = 0 AND content != 'msg_noMsg' ORDER BY createTime DESC LIMIT 1",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
    FMResultSet *set =  [db executeQuery:lastV5MessageSql];
    
    if ([set next]) {
        CMPMessageObject *object = [CMPMessageObject yy_modelWithDictionary:[set resultDictionary]];
        appMessage.content = [NSString stringWithFormat:@"【%@】%@", SY_STRING(object.appName), object.content];
        appMessage.createTime = object.createTime;
        appMessage.appName = @"msg_app";
        appMessage.cId = kMessageType_AppMessage;
        appMessage.topSort = kTopSort_Default;
        appMessage.type = CMPMessageTypeAggregationApp;
        appMessage.sId = [CMPCore sharedInstance].serverID;
        appMessage.iconUrl = [NSString stringWithFormat:@"image:msg_app.png:6330850"];
        appMessage.extra1 = @"";
        // 未读条数
        NSString *unreadCountAppMessageSql = [NSString stringWithFormat:@"SELECT SUM(unreadCount) FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' AND hide = 0 AND extra2 = '1'", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
        appMessage.unreadCount = [db intForQuery:unreadCountAppMessageSql];
        
        NSString *countSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND type = %ld", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, (long)CMPMessageTypeAggregationApp];
        NSUInteger countOfAppMessage = [db intForQuery:countSql];
        if (countOfAppMessage > 0) {
            [self updateMessage:appMessage db:db];
        } else {
            [db executeUpdate:[self transformToInsertString:appMessage]];
        }
        
        // 免打扰状态更新
        NSString *remind = @"1";
        NSString *selectRemindStatusSql = [NSString stringWithFormat:@"SELECT extra2 FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND type = 0 AND hide = 0 AND extra1 = '%@' AND unreadCount > 0", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
        FMResultSet *mentionSet = [db executeQuery:selectRemindStatusSql];
        while ([mentionSet next]) {
            NSString *aMention = [mentionSet stringForColumn:@"extra2"];
            if ([aMention isEqualToString:@"1"]) {
                [mentionSet close];
                remind = @"1";
                break;
            }
            remind = @"0";
        }
        NSString *updateRemindStatusSql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra2 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", remind, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
        [db executeUpdate:updateRemindStatusSql];
    } else {
        NSString *countSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' AND hide = 0", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, kMessageType_AppMessage];
        NSUInteger count = [db intForQuery:countSql];
        
        if (count > 0) { // 处理二级消息列表全是暂无内容的情况
            NSString *countSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE WHERE sId = '%@' AND mId = '%@' AND type = %ld", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, (long)CMPMessageTypeAggregationApp];
            NSUInteger countOfAppMessage = [db intForQuery:countSql];
            if (countOfAppMessage == 0) {
                appMessage.content = kMsg_NoMessage;
                appMessage.appName = @"msg_app";
                appMessage.cId = kMessageType_AppMessage;
                appMessage.createTime = @"";
                appMessage.topSort = kTopSort_Default;
                appMessage.type = CMPMessageTypeAggregationApp;
                appMessage.sId = [CMPCore sharedInstance].serverID;
                appMessage.iconUrl = [NSString stringWithFormat:@"image:msg_app.png:6330850"];
                appMessage.extra1 = @"";
                [db executeUpdate:[self transformToInsertString:appMessage]];
            }
        } else {
            // 应用消息列表所有消息都被删除，隐藏应用消息条目
            NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET hide = 1 WHERE sId = '%@' AND mId = '%@' AND type = %ld", [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, (long)CMPMessageTypeAggregationApp];
            [db executeUpdate:sql];
            [set close];
            return;
        }
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@' , unreadCount = 0, hide = 0 WHERE sId = '%@' AND mId = '%@' AND type = %ld",kMsg_NoMessage, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, (long)CMPMessageTypeAggregationApp];
        [db executeUpdate:sql];
    }
    [set close];
}

- (void)aggregationMessageWithType:(CMPMessageType)type appID:(NSString *)appID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *aggregationID = [CMPMessageObject cIDWithMessageType:type];
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra1 = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ", aggregationID, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)cancelAggregationMessageWithAppID:(NSString *)appID {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET extra1 = '' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' ",[CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID, appID];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
        [weakself messageDidUpdate];
    }];
}

- (void)deleteAppMessage {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET hide = 1 WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' OR type = %ld",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID, kMessageType_AppMessage, (long)CMPMessageTypeAggregationApp];
        [db executeUpdate:sql];
    }];
}

- (void)readAppMessage {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET unreadCount = 0 WHERE sId = '%@' AND mId = '%@' AND extra1 = '%@' OR type = %ld",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID, kMessageType_AppMessage, (long)CMPMessageTypeAggregationApp];
        [db executeUpdate:sql];
        [weakself updateAppMessage:db];
    }];
}

#pragma mark-
#pragma mark 未读条数

- (void)totalUnreadCount:(void (^)(NSInteger))completion {
    if (![CMPCore sharedInstance].inPushPeriod || ![CMPCore sharedInstance].pushAcceptInformation) {
        if (completion) {
            completion (0);
        }
        return;
    }
    
    //设置当前消息条数、应用角标
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = 0;
        if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM TB_MESSAGE where sId = '%@' and mId = '%@' and hide = 0 and type != %ld and type != %ld",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,(long)CMPMessageTypeAggregationApp, (long)CMPMessageTypeAssociate];
            FMResultSet *set =  [db executeQuery:sql];
            while ([set next]) {
                NSInteger unreadCount = 0;
                NSString *notremind = [set stringForColumn:@"extra2"];
                if (![@"1" isEqualToString:notremind]) {
                    NSString *extra15Str = [set stringForColumn:@"extra15"];
                    NSDictionary *extra15Dic = [extra15Str JSONValue];
                    if (extra15Dic && [@"1" isEqualToString:[NSString stringWithFormat:@"%@",extra15Dic[@"isMarkUnread"]]]) {
                        unreadCount = 1;
                    }
                }else{
                    unreadCount = [set intForColumn:@"unreadCount"];
                    if (unreadCount <= 0) {
                        NSString *extra15Str = [set stringForColumn:@"extra15"];
                        NSDictionary *extra15Dic = [extra15Str JSONValue];
                        if (extra15Dic && [@"1" isEqualToString:[NSString stringWithFormat:@"%@",extra15Dic[@"isMarkUnread"]]]) {
                            unreadCount = 1;
                        }
                    }
                }
                count += unreadCount;
            }
        }else{
            NSString *sql = [NSString stringWithFormat:@"SELECT unreadCount FROM TB_MESSAGE where sId = '%@' and mId = '%@' and hide = 0 and type != %ld and type != %ld and extra2 = '1'",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,(long)CMPMessageTypeAggregationApp, (long)CMPMessageTypeAssociate];
            FMResultSet *set =  [db executeQuery:sql];
            while ([set next]) {
                NSInteger unreadCount = [set intForColumn:@"unreadCount"];
                count += unreadCount;
            }
        }
        if (completion) {
            completion (count);
        }
    }];
}

#pragma mark-
#pragma mark 致信

- (void)updateGroupName:(CMPMessageObject *)obj {
    NSString *valueStr = [NSString stringWithFormat:@"appName = '%@'", obj.appName];
    NSString *condition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@'",obj.cId,obj.sId,[CMPCore sharedInstance].userID];
    NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET  %@ WHERE %@",valueStr,condition];
    
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
        [weakself messageDidUpdate];
    }];
}

// 设置置顶
- (void)setRCChatTopStatus:(CMPMessageObject *)obj type:(RCConversationType)type ext:(NSDictionary *)ext {
    NSInteger isTop = obj.isTop ? 1:0;
    NSInteger topSort;
    if (obj.isTop) {
        if (ext && ext[@"serverTopTime"]) {
            long long time = [ext[@"serverTopTime"] longLongValue];
            topSort = -time;
        }else{
            topSort = -[[NSDate date] timeIntervalSince1970];
        }
    }else{
        topSort = kTopSort_Default;
    }
    NSString *valueStr = [NSString stringWithFormat:@"topSort = %ld, isTop = %ld",(long)topSort,(long)isTop];
    NSString *serverId =[CMPCore sharedInstance].serverID;
    NSString *userID =[CMPCore sharedInstance].userID;
    
    //更新消息的Sql
    NSString *condition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@' and type = %lu and subtype = %lu ",obj.cId,serverId,userID,(unsigned long)obj.type, (unsigned long)type];
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET  %@ WHERE %@",valueStr,condition];
    
    //群是否有消息Sql
    NSString *existCondition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@' and type = %lu and subtype = %lu",obj.cId,serverId,userID,(unsigned long)obj.type, (unsigned long)type];
    NSString *existSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE  WHERE %@",existCondition];
    
    if ([NSString isNull:obj.appName]) {
        obj.appName = SY_STRING(kMsg_NoMessage);
    }
    
    __weak typeof(self) weakself = self;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        NSUInteger count = [db intForQuery:existSql];
        if (count >0) {
            [db executeUpdate:updateSql];
        }
        else {
            [db executeUpdate:[weakself transformToInsertString:obj]];
        }
        [weakself messageDidUpdate];
    }];
}

- (void)getRCChatTopStatusWithTargetId:(NSString *)targetId type:(RCConversationType)type completion:(void (^)(BOOL))completion {
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT  isTop FROM TB_MESSAGE where cId = '%@' and sId = '%@' and mId = '%@' and type = 1 and subtype = %lu ",targetId,[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID, (unsigned long)type];
        BOOL istop = NO;
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            istop = [set intForColumn:@"isTop"] == kTopTag_Top ? YES:NO;
        }
        completion(istop);
    }];
}

- (void)clearRCChatMsgWithTargetId:(NSString *)targetId type:(RCConversationType)type {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@' WHERE sId = '%@' AND mId = '%@' AND cId = '%@' AND type = 1 AND subtype = %lu", SY_STRING(kMsg_NoMessage),[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,targetId, (unsigned long)type];
        [db executeUpdate:sql];
        [weakself messageDidUpdate];
    }];
}

- (void)clearRCGroupNotification {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSDate *date = [NSDate date];
        long long time = [date timeIntervalSince1970] * 1000;
        NSString *sql = [NSString stringWithFormat:@"UPDATE TB_MESSAGE SET content = '%@',receiveTime = '%@',unreadCount=0,hide=1 WHERE sId = '%@' AND mId = '%@' AND type = 4", SY_STRING(kMsg_NoMessage), [CMPDateHelper dateStrFromLongLong:time] , [CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID];
        [db executeUpdate:sql];
        [weakself messageDidUpdate];
    }];
}

#pragma mark-
#pragma mark 关联账号

- (void)saveAssociateMessage:(CMPMessageObject *)message {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSUInteger count = [db intForQuery:[weakself transformToCountString:message]];
        if (count > 0) {
            [weakself updateMessage:message db:db];
        } else {
            [db executeUpdate:[weakself transformToInsertString:message]];
        }
        [weakself messageDidUpdate];
    }];
}

- (void)deleteAssociateMessage {
    __weak typeof(self) weakself = self;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM TB_MESSAGE WHERE cId = ? and type = ? and sId = ? and mId = ?",kMessageType_AssociateMessage, [NSNumber numberWithInteger:CMPMessageTypeAssociate], [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID];
        [weakself messageDidUpdate];
    }];
}

#pragma mark-
#pragma mark SQL

//appid 对应的消息条数sql
- (NSString *)transformToCountString:(CMPMessageObject *)obj
{
    NSString *condition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@' and type = %ld and subtype = %ld",obj.cId,[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,(long)obj.type,(long)obj.subtype];
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE  WHERE %@",condition];
    return sql;
}

//appid msgId 对应的消息条数sql
- (NSString *)transformToMsgIdCountString:(CMPMessageObject *)obj {
    NSString *condition = [NSString stringWithFormat:@"cId = '%@' and sId = '%@' and mId = '%@' and type = %ld and msgId = '%@' and unreadCount = '%ld'",obj.cId,obj.sId,[CMPCore sharedInstance].userID,(long)obj.type,obj.msgId,(long)obj.unreadCount];
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM TB_MESSAGE  WHERE %@",condition];
    return sql;
}

//插入数据库sql
- (NSString *)transformToInsertString:(CMPMessageObject *)obj {
   return [self transformToInsertString:obj hide:NO];
}

- (NSString *)transformToInsertString:(CMPMessageObject *)obj hide:(BOOL)isHide {
    NSInteger isTop = obj.isTop ? kTopTag_Top: kTopTag_NotTop;//置顶
    NSString *valusString = [NSString stringWithFormat:@"'%@',%ld,%ld,%ld,%ld,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',%ld,'%@','%@',%ld,'%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",obj.cId,(long)obj.topSort,(long)obj.type,(long)obj.unreadCount,(long)obj.hasUnreadMentioned,obj.timeStamp,obj.content,obj.appName ?: @"未知",obj.iconUrl,obj.createTime,obj.senderName,obj.sId,obj.senderFaceUrl,obj.msgId,obj.receiveTime,(long)isTop,obj.latestMessage,[CMPCore sharedInstance].userID,(long)obj.subtype,obj.gotoParams,isHide?1 :0,obj.extra1,obj.extra2,obj.extra3,obj.extra4,obj.extra5,obj.extra6,obj.extra7,obj.extra8,obj.extra9,obj.extra10,obj.extra11,obj.extra12,obj.extra13,obj.extra14,obj.extra15];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO TB_MESSAGE (cId,topSort,type,unreadCount,hasUnreadMentioned,timeStamp,content,appName,iconUrl,createTime,senderName,sId,senderFaceUrl,msgId,receiveTime,isTop,latestMessage,mId,subtype,gotoParams,hide,extra1,extra2,extra3,extra4,extra5,extra6,extra7,extra8,extra9,extra10,extra11,extra12,extra13,extra14,extra15) VALUES (%@)",valusString];
    return sql;
}

//更新数据库Sql
- (void)updateMessage:(CMPMessageObject *)obj db:(FMDatabase *)db {
    if (![NSString isNull:obj.appName]) { // appName不为空才更新appName
        if (![NSString isNull:obj.createTime]) {
            [db executeUpdate:@"UPDATE TB_MESSAGE SET unreadCount = ?, hasUnreadMentioned = ?, content = ?, createTime = ?, senderName = ?, senderFaceUrl = ?, msgId = ?, receiveTime = ?, latestMessage = ? , gotoParams = ?, appName = ?, iconUrl = ? , hide = 0 , extra15 = ? ,subtype = ? WHERE cId = ? and sId = ? and mId = ? and type = ? and subtype = ?", [NSNumber numberWithInteger:obj.unreadCount],[NSNumber numberWithInteger:obj.hasUnreadMentioned], obj.content, obj.createTime, obj.senderName, obj.senderFaceUrl, obj.msgId, obj.receiveTime, obj.latestMessage, obj.gotoParams, obj.appName, obj.iconUrl, obj.extra15 , [NSNumber numberWithInteger:obj.subtype], obj.cId, obj.sId, [CMPCore sharedInstance].userID, [NSNumber numberWithInteger:obj.type],[NSNumber numberWithInteger:obj.subtype]];
        } else {
            [db executeUpdate:@"UPDATE TB_MESSAGE SET unreadCount = ?, hasUnreadMentioned = ?, content = ?, senderName = ?, senderFaceUrl = ?, msgId = ?, receiveTime = ?, latestMessage = ? , gotoParams = ?, appName = ?, iconUrl = ? , hide = 0 , extra15 = ? ,subtype = ? WHERE cId = ? and sId = ? and mId = ? and type = ? and subtype = ?", [NSNumber numberWithInteger:obj.unreadCount],[NSNumber numberWithInteger:obj.hasUnreadMentioned], obj.content, obj.senderName, obj.senderFaceUrl, obj.msgId, obj.receiveTime, obj.latestMessage, obj.gotoParams, obj.appName, obj.iconUrl, obj.extra15, [NSNumber numberWithInteger:obj.subtype], obj.cId, obj.sId, [CMPCore sharedInstance].userID, [NSNumber numberWithInteger:obj.type],[NSNumber numberWithInteger:obj.subtype]];
        }
    } else {
        if (![NSString isNull:obj.createTime]) {
            [db executeUpdate:@"UPDATE TB_MESSAGE SET unreadCount = ?, hasUnreadMentioned = ?, content = ?, createTime = ?, senderName = ?, senderFaceUrl = ?, msgId = ?, receiveTime = ?, latestMessage = ?, gotoParams = ?, iconUrl = ?, hide = 0 , extra15 = ? ,subtype = ? WHERE cId = ? and sId = ? and mId = ? and type = ? and subtype = ?", [NSNumber numberWithInteger:obj.unreadCount], [NSNumber numberWithInteger:obj.hasUnreadMentioned], obj.content, obj.createTime, obj.senderName, obj.senderFaceUrl, obj.msgId, obj.receiveTime, obj.latestMessage, obj.gotoParams, obj.iconUrl, obj.extra15,[NSNumber numberWithInteger:obj.subtype], obj.cId, obj.sId, [CMPCore sharedInstance].userID, [NSNumber numberWithInteger:obj.type],[NSNumber numberWithInteger:obj.subtype]];
        } else {
            [db executeUpdate:@"UPDATE TB_MESSAGE SET unreadCount = ?, hasUnreadMentioned = ?, content = ?, senderName = ?, senderFaceUrl = ?, msgId = ?, receiveTime = ?, latestMessage = ?, gotoParams = ?, iconUrl = ?, hide = 0 , extra15 = ? ,subtype = ? WHERE cId = ? and sId = ? and mId = ? and type = ? and subtype = ?", [NSNumber numberWithInteger:obj.unreadCount], [NSNumber numberWithInteger:obj.hasUnreadMentioned], obj.content, obj.senderName, obj.senderFaceUrl, obj.msgId, obj.receiveTime, obj.latestMessage, obj.gotoParams, obj.iconUrl, obj.extra15, [NSNumber numberWithInteger:obj.subtype], obj.cId, obj.sId, [CMPCore sharedInstance].userID, [NSNumber numberWithInteger:obj.type],[NSNumber numberWithInteger:obj.subtype]];
        }
    }
}

#pragma mark-
#pragma mark Getter & Setter

- (FMDatabaseQueue *)dataQueue {
    if (!_dataQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:kLocalMessageDBName];
        _dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
        //_dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
        __weak typeof(self) weakself = self;
        [_dataQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:[weakself createSql]];
            if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
                return;
            }
            else if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
//                [weakself initSmartMessage:db];
                [weakself initLeaderMessage:db];
                [weakself initTrackMessage:db];
                [weakself initMentionMessage:db];
            }
        }];
    }
    return _dataQueue;
}

- (CMPMessageObject *)emptyAppMessage {
    CMPMessageObject *obj = [[CMPMessageObject alloc] init];
    obj.type = CMPMessageTypeApp;
    obj.content = kMsg_NoMessage;
    obj.sId = [CMPCore sharedInstance].serverID;
    obj.createTime = [CMPDateHelper getCurrentDateStr];
    obj.extra1 = @"";
    obj.extra2 = @"1"; // 消息默认免打扰
    return obj;
}

- (void)initMessage:(CMPMessageObject *)message db:(FMDatabase *)db {
    NSUInteger count = [db intForQuery:[self transformToCountString:message]];
    if (count == 0) {
        [self updateDefaultSort:message];
        [db executeUpdate:[self transformToInsertString:message]];
    }
}

// 预置智能推送提醒
- (void)initSmartMessage:(FMDatabase *)db {
    NSString *configInfoStr = [CMPCore sharedInstance].currentUser.configInfo;
    CMPLoginConfigInfoModel_2 *configInfo = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:configInfoStr];
    if (!configInfo.config.hasAIPlugin) { // 没有AI插件，不预置智能消息
        return;
    }
    
    CMPMessageObject *obj = [self emptyAppMessage];
    obj.cId = kMessageType_SmartMessage;
    obj.appName = @"msg_push";
    obj.iconUrl = @"image:msg_push.png:7569911";
    [self initMessage:obj db:db];
}

// 预置我的领导消息
- (void)initLeaderMessage:(FMDatabase *)db {
    CMPMessageObject *obj = [self emptyAppMessage];
    obj.cId = kMessageType_LeadershipMessage;
    obj.appName = @"msg_leader";
    obj.iconUrl = @"image:msg_leader.png:5544444";
    [self initMessage:obj db:db];
}

// 预置跟踪消息
- (void)initTrackMessage:(FMDatabase *)db {
    CMPMessageObject *obj = [self emptyAppMessage];
    obj.cId = kMessageType_TrackMessage;
    obj.appName = @"msg_track";
    obj.iconUrl = @"image:msg_track.png:5544444";
    [self initMessage:obj db:db];
}

// 预置@我的消息
- (void)initMentionMessage:(FMDatabase *)db {
    CMPMessageObject *obj = [self emptyAppMessage];
    obj.cId = kMessageType_MentionMessage;
    obj.appName = @"msg_mention";
    obj.iconUrl = @"image:msg_mention.png:11983133";
    [self initMessage:obj db:db];
}


#pragma mark-
#pragma mark SQL语句

- (NSString *)createSql
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS [TB_MESSAGE] (\
    [sId] TEXT, \
    [mId] TEXT,\
    [cId] TEXT, \
    [topSort] INTEGER, \
    [type] INTEGER, \
    [unreadCount] INTEGER, \
    [timeStamp] TEXT, \
    [content] TEXT, \
    [appName] TEXT, \
    [iconUrl] TEXT, \
    [createTime] INTEGER, \
    [senderName] TEXT, \
    [senderFaceUrl] TEXT, \
    [msgId] TEXT, \
    [receiveTime] TEXT, \
    [isTop] INTEGER, \
    [hasUnreadMentioned] INTEGER, \
    [gotoParams] TEXT ,\
    [latestMessage] TEXT ,\
    [subtype] INTEGER ,\
    [hide] INTEGER, \
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

@end

#pragma mark-
#pragma mark CMPMessageDbFilterCondition

@interface CMPMessageDbFilterCondition()
@property (strong, nonatomic) NSMutableDictionary *containConditions;
@property (strong, nonatomic) NSMutableDictionary *exceptConditions;
@end

@implementation CMPMessageDbFilterCondition

- (void)containKey:(NSString *)key values:(NSArray *)values {
    [self addKey:key values:values toDictionary:self.containConditions];
}

- (void)exceptKey:(NSString *)key values:(NSArray *)values {
    [self addKey:key values:values toDictionary:self.exceptConditions];
}

- (void)addKey:(NSString *)key values:(NSArray *)values toDictionary:(NSMutableDictionary *)dic {
    if ([NSString isNull:key] ||
        !values || ![values isKindOfClass:[NSArray class]] ||
        !dic || ![dic isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    NSMutableArray *oldValues = [dic objectForKey:key];
    if (!oldValues) {
        oldValues = [NSMutableArray array];
    }
    [oldValues addObjectsFromArray:values];
    [dic setObject:oldValues forKey:key];
}

- (NSString *)conditionStr {
    NSMutableString *condition = [NSMutableString string];
    
    for (NSString *key in self.containConditions) {
        NSArray *values = self.containConditions[key];
        for (id value in values) {
            NSString *str = [NSString stringWithFormat:@" and %@ = '%@' ", key, value];
            [condition appendString:str];
        }
    }
    
    for (NSString *key in self.exceptConditions) {
        NSArray *values = self.exceptConditions[key];
        for (id value in values) {
            NSString *str = [NSString stringWithFormat:@" and %@ != '%@' ", key, value];
            [condition appendString:str];
        }
    }
    
    return condition;
}


- (NSMutableDictionary *)containConditions {
    if (!_containConditions) {
        _containConditions = [NSMutableDictionary dictionary];
    }
    return _containConditions;
}

- (NSMutableDictionary *)exceptConditions {
    if (!_exceptConditions) {
        _exceptConditions = [NSMutableDictionary dictionary];
    }
    return _exceptConditions;
}

@end
