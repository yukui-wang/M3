//
//  CMPFlowRelationManager.m
//  M3
//
//  Created by wujiansheng on 2018/12/20.
//

#import "CMPFlowRelationManager.h"
@interface CMPFlowRelationManager () {
    OfflineOrgMember *_currentMember;
    
}

@end

@implementation CMPFlowRelationManager
- (void)dealloc
{
    SY_RELEASE_SAFELY(_currentMember);
    SY_RELEASE_SAFELY(_localContactsDB)
    [super dealloc];
}

- (BOOL)checkChoosePersionRelation{
   
    // 不能访问此单位时 需要将这个单位下的所以人员设置成不可见
    [self updateLevelScope:self.getCurrentUser.accountId availabel:0];
    // 如果设置有改变或者需要做初始化 这重新判断
    [self checkOrgScopeWithAccountId:self.getCurrentUser.accountId];

    
    NSArray *selfArray = nil;
    //自己是始终可以看到的，所以不隐藏
    if (![NSString isNull:[CMPCore sharedInstance].userID]) {
        selfArray = [NSArray arrayWithObject:[CMPCore sharedInstance].userID];
    }
    long long curAccount = [[CMPCore sharedInstance].currentUser.accountID longLongValue];
    [self updateRelationByMembersArray:selfArray accountID:curAccount value:1];
    
    return YES;
}


