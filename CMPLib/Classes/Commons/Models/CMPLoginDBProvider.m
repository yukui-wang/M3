//
//  CMPLoginDBProvider.m
//  M3
//
//  Created by CRMO on 2017/12/5.
//

#import "CMPLoginDBProvider.h"
#import "FMDB.h"
#import "FMDatabaseQueueFactory.h"

NSString * const CMPLoginDBProviderDbName = @"Login.db";
NSString * const CMPLoginDBProviderServerTableName = @"m3_server";
NSString * const CMPLoginDBProviderAccountTableName = @"m3_account";
NSString * const CMPLoginDBProviderAssociateTableName = @"m3_associate_account";
NSString * const CMPLoginDBProviderPartTimeTableName = @"m3_parttime";
NSString * const CMPLoginDBProviderOrgLoginTableName = @"m3_org_login";
NSString * const CMPLoginDBProviderServerVpnTableName = @"m3_server_vpn";

@interface CMPLoginDBProvider()
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@end

@implementation CMPLoginDBProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        [self databaseQueue];
    }
    return self;
}

- (void)dealloc {
    [self.databaseQueue close];
}

#pragma mark-
#pragma mark-服务器API

- (NSArray<CMPServerModel *>*)listOfServer {
    NSMutableArray<CMPServerModel *> *servers = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ GROUP BY uniqueID", CMPLoginDBProviderServerTableName];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            CMPServerModel *server = [CMPServerModel yy_modelWithDictionary:[result resultDictionary]];
            [servers addObject:server];
        }
    }];
    return servers;
}

- (NSInteger)countOfServer {
    __block NSInteger count = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:@"SELECT COUNT(*) FROM m3_server"];
    }];
    return count;
}

- (BOOL)addServerWithModel:(CMPServerModel *)model {
    BOOL deleteResult = [self deleteServerWithUniqueID:model.uniqueID];
    __block BOOL insertResult = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        insertResult = [db executeUpdate:@"INSERT INTO m3_server (uniqueID, serverID, host, port, isSafe, scheme, fullUrl, note, inUsed, serverVersion, updateServer, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.uniqueID, model.serverID, model.host, model.port, [NSNumber numberWithBool:model.isSafe], model.scheme, model.fullUrl, model.note, [NSNumber numberWithBool:model.inUsed], model.serverVersion, model.updateServer, model.extend1, model.extend2, model.extend3,model.extend4,model.extend5,model.extend6,model.extend7,model.extend8,model.extend9,model.extend10];
    }];
    return deleteResult && insertResult;
}
//OA-209897 M3-iOS端：关联的账号数据存在一定逻辑问题，具体见描述
- (void)addServerIfServerIdChangeWithModel:(CMPServerModel *)model {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *uniqueID = model.uniqueID;
        NSInteger count = [db intForQuery:@"SELECT COUNT(*) FROM m3_server WHERE serverID = ? and uniqueID = ?",model.serverID,uniqueID];
        if (count > 0) {
            return;
        }
        [db executeUpdate:@"INSERT INTO m3_server (uniqueID, serverID, host, port, isSafe, scheme, fullUrl, note, inUsed, serverVersion, updateServer, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", uniqueID, model.serverID, model.host, model.port, [NSNumber numberWithBool:model.isSafe], model.scheme, model.fullUrl, model.note, [NSNumber numberWithBool:model.inUsed], model.serverVersion, model.updateServer, model.extend1, model.extend2, model.extend3,model.extend4,model.extend5,model.extend6,model.extend7,model.extend8,model.extend9,model.extend10];
    }];
}

- (BOOL)updateServerWithUniqueID:(NSString *)aUniqueID
                        serverID:(NSString *)aServerID
                   serverVersion:(NSString *)aServerVersion
                    updateServer:(NSString *)updateServer
                   allowRotation:(BOOL)allowRotation
                         appList:(NSString *)appList
                 extraDataString:(NSString *)extraDataString
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *aAllowRotation = allowRotation ? @"1" : @"0";
        [db executeUpdate:@"UPDATE m3_server SET serverID = ?, serverVersion = ?, updateServer = ?, extend2 = ?, extend4 = ? , extend10 = ? WHERE uniqueID = ?", aServerID, aServerVersion, updateServer, aAllowRotation, appList, extraDataString, aUniqueID];
    }];
    return result;
}

