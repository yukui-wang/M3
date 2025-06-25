//
//  CMPContactsRelationManager.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "CMPContactsRelationManager.h"


@interface CMPContactsRelationManager () {
    OfflineOrgMember *_currentMember;

}

@end

@implementation CMPContactsRelationManager
- (void)dealloc
{
    SY_RELEASE_SAFELY(_currentMember);
    SY_RELEASE_SAFELY(_localContactsDB)
    [super dealloc];
}

- (BOOL)checkLevelScope:(NSArray<MAccountAvailableEntity *> *)t  defaultValue:(BOOL)init{
    for (MAccountAvailableEntity *e in t) {
        MAccountSetting *setting = e.setting;
        if (!setting) {
            continue;
        }
        if (e.accessable == 0 || init) {
            // 不能访问此单位时 需要将这个单位下的所以人员设置成不可见
            [self updateLevelScope:e.accountId availabel:0];
        }
        if (e.accessable != 0 ) {
            // 如果设置有改变或者需要做初始化 这重新判断
            [self checkLevelScope:setting accountId:e.accountId];
            [self checkPhoneAndLevelShow:setting accountId:e.accountId];
        }
    }
    NSArray *selfArray = nil;
    //自己是始终可以看到的，所以不隐藏
    if (![NSString isNull:[CMPCore sharedInstance].userID]) {
        selfArray = [NSArray arrayWithObject:[CMPCore sharedInstance].userID];
    }
    long long curAccount = [[CMPCore sharedInstance].currentUser.accountID longLongValue];
    [self updateRelationByMembersArray:selfArray accountID:curAccount value:1];

    return YES;
    
}

- (BOOL)checkPhoneAndLevelShow:(MAccountSetting *)s accountId:(long long)accountId{
    int kset = s.keyInfoSet;// 1公开 ，2 公开但对keyInfoList中的隐藏，3隐藏
    // 但对keyInfoList公共
    int ktype = s.keyInfoType; // 1 职务加手机号，2 手机 3 职务
    NSArray *klist = s.keyInfoList;
    NSMutableArray *memberList = [NSMutableArray array];
    NSMutableArray *departList = [NSMutableArray array];
    NSMutableArray *levelList = [NSMutableArray array];
    NSMutableArray *postList = [NSMutableArray array];
    NSMutableArray *accountList = [NSMutableArray array];
    if (klist && klist.count>0 ) {
        for (NSString *temp in klist) {
            NSArray *split = [temp componentsSeparatedByString:@"|"];
            if (split.count <1) {
                continue;
            }
            NSString *split0 = @"";
            if (split.count >0) {
                split0 = [split objectAtIndex:0];
            }
            NSString *split1 = @"";
            if (split.count >1) {
                split1 = [split objectAtIndex:1];
            }
            if ([@"Member" isEqualToString:split0]) {
                [memberList addObject:split1];
            }
            else if ([@"Department" isEqualToString:split0]) {
                [departList addObject:split1];
            }
            else if ([@"Level" isEqualToString:split0]) {
                [levelList addObject:split1];
            }
            else if ([@"Post" isEqualToString:split0]) {
                [postList addObject:split1];
            }
            else if ([@"Account" isEqualToString:split0]) {
                [accountList addObject:split1];
            }
        }
    }
    if (kset == 1) {
        // TODO 公开
        // 1 职务加手机号，2 手机 3 职务
        if (ktype == 1) {
            [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
        } else if (ktype == 2) {
            [self updateMemberInfoShow:accountId phoneShow:1 levelShow:0];
        }
        if (ktype == 3) {
            [self updateMemberInfoShow:accountId phoneShow:0 levelShow:1];
        }
    } else if (kset == 2) { // 1公开 ，2 公开但对keyInfoList中的隐藏，3隐藏
								// 但对keyInfoList公共
        // TODO //1 职务加手机号，2 手机 3 职务
        if (ktype == 1) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:0 levelShow:0];
            }
            else {
               [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
               [self updateMemberInfoShowByDeparts:accountId departList:departList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByLevels:accountId levelList:levelList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByMembers:accountId membersList:memberList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByPost:accountId postList:postList phoneShow:0 levelShow:0];
            }
            
        } else if (ktype == 2) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:0 levelShow:0];
            } else {
                [self updateMemberInfoShow:accountId phoneShow:1 levelShow:0];
                [self updateMemberInfoShowByDeparts:accountId departList:departList phoneShow:0 levelShow:0];
                [self updateMemberInfoShowByLevels:accountId levelList:levelList phoneShow:0 levelShow:0];
                [self updateMemberInfoShowByMembers:accountId membersList:memberList phoneShow:0 levelShow:0];
                [self updateMemberInfoShowByPost:accountId postList:postList phoneShow:0 levelShow:0];
            }
        }
        if (ktype == 3) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:0 levelShow:0];
            } else {
               [self updateMemberInfoShow:accountId phoneShow:0 levelShow:1];
               [self updateMemberInfoShowByDeparts:accountId departList:departList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByLevels:accountId levelList:levelList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByMembers:accountId membersList:memberList phoneShow:0 levelShow:0];
               [self updateMemberInfoShowByPost:accountId postList:postList phoneShow:0 levelShow:0];
            }
        }
    } else if (kset == 3) { // 隐藏 但对keyInfoList公共
        // TODO //1 职务加手机号，2 手机 3 职务
        OfflineOrgMember *currentMember = [self getCurrentUser];
        NSString *userId = [CMPCore sharedInstance].userID;
        NSString *departId = [NSString stringWithFormat:@"%lld",currentMember.departId];
        NSString *levelId = [NSString stringWithFormat:@"%lld",currentMember.levelId];
        NSString *postId = [NSString stringWithFormat:@"%lld",currentMember.postId];
  
        //添加子部门
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *depart in departList) {
            [temp addObject:[self getAllDepartChildren:depart.longLongValue accountID:accountId]];
        }
        [departList addObject:temp];
        
        if (ktype == 1) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
            }
            else {
                [self updateMemberInfoShow:accountId phoneShow:0 levelShow:0];
                if ([departList containsObject:departId] || [memberList containsObject:userId] || [postList containsObject:postId] || [levelList containsObject:levelId]) {
                    [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
                }
            }
        } else if (ktype == 2) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
            } else {
                [self updateMemberInfoShow:accountId phoneShow:0 levelShow:1];
                if ([departList containsObject:departId] || [memberList containsObject:userId] || [postList containsObject:postId] || [levelList containsObject:levelId]) {
                    [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
                }
            }
        } else if (ktype == 3) {
            if ([accountList containsObject:@(accountId).stringValue]) {
                [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
            } else {
                [self updateMemberInfoShow:accountId phoneShow:1 levelShow:0];
                if ([departList containsObject:departId] || [memberList containsObject:userId] || [postList containsObject:postId] || [levelList containsObject:levelId]) {
                    [self updateMemberInfoShow:accountId phoneShow:1 levelShow:1];
                }
            }
        }
    }
    return YES;
}