- (BOOL)checkOrgScopeWithAccountId:(long long)accountId{
    OfflineOrgMember *user = [self getCurrentUser];
    OfflineOrgUnit *unit = [self getAccountByAccountId:accountId];
    if (user.insernal) {
        int scope = unit.sc;// 获取单位工作范围设置
        if (scope < 0) {
            // TODO 没有设置 工作范围 默认都可以看到
            [self updateLevelScope:accountId availabel:1];
            
        } else {
            OfflineOrgLevel *levle = [self getLevelById:user.levelId];
            
            if (user.accountId == accountId) {
                int visibleLevelNum = levle.l - scope;
                NSArray *levels = [self getLevelByScope:accountId scope:visibleLevelNum];
                NSMutableArray *l = [NSMutableArray array]; //new ArrayList<Long>(levels.size());
                for (OfflineOrgLevel *ss in levels) {
                    NSString *oid = [NSString stringWithFormat:@"%lld",ss.oId];
                    [l addObject:oid];
                }
                [self updateRelationByLevelArray:l accountID:accountId value:1];
                NSArray *relation = [self getCurrentRelationship:accountId memberID:user.memberId];
                NSMutableArray *childDepart = [NSMutableArray array];
                NSMutableSet *set = [NSMutableSet set];
                for (OfflineRelationship *ship in relation) {
                    NSArray *tempd = [self getAllDepartChildren:ship.dId accountID:accountId];
                    [set addObjectsFromArray:tempd];
                }
                [childDepart addObjectsFromArray:set.allObjects];
                [self updateRelationByDepartArray2:childDepart accountID:accountId value:1];
            } else {
                NSArray *relation = [self getCurrentRelationship:accountId memberID:user.memberId];
                OfflineOrgLevel *partTimeLevel = nil;
                NSMutableArray *partTimeDepartIds = [NSMutableArray array];
                // TODO 兼职可以有多个 去职务级别最大的那个
                for (OfflineRelationship *ship in relation) {
                    OfflineOrgLevel *temp =  [self getLevelById:ship.lId];
                    if (!partTimeLevel) {
                        partTimeLevel = temp;
                    } else if (temp.l < partTimeLevel.l) {
                        partTimeLevel = temp; // TODO 到底是大于还是小于待定
                    }
                    NSString *did = [NSString stringWithFormat:@"%lld",ship.dId];
                    if (![partTimeDepartIds containsObject:did]) {
                        [partTimeDepartIds addObject:did];
                    }
                }
                if (relation.count >0) {
                    // TODO 表示有兼职;
                    int visibleLevelNum = partTimeLevel.l - scope;
                    NSArray *levels = [self getLevelByScope:accountId scope:visibleLevelNum];
                    NSMutableArray *l = [NSMutableArray array];
                    for (OfflineOrgLevel *ss in levels) {
                        NSString *oId = [NSString stringWithFormat:@"%lld",ss.oId];
                        [l addObject:oId];
                    }
                    [self updateRelationByLevelArray:l accountID:accountId value:1];
                    [self updateRelationByDepartArray:partTimeDepartIds accountID:accountId value:1];
                } else {
                    // TODO 没有兼职
                    NSArray* allLevels = [self getLevelByAccountId:accountId];
                    OfflineOrgLevel *minLevels = [self getMinLevel:allLevels groupId:levle.gl];
                    int visibleLevelNum = minLevels.l - scope;
                    NSArray* levels = [self getLevelByScope:accountId scope:visibleLevelNum];
                    NSMutableArray* l = [NSMutableArray array];
                    for (OfflineOrgLevel *ss in levels) {
                        NSString *oId = [NSString stringWithFormat:@"%lld",ss.oId];
                        [l addObject:oId];
                    }
                    [self updateRelationByLevelArray:l accountID:accountId value:1];
                }
            }
        }
        //内部人员看外部人员 begin
        NSString *sql = [NSString stringWithFormat:@"select m.id, m.ws from tb_member as m inner join tb_relation as r on m.id = r.mid  where m.ins = 0 and r.[AID] = %lld",accountId];
        FMResultSet *set1 =  [_localContactsDB executeQuery:sql];
        NSMutableDictionary *outerDic = [NSMutableDictionary dictionary];
        NSMutableArray *midList = [NSMutableArray array];
        while ([set1 next]) {
            NSString *mid = [set1 stringForColumn:@"id"];
            NSString *ws = [set1 stringForColumn:@"ws"];
            [midList addObject:mid];
            [outerDic setObject:ws forKey:mid];
            
        }
        
        [self updateRelationByMembersArray:midList accountID:accountId value:0];
        
        
        
        //获取当前人员所有的部门，包括副刚部门
        NSString *sql2 = [NSString stringWithFormat:@"SELECT did FROM TB_RELATION WHERE MID = '%lld' and AID = '%lld' ",user.memberId,accountId];
        FMResultSet *set2 =  [_localContactsDB executeQuery:sql2];
        NSMutableArray *userDeptList = [NSMutableArray array];
        while ([set2 next]) {
            NSString *did = [set2 stringForColumn:@"did"];
            [userDeptList addObject:did];
        }
        NSMutableArray *memberIdList = [NSMutableArray array];
        for (NSString *mid in midList) {
            NSString *ws = [outerDic objectForKey:mid];
            
            NSArray *split = [ws componentsSeparatedByString:@","];
            for (NSString *string in split) {
                
                NSString *depart = @"Department|";
                NSString *member = [NSString stringWithFormat:@"Member|%lld",user.memberId];
                NSString *level = [NSString stringWithFormat:@"Level|%lld",user.levelId];
                NSString *post = [NSString stringWithFormat:@"Post|%lld",user.postId];
                NSString *account = [NSString stringWithFormat:@"Account|%lld",user.accountId];
                if ([string rangeOfString:depart].location != NSNotFound) {
                    NSString *outerDept = [string  replaceCharacter:depart withString:@""];
                    NSArray *childList = [self getAllDepartChildren:outerDept.longLongValue accountID:user.accountId];
                    for (NSString *userDept in userDeptList) {
                        if ([childList containsObject:userDept]) {
                            [memberIdList addObject:mid];
                        }
                    }
                } else if ([string isEqualToString:member]) {
                    [memberIdList addObject:mid];
                } else if ([string isEqualToString:level]) {
                    [memberIdList addObject:mid];
                } else if ([string isEqualToString:post]) {
                    [memberIdList addObject:mid];
                } else if ([string isEqualToString:account]) {
                    [memberIdList addObject:mid];
                }
                
            }
        }
        [self updateRelationByMembersArray:memberIdList accountID:accountId value:1];
        //内部人员看外部人员 end
        
        
        
    }
    else {
        if (user.accountId == accountId) {
            NSMutableArray *departlist = [NSMutableArray array];
            NSString *departId = [NSString stringWithFormat:@"%lld",user.departId];
            [departlist addObject:departId];
            NSString* workScope = user.workScope;
            
            NSMutableArray *memberList = [NSMutableArray array];
            NSArray* workScopeArray = [workScope componentsSeparatedByString:@","];
            BOOL isAccountScope = NO;
            for (int x = 0; x < workScopeArray.count; x++) {
                
                NSArray* tempArray = [workScopeArray[x] componentsSeparatedByString:@"|"];
                if (tempArray.count < 2) {
                    continue;
                }
                NSString *temp0 = [tempArray objectAtIndex:0];
                NSString *temp1 = [tempArray objectAtIndex:1];
                if ([@"Account" isEqualToString:temp0]) {
                    isAccountScope = YES;
                }
                else if ([@"Department" isEqualToString:temp0]) {
                    NSArray *childList = [self getAllDepartChildren:temp1.longLongValue accountID:user.accountId];
                    [departlist addObjectsFromArray:childList];
                }
                else if ([@"Member" isEqualToString:temp0]) {
                    [memberList addObject:temp1];
                }
            }
            if (isAccountScope) {
                [self updateLevelScope:accountId availabel:1];
            }
            [self updateRelationByDepartArray:departlist accountID:accountId value:1];
            [self updateRelationByMembersArray:memberList accountID:accountId value:1];
            //除本外部单位的外部单位都不可见
            NSMutableArray  *outDept = [self getAllOutDepartList];
            [outDept removeObject:departId];
            [self updateRelationByDepartArray:outDept accountID:accountId value:0];
            
        } else {
            // TODO 不做处理
        }
    }
    return YES;
}

