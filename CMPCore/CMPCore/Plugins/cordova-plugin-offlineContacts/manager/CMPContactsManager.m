//
//  CMPContactsManager.m
//  CMPCore
//
//  Created by wujiansheng on 2016/12/28.
//
//

#define kOfflinePrepareUrl @"/rest/m3/contacts/offline/prepare"
#define kOfflineCheckUrl @"/rest/m3/contacts/offline/check"
#define kOfflineAccountSetUrl @"/rest/m3/contacts/offline/accountSet"
#define kShowPeopleCardUrl @"/rest/m3/contacts/showPeopleCard/%@"
#define kRequestType_Prepqre @"prepare"
#define kRequestType_Check @"check"
#define kRequestType_AccountSet @"accountSet"
#define kRequestType_Download @"download"
#define kRequestKey @"requestKey"

#define kDownload_record @"0"//记录下，还没下载
#define kDownload_loading @"1"//正在下载
#define kDownload_finish @"2"//下载完成
#define kDownload_fail @"3"//下载失败
#define kOfflineStatusKey @"kOfflineUpdateStatusKey"

#define kmd5Value @"md5Value_seeyon"

#import "CMPContactsManager.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/FMDB.h>
#import <CMPLib/NSString+CMPString.h>
#import "CMPContactsRelationManager.h"

#import <CMPLib/CMPOfflineContactMember.h>

#import "MAccountAvailableEntity.h"
#import "MAccountSetting.h"
#import <CMPLib/JSONKit.h>
#import <CMPLib/NSObject+AutoMagicCoding.h>
#import "CMPContactsDownloadManager.h"
#import "CMPCallIdentificationHelper.h"
#import "CMPCommonManager.h"

#import "CMPFlowRelationManager.h"
#import <CMPLib/FMDatabaseQueueFactory.h>

@interface FMDatabaseQueue(CMPCustom)

- (void)inDatabaseBackground:(void (^)(FMDatabase *))block;

@end

@implementation FMDatabaseQueue(CMPCustom)

- (void)inDatabaseBackground:(void (^)(FMDatabase *))block {
    static dispatch_queue_t contactSerialqueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!contactSerialqueue) {
            contactSerialqueue = dispatch_queue_create("contactSerialqueue", DISPATCH_QUEUE_SERIAL);
        }
    });
    dispatch_async(contactSerialqueue, ^{
        [self inDatabase:block];
    });
}

@end


@interface CMPContactsManager()<CMPContactsDownloadManagerDelegate,CMPDataProviderDelegate> {
    CMPContactsDownloadManager *_downloadManager;
    BOOL _tableChanged;
 }
@property(nonatomic,copy)NSString *serverId;
@property(nonatomic,copy)NSString *accountId;
@property(nonatomic,copy)NSString *dbPath;
@property (nonatomic, retain) FMDatabaseQueue *contactsQueue;
@property (nonatomic,copy) NameBlock nameBlock;
@property (nonatomic, retain) CMPCallIdentificationHelper *callIdentificationHelper;
@property(nonatomic,retain)NSDictionary *accountSetDic;
@property (retain, nonatomic) NSMutableDictionary<NSString *, NSArray *> *allMembers;

@end

@implementation CMPContactsManager
static CMPContactsManager *instance = nil;

- (void)dealloc
{
    SY_RELEASE_SAFELY(_accountSetDic);
    SY_RELEASE_SAFELY(_serverId);
    SY_RELEASE_SAFELY(_accountId);

    SY_RELEASE_SAFELY(_dbPath);
    [_contactsQueue close];
    SY_RELEASE_SAFELY(_contactsQueue);
    SY_RELEASE_SAFELY(_downloadManager);
    self.nameBlock = nil;
    [_allMembers removeAllObjects];
    SY_RELEASE_SAFELY(_allMembers);
    SY_RELEASE_SAFELY(_callIdentificationHelper);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

+ (CMPContactsManager *)defaultManager
{
    if (!instance) {
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:kNotificationName_UserLogout object:nil];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self defaultManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


//网络是否可用
-(BOOL)netConnectAble
{
//    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
//        return NO;
//    }
//    return YES;
    return [CMPCommonManager reachableNetwork];
}

//发送通知
- (void)postNotificationName:(NSString *)name {
    [self dispatchAsyncToMain:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    }];
}

//用户退出登陆需要停止更新
- (void)userLogout {
    [_downloadManager clearData];
    [_allMembers removeAllObjects];
//    [_callIdentificationHelper closeCallIdentification];
    SY_RELEASE_SAFELY(_downloadManager);
}



- (void)beginUpdate
{
    self.accountId = [CMPCore sharedInstance].currentUser.accountID;
    BOOL changeServer = self.contactsQueue && [self.serverId isEqualToString:[CMPCore sharedInstance].serverID];
    [self connectSQLite3];
    if (![self netConnectAble] ||
        ![CMPCommonManager reachableServer]) {
        [self postNotificationName:kContactsUpdate_Fail];
        return;
    }
    
    //最近联系人
    [self requestFrequentContacts];

    [self postNotificationName:kContactsUpdate_Begin];
    [self beginUpdateOfflineContacts];

    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        OfflineStatus status = [self offlineStatus];
        if (!changeServer && status == OfflineStatusUpating) {
            [CMPContactsTableManager clearTable:db];
        }
        
        if (!_downloadManager) {
            _downloadManager = [[CMPContactsDownloadManager alloc] init];
        }
        
        self.accountSetDic = [CMPContactsTableManager getAccountSetting:db];
        NSDictionary *md5Dic = [CMPContactsTableManager getAllupdateLog:db aId:self.accountId sId:self.serverId];
        
        NSString *accountId = [CMPCore sharedInstance].currentUser.accountID;
        NSString *setMd5 = [self.accountSetDic objectForKey:accountId];
        NSDictionary *d = [NSString isNull:setMd5]?[NSDictionary dictionary]:[NSDictionary dictionaryWithObject:setMd5 forKey:accountId];
        NSString *setting = [d JSONRepresentation];
        [self dispatchAsyncToMain:^{
            [_downloadManager updateContactsWithMD5Dic:md5Dic settingInfo:setting delegate:self];
        }];
    }];
}

