//
//  FaceEEAccountManager.m
//  FaceIDFaceAuth
//
//  Created by Megvii on 2023/3/20.
//

#import "FaceEEAccountManager.h"

#define kFaceEEAccountList [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"faceAccountList.data"]

@implementation FaceEEAccountManager

+ (NSArray *)getAccountList {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:kFaceEEAccountList];
}

+ (void)saveAccountList:(NSArray *)accountList {
    [NSKeyedArchiver archiveRootObject:accountList toFile:kFaceEEAccountList];
}

+ (void)addAccountWithDomain:(NSString *)domain endpoint:(NSString *)endpoint {
    NSMutableArray *domainList = [[NSMutableArray alloc] initWithArray:[self getAccountList]];
    [domainList insertObject:@{kAccountDomain: domain, kAccountEndpoint: endpoint} atIndex:0];
    [self saveAccountList:domainList];
}

+ (void)addAccountWithDomain:(NSString *)domain endpoint:(NSString *)endpoint userName:(NSString *)userName displayName:(NSString *)displayName enterprise:(NSString *)enterprise {
    if (!enterprise) {
        enterprise = @"";
    }
    NSArray *list = [self getAccountList];
    NSMutableArray *domainList = [[NSMutableArray alloc] initWithArray:list];
    NSDictionary *tempDict;
    if (enterprise.length > 0) {
        tempDict = @{kAccountDomain: domain, kAccountEndpoint: endpoint, kAccountUserName: userName, kAccountDisplayName: displayName ? displayName : @"", kAccountEnterprise: enterprise};
    } else {
        tempDict = @{kAccountDomain: domain, kAccountEndpoint: endpoint, kAccountUserName: userName, kAccountDisplayName: displayName ? displayName : @""};
    }
    for (int i = 0; i< [list count]; i++) {
        NSDictionary *dict = list[i];
        if ([dict[kAccountDomain] isEqualToString:domain]) {
            [domainList replaceObjectAtIndex:i withObject:tempDict];
            [self saveAccountList:domainList];
            return;
        }
    }
    [domainList insertObject:tempDict atIndex:0];
    [self saveAccountList:domainList];
}

+ (void)deleteCurrentAccount {
    NSMutableArray *accountList = [NSMutableArray arrayWithArray:[self getAccountList]];
    if ([accountList count] > 0) {
        [accountList removeObjectAtIndex:0];
        [self saveAccountList:accountList];
    }
}

+ (void)deleteAccountWithDomain:(NSString *)domain {
    NSArray *list = [self getAccountList];
    NSMutableArray *domainList = [[NSMutableArray alloc] initWithArray:list];
    for (int i = 0; i< [list count]; i++) {
        NSDictionary *dict = list[i];
        if ([dict[kAccountDomain] isEqualToString:domain]) {
            [domainList removeObjectAtIndex:i];
        }
    }
    [self saveAccountList:domainList];
}

+ (void)switchAccountWithDomain:(NSString *)domain {
    NSArray *list = [self getAccountList];
    NSMutableArray *domainList = [[NSMutableArray alloc] initWithArray:list];
    NSDictionary *tempDict = [NSDictionary dictionary];
    for (int i = 0; i< [list count]; i++) {
        NSDictionary *dict = list[i];
        if ([dict[kAccountDomain] isEqualToString:domain]) {
            [domainList removeObjectAtIndex:i];
            tempDict = dict;
        }
    }
    [domainList insertObject:tempDict atIndex:0];
    [self saveAccountList:domainList];
}

+ (NSDictionary *)getAccountWithDomain:(NSString *)domain {
    NSArray *list = [self getAccountList];
    NSDictionary *tempDict = [NSDictionary dictionary];
    for (int i = 0; i< [list count]; i++) {
        NSDictionary *dict = list[i];
        if ([dict[kAccountDomain] isEqualToString:domain]) {
            tempDict = dict;
            break;
        }
    }
    return tempDict;
}

+ (NSDictionary *)getCurrentAccount {
    NSArray *list = [self getAccountList];
    if ([list count] > 0) {
        return list[0];
    } else {
        return nil;
    }
}

@end
