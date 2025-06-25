//
//  CMPOcrItemDBManager.m
//  CMPCore
//
//  Created by Shoujian Rao on 2021/12/9.
//

#import "CMPOcrItemDBManager.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/FMDatabaseQueueFactory.h>

NSString * const CMPOcrItemDbName = @"CMPOcrItem.db";
NSString * const CMPOcrItemTableName = @"m3_ocr_item";
@interface CMPOcrItemDBManager()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation CMPOcrItemDBManager

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
- (BOOL)addItem:(CMPOcrItemModel *)item{
    __block BOOL success;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"INSERT INTO m3_ocr_item (filePath_id, filePath, fileId, fileUrl,filename, taskStatus, packageId, servicePath, userId, serviceId, md5, fileType, exit1, exit2, exit3, createTime, updateTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
         item.filePath_id,
         item.filePath,
         item.fileId,
         item.fileUrl,
         item.filename,
         @(item.taskStatus),
         item.packageId,
         item.servicePath,
         item.userId,
         item.serviceId,
         item.md5,
         item.fileType,
         item.exit1,
         item.exit2,
         item.exit3,
         @([[NSDate date]timeIntervalSince1970]),
         @([[NSDate date]timeIntervalSince1970])];
        NSLog(@"ocr-item-addItem-%d",success);
    }];
    return success;
}
- (void)deleteItem:(CMPOcrItemModel *)item {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"DELETE FROM m3_ocr_item WHERE itemid = ?", item.itemid];
        NSLog(@"ocr-item-deleteItem-%d",success);
    }];
}


- (void)updateItem:(CMPOcrItemModel *)item{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"UPDATE m3_ocr_item SET filePath_id=?, filePath=?,fileId=?, fileUrl=?,filename=?, taskStatus=?, packageId=?, servicePath=?, userId=?, serviceId=?, md5=?, fileType=?, exit1=?, exit2=?, exit3=?, updateTime=? WHERE itemid=?",
         item.filePath_id,
         item.filePath,
         item.fileId,
         item.fileUrl,
         item.filename,
         @(item.taskStatus),
         item.packageId,
         item.servicePath,
         item.userId,
         item.serviceId,
         item.md5,
         item.fileType,
         item.exit1,
         item.exit2,
         item.exit3,
         @([[NSDate date]timeIntervalSince1970]),
         item.itemid
        ];
        NSLog(@"ocr-item-updateItem-%d",success);
    }];
}

- (void)updateItemTaskStatus:(CMPOcrItemModel *)item{
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"UPDATE m3_ocr_item SET taskStatus=?, updateTime=? WHERE itemid=?",
         @(item.taskStatus),
         @([[NSDate date]timeIntervalSince1970]),
         item.itemid
        ];
        NSLog(@"ocr-item-updateItemTaskStatus-%d",success);
    }];
}


- (NSArray<CMPOcrItemModel *> *)getAllItemWithServerId:(NSString *)serverId andUserId:(NSString *)userId andPackageId:(NSString *)packageId{
    __block NSMutableArray *array = [NSMutableArray array];
    __block CMPOcrItemModel *item = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM m3_ocr_item WHERE serviceId=? AND userId = ? AND packageId = ?", serverId,userId,packageId];
        while ([result next]) {
            item = [CMPOcrItemModel yy_modelWithDictionary:[result resultDictionary]];
            item.packageId = [[result resultDictionary] objectForKey:@"packageId"];
            [array addObject:item];
        }
        [result close];
    }];
    return [array copy];
}


#pragma mark - table sql

+ (NSString *)createOcrItemTableSql {
    NSString *sql =
    [NSString stringWithFormat:@"create table if not exists %@ \
     (itemid integer primary key autoincrement,\
     filePath_id text,\
     filePath text,\
     fileId text,\
     fileUrl text, \
     filename text,\
     taskStatus integer, \
     packageId text, \
     servicePath text, \
     userId text, \
     serviceId text,\
     md5 text,\
     fileType text,\
     exit1 text,\
     exit2 text,\
     exit3 text,\
     createTime text,\
     updateTime text)", CMPOcrItemTableName];
    return sql;
}
#pragma mark-Getter & Setter

- (FMDatabaseQueue *)databaseQueue {
    if (!_databaseQueue) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        NSString *dbPath = [documentsPath stringByAppendingPathComponent:CMPOcrItemDbName];
        _databaseQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];//不加密
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:[[self class] createOcrItemTableSql]];
        }];
    }
    return _databaseQueue;
}
@end
