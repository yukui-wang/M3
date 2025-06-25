//
//  CMPLoginUpdateManager.m
//  M3
//
//  Created by CRMO on 2017/11/15.
//

#import "CMPLoginUpdateManager.h"
#import <CMPLib/FMDB.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPAppListModel.h>
#import <CMPLib/FMDatabaseQueueFactory.h>

/** 数据库名定义 **/
NSString * const kMessageCategoryTableName = @"messageCategoryTable";
NSString * const kAppListTableName = @"appListTable";
NSString * const kTodoCategoryTableName = @"todoCategoryTable";
/** 数据库保存路径 **/
NSString * const kCMPLoginUpdateManagerSqliteName = @"serverId_%@_userId_%@_v201705262";

@interface CMPLoginUpdateManager()

@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;

@end

@implementation CMPLoginUpdateManager

#pragma mark-
#pragma mark-API

- (BOOL)createTables {
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL createMessageCategoryTableResult = [db executeUpdate:[[self class] createMessageCategoryTableSql]];
        BOOL createAppListTableResult = [db executeUpdate:[[self class] createAppListTableSql]];
        BOOL createTodoCategoryTableResult = [db executeUpdate:[[self class] createTodoCategoryTableSql]];
        result = createMessageCategoryTableResult && createAppListTableResult && createTodoCategoryTableResult;
    }];
    return result;
}

- (BOOL)insertApps:(CMPAppListModel *)appList {
    if (!appList ||
        appList.data.count == 0) {
        return false;
    }
    
    __block BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        BOOL isRollBack = false;
        [db executeUpdate:[[self class] deleteAllAppSql]];
        @try {
            for (CMPAppListData *app in appList.data) {
                if (!app.tags) {
                    app.tags = @"[]";
                }
//                if (!app || [NSString isNull:app.appId]) {
//                    continue;
//                }
                
                NSInteger count = [db intForQuery:@"select count(*) from appListTable where appType= ? and appId = ? and bizMenuId = ? and bundleName = ?", app.appType, app.appId, app.bizMenuId, app.bundleName];
                
                if (count == 0) {
                    NSString *appStatus = @"1";
                    if (app.sortNum == -1) {
                        appStatus = @"0";
                    }
                    if (![app.appType isEqualToString:@"default"] &&
                        ![app.appType isEqualToString:@"biz"] &&
                        ![app.appType isEqualToString:@"integration_shortcut"]) {
                        appStatus = @"-1";
                    }
                    [db executeUpdate:@"insert into appListTable (appId,domain,appName,desc, bundleIdentifier,version, appShortAddress,cmpShellVersion, appType, iconUrl, serverIdentifier,urlSchemes,entry, updateDate, appJoinAddress,md5,jsUrl,tags,appStatus,bundleName,bizMenuId,gotoParam,sortNum,isShow,unSelect,isThird,  isPreset, hasPlugin,isDelete)  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", app.appId, app.domain, app.appName, app.desc, app.bundleIdentifier, app.version, app.appShortAddress, app.cmpShellVersion, app.appType, app.iconUrl, app.serverIdentifier, app.urlSchemes, app.entry, app.updateDate, app.appJoinAddress, app.md5, app.jsUrl, app.tags, appStatus, app.bundleName, app.bizMenuId, app.gotoParam, [NSNumber numberWithInteger:app.sortNum], app.isShow, app.unSelect, [NSNumber numberWithInteger:app.isThird], [NSNumber numberWithInteger:app.isPreset], [NSNumber numberWithInteger:app.hasPlugin] , @0];
                } else {
                    [db executeUpdate:@"update appListTable set appId=?, domain=?,appName=?,desc=?, bundleIdentifier=?,version=?, appShortAddress=?,cmpShellVersion=?, appType=?, iconUrl=?, serverIdentifier=?,urlSchemes=?,entry=?, updateDate=?, appJoinAddress=?,md5=?,jsUrl=?,tags=?,bundleName=?,bizMenuId=?,gotoParam=?,isShow=?,isThird=?,  isPreset=?, hasPlugin=?, isDelete =? where appId = ? and appType=? and bizMenuId=? and bundleName=? ", app.appId, app.domain, app.appName, app.desc, app.bundleIdentifier, app.version, app.appShortAddress, app.cmpShellVersion, app.appType, app.iconUrl, app.serverIdentifier, app.urlSchemes, app.entry, app.updateDate, app.appJoinAddress, app.md5, app.jsUrl, app.tags, app.bundleName, app.bizMenuId, app.gotoParam, app.isShow, [NSNumber numberWithInteger:app.isThird], [NSNumber numberWithInteger:app.isPreset], [NSNumber numberWithInteger:app.hasPlugin], @0, app.appId, app.appType, app.bizMenuId, app.bundleName];
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        }
        @finally {
            if (!isRollBack) {
                result = [db commit];
            } else {
                result = NO;
            }
        }
    }];
    return result;
}

