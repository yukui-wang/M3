//
//  OfflineBaseEntity.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>

@interface OfflineBaseEntity : CMPObject
@property(nonatomic ,assign) long long oId;
@property(nonatomic ,copy)  NSString *n;
@property(nonatomic ,copy)  NSString *m;
@property(nonatomic ,copy)  NSString *t;
@property(nonatomic ,assign) int v;
@property(nonatomic ,assign) long long s;//sort
@end
