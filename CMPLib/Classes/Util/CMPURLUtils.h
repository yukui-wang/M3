//
//  CMPURLUtils.h
//  M3
//
//  Created by youlin on 2020/3/3.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPURLUtils : CMPObject
//+ (NSString *)urlPathMatch:(NSString *)path serverVersion:(NSString *)version;

+ (NSString *)urlPathMatch:(NSString *)path serverVersion:(NSString *)version contextPath:(NSString *)contextPath;

+ (NSString *)requestURLWithHost:(NSString *)aHost path:(NSString *)aPath;

//忽略默认端口号80或443
+ (NSString *)ignoreDefaultPort:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