- (void)updateServerWithUniqueID:(NSString *)aUniqueID note:(NSString *)note {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_server SET note = ? WHERE uniqueID = ?", note, aUniqueID];
    }];
}

- (void)updateServerWithUniqueID:(NSString *)aUniqueID extraDataString:(NSString *)extraDataString {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_server SET extend10 = ? WHERE uniqueID = ?", extraDataString, aUniqueID];
    }];
}

- (CMPServerModel *)findServerWithUniqueID:(NSString *)uniqueID {
    __block CMPServerModel *serverModel = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_server WHERE uniqueID = ?", uniqueID];
        if ([result next]) {
            serverModel = [CMPServerModel yy_modelWithDictionary:[result resultDictionary]];
        }
        [result close];
    }];
    return serverModel;
}

- (NSArray<CMPServerModel *> *)findServersWithServerID:(NSString *)serverID {
    NSMutableArray *servers = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_server WHERE serverID = ?", serverID];
        while ([result next]) {
            CMPServerModel *serverModel = [CMPServerModel yy_modelWithDictionary:[result resultDictionary]];
            [servers addObject:serverModel];
        }
    }];
    return [servers copy];
}

- (CMPServerModel *)inUsedServer {
    __block CMPServerModel *serverModel = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE inUsed = 1", CMPLoginDBProviderServerTableName];
        FMResultSet *result = [db executeQuery:sql];
        if ([result next]) {
            serverModel = [CMPServerModel yy_modelWithDictionary:[result resultDictionary]];
        }
        [result close];
    }];
    return serverModel;
}

- (BOOL)deleteServerWithUniqueID:(NSString *)uniqueID {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM m3_server WHERE uniqueID = ?", uniqueID];
    }];
    return result;
}

- (void)deleteServerWithServerID:(NSString *)serverID {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM m3_server WHERE serverID = ?", serverID];
    }];
}

- (BOOL)switchUsedServerWithUniqueID:(NSString *)uniqueID {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"UPDATE m3_server SET inUsed = 0"];
        result = [db executeUpdate:@"UPDATE m3_server SET inUsed=1 WHERE uniqueID = ?", uniqueID] && result;
    }];
    return result;
}

- (NSInteger)countOfMainServer {
    __block NSInteger count = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:@"SELECT COUNT(*) FROM m3_server WHERE extend1 != '1' OR extend1 is NULL"];
    }];
    return count;
}

#pragma mark-
#pragma mark-账号API

- (CMPLoginAccountModel *)inUsedAccountWithServerID:(NSString *)serverID {
    __block CMPLoginAccountModel *account = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account WHERE serverID = ? AND inUsed = 1", serverID];
        if ([result next]) {
            account = [CMPLoginAccountModel yy_modelWithDictionary:[result resultDictionary]];
        }
        [result close];
    }];
    return account;
}

- (CMPLoginAccountModel *)accountWithServerID:(NSString *)serverID userID:(NSString *)userID {
    __block CMPLoginAccountModel *account = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account WHERE serverID = ? AND userID = ?", serverID, userID];
        if ([result next]) {
            account = [CMPLoginAccountModel yy_modelWithDictionary:[result resultDictionary]];
        }
        [result close];
    }];
    return account;
}

- (NSArray<CMPLoginAccountModel *> *)allAccount {
    __block CMPLoginAccountModel *account = nil;
    __block NSMutableArray *array = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account"];
        while ([result next]) {
            account = [CMPLoginAccountModel yy_modelWithDictionary:[result resultDictionary]];
            [array addObject:account];
        }
        [result close];
    }];
    return [array copy];
}

- (void)updateDatabaseOldAccountAlreadyPopuUppPrivacypPage {
    NSArray *array = [self allAccount];
    __block NSString *extraDataModelStr = nil;
    if (array.count > 0) {
        [array enumerateObjectsUsingBlock:^(CMPLoginAccountModel *account, NSUInteger idx, BOOL * _Nonnull stop) {
            CMPLoginAccountExtraDataModel *extraDataModel = [CMPLoginAccountExtraDataModel yy_modelWithJSON:account.extend10];
            extraDataModel.isAlreadyShowPrivacyAgreement = YES;
            extraDataModelStr = [extraDataModel yy_modelToJSONString];
            [self updateAccount:account extend10:extraDataModelStr];
        }];
    }
}

