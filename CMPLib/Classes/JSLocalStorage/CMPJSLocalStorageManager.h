//
//  CMPJSLocalStorageManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2021/11/11.
//

#import "CMPObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPJSLocalStorageManager : CMPObject

+(CMPJSLocalStorageManager *)shareManager;
+(BOOL)setItem:(NSString *)value forKey:(NSString *)key;
+(NSString *)getItem:(NSString *)key;
+(BOOL)removeItem:(NSString *)key;
+(BOOL)clear;
+(NSDictionary *)allLocalStorageInfo;
+(NSString *)dbPath;

@end

NS_ASSUME_NONNULL_END
