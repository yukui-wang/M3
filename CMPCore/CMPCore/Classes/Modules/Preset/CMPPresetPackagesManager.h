//
//  CMPPresetPackagesManager.h
//  M3
//
//  Created by Kaku Songu on 10/13/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPPresetPackagesManager : NSObject

+(BOOL)ifNeedPresetHandle;
+(BOOL)isCMPScheme;
+(NSArray *)handleServerAppList:(NSArray *)serverList
                  movedComplete:(void(^)(BOOL success))movedComplete;

@end

NS_ASSUME_NONNULL_END