- (OfflineOrgLevel *)getMinLevel:(NSArray <OfflineOrgLevel*>*) ls groupId:(long long)groupId{
    OfflineOrgLevel *level = nil;
    for (OfflineOrgLevel *l in ls) {
        if (l.gl == groupId) {
            level = l;
            break;
        } else {
            if (!level) {
                level = l;
            } else {
                if (l.l > level.l) {
                    level = l;
                }
            }
        }
    }
    return level;
}

//-- 获取当前单位权限范围内的职务级别集合
- (NSArray<OfflineOrgLevel*>*)getLevelByScope:(long long) accountId scope:(int)scope{
    NSString *sql = [NSString stringWithFormat:@"select * from tb_level  where AID = %lld and level >= %d",accountId,scope];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *resultList = [NSMutableArray array];
    while ([set next]) {
        OfflineOrgLevel *level = [[OfflineOrgLevel alloc] init];
        level.oId = [set longLongIntForColumn:@"id"];
        level.n = [set stringForColumn:@"name"];
        level.m = [set stringForColumn:@"mark"];
        //        level.t = [set stringForColumn:@"t"];
        level.v = [set intForColumn:@"view"];
        level.s = [set longLongIntForColumn:@"scope"];
        level.aId = [set longLongIntForColumn:@"aId"];
        level.l = [set intForColumn:@"level"];
        level.gl = [set longLongIntForColumn:@"group_level"];
        [resultList addObject:level];
        SY_RELEASE_SAFELY(level)
    }
    return resultList;
}
//-- 获取当前单位的职务级别集合
- (NSArray<OfflineOrgLevel*>*)getLevelByAccountId:(long long) accountId{
    NSString *sql = [NSString stringWithFormat:@"select * from tb_level  where AID = %lld",accountId];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *resultList = [NSMutableArray array];
    while ([set next]) {
        OfflineOrgLevel *level = [[OfflineOrgLevel alloc] init];
        level.oId = [set longLongIntForColumn:@"id"];
        level.n = [set stringForColumn:@"name"];
        level.m = [set stringForColumn:@"mark"];
        //        level.t = [set stringForColumn:@"t"];
        level.v = [set intForColumn:@"view"];
        level.s = [set longLongIntForColumn:@"scope"];
        level.aId = [set longLongIntForColumn:@"aId"];
        level.l = [set intForColumn:@"level"];
        level.gl = [set longLongIntForColumn:@"group_level"];
        [resultList addObject:level];
        SY_RELEASE_SAFELY(level)
    }
    return resultList;
}


