//
//  CMPRCUserCacheManager.m
//  CMPCore
//
//  Created by CRMO on 2017/8/22.
//
//

#import "CMPRCUserCacheManager.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDateHelper.h>
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/FMDatabaseQueueFactory.h>
#import "RCIM+InfoCache.h"

static NSString const *TB_NAME = @"TB_GROUP_USER";

@interface CMPRCUserCacheManager()<CMPDataProviderDelegate>

@property (nonatomic, strong) FMDatabaseQueue *dataQueue;
@property (nonatomic, strong) NSMutableDictionary *requestMap; // 网络请求队列

@end

@implementation CMPRCUserCacheManager

#pragma mark -
#pragma mark -Init

- (void)dealloc {
    [_requestMap removeAllObjects];
    SY_RELEASE_SAFELY(_requestMap);
    [_dataQueue release];
    _dataQueue = nil;
    [super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        [self createSqlite];
        if (!_requestMap) {
            _requestMap = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

#pragma mark -
#pragma mark -数据接口

- (void)setCache:(NSArray<CMPRCUserCacheObject *> *)users {
    if (!users || ![users isKindOfClass:[NSArray class]]) {
        NSLog(@"RC---CMPRCUserCacheManager setCache Error:userCache is nil or not a NSArray");
        return;
    }
    
    [_dataQueue inDatabase:^(FMDatabase *db) {
        for (CMPRCUserCacheObject *user in users) {
            if (!user || ![user isKindOfClass:[CMPRCUserCacheObject class]]) {
                NSLog(@"RC---CMPRCUserCacheManager setCache Error:user is nil or not a CMPRCUserCacheObject");
                continue;
            }
            
            if ([user.userId isEqualToString:[CMPCore sharedInstance].userID]) {
                continue;
            }
            
//            NSString *lastUpadateTime = [db stringForQuery:[CMPRCUserCacheManager queryUpdateTimeSql:user.userId]];
//            if (lastUpadateTime) { // 有记录，判断set的缓存是否是最新的
//                NSDateFormatter *format = [[NSDateFormatter alloc] init];
//                [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                NSDate *lastUpdateDate = [format dateFromString:lastUpadateTime];
//                NSDate *updateDate = [format dateFromString:user.updateTime];
//                [format release];
//                format = nil;
//                
//                if ([updateDate timeIntervalSinceDate:lastUpdateDate] > 0) {
//                    // 先缓存到融云
//                    NSString *portrait =[CMPCore memberIconUrlWithId:user.userId];
//                    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:user.userId name:user.name portrait:portrait];
//                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:user.userId];
//                    [userInfo release];
//                    userInfo = nil;
//
            [[RCIM sharedRCIM] refreshUserNameCache:user.name withUserId:user.userId];
            [db executeUpdate:[CMPRCUserCacheManager deleteSql:user.userId]];
            [db executeUpdate:[CMPRCUserCacheManager insertSql:user]];
//                }
//            } else { // 没有记录，直接缓存
//                [db executeUpdate:[CMPRCUserCacheManager insertSql:user]];
//            }
        }
    }];
}

- (void)getUserName:(NSString *)userId groupId:(NSString *)groupId done:(UserNameDoneBlock)block {
    if ([NSString isNull:userId]) {
        block(@"");
        return;
    }
    
    __weak CMPRCUserCacheManager *weakself = self;
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[CMPRCUserCacheManager querySql:userId]];
        NSMutableArray *array = [NSMutableArray array];
        
        while ([set next]) {
            [array addObject:[set stringForColumn:@"name"]];
        }
        
        if (array.count > 0) { // 数据库有缓存直接返回
            block([array lastObject]);
        } else { // 没有缓存刷新群组缓存
            [weakself refreshCache:groupId userId:userId done:block];
        }
        
        [array removeAllObjects];
        array = nil;
    }];
}

- (void)getUserName:(NSString *)userId done:(UserNameDoneBlock)block {
    if ([NSString isNull:userId]) {
        block(@"");
        return;
    }
    
    [_dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:[CMPRCUserCacheManager querySql:userId]];
        NSMutableArray *array = [NSMutableArray array];
        
        while ([set next]) {
            [array addObject:[set stringForColumn:@"name"]];
        }
        
        if (array.count > 0) { // 数据库有缓存直接返回
            block([array lastObject]);
        }
        
        [array removeAllObjects];
        array = nil;
    }];
}

- (void)clearAllCache {
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCUserCacheManager deleteAllSql]];
    }];
}

