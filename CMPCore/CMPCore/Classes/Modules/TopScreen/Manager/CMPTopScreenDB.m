//
//  CMPTopScreenDB.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import "CMPTopScreenDB.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/FMDatabaseQueueFactory.h>

NSString * const CMPTopScreenDbName = @"CMPTopScreen.db";
NSString * const CMPTopScreenTableName = @"cmpTopScreen";
@interface CMPTopScreenDB()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation CMPTopScreenDB

- (instancetype)init {
    self = [super init];
    if (self) {
        [self databaseQueue];
    }
    return self;
}
- (void)dealloc {
    NSLog(@"%@-dealloc",self.class);
    [self.databaseQueue close];
}

#pragma mark - CRUD

- (BOOL)addItem:(CMPTopScreenModel *)model{
    __block BOOL success;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (uniqueId,appId, appType,bundleName,bizMenuId,m3from,iconUrl,appName,openType,goToParam,click,serverId,userId,serverVersion, createTime, updateTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",CMPTopScreenTableName];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql,
            model.uniqueId,
            model.appId,
            model.appType,
            model.bundleName,
            model.bizMenuId,
            model.m3from,
            model.iconUrl,
            model.appName,
            @(model.openType),
            model.goToParam,
            @(1),
            kCMP_ServerID,
            CMP_USERID,
            [CMPCore sharedInstance].serverVersion,
            @([[NSDate date]timeIntervalSince1970]),
            @([[NSDate date]timeIntervalSince1970])];
        NSLog(@"CMPTopScreenModel-addItem-%d",success);
    }];
    return success;
}

//app click+1
- (BOOL)addAppClick:(CMPTopScreenModel *)model{
    //INSERT OR REPLACE INTO 表名 (id, 字段名) VALUES (唯一ID, 新值);
    
    //先检查是否有数据
    NSString *sql0 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE serverId='%@' AND userId='%@' AND uniqueId='%@' AND serverVersion ='%@';",CMPTopScreenTableName,kCMP_ServerID,CMP_USERID,model.uniqueId,[CMPCore sharedInstance].serverVersion];
    __block BOOL exist = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql0];
        while ([result next]) {
            exist = YES;
        }
        [result close];
    }];
    if (exist) {//如果数据存在，则click+1
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET click = click + 1,updateTime=? WHERE uniqueId = '%@' AND serverId='%@' AND userId='%@' AND serverVersion ='%@';",CMPTopScreenTableName,model.uniqueId,kCMP_ServerID,CMP_USERID,[CMPCore sharedInstance].serverVersion];
        __block BOOL success;
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            success = [db executeUpdate:sql,@([[NSDate date]timeIntervalSince1970])];
            NSLog(@"CMPTopScreenModel-updateClick+1-%d",success);
        }];
        return success;
    }else{//新增数据
        return [self addItem:model];
    }

}

//获取top click点击数排前的app
- (NSArray<CMPTopScreenModel *> *)getTopAppClickCount:(NSInteger)topCount{
    __block NSMutableArray *array = [NSMutableArray array];
    __block CMPTopScreenModel *model = nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE serverId='%@' AND userId='%@' AND serverVersion ='%@' ORDER BY click DESC,updateTime DESC LIMIT %ld;",CMPTopScreenTableName,kCMP_ServerID,CMP_USERID,[CMPCore sharedInstance].serverVersion,topCount];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            model = [CMPTopScreenModel yy_modelWithDictionary:[result resultDictionary]];
            [array addObject:model];
        }
        [result close];
    }];
    
    return [array copy];
}

- (BOOL)delAllTopApp{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE serverId='%@' AND userId='%@'",CMPTopScreenTableName,kCMP_ServerID,CMP_USERID];
    __block BOOL success = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql];
        NSLog(@"delAllTopApp-%d",success);
    }];
    return success;
}

#pragma mark - table sql

+ (NSString *)createTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (modelId integer primary key autoincrement,\
    uniqueId text,\
    appId text,\
    appType text,\
    bundleName text,\
    bizMenuId text, \
    m3from text, \
    iconUrl text, \
    appName text, \
    openType integer,\
    goToParam text,\
    click integer,\
    serverVersion text,\
    userId text,\
    serverId text,\
    createTime text,\
    updateTime text,\
    ext1 text,\
    ext2 text,\
    ext3 text)", CMPTopScreenTableName];
    return sql;
}
#pragma mark-Getter & Setter

- (FMDatabaseQueue *)databaseQueue {
    if (!_databaseQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:CMPTopScreenDbName];
        _databaseQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];//不加密
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:[[self class] createTableSql]];
        }];
    }
    return _databaseQueue;
}
@end