- (void)updateAccount:(CMPLoginAccountModel *)account
             extend10:(NSString *)extend10 {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET extend10 = ? WHERE userID = ? AND serverID = ?",extend10, account.userID, account.serverID];
    }];
}

- (void)updateAccount:(CMPLoginAccountModel *)account
              AppList:(NSString *)appList {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET appList = ? WHERE userID = ? AND serverID = ?", appList, account.userID, account.serverID];
    }];
}

- (void)updateAccount:(CMPLoginAccountModel *)account
           ConfigInfo:(NSString *)configInfo {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET configInfo = ? WHERE userID = ? AND serverID = ?", configInfo, account.userID, account.serverID];
    }];
}

- (void)updateAccount:(CMPLoginAccountModel *)account
                token:(NSString *)token
           expireTime:(NSString *)expireTime {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET extend6 = ?, extend7 = ? WHERE userID = ? AND serverID = ?", token, expireTime, account.userID, account.serverID];
    }];
}

- (void)clearAccountToken:(CMPLoginAccountModel *)account {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET extend6 = '', extend7 = '' WHERE userID = ? AND serverID = ?", account.userID, account.serverID];
    }];
}

- (void)clearAllTokens {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET extend6 = '', extend7 = ''"];
    }];
}

- (BOOL)addAccount:(CMPLoginAccountModel *)account inUsed:(BOOL)inUsed
{
    if ([NSString isNull:account.serverID] ||
        [NSString isNull:account.userID]) {
        return NO;
    }
    // 1、 删除已经存在的用户信息
    [self deleteAccount:account];
    // 2、设置当前服务器所有账号为未使用状态
    NSString *aServerId = account.serverID;
    [self updateAllAccountsUnUsedWithServerId:aServerId];
    // 3、重新添加账号
    CMPLoginAccountModel *model = account;
    model.inUsed = YES;
    __block BOOL aResult = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        aResult = [db executeUpdate:@"INSERT INTO m3_account (serverID, userID, loginName, loginPassword, name, gesturePassword, gestureMode, inUsed, loginResult, appList, configInfo, accountID, departmentID, levelID, postID, departmentName, postName, iconUrl, pushConfig, ucConfig, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", model.serverID, model.userID, model.loginName, model.loginPassword, model.name, model.gesturePassword, [NSNumber numberWithLongLong:model.gestureMode], [NSNumber numberWithBool:model.inUsed], model.loginResult, model.appList, model.configInfo, model.accountID, model.departmentID, model.levelID, model.postID,model.departmentName,model.postName, model.iconUrl, model.pushConfig, model.ucConfig, model.extend1, model.extend2, model.extend3,model.extend4,model.extend5,model.extend6,model.extend7,model.extend8,model.extend9,model.extend10];
    }];
    return aResult;
}

- (BOOL)deleteAccount:(CMPLoginAccountModel *)account
{
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM m3_account WHERE userID = ? AND serverID = ?", account.userID, account.serverID];
    }];
    return result;
}

- (BOOL)updateGesturePassword:(NSString *)password
                     serverID:(NSString *)serverID
                       userID:(NSString *)userID
                  gestureMode:(NSInteger)aMode {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET gesturePassword = ?, gestureMode = ? WHERE userID = ? AND serverID = ?", password, [NSNumber numberWithInteger:aMode], userID, serverID];
    }];
    return result;
}

- (BOOL)updateAllAccountsUnUsedWithServerId:(NSString *)aServerId {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET loginPassword = '', inUsed = 0 WHERE serverID = ?", aServerId];
    }];
    return result;
}

- (void)clearLoginPasswordWithServerId:(NSString *)aServerId {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET loginPassword = '' WHERE serverID = ?", aServerId];
    }];
}
- (void)clearLoginAllPasswordWithServerID:(NSString *)serverID userId:(NSString *)userID{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET loginPassword = '' , extend2 = '' WHERE serverID = ? AND userID = ?", serverID, userID];
    }];
}

- (void)clearLoginPasswordWithServerID:(NSString *)serverID userId:(NSString *)userID{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET loginPassword = '' WHERE serverID = ? AND userID = ?", serverID, userID];
    }];
}

- (BOOL)clearAllLoginPassword {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET loginPassword = ''"];
    }];
    return result;
}

- (BOOL)updatePushConfig:(NSString *)pushConfig serverID:(NSString *)serverID userID:(NSString *)userID {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET pushConfig = ? WHERE serverID = ? AND userID = ?", pushConfig, serverID, userID];
    }];
    return result;
}

