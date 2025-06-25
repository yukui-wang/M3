//
//  CMPScreenshotControlManager.h
//  M3
//
//  Created by MacBook on 2019/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPScreenshotControlManager : NSObject

+ (instancetype)sharedManager;

- (void)initializeScreenshotConfig;

@end

NS_ASSUME_NONNULL_END
