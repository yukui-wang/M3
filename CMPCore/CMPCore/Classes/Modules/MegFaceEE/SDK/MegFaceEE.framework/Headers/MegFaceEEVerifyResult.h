//
//  MegFaceEEVerifyResult.h
//  MegFaceEE
//
//  Created by Megvii on 2023/2/27.
//

#import <Foundation/Foundation.h>
#import <MegFaceEE/MegFaceEEOTPResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEVerifyResult : NSObject

@property (nonatomic, strong) NSString *verifyToken;
@property (nonatomic, strong) MegFaceEEOTPResult *otpResult;

@end

NS_ASSUME_NONNULL_END
