//
//  CMPFileStatusProvider.m
//  CMPCore
//
//  Created by CRMO on 2017/9/15.
//
//

#import "CMPFileStatusProvider.h"
#import <CMPLib/CMPDateHelper.h>

static NSString *const kUserDefaultsKey = @"CMPFileStatusProviderKey";
static NSString *const kUserDefaultsMsgUIdKey = @"msgUId";
static NSString *const kUserDefaultsTimestampKey = @"timestamp";

@implementation CMPFileStatusProvider

+ (BOOL)fileDownloadedWithMsgUId:(NSString *)msgUId {
    if ([NSString isNull:msgUId]) {
        NSLog(@"RC---CMPFileStatusProvider:fileDownloadedWithMsgUId:msgUid is nil");
        return NO;
    }
    if ([[self class] isMsgUIdExit:msgUId]) {
        return YES;
    }
    
    NSMutableArray *arrs = [NSMutableArray arrayWithArray:[[self class] fileStatusArray]];
    NSDictionary *dic = @{kUserDefaultsMsgUIdKey : msgUId,
                          kUserDefaultsTimestampKey : [CMPDateHelper currentNumberDate]};
    [arrs addObject:dic];
    NSArray *result = [arrs copy];
    [UserDefaults setObject:result forKey:kUserDefaultsKey];
    [result release];
    result = nil;
    return [UserDefaults synchronize];
}

+ (BOOL)isFileDownloadedWithMsgUId:(NSString *)msgUId {
    [[self class] clearCache];
    return [[self class] isMsgUIdExit:msgUId];
}

+ (NSArray *)fileStatusArray {
    NSArray *fileStatuses = [UserDefaults objectForKey:kUserDefaultsKey];
    if (!fileStatuses || ![fileStatuses isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return fileStatuses;
}

/**
 MsgUId是否有缓存
 */
+ (BOOL)isMsgUIdExit:(NSString *)msgUId {
    NSArray *fileStatuses = [[self class] fileStatusArray];
    for (NSDictionary *dic in fileStatuses) {
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString *aMsgUid = dic[kUserDefaultsMsgUIdKey];
        if ([aMsgUid isEqualToString:msgUId]) {
            return YES;
        }
    }
    return NO;
}

/**
 清理缓存
 */
+ (void)clearCache {
    NSArray *fileStatuses = [[self class] fileStatusArray];
    NSMutableArray *newFileStatuse = [NSMutableArray array];
    
    for (NSDictionary *dic in fileStatuses) {
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSNumber *timestampNumber = dic[kUserDefaultsTimestampKey];
        
        if (!timestampNumber || ![timestampNumber isKindOfClass:[NSNumber class]]) {
            return;
        }
        
        long long timestamp = [timestampNumber longLongValue];
        long long currentTimestamp = [[CMPDateHelper currentNumberDate] longLongValue];
        
        if (currentTimestamp - timestamp < 5 * 60) { // 清理5分钟前的缓存
            [newFileStatuse addObject:dic];
        }
    }
    
    [UserDefaults setObject:newFileStatuse forKey:kUserDefaultsKey];
    [UserDefaults synchronize];
}

@end
