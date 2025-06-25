//
//  MegFaceEEAgreementConfig.h
//  MegFaceEE
//
//  Created by tongshasha on 2023/8/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MegFaceEE/MegFaceEEConfig.h>


NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEAgreementConfig : NSObject

@property (nonatomic, strong) NSString * agreementTitle;
@property (nonatomic, strong) NSString * agreementUrl;
@property (nonatomic, copy) MegFaceEEStartFaceDetectBlock startFaceDetect;

- (instancetype)initWithAgreementTitle:(NSString *)agreementTitle agreementUrl:(NSString *)agreementUrl error:(MegFaceEEError *_Nullable*_Nullable)error;

- (instancetype)initWithStartFaceDetectBlock:(MegFaceEEStartFaceDetectBlock)startFaceDetect error:(MegFaceEEError *_Nullable*_Nullable)error;

@end

NS_ASSUME_NONNULL_END
