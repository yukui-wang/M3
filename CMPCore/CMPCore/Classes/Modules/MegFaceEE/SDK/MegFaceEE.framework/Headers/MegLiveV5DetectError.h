//
//  MegLiveV5DetectError.h
//  MegLiveV5Detect
//
//  Created by MegviiDev on 2021/10/15.
//

#import <Foundation/Foundation.h>
#if __has_include(<MegLiveV5Detect/MegLiveV5DetectConfig.h>)
#import <MegLiveV5Detect/MegLiveV5DetectConfig.h>
#else
#import "MegLiveV5DetectConfig.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MegLiveV5DetectError : NSObject

@property (nonatomic, assign) MegLiveV5DetectErrorType errorCode;
@property (nonatomic, strong) NSString* errorMessage;

@end

NS_ASSUME_NONNULL_END