- (NSString *)pushConfigWithServerID:(NSString *)serverID userID:(NSString *)userID {
    __block NSString *pushConfig = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account WHERE serverID = ? AND userID = ?", serverID, userID];
        if ([result next]) {
            pushConfig = [result stringForColumn:@"pushConfig"];
        }
        [result close];
    }];
    return pushConfig;
}

- (BOOL)updateUcConfig:(NSString *)ucConfig serverID:(NSString *)serverID userID:(NSString *)userID {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_account SET ucConfig = ? WHERE serverID = ? AND userID = ?", ucConfig, serverID, userID];
    }];
    return result;
}

- (NSString *)ucConfigWithServerID:(NSString *)serverID userID:(NSString *)userID {
    __block NSString *pushConfig = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account WHERE serverID = ? AND userID = ?", serverID, userID];
        if ([result next]) {
            pushConfig = [result stringForColumn:@"ucConfig"];
        }
        [result close];
    }];
    return pushConfig;
}

- (NSString *)passwordWithPhone:(NSString *)phone {
    __block NSString *password = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_account WHERE extend5 = ?", phone];
        if ([result next]) {
            password = [result stringForColumn:@"loginPassword"];
        }
        [result close];
    }];
    return password;
}

#pragma mark-
#pragma mark 关联账号

- (CMPAssociateAccountModel *)assAcountWithServerID:(NSString *)serverID userID:(NSString *)userID {
    __block CMPAssociateAccountModel *assAcount = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_associate_account WHERE serverID = ? AND userID = ?", serverID, userID];
        if ([result next]) {
            assAcount = [CMPAssociateAccountModel yy_modelWithDictionary:[result resultDictionary]];
        }
        [result close];
    }];
    return assAcount;
}

- (void)addAssAccount:(CMPAssociateAccountModel *)assAccount {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO m3_associate_account (serverUniqueID, serverID, userID, groupID, createTime, switchTime, unreadCount, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", assAccount.serverUniqueID, assAccount.serverID, assAccount.userID, assAccount.groupID, assAccount.createTime, assAccount.switchTime, @0, assAccount.extend1, assAccount.extend2, assAccount.extend3, assAccount.extend4, assAccount.extend5, assAccount.extend6, assAccount.extend7, assAccount.extend8, assAccount.extend9, assAccount.extend10];
    }];
}

- (NSArray<CMPAssociateAccountModel *> *)assAcountListWithServerID:(NSString *)serverID userID:(NSString *)userID {
    NSMutableArray *result = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM m3_associate_account WHERE groupID = (SELECT groupID FROM m3_associate_account WHERE serverID = ? AND userID = ?) ORDER BY createTime DESC", serverID, userID];
        while ([resultSet next]) {
            CMPAssociateAccountModel *assAccountModel = [CMPAssociateAccountModel yy_modelWithDictionary:[resultSet resultDictionary]];
            if ([assAccountModel.serverID isEqualToString:[CMPCore sharedInstance].serverID]) {
                continue;
            }
            FMResultSet *accountSet = [db executeQuery:@"SELECT * FROM m3_account WHERE serverID = ? AND userID = ?", assAccountModel.serverID, assAccountModel.userID];
            [accountSet next];
            CMPLoginAccountModel *loginAccountModel = [CMPLoginAccountModel yy_modelWithDictionary:[accountSet resultDictionary]];
            [accountSet close];
            
            FMResultSet *serverSet = [db executeQuery:@"SELECT * FROM m3_server WHERE serverID = ?", assAccountModel.serverID];
            [serverSet next];
            CMPServerModel *serverModel = [CMPServerModel yy_modelWithDictionary:[serverSet resultDictionary]];
            [serverSet close];
            
            assAccountModel.server = serverModel;
            assAccountModel.loginAccount = loginAccountModel;
            
            [result addObject:assAccountModel];
        }
    }];
    return result;
}