//连接数据库
- (void)connectSQLite3 {
    if (self.contactsQueue) {
        if ([self.serverId isEqualToString:[CMPCore sharedInstance].serverID]) {
            NSString *currentId = [CMPCore sharedInstance].userID;
            NSString *key = @"currentContactsUser";
            NSString *preId = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (![currentId isEqualToString:preId] ) {
                //切换了人员 把临时表删了
                [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
                    //创建表
                    [CMPContactsTableManager createTables:db];
                    // post level 默认有 -1 的值
                    [CMPContactsTableManager defaultValusForTables:db];
                    [CMPContactsTableManager dropTempTable:db];
                }];
            }
            else {
                [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
                    //创建表
                    [CMPContactsTableManager createTables:db];
                    // post level 默认有 -1 的值
                    [CMPContactsTableManager defaultValusForTables:db];
                }];
            }
            return;
        }
        [_downloadManager clearData];
        SY_RELEASE_SAFELY(_downloadManager);
    }
    self.serverId = [CMPCore sharedInstance].serverID;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSString *localContactsName = [NSString stringWithFormat:@"contacts_table_%@_V1_encrypt.sqlite",self.serverId];
    SY_RELEASE_SAFELY(_dbPath);
    self.dbPath = [documentsPath stringByAppendingPathComponent:localContactsName];
    [_contactsQueue close];
    SY_RELEASE_SAFELY(_contactsQueue);
//    self.contactsQueue = [FMDatabaseQueueFactory databaseQueueWithPath:_dbPath encrypt:YES];
    self.contactsQueue = [FMDatabaseQueueFactory databaseQueueWithPath:_dbPath encrypt:YES];
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        //创建表
        [CMPContactsTableManager createTables:db];
        // post level 默认有 -1 的值
        [CMPContactsTableManager defaultValusForTables:db];
        
        NSString *currentId = [CMPCore sharedInstance].userID;
        NSString *key = @"currentContactsUser";
        NSString *preId = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (![currentId isEqualToString:preId] ) {
            //切换了人员 把临时表删了
            [CMPContactsTableManager dropTempTable:db];
        }
    }];
}


//开始更新处理
-(void)beginUpdateOfflineContacts {
    [self setupOfflineStatus:OfflineStatusUpating];
    [self postNotificationName:kContactsUpdate_Begin];
}
//更新完成处理
- (void)endUpdateOfflineContacts:(FMDatabase *)db {
    _tableChanged = NO;
    [self allMembersCompletion:^(NSArray<CMPOfflineContactMember *> *allMembers) {
        if (!allMembers || allMembers.count == 0) {
            [self setupOfflineStatus:OfflineStatusFail];
            [self postNotificationName:kContactsUpdate_Fail];
        } else {
            [self setupOfflineStatus:OfflineStatusFinish];
            [self postNotificationName:kContactsUpdate_Finish];
        }
    }];
    
    // 通讯录下载完成自动更新来电识别
    if (!_callIdentificationHelper) {
        _callIdentificationHelper = [[CMPCallIdentificationHelper alloc] init];
    }
    [self dispatchAsyncToChild:^{
        [_callIdentificationHelper reloadCallIdentification];
    }];
    
    if (self.nameBlock) {
        if (db) {
            NSArray *nameList = [self getmemberNameList:db];
            self.nameBlock(nameList,YES);
            self.nameBlock = nil;
        }
        else {
            [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
                if (self.nameBlock) {
                    NSArray *nameList = [self getmemberNameList:db];
                    self.nameBlock(nameList,YES);
                    self.nameBlock = nil;
                }
            }];
        }
    }
}
//更新失败处理
- (void)failUpdateOfflineContacts {
    if (self.nameBlock) {
        self.nameBlock(nil,NO);
        self.nameBlock = nil;
    }
    _tableChanged = NO;
    [self setupOfflineStatus:OfflineStatusFail];
    [self postNotificationName:kContactsUpdate_Fail];
}

//当前更新状态
- (OfflineStatus)offlineStatus {
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:kOfflineStatusKey];
    OfflineStatus status = [value integerValue];
    return status;
}

//设置更新状态
- (void)setupOfflineStatus:(OfflineStatus)status {
    NSString *value = [NSString stringWithFormat:@"%ld",(long)status];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kOfflineStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark CMPContactsDownloadManagerDelegate
- (void)managerBeginUpdateContacts:(CMPContactsDownloadManager *)manager{

}
- (void)managerEndUpdateContacts:(CMPContactsDownloadManager *)manager
{
}
- (void)manager:(CMPContactsDownloadManager *)manager failUpdateContactsWithMessage:(NSString *)message
{
    [self failUpdateOfflineContacts];
}

- (void)manager:(CMPContactsDownloadManager *)manager saveMd5:(NSString *)md5 type:(NSString *)type
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSArray *sqlList = [CMPContactsTableManager updateLogWithType:type value:md5 aId:self.accountId];
        for (NSString *aql in sqlList) {
            [db executeUpdate:aql];
        }
    }];
}

- (void)managerFinishDownLoadTable:(CMPContactsDownloadManager *)manager
                              info:(NSDictionary *)info
                         filePaths:(NSArray *)filePath
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        BOOL isRollBack = NO;
        NSString *md5 = [info objectForKey:@"md5"];
        NSString *type = [info objectForKey:@"type"];
        type = type.lowercaseString;
        
        NSMutableArray *sqlList = [[NSMutableArray alloc] init];
        for (NSString *path in filePath) {
            [sqlList addObjectsFromArray:[CMPContactsTableManager sqlArrayWithPath:path info:info]];
        }
        if (sqlList.count == 0) {
            //没有数据直接跳过
            SY_RELEASE_SAFELY(sqlList);
            return;
        }
        _tableChanged = YES;
        [sqlList addObjectsFromArray:[CMPContactsTableManager updateLogWithType:type value:md5 aId:self.accountId]];
        [db beginTransaction];
        @try {
            for (NSString *aql in sqlList) {
                [db executeUpdate:aql];
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
            
        }
        @finally {
            if (!isRollBack) {
                [db commit];
            }
            SY_RELEASE_SAFELY(sqlList);
        }
    }];
}

