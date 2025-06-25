//
//  CMPJSLocalStorageDBProvider.m
//  M3
//
//  Created by Kaku Songu on 11/22/21.
//

#import "CMPJSLocalStorageDBProvider.h"
#import "FMDB.h"
#import "FMDatabaseQueueFactory.h"

@interface CMPJSLocalStorageDBProvider()
@property (strong, nonatomic) FMDatabaseQueue *dataQueue;
@property (nonatomic,copy) NSString *dbPath;
@end

@implementation CMPJSLocalStorageDBProvider

- (instancetype)init {
    if (self = [super init]) {
        if ([self dataQueue]) {
            return self;
        }
    }
    return nil;
}

- (BOOL)setItem:(NSString *)value forKey:(NSString *)key {
    if ([NSString isNull:value] ||
        [NSString isNull:key]) {
        return NO;
    }
    
    __block BOOL result;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from ItemTable where key = ?", key];
        result = [db executeUpdate:@"insert into ItemTable (key, value) values (?, ?)", key, value];
    }];
    return result;
}

- (NSString *)getItem:(NSString *)key {
    if ([NSString isNull:key]) {
        return nil;
    }
    
    __block NSString *result;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        result = [db stringForQuery:@"select value from ItemTable where key = ?", key];
    }];
    return result;
}

- (BOOL)removeItem:(NSString *)key
{
    if ([NSString isNull:key]) {
        return NO;
    }
    __block BOOL result;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from ItemTable where key = ?", key];
    }];
    return result;
}

- (NSDictionary *)allData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select * from ItemTable"];
        while ([result next]) {
            NSString *key = [result stringForColumn:@"key"];
            NSString *val = [result stringForColumn:@"value"];
            [dic setObject:val forKey:key];
        }
    }];
    return dic;
}

- (BOOL)clearAllData {
    return NO;
}

- (void)close {
    [self.dataQueue close];
}

- (FMDatabaseQueue *)dataQueue {
    if (!_dataQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"cmpJsLS.db"];
        _dbPath = dbPath;
        _dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
        [_dataQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ItemTable (key TEXT, value TEXT, identifier TEXT, extend TEXT)"];
        }];
    }
    return _dataQueue;
}

-(NSString *)dbPath
{
    return _dbPath;
}
@end
