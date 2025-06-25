//
//  TrustdoNativeCall.h
//  M3
//
//  Created by wangxinxu on 2019/2/20.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrustdoNativeCall : NSObject

+ (TrustdoNativeCall *)sharedInstance;

// 获取调用手机盾数据
- (void)mokeyNativeCallWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