- (void)deleteAssAccountAndServerForServerID:(NSString *)serverID {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM m3_associate_account WHERE groupID = (SELECT groupID FROM m3_associate_account WHERE serverID = ?)", serverID];
        NSString *groupID = nil;
        while ([resultSet next]) {
            CMPAssociateAccountModel *assAccountModel = [CMPAssociateAccountModel yy_modelWithDictionary:[resultSet resultDictionary]];
            [db executeUpdate:@"DELETE FROM m3_account WHERE serverID = ? AND userID = ?", assAccountModel.serverID, assAccountModel.userID];
            [db executeUpdate:@"DELETE FROM m3_server WHERE serverID = ?", assAccountModel.serverID];
            groupID = assAccountModel.groupID;
        }
        if (![NSString isNull:groupID]) {
            [db executeUpdate:@"DELETE FROM m3_associate_account WHERE groupID = ?", groupID];
        }
    }];
}

- (void)deleteAssAccount:(CMPAssociateAccountModel *)assAccount {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM m3_associate_account WHERE serverID = ? AND userID = ?", assAccount.serverID, assAccount.userID];
    }];
}

- (void)updateUnreadWithAssAccount:(CMPAssociateAccountModel *)assAccount {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_associate_account SET unreadCount = ? WHERE serverID = ? AND userID = ?", [NSNumber numberWithInteger:assAccount.unreadCount], assAccount.serverID, assAccount.userID];
    }];
}

- (void)updateSwitchTimeWithAssAccount:(CMPAssociateAccountModel *)assAccount {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE m3_associate_account SET switchTime = ? WHERE serverID = ? AND userID = ?", assAccount.switchTime,  assAccount.serverID, assAccount.userID];
    }];
}

- (NSInteger)countOfAssAcountWithServerID:(NSString *)serverID {
    __block NSInteger count = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:@"SELECT COUNT(*) FROM m3_associate_account WHERE groupID = (SELECT groupID FROM m3_associate_account WHERE serverID = ?)", serverID];
    }];
    return count;
}

#pragma mark-
#pragma mark 兼职单位

- (NSArray<CMPPartTimeModel *> *)partTimeListWithServerID:(NSString *)serverID
                          userID:(NSString *)userID {
    NSMutableArray *result = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM m3_parttime WHERE serverID = ? AND userID = ? AND accountID != ?", serverID, userID, [CMPCore sharedInstance].currentUser.accountID];
        while ([resultSet next]) {
            CMPPartTimeModel *partTimeModel = [CMPPartTimeModel yy_modelWithDictionary:[resultSet resultDictionary]];
            [result addObject:partTimeModel];
        }
    }];
    return [result copy];
}

- (CMPPartTimeModel *)partTimeWithServerID:(NSString *)serverID
                                    userID:(NSString *)userID
                                 accountID:(NSString *)accountID {
    __block CMPPartTimeModel *result = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM m3_parttime WHERE serverID = ? AND userID = ? AND accountID = ?", serverID, userID, accountID];
        if ([resultSet next]) {
            result = [CMPPartTimeModel yy_modelWithDictionary:[resultSet resultDictionary]];
        }
        [resultSet close];
    }];
    return result;
}

- (void)clearPartTimesWithServerID:(NSString *)serverID
                            userID:(NSString *)userID {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM m3_parttime WHERE serverID = ? AND userID = ?", serverID, userID];
    }];
}

- (void)addPartTimes:(NSArray<CMPPartTimeModel *> *)partTimes; {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        for (CMPPartTimeModel *partTime in partTimes) {
            [db executeUpdate:@"INSERT INTO m3_parttime (serverID, userID, createTime, switchTime, accountID, accountName, accountShortName, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", partTime.serverID, partTime.userID, partTime.createTime, partTime.switchTime, partTime.accountID, partTime.accountName, partTime.accountShortName, partTime.extend1, partTime.extend2, partTime.extend3, partTime.extend4, partTime.extend5, partTime.extend6, partTime.extend7, partTime.extend8, partTime.extend9, partTime.extend10];
        }
    }];
}

#pragma mark-
#pragma mark-Getter & Setter

- (FMDatabaseQueue *)databaseQueue {
    if (!_databaseQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:CMPLoginDBProviderDbName];
        _databaseQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
        //_databaseQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:[[self class] createServerTableSql]];
            [db executeUpdate:[[self class] createUserTableSql]];
            [db executeUpdate:[[self class] createAssociateTableSql]];
            [db executeUpdate:[[self class] createPartTimeTableSql]];
            [db executeUpdate:[[self class] createOrgLoginTableSql]];
            [db executeUpdate:[[self class] createServerVpnTableSql]];
        }];
    }
    return _databaseQueue;
}

#pragma mark-
#pragma mark-SQLS