- (void)manager:(CMPContactsDownloadManager *)manager finishLoadSettings:(NSArray *)settings
{
    __weak typeof(self) weakSelf = self;
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        //选人权限
        CMPFlowRelationManager *manager = [[CMPFlowRelationManager alloc] init];
        manager.localContactsDB = db;
        [manager checkChoosePersionRelation];
        SY_RELEASE_SAFELY(manager);
        [CMPContactsTableManager createFlowTempTable:db];
        
        //通讯录权限
        BOOL changeUser = YES;
        NSString *currentId = [[[CMPCore sharedInstance].userID copy] autorelease];
        NSString *key = @"currentContactsUser";
        NSString *preId = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if ([currentId isEqualToString:preId] ) {
            //切换了人员
            changeUser = NO;
        }
        BOOL needSet = _tableChanged || changeUser;
        
        NSMutableArray *changeList = [NSMutableArray array];
        for (MAccountAvailableEntity *entity in settings) {
            NSString *accountId = [NSString stringWithFormat:@"%lld",entity.accountId];
            NSString *oldMd5 = [_accountSetDic objectForKey:accountId];
            if (needSet ||[NSString isNull:oldMd5] || ![oldMd5 isEqualToString:entity.md5]) {
                [CMPContactsTableManager runInsertAccountSettingSql:entity db:db];
                if (entity.accountId == [CMPCore sharedInstance].currentUser.accountID.longLongValue) {
                    [changeList addObject:entity];
                }
            }
        }
        if (changeList.count >0) {
            CMPContactsRelationManager *relationManager = [[CMPContactsRelationManager alloc] init];
            relationManager.localContactsDB = db;
            [relationManager checkLevelScope:changeList defaultValue:YES];
            SY_RELEASE_SAFELY(relationManager);
            [CMPContactsTableManager createTempTable:db];
        } else if (![CMPContactsTableManager isExitTempTable:db]) {
            [CMPContactsTableManager createTempTable:db];
        }
        [[NSUserDefaults standardUserDefaults] setObject:currentId forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf endUpdateOfflineContacts:nil];
        });
    }];
}

- (void)managerShouldClearTables:(CMPContactsDownloadManager *)manager
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        [CMPContactsTableManager clearTable:db];
        //这儿不删除临时表，应为在创建临时表(createTempTable)的时候会先删除它
        //[CMPContactsTableManager dropTempTable:db];
    }];
}

#pragma mark 从数据库拿数据

- (void)allMemberInAz:(void (^)(CMPContactsResult *))block
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        BOOL isExistTable = [CMPContactsTableManager isExitTempTable:db];
        if (!isExistTable) {
            CMPContactsResult *result = [[CMPContactsResult alloc] init];
            result.sucessfull = NO;
            block([result autorelease]);
            return ;
        }
        
        NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT memberName ,  memberId  ,  departmentId ,  accountId , postId , postName , ePost , mobilePhone , pinYin , py , pyh, show_tel FROM  %@ where type = 1 GROUP BY memberId ORDER BY  pinYin",kContactsTempTable];
        
        FMResultSet *set =  [db executeQuery:sql];
        NSString *customString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        NSMutableArray *otherArray = [NSMutableArray array];
        NSMutableArray *keyList = [NSMutableArray array];
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *allMemberList = [NSMutableArray array];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberId"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            member.accountId = [set stringForColumn:@"accountId"];
            member.name = [set stringForColumn:@"memberName"];
            NSString* firstSpell = [set stringForColumn:@"py"];
            member.nameSpell = [set stringForColumn:@"pinYin"];
            member.nameSpellHead = [set stringForColumn:@"pyh"];
            member.postName = [set stringForColumn:@"postName"];
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            // show_level
            
            NSString *pId = [set stringForColumn:@"postId"];
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            
            //ks add 搜索添加父部门全路径 8.1
            // 查父部门列表
            NSMutableArray *parentDepts = [NSMutableArray array];
            // 部门ID
            NSString *departmentID = [db stringForQuery:@"SELECT departmentId FROM TB_CONTACTSTEMPS WHERE memberId = ? AND type = 1", member.orgID];
            // 父部门ID
            FMResultSet *parentDeptsSet = [db executeQuery:@"SELECT * FROM TB_UNIT WHERE ID = ?", departmentID];
            while ([parentDeptsSet next]) {
                NSString *depName = [parentDeptsSet stringForColumn:@"NAME"];
//                NSDictionary *depDic = @{@"departmentName" : depName,
//                                         @"departmentId" : departmentID};
                [parentDepts addObject:depName];
                NSString *parentDepID = [parentDeptsSet stringForColumn:@"PARENT_ID"];
                [parentDeptsSet close];
                parentDeptsSet = [db executeQuery:@"SELECT * FROM TB_UNIT WHERE ID = ?", parentDepID];
                departmentID = parentDepID;
            }
            member.parentDepts = [[parentDepts reverseObjectEnumerator] allObjects];
            //end
            
            if ([customString rangeOfString:firstSpell].location != NSNotFound) {
                if ([keyList containsObject:firstSpell]) {
                    NSMutableArray *array = (NSMutableArray *)[dataDictionary objectForKey:firstSpell];
                    [array addObject:member];
                }
                else {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:member];
                    [keyList addObject:firstSpell];
                    [dataDictionary setObject:array forKey:firstSpell];
                }
            }
            else {
                [otherArray addObject:member];
            }
            [allMemberList addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        if (otherArray.count >0) {
            [dataDictionary setObject:otherArray forKey:@"#"];
            [keyList addObject:@"#"];
        }
        CMPContactsResult *result = [[CMPContactsResult alloc] init];
        result.keyList = keyList;
        result.dataDic = dataDictionary;
        result.allMemberList = allMemberList;
        result.sucessfull = YES;
        block([result autorelease]);
    }];
}

