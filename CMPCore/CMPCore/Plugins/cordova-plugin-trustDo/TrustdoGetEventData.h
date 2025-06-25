//
//  TrustdoGetEventData.h
//  M3
//
//  Created by wangxinxu on 2019/2/19.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrustdoGetEventData : CMPObject<CMPDataProviderDelegate>

+ (TrustdoGetEventData *)sharedInstance;

// 获取登录挑战数据
- (void)getMokeyLoginEventData;

// 获取更新证书的挑战数据
- (void)getMokeyUpdateCertEventDataWithLoginName:(NSString *)loginName;

@end

NS_ASSUME_NONNULL_END