+ (NSString *)createServerTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     uniqueID text,\
     serverID text,\
     host text,\
     port text, \
     isSafe integer, \
     scheme text, \
     fullUrl text, \
     note text,\
     inUsed integer,\
     serverVersion text, \
     updateServer text, \
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderServerTableName];
    return sql;
}

+ (NSString *)createUserTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     serverID text,\
     userID text,\
     loginName text, \
     loginPassword text, \
     name text, \
     gesturePassword text,\
     gestureMode integer,\
     inUsed integer,\
     loginResult text,\
     appList text,\
     configInfo text,\
     accountID text,\
     departmentID text,\
     levelID text,\
     postID text,\
     departmentName text,\
     postName text,\
     iconUrl text,\
     pushConfig text,\
     ucConfig text,\
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderAccountTableName];
    return sql;
}

+ (NSString *)createAssociateTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     serverID text,\
     userID text,\
     serverUniqueID text,\
     groupID text,\
     createTime INTEGER,\
     switchTime INTEGER,\
     unreadCount INTEGER,\
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderAssociateTableName];
    return sql;
}

+ (NSString *)createPartTimeTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     serverID text,\
     userID text,\
     accountID text,\
     accountName text,\
     accountShortName text,\
     createTime INTEGER,\
     switchTime INTEGER,\
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderPartTimeTableName];
    return sql;
}

#pragma mark 组织码

+ (NSString *)createOrgLoginTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     orgCode text,\
     loginName text,\
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderOrgLoginTableName];
    return sql;
}

- (BOOL)addOrgLoginInfoWithOrgCode:(NSString *)orgCode loginName:(NSString*)loginName{
    __block BOOL insertResult = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM m3_org_login"];
        insertResult = [db executeUpdate:@"INSERT INTO m3_org_login (orgCode, loginName, extend1, extend2, extend3, extend4, extend5, extend6, extend7, extend8, extend9, extend10) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", orgCode, loginName,@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];

    }];
    return insertResult;
}

- (NSDictionary *)findOrgLoginInfo {
    NSMutableArray *resultArray = [NSMutableArray array];
       [self.databaseQueue inDatabase:^(FMDatabase *db) {
           FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_org_login ", CMPLoginDBProviderOrgLoginTableName];
           while ([result next]) {
               NSString *orgCode = [result stringForColumn:@"orgCode"];
               NSString *loginName = [result stringForColumn:@"loginName"];
               NSDictionary *dic = @{
                   @"orgCode":orgCode?:@"",
                   @"loginName":loginName?:@""
               };
               [resultArray addObject:dic];
           }
       }];
    return resultArray.firstObject;
}

#pragma mark - vpn
+ (NSString *)createServerVpnTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (id integer primary key autoincrement,\
     serverID text,\
     vpnUrl text,\
     vpnLoginName text, \
     vpnLoginPwd text, \
     extend1 text,\
     extend2 text,\
     extend3 text,\
     extend4 text,\
     extend5 text,\
     extend6 text,\
     extend7 text,\
     extend8 text,\
     extend9 text,\
     extend10 text)", CMPLoginDBProviderServerVpnTableName];
    return sql;
}

- (BOOL)addVpnInfoWith:(CMPServerVpnModel *)vpnModel{
    BOOL deleteResult = [self deleteServerVpnWithServerID:vpnModel.serverID];
    __block BOOL insertResult = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        insertResult = [db executeUpdate:@"INSERT INTO m3_server_vpn (serverID, vpnUrl, vpnLoginName, vpnLoginPwd, extend1) VALUES (?, ?, ?, ?, ?)",vpnModel.serverID,vpnModel.vpnUrl,vpnModel.vpnLoginName,vpnModel.vpnLoginPwd,vpnModel.vpnSPA];
    }];
    return deleteResult && insertResult;
}

- (BOOL)deleteServerVpnWithServerID:(NSString *)serverID {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM m3_server_vpn WHERE serverID = ?", serverID];
    }];
    return result;
}

- (CMPServerVpnModel *)getVpnInfoByServerID:(NSString *)serverID {
    NSMutableArray<CMPServerVpnModel *> *serverVpns = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM m3_server_vpn WHERE serverID = %@",serverID];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            CMPServerVpnModel *serverVpn = [CMPServerVpnModel yy_modelWithDictionary:[result resultDictionary]];
            [serverVpns addObject:serverVpn];
        }
    }];
    return serverVpns.firstObject;
}

@end
