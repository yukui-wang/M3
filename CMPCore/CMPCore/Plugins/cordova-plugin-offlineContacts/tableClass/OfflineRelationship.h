//
//  OfflineRelationship.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>

@interface OfflineRelationship : CMPObject
@property(nonatomic, assign)long long oId;
@property(nonatomic, assign)long long mId;
@property(nonatomic, assign)long long aId;
@property(nonatomic, assign)long long dId;
@property(nonatomic, assign)long long lId;
@property(nonatomic, assign)long long pId;
@property(nonatomic, assign) int t;
@property(nonatomic, copy) NSString *m;
@end