- (void)refreshCache:(NSString *)groupId {
    if ([NSString isNull:groupId]) {
        return;
    }
    
    NSMutableArray *array = [_requestMap objectForKey:groupId];
    if (array) { // 正在请求进行网络请求
        return;
    } else {
        array = [NSMutableArray array];
        [_requestMap setObject:array forKey:groupId];
    }
    
    __weak CMPRCUserCacheManager *weakself = self;
    [self dispatchAsyncToChild:^{
        [weakself refreshFromNetwork:groupId];
    }];
}

- (void)refreshCache:(NSString *)groupId userId:(NSString *)userId done:(UserNameDoneBlock)block {
    if ([NSString isNull:groupId] ||
        [NSString isNull:userId]) {
        return;
    }
    
    NSMutableArray *array = [_requestMap objectForKey:groupId];
    CMPRCBlockObject *object = [[CMPRCBlockObject alloc] init];
    object.userNameDoneBlock = block;
    NSDictionary *dic = @{@"userId" : userId,
                          @"blockObj" : object};
    
    if (array) { // 正在请求进行网络请求
        [array addObject:dic];
        return;
    } else {
        array = [NSMutableArray array];
        [array addObject:dic];
        [_requestMap setObject:array forKey:groupId];
    }
    
    __weak CMPRCUserCacheManager *weakself = self;
    [self dispatchAsyncToChild:^{
        [weakself refreshFromNetwork:groupId];
    }];
    
    [object release];
    object = nil;
}

