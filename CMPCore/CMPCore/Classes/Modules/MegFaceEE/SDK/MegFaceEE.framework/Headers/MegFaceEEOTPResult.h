//
//  MegFaceEEOTPResult.h
//  MegFaceEE
//
//  Created by Megvii on 2023/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEOTPResult : NSObject

@property (nonatomic, strong) NSString *otpCode;
@property (nonatomic, assign) NSInteger timeLeft;

@end

NS_ASSUME_NONNULL_END