//-- 根据职务级别ID获取职务级别信息
- (OfflineOrgLevel *)getLevelById:(long long) levelId{
    
    NSString *sql = [NSString stringWithFormat:@"select * from tb_level  where ID = %lld",levelId];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    OfflineOrgLevel *level = [[OfflineOrgLevel alloc] init];
    while ([set next]) {
        level.oId = [set longLongIntForColumn:@"id"];
        level.n = [set stringForColumn:@"name"];
        level.m = [set stringForColumn:@"mark"];
        //        level.t = [set stringForColumn:@"t"];
        level.v = [set intForColumn:@"view"];
        level.s = [set longLongIntForColumn:@"scope"];
        level.aId = [set longLongIntForColumn:@"aId"];
        level.l = [set intForColumn:@"level"];
        level.gl = [set longLongIntForColumn:@"group_level"];
    }
    return [level autorelease];
}
//-- 根据单位ID获取单位信息
- (OfflineOrgUnit *)getAccountByAccountId:(long long) accountId{
    
    NSString *sql = [NSString stringWithFormat:@"select * from TB_UNIT  where ID = %lld",accountId];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    OfflineOrgUnit *orgUnit = [[OfflineOrgUnit alloc] init];
    while ([set next]) {
        orgUnit.oId = [set longLongIntForColumn:@"id"];
        orgUnit.n = [set stringForColumn:@"name"];
        orgUnit.m = [set stringForColumn:@"org_mark"];
        orgUnit.t = [set stringForColumn:@"type"];
        orgUnit.v = [set intForColumn:@"view"];
        orgUnit.s = [set longLongIntForColumn:@"sort"];
        orgUnit.pa = [set stringForColumn:@"path"];
        orgUnit.fa = [set longLongIntForColumn:@"parent_Id"];
        orgUnit.aId = [set longLongIntForColumn:@"id"];
        orgUnit.sc = [set intForColumn:@"scope"];//??
        orgUnit.internal = [set intForColumn:@"internal"];
        //        orgUnit.ac = [set intForColumn:@"ac"];
    }
    return [orgUnit autorelease];
}

/*
 * 获取部门下的所有子部门 根据 new OfflineOrgUnit().getPa(); 先根据 departmentId 获取当前部门的path
 * 再获取所有此单位下 pa 以path开头的所有部门ID like ‘path%’
 */

//-- 根据单位ID和部门ID获取部门下面的所有子部门
- (NSArray *)getAllDepartChildren:(long long)departmentId accountID:(long long)accountID{
    
    NSString *pathSql = [NSString stringWithFormat:@"SELECT [PATH] FROM tb_unit WHERE [ID] = '%lld'",departmentId];
    FMResultSet *pathset =  [_localContactsDB executeQuery:pathSql];
    NSString *path = @"";
    while ([pathset next]) {
        path = [pathset stringForColumn:@"PATH"];
    }
    NSMutableArray *resultList = [NSMutableArray array];
    if ([NSString isNull:path]) {
        return resultList;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM tb_unit WHERE [PATH] LIKE '%@%%'",path];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    while ([set next]) {
        NSString *string = [set stringForColumn:@"ID"];
        [resultList addObject:string];
    }
    return resultList;
}