- (void)refreshCache:(NSString *)groupId  done:(GroupNameDoneBlock)block {
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/groups/bygid/%@",groupId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers =  [CMPDataProvider headers];;
    aDataRequest.timeout = 30;
    NSMutableDictionary *mUserInfo = [NSMutableDictionary dictionary];
    mUserInfo[@"groupId"] = groupId;
    mUserInfo[@"GroupNameDoneBlock"] = [block copy];
    aDataRequest.userInfo = [mUserInfo copy];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

#pragma -mark CMPDataProviderDelegate

- (void)refreshFromNetwork:(NSString *)groupId {
//    NSString *url = [NSString stringWithFormat:@"%@/seeyon/rest/uc/rong/groups/bygid/%@",[CMPCore sharedInstance].serverurl, groupId];
//    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
//    aDataRequest.requestUrl = url;
//    aDataRequest.delegate = self;
//    aDataRequest.requestMethod = @"GET";
//    aDataRequest.headers =  [CMPDataProvider headers];;
//    aDataRequest.timeout = 30;
//    aDataRequest.userInfo = @{@"groupId" : groupId};
//    aDataRequest.requestType = kDataRequestType_Url;
//    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
//    [aDataRequest release];
    [self refreshCache:groupId done:nil];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    __weak CMPRCUserCacheManager *weakself = self;
    [self dispatchAsyncToChild:^{
        NSString *responseStr = [aResponse responseStr];
        if ([NSString isNull:responseStr]) {
            return;
        }
        NSDictionary *responseData = [responseStr JSONValue];
        // 如果responseData不是NSDictionary则返回
        if (![responseData isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *status = responseData[@"status"];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *groupId = userInfo[@"groupId"];
        GroupNameDoneBlock groupNameDoneBlock = userInfo[@"GroupNameDoneBlock"];
        NSMutableDictionary *userCacheDic = [NSMutableDictionary dictionary];
        if (![NSString isNull:status] && [status isEqualToString:@"ok"])
        {
            NSDictionary *groupDic = responseData[@"group"];
            if (![groupDic isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            NSString *groupName = groupDic[@"n"];
            NSDictionary *newGroupInfo = @{@"groupName" : groupName,
                                           @"groupId" : groupId};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ChangeGroupName object:newGroupInfo];
            if (groupNameDoneBlock) {
                groupName = [NSString isNotNull:groupName] ? groupName : @"";
                groupNameDoneBlock(groupName);
            }
            
            NSArray *memberList = groupDic[@"ma"];
            if (![memberList isKindOfClass:[NSArray class]]) {
                return;
            }
            
            NSMutableArray *userArray = [NSMutableArray array];
            for (NSString *member in memberList) {
                if ([NSString isNull:member]) {
                    continue;
                }
                NSDictionary *memberDic = [member JSONValue];
                if (![memberDic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSString *name = memberDic[@"name"];
                NSString *userId = memberDic[@"id"];
                
                if ([NSString isNull:name] ||
                    [NSString isNull:userId]) {
                    continue;
                }
                
                CMPRCUserCacheObject *user = [[CMPRCUserCacheObject alloc] init];
                user.sId = [CMPCore sharedInstance].serverID;
                user.mId = [CMPCore sharedInstance].userID;
                user.updateTime = [CMPDateHelper dateStrFromLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
                user.name = name;
                user.userId = userId;
                user.groupId = groupId;
                [userCacheDic setObject:name forKey:userId];
                [userArray addObject:user];
                [user release];
                user = nil;
            }
            [weakself setCache:userArray];
            [userArray removeAllObjects];
            userArray = nil;
        }
        
        NSMutableArray *blocks = [_requestMap objectForKey:groupId];
        NSArray *blocksTmp = [blocks copy];
        
        for (NSDictionary *dic in blocksTmp) {
            CMPRCBlockObject *object = dic[@"blockObj"];
            UserNameDoneBlock block = object.userNameDoneBlock;
            NSString *userId = dic[@"userId"];
            block([userCacheDic objectForKey:userId]);
        }
        
        [blocks removeObjectsInArray:blocksTmp]; // 回调完从队列中移除
        [blocksTmp release];
        blocksTmp = nil;
        
        if (blocks.count == 0) {
            [_requestMap removeObjectForKey:groupId];
        }
        
        [userCacheDic removeAllObjects];
        userCacheDic = nil;
    }];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSDictionary *userInfo = aRequest.userInfo;
    NSString *groupId = userInfo[@"groupId"];
    NSMutableArray *blocks = [_requestMap objectForKey:groupId];
    NSArray *blocksTmp = [NSArray arrayWithArray:blocks];
    for (NSDictionary *dic in blocksTmp) {
        CMPRCBlockObject *object = dic[@"blockObj"];
        UserNameDoneBlock block = object.userNameDoneBlock;
        block(nil);
    }
    [blocks removeObjectsInArray:blocksTmp];
    if (blocks.count == 0) {
        [_requestMap removeObjectForKey:groupId];
    }
    GroupNameDoneBlock groupNameDoneBlock = userInfo[@"GroupNameDoneBlock"];
    if (groupNameDoneBlock) {
        groupNameDoneBlock(@"");
    }
}

#pragma mark -
#pragma mark -数据库操作

- (void)createSqlite {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"RCUserCache.db"];
    self.dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
    //self.dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
    [_dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[CMPRCUserCacheManager createSql]];
    }];
}

+ (NSString *)createSql {
    NSString *sql = [NSString
                     stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@] (\
                     [sId] TEXT, \
                     [mId] TEXT,\
                     [groupId] TEXT,\
                     [type] INTEGER, \
                     [userId] TEXT, \
                     [name] TEXT, \
                     [updateTime] TEXT, \
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
                     [extra15] TEXT)", TB_NAME];
    return sql;
}

+ (NSString *)insertSql:(CMPRCUserCacheObject *)user {
    NSString *value = [NSString stringWithFormat:@"'%@', '%@', '%ld', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@'", user.sId, user.groupId, user.type, user.userId, user.name, user.updateTime, user.extra1, user.extra2, user.extra3, user.extra4, user.extra5, user.extra6, user.extra7, user.extra8, user.extra9, user.extra10, user.extra11, user.extra12, user.extra13, user.extra14, user.extra15];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ \
                     (sId,groupId,type,userId,name,updateTime,\
                     extra1,extra2,extra3,extra4,extra5,extra6,extra7,extra8,extra9,extra10,extra11,extra12,extra13,extra14,extra15)\
                     VALUES (%@)", TB_NAME, value];
    return sql;
}

+ (NSString *)querySql:(NSString *)userId {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE sId = '%@' AND userId = '%@'", TB_NAME, [CMPCore sharedInstance].serverID, userId];
    return sql;
}

+ (NSString *)queryUpdateTimeSql:(NSString *)userId {
    NSString *sql = [NSString stringWithFormat:@"SELECT updateTime FROM %@ WHERE sId = '%@' AND userId = '%@'", TB_NAME, [CMPCore sharedInstance].serverID, userId];
    return sql;
}

+ (NSString *)deleteSql:(NSString *)userId {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE sId = '%@' AND userId = '%@'", TB_NAME, [CMPCore sharedInstance].serverID, userId];
    return sql;
}

+ (NSString *)deleteAllSql {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE sId = '%@'", TB_NAME, [CMPCore sharedInstance].serverID];
    return sql;
}



@end
