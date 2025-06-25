//
//  CMPLocalStorageDbProvider.h
//  M3
//
//  Created by CRMO on 2018/3/29.
//

#import <CMPLib/CMPObject.h>

@interface CMPLocalStorageDbProvider : CMPObject

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)valueWithKey:(NSString *)key;
- (BOOL)clearAllData;
- (void)close;

@end
