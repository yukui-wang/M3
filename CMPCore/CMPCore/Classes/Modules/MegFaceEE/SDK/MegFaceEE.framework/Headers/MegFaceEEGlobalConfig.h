//
//  MegFaceEEGlobalConfig.h
//  MegFaceEE
//
//  Created by tongshasha on 2023/8/31.
//

#import <Foundation/Foundation.h>
#import <MegFaceEE/MegFaceEEAgreementConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEGlobalConfig : NSObject

@property (nonatomic, strong) MegFaceEEAgreementConfig *agreementConfig;

- (void)setAgreementConfig:(MegFaceEEAgreementConfig *)agreementConfig;

@end

NS_ASSUME_NONNULL_END
