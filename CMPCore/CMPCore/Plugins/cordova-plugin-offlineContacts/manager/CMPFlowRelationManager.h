//
//  CMPFlowRelationManager.h
//  M3
//
//  Created by wujiansheng on 2018/12/20.
//

#import <CMPLib/CMPObject.h>
#import "MAccountAvailableEntity.h"
#import "MAccountSetting.h"
#import "OfflineOrgMember.h"
#import "OfflineOrgLevel.h"
#import "OfflineOrgUnit.h"
#import "OfflineRelationship.h"
#import <CMPLib/FMDatabase.h>

// 协同选人权限逻辑

@interface CMPFlowRelationManager : CMPObject
@property (nonatomic, retain) FMDatabase *localContactsDB;

- (BOOL)checkChoosePersionRelation;

@end

