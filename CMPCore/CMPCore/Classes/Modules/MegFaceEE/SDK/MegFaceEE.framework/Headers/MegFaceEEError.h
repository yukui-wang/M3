//
//  MegFaceEEError.h
//  MegFaceEE
//
//  Created by Megvii on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import <MegFaceEE/MegFaceEEConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface MegFaceEEError : NSObject

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *errorDescription;

@end

NS_ASSUME_NONNULL_END