- (BOOL)checkLevelScope:(MAccountSetting *)s accountId:(long long)accountId{
    int type = s.viewSetType;
    OfflineOrgMember *user = [self getCurrentUser];
    if (type == 1) {
        // 同选人
        [self checkOrgScope:s accountId:accountId];
        //  隐藏
        NSArray *viewScopeList = s.viewScopeList;
        NSMutableArray *memberList = [NSMutableArray array];
        NSMutableArray *departList = [NSMutableArray array];
        NSMutableArray *levelList = [NSMutableArray array];
        NSMutableArray *postList = [NSMutableArray array];
        if (viewScopeList && viewScopeList.count>0 ) {
            for (NSString *temp in viewScopeList) {
                NSArray *split = [temp componentsSeparatedByString:@"|"];
                if (split.count <2) {
                    continue;
                }
                NSString *split0 = @"";
                if (split.count >0) {
                    split0 = [split objectAtIndex:0];
                }
                NSString *split1 = @"";
                if (split.count >1) {
                    split1 = [split objectAtIndex:1];
                }
                if ([@"Member" isEqualToString:split0]) {
                    [memberList addObject:split1];
                }
                else if ([@"Department" isEqualToString:split0]) {
                    NSArray *children = [self getAllDepartChildren:split1.longLongValue accountID:accountId];
                    [departList addObjectsFromArray:children];
                }
                else if ([@"Level" isEqualToString:split0]) {
                    [levelList addObject:split1];
                }
                else if ([@"Post" isEqualToString:split0]) {
                    [postList addObject:split1];
                }
                else if ([@"Account" isEqualToString:split0]) {
                    [self updateLevelScope:accountId availabel:0];
                    return YES;
                }
            }
        }
   
        /*OA-156657 M3，通讯录，通讯录隐藏选择部门时，客户端未对部门下的副岗人员进行隐藏 start*/
        NSArray *notMainMembers =  [self getNotMainPostMembersInDeparts:departList accountID:accountId];
        if (notMainMembers.count >0) {
            //获取部门下所有的非主岗人员ID
            [memberList addObjectsFromArray:notMainMembers];
        }
        /*OA-156657 M3，通讯录，通讯录隐藏选择部门时，客户端未对部门下的副岗人员进行隐藏 end*/

        [self updateRelationByDepartArray:departList accountID:accountId value:0];
        [self updateRelationByLevelArray:levelList accountID:accountId value:0];
        [self updateRelationByMembersArray:memberList accountID:accountId value:0];
        [self updateRelationByPostArray:postList accountID:accountId value:0];
        
    }
    else {
        // 只能看在当前部门 以及子部门人员 viewScope是可以访问整个单位
        NSArray *tempvViewScope = s.viewScopeList;
        NSMutableArray *viewScope = [NSMutableArray arrayWithArray:tempvViewScope];
        for (NSString *str in tempvViewScope) {
            if ([str rangeOfString:@"Department|"].location != NSNotFound) {
                NSString *subStr = [str replaceCharacter:@"Department|" withString:@""];
                NSArray *arr = [self getAllDepartChildren:subStr.longLongValue accountID:accountId];
                for (NSString *str1 in arr) {
                    NSString *vstr = [NSString stringWithFormat:@"Department|%@",str1];
                    [viewScope addObject:vstr];
                }
            }
        }
        NSArray *shipList = [self getCurrentRelationship:accountId memberID:user.memberId];
        if (shipList && shipList.count >0) {
            for (OfflineRelationship *ship in shipList) {
                NSString *depart = [NSString stringWithFormat:@"Department|%lld",ship.dId];
                NSString *member = [NSString stringWithFormat:@"Member|%lld",ship.mId];
                NSString *level = [NSString stringWithFormat:@"Level|%lld",ship.lId];
                NSString *post = [NSString stringWithFormat:@"Post|%lld",ship.pId];
                NSString *account = [NSString stringWithFormat:@"Account|%lld",ship.aId];
                if ([viewScope containsObject:depart]) {
                    // TODO 子部门 需要处理
                    [self updateLevelScope:accountId availabel:1];
                    return true;
                } else if ([viewScope containsObject:member]) {
                    [self updateLevelScope:accountId availabel:1];
                    return true;
                } else if ([viewScope containsObject:level]) {
                    [self updateLevelScope:accountId availabel:1];
                    return true;
                } else if ([viewScope containsObject:post]) {
                    [self updateLevelScope:accountId availabel:1];
                    return true;
                } else if ([viewScope containsObject:account]) {
                    [self updateLevelScope:accountId availabel:1];
                    return true;
                }
            }
        }
        if (user.accountId == accountId) {
            // 如果是同一个单位
            
            if (user.insernal) {
                //内部人员看内部人员
                NSMutableArray *departs = [NSMutableArray array];
                NSMutableSet *set = [NSMutableSet set];
                for (OfflineRelationship *ship in shipList) {
                    NSArray* tempd = [self getAllDepartChildren:ship.dId accountID:accountId];
                    [set addObjectsFromArray:tempd];
                }
                [departs addObjectsFromArray:set.allObjects];
                //如果在某个部门可见某人员，该人员在其他部门也应该可见
                [self updateRelationByDepartArray2:departs accountID:accountId value:1];
                
                //内部人员看外部人员
                //当前部门所有外部人员
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
                NSMutableArray *memberIdList = [NSMutableArray array];
                NSString *userDept = [NSString stringWithFormat:@"%lld",user.departId];
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
                            NSArray *childList = [self getAllDepartChildren:userDept.longLongValue accountID:user.accountId];
                            if ([childList containsObject:outerDept]) {
                                [memberIdList addObject:mid];
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
                
            }
            else {
                //外部人员
//                NSArray *deptList = [NSArray arrayWithObject:[NSString stringWithFormat:@"%lld",user.departId]];
//                [self updateRelationByDepartArray:deptList accountID:accountId value:1];
                
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
                    } else if ([@"Department" isEqualToString:temp0]) {
                        NSArray *childList = [self getAllDepartChildren:temp1.longLongValue accountID:user.accountId];
                        [departlist addObjectsFromArray:childList];
//                        [departlist addObject:temp1];
                    } else if ([@"Member" isEqualToString:temp0]) {
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
            }
            
        } else {
            // 如果不是同一个单位
            if (!user.insernal) {
                // TODO 通讯录时 次设置不能看其他单位
            } else {
                // 这是当前人员在这个单位的所以兼职
                NSMutableSet *dSet = [NSMutableSet set];
                for (OfflineRelationship *ship in shipList) {
                    NSArray* tempd = [self getAllDepartChildren:ship.dId accountID:accountId];
                    [dSet addObjectsFromArray:tempd];
                }
                NSArray *departs = [NSArray arrayWithArray:dSet.allObjects];
                [self updateRelationByDepartArray:departs accountID:accountId value:1];
            }
        }
    }
    return YES;
}

- (BOOL)checkOrgScope:(MAccountSetting *)s accountId:(long long)accountId{
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

- (NSArray *)getDepartmentsByAccountId:(long long)accountId {
    NSString *sql = [NSString stringWithFormat:@"select * from TB_UNIT  where PARENT_ID = %lld order by internal desc, sort",accountId];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *result = [NSMutableArray array];
    while ([set next]) {
        OfflineOrgUnit *orgUnit = [[OfflineOrgUnit alloc] init];
        orgUnit.oId = [set longLongIntForColumn:@"id"];
        orgUnit.n = [set stringForColumn:@"name"];
        orgUnit.m = [set stringForColumn:@"org_mark"];
        orgUnit.t = [set stringForColumn:@"type"];
        orgUnit.v = [set intForColumn:@"view"];
        orgUnit.s = [set longLongIntForColumn:@"sort"];
        orgUnit.pa = [set stringForColumn:@"path"];
        orgUnit.fa = [set longLongIntForColumn:@"parent_Id"];
        orgUnit.aId = [set longLongIntForColumn:@"id"];
        orgUnit.sc = [set intForColumn:@"scope"];
        orgUnit.internal = [set intForColumn:@"internal"];
        [result addObject:orgUnit];
        SY_RELEASE_SAFELY(orgUnit);
    }
    return result;
}

- (NSArray *)getDepartmentsByAccountId:(long long)accountId limit:(NSInteger)limit offset:(NSInteger)offset {
    NSString *sql = [NSString stringWithFormat:@"select * from TB_UNIT  where PARENT_ID = %lld order by internal desc, sort LIMIT %ld OFFSET %ld",accountId, limit, offset];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *result = [NSMutableArray array];
    while ([set next]) {
        OfflineOrgUnit *orgUnit = [[OfflineOrgUnit alloc] init];
        orgUnit.oId = [set longLongIntForColumn:@"id"];
        orgUnit.n = [set stringForColumn:@"name"];
        orgUnit.m = [set stringForColumn:@"org_mark"];
        orgUnit.t = [set stringForColumn:@"type"];
        orgUnit.v = [set intForColumn:@"view"];
        orgUnit.s = [set longLongIntForColumn:@"sort"];
        orgUnit.pa = [set stringForColumn:@"path"];
        orgUnit.fa = [set longLongIntForColumn:@"parent_Id"];
        orgUnit.aId = [set longLongIntForColumn:@"id"];
        orgUnit.sc = [set intForColumn:@"scope"];
        orgUnit.internal = [set intForColumn:@"internal"];
        [result addObject:orgUnit];
        SY_RELEASE_SAFELY(orgUnit);
    }
    return result;
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
//-- 根据单位ID和部门ID列表获取  非主岗人员
- (NSArray *)getNotMainPostMembersInDeparts:(NSArray *)deptList  accountID:(long long)accountID {
   
    NSString *deptStr = [self stringFormList:deptList];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT MID FROM TB_RELATION WHERE DID in ( %@ ) AND AID = '%lld' AND TYPE != 1",deptStr,accountID];
    FMResultSet *set =  [_localContactsDB executeQuery:sql];
    NSMutableArray *resultList = [NSMutableArray array];
    while ([set next]) {
        NSString *string = [set stringForColumn:@"MID"];
        [resultList addObject:string];
    }
    return resultList;
}


// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成value
- (BOOL)updateRelationByDepartArray:(NSArray *)depart accountID:(long long)accountID  value:(NSInteger)value{
    if (!depart || depart.count ==0) {
        return NO;
    }
    NSString *departString = [self stringFormList:depart];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %ld WHERE [DID] IN (%@) AND [AID] = '%lld'",(long)value,departString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}
- (BOOL)updateRelationByDepartArray2:(NSArray *)depart accountID:(long long)accountID  value:(NSInteger)value{
    //只可见所在部门（含子部门），但以下人员能看全单位   如果在某个部门可见某人员，该人员在其他部门也应该可见
    if (!depart || depart.count ==0) {
        return NO;
    }
    NSString *departString = [self stringFormList:depart];
    NSString *sql1 = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %ld WHERE [MID] IN (SELECT MID FROM TB_RELATION WHERE DID IN ( %@ ) AND [AID] = '%lld' ) AND [AID] = '%lld'",(long)value,departString,accountID,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql1];
    return result;
}

// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成1
- (BOOL)updateRelationByMembersArray:(NSArray *)members accountID:(long long)accountID  value:(NSInteger)value{
    
    if (!members || members.count ==0) {
        return NO;
    }
    NSString *memberString = [self stringFormList:members];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %ld WHERE [MID] IN (%@) AND [AID] = '%lld'",(long)value,memberString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}

// 更新人员关系表 将 AVAILABLE_CONTACTS 设置成1
- (BOOL)updateRelationByLevelArray:(NSArray *) level accountID:(long long)accountID value:(NSInteger)value{
    if (!level || level.count ==0) {
        return NO;
    }
    NSString *levelString = [self stringFormList:level];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %ld WHERE [LID] IN (%@) AND [AID] = '%lld'",(long)value,levelString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}

- (BOOL)updateRelationByPostArray:(NSArray *)post accountID:(long long)accountID value:(NSInteger)value{
    if (!post || post.count ==0) {
        return NO;
    }
    NSString *levelString = [self stringFormList:post];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %ld WHERE [PID] IN (%@) AND [AID] = '%lld'",(long)value,levelString,accountID];
    BOOL result = [_localContactsDB executeUpdate:sql];
    return result;
}

// 判断当前人员是内部还是外部人员 true 内部 ，false 外部
- (OfflineOrgMember *)getCurrentUser{
    
    if (_currentMember) {
        if ([CMPCore sharedInstance].userID.longLongValue == _currentMember.memberId) {
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
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET AVAILABLE_CONTACTS = %d WHERE AID = '%lld'",availabel,accountId];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}

//-- 设置职务级别与电话号码是否可以查看权限
- (BOOL)updateMemberInfoShow:(long long)accountId
                   phoneShow:(int)phoneShow
                   levelShow:(int)levelShow{
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET SHOW_TEL = %d, SHOW_LEVEL = %d WHERE AID = '%lld'",phoneShow,levelShow,accountId];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}

//-- 设置职务级别与电话号码是否可以查看权限根据部门的ID集合
- (BOOL)updateMemberInfoShowByDeparts:(long long)accountId
                           departList:(NSArray *)departList
                            phoneShow:(int)phoneShow
                            levelShow:(int)levelShow{
    if (!departList ||departList.count ==0 ) {
        return NO;
    }
    NSString *departIdString = [self stringFormList:departList];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET SHOW_TEL = %d, SHOW_LEVEL = %d WHERE AID = '%lld' AND DID IN (%@)",phoneShow,levelShow,accountId,departIdString];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}

//-- 设置职务级别与电话号码是否可以查看权限根据职务级别的ID集合
- (BOOL)updateMemberInfoShowByLevels:(long long)accountId
                           levelList:(NSArray *)levelList
                           phoneShow:(int)phoneShow
                           levelShow:(int)levelShow{
    if (!levelList ||levelList.count ==0 ) {
        return NO;
    }
    NSString *levelIdString = [self stringFormList:levelList];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET SHOW_TEL = %d, SHOW_LEVEL = %d WHERE AID = '%lld' AND LID IN (%@)",phoneShow,levelShow,accountId,levelIdString];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}

//-- 设置职务级别与电话号码是否可以查看权限根据岗位的ID集合
- (BOOL)updateMemberInfoShowByPost:(long long)accountId
                          postList:(NSArray *)postList
                         phoneShow:(int)phoneShow
                         levelShow:(int)levelShow{
    
    
    if (!postList ||postList.count ==0 ) {
        return NO;
    }
    NSString *postIdString = [self stringFormList:postList];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET SHOW_TEL = %d, SHOW_LEVEL = %d WHERE AID = '%lld' AND PID IN (%@)",phoneShow,levelShow,accountId,postIdString];
    BOOL resutl = [_localContactsDB executeUpdate:sql];
    return resutl;
}

//-- 设置职务级别与电话号码是否可以查看权限根据人员的ID集合
- (BOOL)updateMemberInfoShowByMembers:(long long)accountId
                          membersList:(NSArray *)membersList
                            phoneShow:(int)phoneShow
                            levelShow:(int)levelShow{
    
    if (!membersList ||membersList.count ==0 ) {
        return NO;
    }
    NSString *memberIdString = [self stringFormList:membersList];
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_relation SET SHOW_TEL = %d, SHOW_LEVEL = %d WHERE AID = '%lld' AND MID IN (%@)",phoneShow,levelShow,accountId,memberIdString];
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