//根据人员Id 部门id 单位id 查询人员信息
- (void)memberInfoForId:(NSString *)memberId
           departmentId:(NSString *)departmentId
              accpuntId:(NSString *)accpuntId
             completion:(void (^)(CMPOfflineContactMember *))completion
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
        NSString *sql =  [NSString stringWithFormat:@"SELECT DISTINCT * FROM %@ where accountId = '%@' and departmentId = '%@' and  memberId = '%@' " ,kContactsTempTable,accountID,departmentId,memberId];
        FMResultSet *set =  [db executeQuery:sql];
        CMPOfflineContactMember *member = [[[CMPOfflineContactMember alloc] init] autorelease];
        while ([set next]) {
            member.orgID = memberId;
            member.sort = [set stringForColumn:@"memberSort"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.mark = [set stringForColumn:@"mark"];
            member.postName = [set stringForColumn:@"postName"];
            member.postId = [set stringForColumn:@"postId"];
            if ([member.postId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            member.department = [set stringForColumn:@"department"] ;//部门
            member.departmentId = departmentId;//部门
            member.account = [set stringForColumn:@"account"];//单位
            member.accountId = accountID;//单位Id
           //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
        }
        completion(member);
    }];
}


- (NSArray *)getmemberNameList:(FMDatabase *)db
{
    NSString *sql =[NSString stringWithFormat:@"SELECT DISTINCT memberName  FROM  %@",kContactsTempTable];
    FMResultSet *set =  [db executeQuery:sql];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([set next]) {
        NSString *name = [set stringForColumn:@"memberName"];
        if (![NSString isNull:name ]) {
            [result addObject:name];
        }
    }
    return [result autorelease];
}


- (void)memberNameList:(NameBlock)block
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        BOOL isExistTable = [CMPContactsTableManager isExitTempTable:db];
        if (isExistTable) {
            NSArray *nameList = [self getmemberNameList:db];
            block(nameList,YES);
        }
        else {
            self.nameBlock = block;
        }
    }];
}

- (void)memberListForNameArray:(NSArray *)nameArray
                        tbName:(NSString *)tbName
                    completion:(void (^)(NSArray *))completion {
    if (nameArray.count == 0) {
        completion(nil);
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
        NSMutableString *str = [NSMutableString string];
        for (NSInteger i = 0; i < nameArray.count; i++) {
            if (i != 0 ) {
                [str appendString:@" or "];
            }
            [str appendFormat:@" memberName like '%%%@%%' ",[nameArray objectAtIndex:i]];
        }
        NSString *sql =  [NSString stringWithFormat:@"SELECT DISTINCT * FROM %@ where ( %@ ) and type = 1  order by memberSort",tbName,str];

        FMResultSet *set =  [db executeQuery:sql];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberId"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.postName = [set stringForColumn:@"postName"];
            
            member.department = [set stringForColumn:@"department"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            // member.account = ;通过accountID 单独查询
            member.accountId = accountID;
            member.mark = [set stringForColumn:@"mark"];
            member.sort = [set stringForColumn:@"memberSort"];
            NSString *pId = [set stringForColumn:@"postId"];
            member.postId = pId;
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = @"";
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            [result addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        completion([result autorelease]);
    }];
}

- (void)memberListForName:(NSString *)name completion:(void (^)(NSArray *))completion
{
    if ([NSString isNull:name]) {
        completion([NSArray array]);
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
        NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM %@ where memberName like '%%%@%%' and type = 1  order by memberSort ",kContactsTempTable,name ];
        FMResultSet *set =  [db executeQuery:sql];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberId"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.postName = [set stringForColumn:@"postName"];
            
            member.department = [set stringForColumn:@"department"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            // member.account = ;通过accountID 单独查询
            member.accountId = accountID;
            member.mark = [set stringForColumn:@"mark"];
            member.sort = [set stringForColumn:@"memberSort"];
            NSString *pId = [set stringForColumn:@"postId"];
            member.postId = pId;
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = @"";
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            [result addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        completion([result autorelease]);
    }];
}

- (void)memberListForPinYin:(NSString *)name completion:(void (^)(NSArray *))completion
{
    if ([NSString isNull:name]) {
        completion([NSArray array]);
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
        NSString *pinyin = [CMPContactsTableManager pinyin:name];
        NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM %@ where pinYin like '%%%@%%' and type = 1 order by memberSort  ",kContactsTempTable,pinyin ];
        FMResultSet *set =  [db executeQuery:sql];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberId"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.postName = [set stringForColumn:@"postName"];
            
            member.department = [set stringForColumn:@"department"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            // member.account = ;通过accountID 单独查询
            member.accountId = accountID;
          
            member.mark = [set stringForColumn:@"mark"];
            member.sort = [set stringForColumn:@"memberSort"];
            NSString *pId = [set stringForColumn:@"postId"];
            member.postId = pId;
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            [result addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        completion([result autorelease]);
    }];
}

- (void)searchMemberWithKey:(NSString *)key
                     tbName:(NSString *)tbName
                 completion:(void (^)(NSArray *))completion {
    if ([NSString isNull:key]) {
        completion([NSArray array]);
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString* accountID = [CMPCore sharedInstance].currentUser.accountID;
        //                NSString *pinyin = [CMPContactsTableManager pinyin:key];
        NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM %@ where type = 1 and ( memberName like '%%%@%%' or pinYin like '%%%@%%' or pyh like '%%%@%%' ) order by memberSort ",tbName,key,key,key];
        FMResultSet *set =  [db executeQuery:sql];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberId"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.postName = [set stringForColumn:@"postName"];
            
            member.department = [set stringForColumn:@"department"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            // member.account = ;通过accountID 单独查询
            member.accountId = accountID;
            member.mark = [set stringForColumn:@"mark"];
            member.sort = [set stringForColumn:@"memberSort"];
            NSString *pId = [set stringForColumn:@"postId"];
            member.postId = pId;
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            [result addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        completion([result autorelease]);
    }];
}


- (void)memberNameForId:(NSString *)memberId completion:(void (^)(NSString *))completion {
    if ([NSString isNull:memberId]) {
        completion(@"");
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT memberName  FROM %@ where memberId = '%@' ",kContactsTempTable,memberId ];
        NSString *name = [db stringForQuery:sql];
        completion(name);
    }];
}

- (void)memberNamefromServerForId:(NSString *)memberId completion:(void (^)(NSString *))completion {
    if ([NSString isNull:memberId]) {
        completion(@"");
        return;
    }
    [self requestUserInfoWithUserId:memberId completeBlock:^(NSString *name) {
        completion(name);
    }];
    
}


- (void)memberNamesForIds:(NSArray *)memberIds completion:(void (^)(NSDictionary *))completion {
    if (memberIds.count == 0) {
        completion([NSDictionary dictionary]);
        return;
    }

    
    NSMutableString *values = [NSMutableString string];
    for (int i= 0; i < memberIds.count; i++) {
        NSString *string = [memberIds objectAtIndex:i];
        if (i != 0) {
            [values appendString:@" , "];
        }
        [values appendString:string];
    }
    
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT memberName , memberId FROM %@ where memberId IN (%@) ",kContactsTempTable,values ];
        FMResultSet *set =  [db executeQuery:sql];
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        while ([set next]) {
            NSString *memberId = [set stringForColumn:@"memberId"];
            NSString *memberName = [set stringForColumn:@"memberName"];
            [result setObject:memberName forKey:memberId];
        }
        completion(result);
    }];
}
- (void)phoneForId:(NSString *)memberId completion:(void (^)(NSString *))completion {
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT mobilePhone , show_tel  FROM %@ where memberId = '%@' ",kContactsTempTable,memberId ];
        FMResultSet *set =  [db executeQuery:sql];
        NSString *result = @"";
        while ([set next]) {
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                result = kContactMemberHideVaule;
            }
            else {
                result = [set stringForColumn:@"mobilePhone"];
            }
        }
        completion(result);
    }];
}

