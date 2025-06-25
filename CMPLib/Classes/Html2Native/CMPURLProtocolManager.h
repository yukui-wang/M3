//
//  CMPURLProtocolManager.h
//  CMPLib
//
//  Created by Kaku Songu on 5/27/21.
//  Copyright © 2021 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPURLProtocolManager : NSObject

@property (nonatomic,strong) NSArray *ignoreQueryArr;
@property (nonatomic,strong) NSArray *ignoreHostArr;
@property (nonatomic,strong) NSArray *ignoreSafariLoadHostArr;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
