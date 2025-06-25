//
//  CMPLoginRsaTools.h
//  M3
//
//  Created by CRMO on 2018/11/13.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLoginRsaTools : CMPObject

+ (NSString *)signWithPrivate:(NSString *)str;

+ (NSDictionary *)appendRsaParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