#pragma mark 常用联系人

- (void)requestFrequentContacts {
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:kFequestLoadFinish];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *url = [NSString stringWithFormat:@"%@%@",[CMPCore fullUrlPathMapForPath:@"/api/contacts2/frequentContacts/"],[CMPCore sharedInstance].userID];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

#pragma mark 从服务器获取人员信息

- (void)requestUserInfoWithUserId:(NSString *)userId completeBlock:(void (^)(NSString *name) )completesBlock {
    CMPContactsManagerCompleteBlock block = ^(BOOL isSuccessful,id data, NSError *error ) {
        if (isSuccessful) {
            if (completesBlock) {
                NSDictionary *responseDic = data;
                NSUInteger code = [responseDic[@"code"] integerValue];
                NSDictionary *dataDic = responseDic[@"data"];
                if (code == 200) {
                    completesBlock(dataDic[@"name"] ?: @"");
                } else {
                    completesBlock(@"");
                }
            }
        } else {
            if (completesBlock) {
                 completesBlock(@"");
            }
        }
    };
    
    NSString *url = [CMPCore fullUrlForPathFormat:kShowPeopleCardUrl,userId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{ @"requestTag" : @"requestUserInfoWithUserId",
                               @"completeBlock" : [block copy] };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}


- (void)allFrequentContact:(void (^)(CMPContactsResult *))block
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        //            NSString *sql = @"SELECT DISTINCT id ,  name  ,  iconUrl ,  departmentName , accShortName , levelName , postName , tel  FROM  TB_FREQUENT";
        NSString *sql = @"SELECT * FROM TB_FREQUENT";
        FMResultSet *set =  [db executeQuery:sql];
        NSMutableArray *allMemberList = [NSMutableArray array];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"id"];
            member.name = [set stringForColumn:@"name"];
            member.postName = [set stringForColumn:@"postName"];
            member.mobilePhone = [set stringForColumn:@"tel"];
            member.level =  [set stringForColumn:@"levelName"];
            member.department =  [set stringForColumn:@"departmentName"];
            member.account =  [set stringForColumn:@"accShortName"];
            member.accountId = [set stringForColumn:@"accountId"];
            member.departmentId = [set stringForColumn:@"departmentId"];
            member.postId = [set stringForColumn:@"postId"];
            member.levelId = [set stringForColumn:@"levelId"];
            [allMemberList addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        
        NSString *key = SY_STRING(@"contacts_frequent");
        CMPContactsResult *result = [[CMPContactsResult alloc] init];
        result.keyList = [NSArray arrayWithObject:key];
        result.dataDic = [NSDictionary dictionaryWithObject:allMemberList forKey:key];
        result.allMemberList = allMemberList;
        result.sucessfull = YES;
        block([result autorelease]);
    }];
}

