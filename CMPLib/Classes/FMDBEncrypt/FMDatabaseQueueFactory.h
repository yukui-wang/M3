//
//  FMDatabaseQueueFactory.h
//  FmdbDemo
//
//  Created by 程昆 on 2019/4/10.
//  Copyright © 2019 ZhengXiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabaseQueueFactory : NSObject

+ (FMDatabaseQueue *)databaseQueueWithPath:(NSString *)path encrypt:(BOOL)isEncrypted;

@end

NS_ASSUME_NONNULL_END
