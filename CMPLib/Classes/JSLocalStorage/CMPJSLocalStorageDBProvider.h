//
//  CMPJSLocalStorageDBProvider.h
//  M3
//
//  Created by Kaku Songu on 11/22/21.
//

#import "CMPObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPJSLocalStorageDBProvider : CMPObject

- (BOOL)setItem:(NSString *)value forKey:(NSString *)key;
- (NSString *)getItem:(NSString *)key;
- (BOOL)removeItem:(NSString *)key;
- (BOOL)clearAllData;
- (void)close;
- (NSDictionary *)allData;
-(NSString *)dbPath;

@end

NS_ASSUME_NONNULL_END