//常用联系人前十位
- (void)topTenFrequentContact:(void (^)(NSArray *))block  addressbook:(BOOL)adressbook
{
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSMutableArray *memberList = [NSMutableArray array];
        if (adressbook) {
            NSString *idsql = [NSString stringWithFormat:@"SELECT id FROM  TB_FREQUENT where id in (select memberId from %@ ) LIMIT 0,10",kContactsTempTable];
            FMResultSet *idset =  [db executeQuery:idsql];
            NSMutableArray *idList = [NSMutableArray array];
            NSMutableString *idString = [NSMutableString string];
            while ([idset next]) {
                NSString *idStr = [idset stringForColumn:@"id"];
                [idList addObject:idStr];
                if (idString.length > 0) {
                    [idString appendString:@","];
                }
                [idString appendString:idStr];
            }
            if ( idList.count > 0) {
                NSMutableDictionary *memberDic = [NSMutableDictionary dictionary];
                NSString *sql = [NSString stringWithFormat:@"SELECT * FROM  %@ where memberId in (%@) and type = 1",kContactsTempTable,idString];
                FMResultSet *set =  [db executeQuery:sql];
                while ([set next]) {
                    CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
                    member.orgID = [set stringForColumn:@"memberId"];
                    member.name = [set stringForColumn:@"memberName"];
                    member.nameSpell = [set stringForColumn:@"pinYin"];;
                    member.tel = [set stringForColumn:@"tel"];
                    member.mail= [set stringForColumn:@"mail"];
                    member.postName = [set stringForColumn:@"postName"];
                    member.department = [set stringForColumn:@"department"];
                    member.departmentId = [set stringForColumn:@"departmentId"];
                    // member.account = ;通过accountID 单独查询
                    member.accountId = [set stringForColumn:@"accountId"];
                    member.mark = [set stringForColumn:@"mark"];
                    member.sort = [set stringForColumn:@"memberSort"];
                    NSString *pId = [set stringForColumn:@"postId"];
                    member.postId = pId;
                    if ([pId isEqualToString:@"-1"]) {
                        member.postName = [set stringForColumn:@"ePost"];
                    }
                    //level
                    NSInteger showLevel = [set intForColumn:@"show_level"];
                    member.levelId = [set stringForColumn:@"levelId"];//职务级别id
                    if (showLevel != 1) {
                        member.level = kContactMemberHideVaule;
                    }
                    else {
                        if ([member.levelId isEqualToString:@"-1"]) {
                            member.level = [set stringForColumn:@"eLevel"];
                        }
                        else {
                            member.level = [set stringForColumn:@"level"];//职务级别
                        }
                    }
                    NSInteger show_tel = [set intForColumn:@"show_tel"];
                    if (show_tel != 1) {
                        member.mobilePhone = kContactMemberHideVaule;
                    }
                    else {
                        member.mobilePhone = [set stringForColumn:@"mobilePhone"];
                    }
                    [memberDic setObject:member forKey:member.orgID];
                    SY_RELEASE_SAFELY(member);
                }
                for (NSString *ids in idList) {
                    CMPOfflineContactMember *member = memberDic[ids];
                    if (member) {
                        [memberList addObject:member];
                    }
                }
            }
        }
        else {
            NSString *sql = @"SELECT * FROM  TB_FREQUENT LIMIT 0,10";
            FMResultSet *set =  [db executeQuery:sql];
            while ([set next]) {
                CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
                member.orgID = [set stringForColumn:@"id"];
                member.name = [set stringForColumn:@"name"];
                member.postName = [set stringForColumn:@"postName"];
                member.mobilePhone = [set stringForColumn:@"tel"];
                member.level =  [set stringForColumn:@"levelName"];
                member.department =  [set stringForColumn:@"departmentName"];
                member.account =  [set stringForColumn:@"accShortName"];
                member.accountId = [set stringForColumn:@"accountId"];
                member.departmentId = [set stringForColumn:@"departmentId"];
                member.postId = [set stringForColumn:@"postId"];
                member.levelId = [set stringForColumn:@"levelId"];
                [memberList addObject:member];
                SY_RELEASE_SAFELY(member);
            }
        }
        block(memberList);
    }];
}

#pragma mark-
#pragma mark-组织架构离线

- (void)accountInfoWithAccountID:(NSString *)accountID completion:(void (^)(BOOL isContactReady, OfflineOrgUnit *account))completion {
    if ([self offlineStatus] != OfflineStatusFinish) {
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT count(*) FROM TB_CONTACTSTEMPS"];
        if (count == 0) {
            if (completion) {
                completion(NO, nil);
            }
            return;
        }
        
        CMPContactsRelationManager *relationManager = [[CMPContactsRelationManager alloc] init];
        relationManager.localContactsDB = db;
        OfflineOrgUnit *unit = [relationManager getAccountByAccountId:[accountID longLongValue]];
        SY_RELEASE_SAFELY(relationManager);
        if (completion) {
            completion(YES, unit);
        }
    }];
}

- (void)departmentsWithAccountID:(NSString *)accountID
                      completion:(void (^)(BOOL isContactReady, OfflineOrgUnit *myDepartment, NSArray<OfflineOrgUnit *> *childDepartments))completion {
    if ([self offlineStatus] != OfflineStatusFinish) {
        if (completion) {
            completion(NO, nil, nil);
        }
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT count(*) FROM TB_CONTACTSTEMPS"];
        if (count == 0) {
            if (completion) {
                completion(NO, nil, nil);
            }
            return;
        }
        
        CMPContactsRelationManager *relationManager = [[CMPContactsRelationManager alloc] init];
        relationManager.localContactsDB = db;
        NSString *myDepartmentID = [CMPCore sharedInstance].currentUser.departmentID;
        OfflineOrgUnit *myDepartment = [relationManager getAccountByAccountId:[myDepartmentID longLongValue]];
        NSArray<OfflineOrgUnit *> *childDepartment = [relationManager getDepartmentsByAccountId:[accountID longLongValue]];
        SY_RELEASE_SAFELY(relationManager);
        if (completion) {
            completion(YES, myDepartment, childDepartment);
        }
    }];
}

