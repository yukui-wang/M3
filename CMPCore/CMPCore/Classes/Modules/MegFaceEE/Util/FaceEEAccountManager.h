//
//  FaceEEAccountManager.h
//  FaceIDFaceAuth
//
//  Created by Megvii on 2023/3/20.
//

#import <Foundation/Foundation.h>

#define kAccountDomain @"domain"
#define kAccountEndpoint @"endpoint"
#define kAccountUserName @"userName"
#define kAccountDisplayName @"displayName"
#define kAccountEnterprise @"enterprise"

NS_ASSUME_NONNULL_BEGIN

@interface FaceEEAccountManager : NSObject

+ (NSArray *)getAccountList;

+ (void)saveAccountList:(NSArray *)accountList;

+ (void)addAccountWithDomain:(NSString *)domain endpoint:(NSString *)endpoint;

+ (void)addAccountWithDomain:(NSString *)domain endpoint:(NSString *)endpoint userName:(NSString *)userName displayName:(NSString *)displayName enterprise:(NSString *)enterprise;

+ (void)deleteAccountWithDomain:(NSString *)domain;

+ (void)switchAccountWithDomain:(NSString *)domain;

+ (NSDictionary *)getAccountWithDomain:(NSString *)domain;

+ (void)deleteCurrentAccount;

+ (NSDictionary *)getCurrentAccount;

@end

NS_ASSUME_NONNULL_END
