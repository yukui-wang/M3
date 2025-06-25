//
//  TrustdoLoginManager.h
//  M3
//
//  Created by wangxinxu on 2019/2/19.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrustdoLoginManager : CMPObject<CMPDataProviderDelegate>

+ (TrustdoLoginManager *)sharedInstance;

// 获取KeyId
- (void)getMokeyKeyIdWithLoginName:(NSString *)loginName Style:(NSString *)style;

// 手机盾重置
- (void)doMokeyResetWithLoginName:(NSString *)loginName EventData:(NSString *)eventData Style:(NSString *)style;

// 是否有手机盾权限
- (BOOL)isHaveMokeyLoginPermission;

@end

NS_ASSUME_NONNULL_END
