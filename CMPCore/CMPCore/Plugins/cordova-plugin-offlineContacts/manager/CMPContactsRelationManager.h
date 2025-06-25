//
//  CMPContactsRelationManager.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>
#import "MAccountAvailableEntity.h"
#import "MAccountSetting.h"
#import "OfflineOrgMember.h"
#import "OfflineOrgLevel.h"
#import "OfflineOrgUnit.h"
#import "OfflineRelationship.h"
#import <CMPLib/FMDatabase.h>

@interface CMPContactsRelationManager : CMPObject
@property (nonatomic, retain) FMDatabase *localContactsDB;

- (BOOL)checkLevelScope:(NSArray<MAccountAvailableEntity *> *)t  defaultValue:(BOOL)init;

- (BOOL)checkPhoneAndLevelShow:(MAccountSetting *)s accountId:(long long)accountId;

- (BOOL)checkLevelScope:(MAccountSetting *)s accountId:(long long)accountId;

- (BOOL)checkOrgScope:(MAccountSetting *)s accountId:(long long)accountId;

- (OfflineOrgLevel *)getMinLevel:(NSArray <OfflineOrgLevel*>*) ls groupId:(long long)groupId;

- (NSArray<OfflineOrgLevel*>*)getLevelByScope:(long long) accountId scope:(int)scope;

- (NSArray<OfflineOrgLevel*>*)getLevelByAccountId:(long long) accountId;

- (OfflineOrgLevel *)getLevelById:(long long) levelId;

- (OfflineOrgUnit *)getAccountByAccountId:(long long) accountId;

- (NSArray *)getDepartmentsByAccountId:(long long)accoundId;
- (NSArray *)getDepartmentsByAccountId:(long long)accountId limit:(NSInteger)limit offset:(NSInteger)offset;

/*
 * 获取部门下的所有子部门 根据 new OfflineOrgUnit().getPa(); 先根据 departmentId 获取当前部门的path
 * 再获取所有此单位下 pa 以path开头的所有部门ID like ‘path%’
 */
- (NSArray *)getAllDepartChildren:(long long)departmentId accountID:(long long)accountID;

// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成1
- (BOOL)updateRelationByDepartArray:(NSArray *)depart accountID:(long long)accountID value:(NSInteger)value;

// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成1
- (BOOL)updateRelationByMembersArray:(NSArray *)members accountID:(long long)accountID value:(NSInteger)value;

// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成1
- (BOOL)updateRelationByLevelArray:(NSArray *) level accountID:(long long)accountID value:(NSInteger)value;
- (BOOL)updateRelationByPostArray:(NSArray *) level accountID:(long long)accountID value:(NSInteger)value;

// 判断当前人员是内部还是外部人员 true 内部 ，false 外部
- (OfflineOrgMember *)getCurrentUser;
// TODO 获取当前登陆人员的关系列表
- (NSArray <OfflineRelationship *>*) getCurrentRelationship:(long long)accountID memberID:(long long) memberID;

/**
 * 将此单位下的所有关系设置为不可见 对应的对象为OfflineRelationship android需要在次对象中设置通讯录访问权限属性
 * availabel_contacts int, 0,1 availabel_flow int,0,1 availabel_edoc int
 * ,0,1 availabel_form int,0,1 showTel int,0,1 showLevel int0,1
 *
 * @param accountId
 * @return
 */
- (BOOL)updateLevelScope:(long long)accountId availabel:(int)availabel;

- (BOOL)updateMemberInfoShow:(long long)account
                   phoneShow:(int)phoneShow
                   levelShow:(int)levelShow;

- (BOOL)updateMemberInfoShowByDeparts:(long long)account
                           departList:(NSArray *)departList
                            phoneShow:(int)phoneShow
                            levelShow:(int)levelShow;

- (BOOL)updateMemberInfoShowByLevels:(long long)account
                           levelList:(NSArray *)levelList
                           phoneShow:(int)phoneShow
                           levelShow:(int)levelShow;

- (BOOL)updateMemberInfoShowByPost:(long long)account
                          postList:(NSArray *)postList
                         phoneShow:(int)phoneShow
                         levelShow:(int)levelShow;

- (BOOL)updateMemberInfoShowByMembers:(long long)account
                          membersList:(NSArray *)membersList
                            phoneShow:(int)phoneShow
                            levelShow:(int)levelShow;

@end
