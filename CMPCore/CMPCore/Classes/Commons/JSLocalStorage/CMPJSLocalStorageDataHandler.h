//
//  CMPJSLocalStorageDataHandler.h
//  M3
//
//  Created by Kaku Songu on 11/19/21.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPJSLocalStorageDataHandler : CMPObject

+ (void)initSeverVersion:(NSString *)serverVersion companyID:(NSString *)companyID;
+ (void)saveServerInfo:(NSString *)data;
+ (void)saveLoginCache:(NSString *)data loginName:(NSString *)loginName password:(NSString *)password serverVersion:(NSString *)version;
+ (void)updateAccountID:(NSString *)accountID
            accountName:(NSString *)accountName
              shortName:(NSString *)shortName
            accountCode:(NSString *)accountCode
             configInfo:(NSString *)configInfo
            currentInfo:(id)currentInfo
                preInfo:(id)preInfo;
+ (void)saveConfigInfo:(NSString *)data;
+ (void)saveGestureState:(NSUInteger)state;
+ (void)saveV5Product:(NSString *)product;

@end

NS_ASSUME_NONNULL_END