- (void)childrensWithAccoundID:(NSString *)accountID
                  departmentID:(NSString *)departmentID
                       pageNum:(NSNumber *)pageNum
                   memberFirst:(BOOL)memberFirst
                    completion:(void (^)(BOOL isContactReady, NSInteger total, NSArray<OfflineOrgUnit *> *childDepartments, NSArray<CMPOfflineContactMember *> *members))completion {
    if ([self offlineStatus] != OfflineStatusFinish) {
        if (completion) {
            completion(NO, 0, nil, nil);
        }
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT count(*) FROM TB_CONTACTSTEMPS"];
        if (count == 0) {
            if (completion) {
                completion(NO, 0, nil, nil);
            }
            return;
        }
        
        // 查人员总数
        NSInteger memberSum = [db intForQuery:@"SELECT COUNT(DISTINCT memberid) FROM TB_CONTACTSTEMPS where accountId = ? and  departmentId = ?", accountID, departmentID];
        NSInteger departmentSum = [db intForQuery:@"select count(*) from TB_UNIT  where PARENT_ID = ?",[NSNumber numberWithLongLong:[departmentID longLongValue]]];
        NSInteger memberLimit = 0;
        NSInteger memberOffset = 0;
        NSInteger departmentLimit = 0;
        NSInteger departmentOffset = 0;
        // 每页返回的人员个数 = 20 - 该页子部门数
        NSInteger page = [pageNum integerValue];
        NSInteger hybridPage = 0;
        if (memberFirst) {
            hybridPage = memberSum / 20 + 1;
            if (page < hybridPage) {
                memberLimit = 20;
                memberOffset = (page - 1) * 20;
                departmentLimit = 0;
                departmentOffset = 0;
            } else if (page == hybridPage) {
                memberLimit = memberSum % 20;
                memberOffset = (page - 1) * 20;
                departmentLimit = 20 - memberLimit;
                departmentOffset = 0;
            } else {
                memberLimit = 0;
                memberOffset = 0;
                departmentLimit = 20;
                departmentOffset = (page - hybridPage - 1) * 20 + (20 - memberSum % 20);
            }
        } else {
            hybridPage = departmentSum / 20 + 1;
            if (page < hybridPage) {
                departmentLimit = 20;
                departmentOffset = (page - 1) * 20;
                memberLimit = 0;
                memberOffset = 0;
            } else if (page == hybridPage) {
                departmentLimit = departmentSum % 20;
                departmentOffset = (page - 1) * 20;
                memberLimit = 20 - departmentLimit;
                memberOffset = 0;
            } else {
                departmentLimit = 0;
                departmentOffset = 0;
                memberLimit = 20;
                memberOffset = (page - hybridPage - 1) * 20 + (20 - departmentSum % 20);
            }
        }
        
        // 查关联单位
        CMPContactsRelationManager *relationManager = [[CMPContactsRelationManager alloc] init];
        relationManager.localContactsDB = db;
        NSArray<OfflineOrgUnit *> *childDepartment = [relationManager getDepartmentsByAccountId:[departmentID longLongValue] limit:departmentLimit offset:departmentOffset];
        SY_RELEASE_SAFELY(relationManager);
        
        NSString *selectSql =  [NSString stringWithFormat:@"SELECT * FROM (SELECT DISTINCT * FROM %@ where accountId = '%@' and  departmentId = '%@' order by type asc) group by memberid order by memberSort LIMIT %ld OFFSET %ld" , kContactsTempTable, accountID, departmentID, memberLimit, memberOffset];
        NSMutableArray *members = [NSMutableArray array];
        FMResultSet *set =  [db executeQuery:selectSql];
        while ([set next]) {
            CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
            member.orgID = [set stringForColumn:@"memberid"];
            member.sort = [set stringForColumn:@"memberSort"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.mark = [set stringForColumn:@"mark"];
            member.postName = [set stringForColumn:@"postName"];
            member.postId = [set stringForColumn:@"postId"];
            if ([member.postId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            member.department = [set stringForColumn:@"department"] ;//部门
            member.departmentId = departmentID;//部门
            member.account = [set stringForColumn:@"account"];//单位
            member.accountId = accountID;//单位Id
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = @"";
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            member.ins = [set stringForColumn:@"ins"];
            member.internal = [set stringForColumn:@"department_internal"];
            [members addObject:member];
            SY_RELEASE_SAFELY(member);
        }
        
        if (completion) {
            completion(YES, memberSum + departmentSum, childDepartment, members);
        }
    }];
}

//根据人员Id 单位id 查询人员信息
- (void)memberInfoForID:(NSString *)memberID
              accountID:(NSString *)accountID
             completion:(void (^)(CMPOfflineContactMember *))completion
{
    if ([self offlineStatus] != OfflineStatusFinish) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString *sql =  [NSString stringWithFormat:@"SELECT * FROM %@ where accountId = '%@' and  memberId = '%@' AND type = 1 " ,kContactsTempTable,accountID,memberID];
        FMResultSet *set =  [db executeQuery:sql];
        CMPOfflineContactMember *member = [[[CMPOfflineContactMember alloc] init] autorelease];
        if ([set next]) {
            member.orgID = memberID;
            member.sort = [set stringForColumn:@"memberSort"];
            member.name = [set stringForColumn:@"memberName"];
            member.nameSpell = [set stringForColumn:@"pinYin"];;
            member.tel = [set stringForColumn:@"tel"];
            member.mail= [set stringForColumn:@"mail"];
            member.mark = [set stringForColumn:@"mark"];
            member.postName = [set stringForColumn:@"postName"];
            member.postId = [set stringForColumn:@"postId"];
            if ([member.postId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            member.department = [set stringForColumn:@"department"] ;//部门
            member.departmentId = [set stringForColumn:@"departmentId"];//部门
            member.account = [set stringForColumn:@"account"];//单位
            member.accountId = accountID;//单位Id
            
            member.workAddr = [set stringForColumn:@"workAddr"];
            member.wb = [set stringForColumn:@"wb"];
            member.wx = [set stringForColumn:@"wx"];
            member.homeAddr = [set stringForColumn:@"homeAddr"];
            member.port = [set stringForColumn:@"port"];
            member.communicationAddr = [set stringForColumn:@"communicationAddr"];
            
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            
            // 查副岗信息
            NSMutableArray *deputyPost = [NSMutableArray array];
            FMResultSet *deputyPostIDSet = [db executeQuery:@"SELECT PID FROM TB_RELATION WHERE MID = ? AND TYPE = '2'", memberID];
            while ([deputyPostIDSet next]) {
                NSString *pID = [deputyPostIDSet stringForColumn:@"PID"];
                FMResultSet *deputyPostNameSet = [db executeQuery:@"SELECT NAME FROM TB_POST WHERE ID = ?", pID];
                if ([deputyPostNameSet next]) {
                    [deputyPost addObject:[deputyPostNameSet stringForColumn:@"NAME"]];
                }
            }
            member.deputyPost = [deputyPost copy];
            
            // 查父部门列表
            NSMutableArray *parentDepts = [NSMutableArray array];
            // 部门ID
            NSString *departmentID = [db stringForQuery:@"SELECT departmentId FROM TB_CONTACTSTEMPS WHERE memberId = ? AND type = 1", memberID];
            // 父部门ID
            FMResultSet *parentDeptsSet = [db executeQuery:@"SELECT * FROM TB_UNIT WHERE ID = ?", departmentID];
            while ([parentDeptsSet next]) {
                NSString *depName = [parentDeptsSet stringForColumn:@"NAME"];
                NSDictionary *depDic = @{@"departmentName" : depName,
                                         @"departmentId" : departmentID};
                [parentDepts addObject:depDic];
                NSString *parentDepID = [parentDeptsSet stringForColumn:@"PARENT_ID"];
                [parentDeptsSet close];
                parentDeptsSet = [db executeQuery:@"SELECT * FROM TB_UNIT WHERE ID = ?", parentDepID];
                departmentID = parentDepID;
            }
            member.parentDepts = [[parentDepts reverseObjectEnumerator] allObjects];
        } else { // 离线通讯录中找不到在常用联系人中找
            NSString *searchInFrequentSql = [NSString stringWithFormat:@"SELECT * FROM %@ where id = '%@'", kContactsFrequentTable, memberID];
            FMResultSet *searchInFrequentSet =  [db executeQuery:searchInFrequentSql];
            if ([searchInFrequentSet next]) {
                member.orgID = memberID;
                member.name = [searchInFrequentSet stringForColumn:@"name"];
                member.postName = [searchInFrequentSet stringForColumn:@"postName"];
                member.department = [searchInFrequentSet stringForColumn:@"departmentName"] ;
            }
            [searchInFrequentSet close];
        }
        [set close];
        
        completion(member);
    }];
}

- (void)allMembersCompletion:(void(^)(NSArray<CMPOfflineContactMember *> *allMembers))completion {
    if (_allMembers && _allMembers.count > 0) { // 如果有缓存直接返回
        NSArray *members = _allMembers[[CMPCore sharedInstance].userID];
        completion(members);
        return;
    }
    
    // 没有缓存查数据库
    [self allMemberInAz:^(CMPContactsResult *result) {
        if (!result.sucessfull) {
            completion(nil);
            return;
        }
        
        if (!self.allMembers) {
            self.allMembers = [NSMutableDictionary dictionary];
        }
        
        NSArray *arr = [NSArray arrayWithArray:result.allMemberList];
        
        if (![NSString isNull:[CMPCore sharedInstance].userID]) {
            [self.allMembers setObject:arr forKey:[CMPCore sharedInstance].userID];
        }
        
        completion(arr);
    }];
}

//更新常用联系人的信息
- (void)updateFrequentMemberInfo:(NSArray *)memberList completion:(void (^)(NSArray *))completion {
    NSMutableString *string =  [NSMutableString string];
    NSMutableDictionary *memberdic = [NSMutableDictionary dictionary];
    for (NSInteger t = 0 ; t <memberList.count; t++) {
        CMPOfflineContactMember *member = [memberList objectAtIndex:t];
        NSString *memberId = member.orgID;
        [memberdic setObject:member forKey:memberId];
        if (t > 0) {
            [string appendFormat:@" , %@ ",memberId];
        }
        else {
            [string appendFormat:@" %@ ",memberId];
        }
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT memberId  ,  mobilePhone , show_tel , postName , postId , ePost , level , show_level , levelId , eLevel  FROM %@ where memberId IN (%@) ",kContactsTempTable,string ];
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            NSString *memberId = [set stringForColumn:@"memberId"];
            CMPOfflineContactMember *member = [memberdic objectForKey:memberId];
            NSInteger show_tel = [set intForColumn:@"show_tel"];
            if (show_tel != 1) {
                member.mobilePhone = kContactMemberHideVaule;
            }
            else {
                member.mobilePhone = [set stringForColumn:@"mobilePhone"];
            }
            member.postName = [set stringForColumn:@"postName"];
            NSString *pId = [set stringForColumn:@"postId"];
            if ([pId isEqualToString:@"-1"]) {
                member.postName = [set stringForColumn:@"ePost"];
            }
            //level
            NSInteger showLevel = [set intForColumn:@"show_level"];
            member.levelId = [set stringForColumn:@"levelId"];//职务级别id
            if (showLevel != 1) {
                member.level = kContactMemberHideVaule;
            }
            else {
                if ([member.levelId isEqualToString:@"-1"]) {
                    member.level = [set stringForColumn:@"eLevel"];
                }
                else {
                    member.level = [set stringForColumn:@"level"];//职务级别
                }
            }
        }
        completion(memberList);
    }];
    
}

