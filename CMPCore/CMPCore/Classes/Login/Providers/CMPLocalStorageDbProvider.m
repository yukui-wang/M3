//
//  CMPLocalStorageDbProvider.m
//  M3
//
//  Created by CRMO on 2018/3/29.
//

#import "CMPLocalStorageDbProvider.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/FMDatabaseQueueFactory.h>

@interface CMPLocalStorageDbProvider()
@property (strong, nonatomic) FMDatabaseQueue *dataQueue;
@end

@implementation CMPLocalStorageDbProvider

- (instancetype)init {
    if (self = [super init]) {
        if ([self dataQueue]) {
            return self;
        }
    }
    return nil;
}

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key {
    if ([NSString isNull:value] ||
        [NSString isNull:key]) {
        return NO;
    }
    
    __block BOOL result;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from ItemTable where key = ?", key];
        NSData *data = [value dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
        result = [db executeUpdate:@"insert into ItemTable (key, value) values (?, ?)", key, data];
    }];
    return result;
}

- (NSString *)valueWithKey:(NSString *)key {
    if ([NSString isNull:key]) {
        return nil;
    }
    
    __block NSString *result;
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        NSData *data = [db dataForQuery:@"select value from ItemTable where key = ?", key];
        result = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    }];
    return result;
}

- (BOOL)clearAllData {
    return NO;
}

- (void)close {
    [self.dataQueue close];
}

#pragma mark-
#pragma mark- Getter & Setter

- (FMDatabaseQueue *)dataQueue {
    if (!_dataQueue) {
        NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbDir = [libDir stringByAppendingPathComponent:@"WebKit/LocalStorage/"];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dbDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        NSString *dbPath = [dbDir stringByAppendingPathComponent:@"file__0.localstorage"];
        _dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
        [_dataQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB NOT NULL ON CONFLICT FAIL)"];
        }];
    }
    return _dataQueue;
}

@end
