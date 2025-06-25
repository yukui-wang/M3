//
//  NSObject+Cache.m
//  CMPLib
//
//  Created by CRMO on 2017/11/15.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "NSObject+Cache.h"
#import "CMPFileManager.h"

NSString * const kNSObjectCacheDefaultFolderName = @"cache";
NSString * const kNSObjectCacheRootFolderName = @"Documents/File";

@implementation NSObject(Cache)

- (BOOL)cmp_cacheToDiskWithKey:(NSString *)key {
    return [self cmp_cacheToDiskWithKey:key folder:kNSObjectCacheDefaultFolderName];
}

- (BOOL)cmp_cacheToDiskWithKey:(NSString *)key folder:(NSString *)folder {
    if ([NSString isNull:key] ||
        [NSString isNull:folder]) {
        return false;
    }
    
    NSString *folderPath = [CMPFileManager createFullPath:[NSString stringWithFormat:@"%@/%@", kNSObjectCacheRootFolderName, folder]];
    NSString *path = [folderPath stringByAppendingPathComponent:key];
    NSString *json = [self yy_modelToJSONString];
    return [json writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSObject *)cmp_getObjectFromCacheWithKey:(NSString *)key {
    return [self cmp_getObjectFromCacheWithKey:key folder:kNSObjectCacheDefaultFolderName];
}

- (NSObject *)cmp_getObjectFromCacheWithKey:(NSString *)key folder:(NSString *)folder {
    if ([NSString isNull:key] ||
        [NSString isNull:folder]) {
        return false;
    }
    
    NSString *folderPath = [CMPFileManager createFullPath:[NSString stringWithFormat:@"%@/%@", kNSObjectCacheRootFolderName, folder]];
    NSString *path = [folderPath stringByAppendingPathComponent:key];
    NSString *json = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    if ([NSString isNull:json]) {
        return nil;
    }
    
    return [[self class] yy_modelWithJSON:json];
}

@end