#pragma mark-
#pragma mark-Getter & Setter

- (FMDatabaseQueue *)databaseQueue {
    if (!_databaseQueue) {
        NSString *dbFolder = [CMPFileManager createFullPath:@"Library/LocalDatabase"];
        NSString *dbName = [NSString stringWithFormat:kCMPLoginUpdateManagerSqliteName, [CMPCore sharedInstance].serverID, [CMPCore sharedInstance].userID];
        NSString *dbPath = [dbFolder stringByAppendingPathComponent:dbName];
        _databaseQueue = [FMDatabaseQueueFactory databaseQueueWithPath:dbPath encrypt:NO];
    }
    return _databaseQueue;
}

#pragma mark-
#pragma mark-SQLS

/**
 创建messageCategoryTable的sql
 */
+ (NSString *)createAppListTableSql {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  %@  (id integer primary key, appId VARCHAR(30),domain varchar(20), appName VARCHAR(30),desc VARCHAR(20), bundleIdentifier VARCHAR(50),version VARCHAR(20), appShortAddress VARCHAR(100),cmpShellVersion varchar(10), appType VARCHAR(20), iconUrl text, serverIdentifier VARCHAR(30),urlSchemes VARCHAR(50),entry VARCHAR(200), updateDate VARCHAR(50), appJoinAddress text,md5 VARCHAR(50),jsUrl VARCHAR(200),tags text,appStatus VARCHAR(5),bundleName VARCHAR(40),bizMenuId VARCHAR(40),gotoParam VARCHAR(100),sortNum integer,isShow VARCHAR(5),unSelect VARCHAR(5),isDelete integer,isThird  integer,isPreset integer,hasPlugin integer,ext1 text,ext2 text,ext3 text,ext4 text,ext5 text,ext6 text,ext7 text,ext8 text,ext9 text,ext10 text,ext11 text,ext12 text,ext13 text,ext14 text,ext15 text)", kAppListTableName];
    return sql;
}

/**
 创建appListTable
 */
+ (NSString *)createMessageCategoryTableSql {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key, appId VARCHAR(30),unreadCount varchar(5),content varchar(50),createTime varchar(30),serverIdentifier varchar(30),orderId integer,thirdAppId VARCHAR(100),appName varchar(50),appType varchar(20),iconUrl text,isDelete integer,body varchar(50), fromId varchar(50), fromname varchar(50), gotoParams text, groupname varchar(50), msgtype varchar(20), timestamp varchar(50), toId varchar(50), toname varchar(30), type varchar(20),ext1 text,ext2 text,ext3 text,ext4 text,ext5 text,ext6 text,ext7 text,ext8 text,ext9 text,ext10 text,ext11 text,ext12 text,ext13 text,ext14 text,ext15 text)", kMessageCategoryTableName];
    return sql;
}

/**
 创建todoCategoryTable
 */
+ (NSString *)createTodoCategoryTableSql {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key,appId VARCHAR(30),classificationName varchar(50),subAppId varchar(5),isThird integer,sortNum integer,status integer,isPortlet integer,portletParams text,canDrag integer,total integer,isDelete integer)", kTodoCategoryTableName];
    return sql;
}

/**
 将appListTable中所有数据isDelete置1
 */
+ (NSString *)deleteAllAppSql {
    NSString *sql = [NSString stringWithFormat:@"update %@ set isDelete = 1", kAppListTableName];
    return sql;
}

@end
