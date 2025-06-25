//
//  OfflineOrgMember.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import <CMPLib/CMPObject.h>

@interface OfflineOrgMember : CMPObject
@property(nonatomic, assign) long long memberId;
@property(nonatomic, assign) long long  accountId;
@property(nonatomic, assign) BOOL insernal;
@property(nonatomic, assign) long long  departId;
@property(nonatomic, assign) long long  postId;
@property(nonatomic, assign) long long  levelId;
@property(nonatomic, copy)  NSString *workScope;
@end