// 更新人员关系表 将 AVAILABLE_FLOW 设置成value
- (BOOL)updateRelationByDepartArray:(NSArray *)depart accountID:(long long)accountID  value:(NSInteger)value{
    if (!depart || depart.count ==0) {
        return NO;
    }
    NSString *departString = [self stringFormList:depart];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_FLOW = %ld WHERE [DID] IN (%@) AND [AID] = '%lld'",(long)value,departString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}
- (BOOL)updateRelationByDepartArray2:(NSArray *)depart accountID:(long long)accountID  value:(NSInteger)value{
    //只可见所在部门（含子部门），但以下人员能看全单位   如果在某个部门可见某人员，该人员在其他部门也应该可见
    if (!depart || depart.count ==0) {
        return NO;
    }
    NSString *departString = [self stringFormList:depart];
    NSString *sql1 = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_FLOW = %ld WHERE [MID] IN (SELECT MID FROM TB_RELATION WHERE DID IN ( %@ ) AND [AID] = '%lld' ) AND [AID] = '%lld'",(long)value,departString,accountID,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql1];
    return result;
}

// 更新人员关系表 将 AVAILABLE_FLOW 设置成1
- (BOOL)updateRelationByMembersArray:(NSArray *)members accountID:(long long)accountID  value:(NSInteger)value{
    
    if (!members || members.count ==0) {
        return NO;
    }
    NSString *memberString = [self stringFormList:members];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_FLOW = %ld WHERE [MID] IN (%@) AND [AID] = '%lld'",(long)value,memberString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}

// 更新人员关系表 将 AVAILABLE_FLOW 设置成1
- (BOOL)updateRelationByLevelArray:(NSArray *) level accountID:(long long)accountID value:(NSInteger)value{
    if (!level || level.count ==0) {
        return NO;
    }
    NSString *levelString = [self stringFormList:level];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_FLOW = %ld WHERE [LID] IN (%@) AND [AID] = '%lld'",(long)value,levelString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}

// 判断当前人员是内部还是外部人员 true 内部 ，false 外部
- (OfflineOrgMember *)getCurrentUser{
    //加锁防止出现向已释放的对象发送消息的情况
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    if (_currentMember) {
        if ([CMPCore sharedInstance].userID.longLongValue == _currentMember.memberId) {
            [lock unlock];
            [lock release];
            lock = nil;
            return _currentMember;
        }
        SY_RELEASE_SAFELY(_currentMember);
    }
    CMPLoginAccountModel *userInfo = [CMPCore sharedInstance].currentUser;
    NSString *memberId = userInfo.userID;
    
    _currentMember = [[OfflineOrgMember alloc] init];
    _currentMember.memberId = [memberId longLongValue];
    _currentMember.accountId = [userInfo.accountID longLongValue];
    _currentMember.departId =  [userInfo.departmentID longLongValue];
    _currentMember.postId = [userInfo.postID longLongValue];
    _currentMember.levelId =  [userInfo.levelID longLongValue];
    _currentMember.insernal = YES;
    
    NSString *sql = [NSString stringWithFormat:@"select ins,WS  from tb_member  where ID = %@ ",memberId];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    
    while ([set next]) {
        _currentMember.insernal = [[set stringForColumn:@"ins"] boolValue];
        _currentMember.workScope = [set stringForColumn:@"WS"];
    }
    [lock unlock];
    [lock release];
    lock = nil;
    return _currentMember;
}

// TODO 获取当前登陆人员的关系列表
- (NSArray <OfflineRelationship *>*) getCurrentRelationship:(long long)accountID memberID:(long long) memberID{
    
    NSString *sql = [NSString stringWithFormat:@"select * from TB_RELATION  where [AID] = '%lld' AND [MID] = '%lld'",accountID,memberID];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *resultList = [NSMutableArray array];
    while ([set next]) {
        OfflineRelationship *ship = [[OfflineRelationship alloc] init];
        ship.oId = [set longLongIntForColumn:@"id"];
        ship.mId = [set longLongIntForColumn:@"mId"];
        ship.aId = [set longLongIntForColumn:@"aId"];
        ship.dId = [set longLongIntForColumn:@"dId"];
        ship.lId = [set longLongIntForColumn:@"lId"];
        ship.pId = [set longLongIntForColumn:@"pId"];
        ship.t = [set intForColumn:@"type"];
        //        ship.m = [set stringForColumn:@"org_Mark"];
        [resultList addObject:ship];
        SY_RELEASE_SAFELY(ship)
    }
    return resultList;
    
}

/**
 * 将此单位下的所有关系设置为不可见 对应的对象为OfflineRelationship android需要在次对象中设置通讯录访问权限属性
 * availabel_contacts int, 0,1 availabel_flow int,0,1 availabel_edoc int
 * ,0,1 availabel_form int,0,1 showTel int,0,1 showLevel int0,1
 *
 * @param accountId
 * @return
 */

//-- 设置通讯录权限
- (BOOL)updateLevelScope:(long long)accountId availabel:(int)availabel{
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_FLOW = %d WHERE AID = '%lld'",availabel,accountId];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}




- (NSString *)stringFormList:(NSArray *)array
{
    if (!array || array.count ==0) {
        return @"";
    }
    NSMutableString *resultString = [NSMutableString string];
    for (int i= 0; i < array.count; i++) {
        NSString *string = [array objectAtIndex:i];
        if (i != 0) {
            [resultString appendString:@","];
        }
        [resultString appendString:string];
    }
    return resultString;
}

- (NSMutableArray *)getAllOutDepartList{
    NSString *outDept = @"select ID from TB_UNIT  where INTERNAL = 0 ";
    FMResultSet *outDeptSet =  [_localContactsDB executeQuery:outDept];
    NSMutableArray *outerDept = [NSMutableArray array];
    while ([outDeptSet next]) {
        NSString *did = [outDeptSet stringForColumn:@"id"];
        [outerDept addObject:did];
    }
    return outerDept;
}
@end
