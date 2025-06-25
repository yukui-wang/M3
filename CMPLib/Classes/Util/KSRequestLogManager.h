//
//  KSRequestLogManager.h
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/5/19.
//  Copyright © 2022 crmo. All rights reserved.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSRequestLogManager : CMPObject
@property(nonatomic,copy) void(^blk)(NSString *key,NSInteger act,id ext);
+(KSRequestLogManager *)shareManager;
-(BOOL)filterRequest:(NSString *)url reqid:(NSString *)reqid;
-(BOOL)handleResponse:(NSString *)url reqid:(NSString *)reqid;

@end

NS_ASSUME_NONNULL_END
