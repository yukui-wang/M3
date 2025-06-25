//
//  CMPPreferenceManager.h
//  M3
//
//  Created by Kaku Songu on 8/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MapTypeInUse_Gaode,
    MapTypeInUse_Google,
    MapTypeInUse_Apple
} MapTypeInUse;

@interface CMPPreferenceManager : NSObject

+ (BOOL)setMapTypeInUse:(MapTypeInUse)mapType;
+ (MapTypeInUse)getMapTypeInUse;

@end

NS_ASSUME_NONNULL_END
