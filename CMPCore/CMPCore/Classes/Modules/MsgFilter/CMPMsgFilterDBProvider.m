//
//  CMPMsgFilterDBProvider.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/13.
//

#import "CMPMsgFilterDBProvider.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/FMDatabaseQueueFactory.h>
#import <CMPLib/CMPCore.h>
#import "CMPMsgFilterResult.h"

@interface CMPMsgFilterDBProvider()
@property (strong, nonatomic) FMDatabaseQueue *dataQueue;
@property (nonatomic,copy) NSString *dbPath;
@property (nonatomic,copy) NSString *identifier;
@end

@implementation CMPMsgFilterDBProvider


-(NSArray<CMPMsgFilter *>*)allFilters
{
    NSMutableArray<CMPMsgFilter *> *filters = [NSMutableArray array];
    [self.dataQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select * from ItemTable"];
        while ([result next]) {
            NSString *matchVal = [result stringForColumn:@"key"];
            NSString *replaceVal = [result stringForColumn:@"replace"];
            int level = [result intForColumn:@"type"];
            
            CMPMsgFilter *filter = [[CMPMsgFilter alloc] init];
            filter.matchVal = matchVal;
            filter.replaceVal = replaceVal;
            filter.level = level;
            
            [filters addObject:filter];
        }
    }];
    return filters;
}

-(BOOL)updateFilters:(NSArray<CMPMsgFilter *> *)filters
{
    if (!filters) {
        return NO;
    }
    __block BOOL rslt = NO;
    [self.dataQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            
            [db executeUpdate:@"DELETE FROM ItemTable"];
            for (CMPMsgFilter *filter in filters) {
                [db executeUpdate:@"insert into ItemTable (key, type, replace) values (?,?,?)",filter.matchVal,@(filter.level).stringValue,filter.replaceVal];
            }
            
        } @catch (NSException *exception) {
            
            *rollback = YES;
            rslt = NO;
            
        } @finally {
            
            *rollback = NO;
            rslt = YES;
        }
    }];
    return rslt;
}

-(void)close
{
    if (_dataQueue) {
        [_dataQueue close];
    }
}

-(FMDatabaseQueue *)dataQueue
{
    if (!_dataQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cmpMsgFilter_%@.db",self.identifier]];
        _dataQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:YES];
        [_dataQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ItemTable (key TEXT, type TEXT,replace TEXT, extend TEXT)"];
        }];
    }
    return _dataQueue;
}

-(NSString *)identifier
{
    if (!_identifier || _identifier.length == 0) {
        _identifier = [NSString stringWithFormat:@"%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].currentUser.accountID];
    }
    return _identifier;
}

@end
