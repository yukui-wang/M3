//
//  MegFaceEEUserInfo.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import <MegFaceEE/MegFaceEEConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEUserInfo : NSObject
@property (nonatomic, assign) BOOL isPassed;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) MegFaceEECredentialType defaultCredentialType;
@property (nonatomic, assign) BOOL isFastPassHighLevel;
@property (nonatomic, strong) NSArray<NSNumber *> *availableVerificationCredentials;
@property (nonatomic, strong) NSArray<NSNumber *> *availableUploadCredentials;
@property (nonatomic, assign) BOOL hasPlugin;
@property (nonatomic, assign) BOOL isLicenseExpired;
@end

NS_ASSUME_NONNULL_END
