//
//  CMPUpgradeToEncryptedDatabaseHelper.h
//  M3
//
//  Created by 程昆 on 2019/4/10.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPUpgradeToEncryptedDatabaseHelper : CMPObject

/**
 升级数据库为加密数据库
 */
+ (void)upgradeToEncryptedDatabase;

+ (void)postUpgradeToEncryptedDatabaseNotification;

@end

NS_ASSUME_NONNULL_END
