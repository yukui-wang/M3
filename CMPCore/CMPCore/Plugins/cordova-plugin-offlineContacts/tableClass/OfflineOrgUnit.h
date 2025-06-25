//
//  OfflineOrgUnit.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

//单位、部门 对象

#import "OfflineBaseEntity.h"

@interface OfflineOrgUnit : OfflineBaseEntity
@property(nonatomic, copy)NSString  *pa;//path
@property(nonatomic, assign)long long fa;//parentId;
@property(nonatomic, assign)long long aId;//AccountId
@property(nonatomic, assign)int sc;//scope
@property(nonatomic, assign)int ac;// 0 false ;1 true
@property(nonatomic, assign)int internal;// 内/外部单位
@end
