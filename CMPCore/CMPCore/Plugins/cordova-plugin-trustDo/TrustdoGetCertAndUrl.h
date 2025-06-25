//
//  TrustdoGetCertAndUrl.h
//  M3
//
//  Created by wangxinxu on 2019/2/20.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrustdoGetCertAndUrl : CMPObject<CMPDataProviderDelegate>

+ (TrustdoGetCertAndUrl *)sharedInstance;

// 获取手机盾证书和地址
- (void)getMokeyCertAndUrl;

@end

NS_ASSUME_NONNULL_END
