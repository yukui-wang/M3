//
//  CMPContactsResult.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/14.
//
//

#import <CMPLib/CMPObject.h>

@interface CMPContactsResult : CMPObject
@property(nonatomic, retain)NSArray *keyList;
@property(nonatomic, retain)NSDictionary *dataDic;
@property(nonatomic, retain)NSArray *allMemberList;
@property(nonatomic, assign)BOOL sucessfull;

@end
