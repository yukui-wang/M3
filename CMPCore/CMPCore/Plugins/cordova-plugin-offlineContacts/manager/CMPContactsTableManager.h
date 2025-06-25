//
//  CMPContactsTableManager.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#define kContactsTempTable @"TB_CONTACTSTEMPS"
#define kContactsFrequentTable @"TB_FREQUENT"
#define kFlowTempTable @"TB_FLOWTEMPS"


#import <CMPLib/CMPObject.h>
#import <CMPLib/FMDatabase.h>
#import "MAccountAvailableEntity.h"
@interface CMPContactsTableManager : CMPObject

+ (void)createTables:(FMDatabase *)contactsDB;
+ (void)defaultValusForTables:(FMDatabase *)contactsDB;
+ (void)clearTable:(FMDatabase *)contactsDB;

+ (NSArray *)sqlArrayWithPath:(NSString *)path info:(NSDictionary *)info;
//更新
+ (NSArray *)updateLogWithType:(NSString *)type value:(NSString *)value aId:(NSString *)aId;
+ (NSDictionary *)getAllupdateLog:(FMDatabase *)contactsDB aId:(NSString *)aId sId:(NSString *)sId;

+ (BOOL)needUpdateAccountSettingSql:(MAccountAvailableEntity *)entity db:(FMDatabase *)contactsDB;

+ (void)runInsertAccountSettingSql:(MAccountAvailableEntity *)entity db:(FMDatabase *)contactsDB;
+ (NSString *)jsonForAccountSettingInSql:(FMDatabase *)contactsDB;//暂时不用了
+ (NSDictionary *)getAccountSetting:(FMDatabase *)contactsDB;

//创建临时表
+ (BOOL)isExitTempTable:(FMDatabase *)db;
+ (void)dropTempTable:(FMDatabase *)db;
+ (void)createTempTable:(FMDatabase *)db;

//汉字转拼音
+ (NSString *)pinyin:(NSString *)name;


//常用联系人
+ (void)insertFequestFrequentContacts:(NSArray *)dataList db:(FMDatabase *)db;

//协同选人选人零时表
+ (void)createFlowTempTable:(FMDatabase *)db;

@end
