//
//  CMPUpgradeToEncryptedDatabaseHelper.m
//  M3
//
//  Created by 程昆 on 2019/4/10.
//

#import "CMPUpgradeToEncryptedDatabaseHelper.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/FMEncryptHelper.h>
#import <CMPLib/FMEncryptDatabase.h>

NSString * const CMPLoginDBProviderDatabaseName = @"Login.db";
NSString * const CMPCommonDBProviderDatabaseName = @"seeyon_cmp_db.db";
NSString * const kLocalMessagerDatabaseName = @"localMessage.db";
NSString * const kRCUserCacheDatabaseName = @"RCUserCache.db";

NSNotificationName const CMPDatabaseDidUpgradeToEncrypNotification = @"DatabaseDidUpgradeToEncrypt";

@implementation CMPUpgradeToEncryptedDatabaseHelper

+ (void)upgradeToEncryptedDatabase {
    NSString * const encryptKey = [[[[[NSString stringWithFormat:@"sghxhshs"]
                                       stringByAppendingPathComponent:@"152552"]
                                       stringByAppendingPathExtension:@"1626hdhdhnj28xh"]
                                       stringByReplacingOccurrencesOfString:@"a1" withString:@"bb"]
                                       stringByDeletingPathExtension];
    [FMEncryptDatabase setEncryptKey:encryptKey];
    
    NSString *databaseEncryptFlag_contact = @"databaseEncryptFlag_contact";
    BOOL databaseEncryptValue_contact = [[NSUserDefaults standardUserDefaults] boolForKey:databaseEncryptFlag_contact];
    if (!databaseEncryptValue_contact) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:nil];
        for (NSString *fileName in fileList) {
            if (([fileName hasPrefix:@"contacts_table_"] && [fileName hasSuffix:@".sqlite"])
                ||([fileName hasPrefix:@"cmpMsgFilter_"] && [fileName hasSuffix:@".db"])) {
                NSString *_aPath = [docPath stringByAppendingPathComponent:fileName];
                [FMEncryptHelper encryptDatabase:_aPath];
            }
        }
        
        NSString *lsDbPath = [docPath stringByAppendingPathComponent:@"cmpJsLS.db"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:lsDbPath]) {
            [FMEncryptHelper encryptDatabase:lsDbPath];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:databaseEncryptFlag_contact];
    }
    
    NSString *databaseEncryptFlag = kUserDefaultName_DatabaseEncryptFlag;
    BOOL databaseEncryptValue = [[NSUserDefaults standardUserDefaults] boolForKey:databaseEncryptFlag];
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:CMPLoginDBProviderDatabaseName];
    BOOL isDatabaseExists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    
    if (databaseEncryptValue || !isDatabaseExists) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_DatabaseEncryptFlag];
        //[[NSNotificationCenter defaultCenter] postNotificationName:CMPDatabaseDidUpgradeToEncrypNotification object:nil];
        [self postUpgradeToEncryptedDatabaseNotification];
        return;
    }
    
    NSString *loginDBProviderDatabasePath = [documentsPath stringByAppendingPathComponent:CMPLoginDBProviderDatabaseName];
    NSString *commonDBProviderDatabasePath = [documentsPath stringByAppendingPathComponent:CMPCommonDBProviderDatabaseName];
    NSString *localMessagerDatabasePath = [documentsPath stringByAppendingPathComponent:kLocalMessagerDatabaseName];
    NSString *RCUserCacheDatabasePath = [documentsPath stringByAppendingPathComponent:kRCUserCacheDatabaseName];
    [FMEncryptHelper encryptDatabase:loginDBProviderDatabasePath];
    [FMEncryptHelper encryptDatabase:commonDBProviderDatabasePath];
    [FMEncryptHelper encryptDatabase:localMessagerDatabasePath];
    [FMEncryptHelper encryptDatabase:RCUserCacheDatabasePath];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_DatabaseEncryptFlag];
    //[[NSNotificationCenter defaultCenter] postNotificationName:CMPDatabaseDidUpgradeToEncrypNotification object:nil];
    [self postUpgradeToEncryptedDatabaseNotification];
   
    
    return;
}

+ (void)postUpgradeToEncryptedDatabaseNotification {
    [[CMPCore sharedInstance] databaseDidUpgradeToEncrypt];
//    [[NSNotificationCenter defaultCenter] postNotificationName:CMPDatabaseDidUpgradeToEncrypNotification object:nil];
}

@end