#pragma -mark  接口代理方法 CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    
//    aDataRequest.userInfo = @{ @"requestTag" : @"requestUserInfoWithUserId",
//    @"completeBlock" : [completeBlock copy] };a
    NSDictionary *userInfo = aRequest.userInfo;
    NSString *requestTag = userInfo[@"requestTag"];
    CMPContactsManagerCompleteBlock block =  userInfo[@"completeBlock"];
    if ([requestTag isEqualToString:@"requestUserInfoWithUserId"]) {
        if (block) {
            block(YES,[aResponse.responseStr JSONValue],nil);
        }
        return;
    }
    
    NSDictionary *result = [[aResponse responseStr] JSONValue];
    NSArray *list = [result objectForKey:@"data"];
    if (![list isKindOfClass:[NSArray class]]) {
        return;
    }
    [_contactsQueue inDatabaseBackground:^(FMDatabase *db) {
        [CMPContactsTableManager insertFequestFrequentContacts:list db:db];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kFequestLoadFinish];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFequestLoadFinish object:nil];
    }];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSDictionary *userInfo = aRequest.userInfo;
    NSString *requestTag = userInfo[@"requestTag"];
    CMPContactsManagerCompleteBlock block =  userInfo[@"completeBlock"];
    if ([requestTag isEqualToString:@"requestUserInfoWithUserId"]) {
        if (block) {
            block(NO,nil,error);
        }
        return;
    }
}

@end
