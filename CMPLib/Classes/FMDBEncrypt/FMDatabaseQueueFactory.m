//
//  FMDatabaseQueueFactory.m
//  FmdbDemo
//
//  Created by 程昆 on 2019/4/10.
//  Copyright © 2019 ZhengXiankai. All rights reserved.
//

#import "FMDatabaseQueueFactory.h"
#import "FMDB.h"
#import "FMEncryptDatabaseQueue.h"

@implementation FMDatabaseQueueFactory

+ (FMDatabaseQueue *)databaseQueueWithPath:(NSString *)path encrypt:(BOOL)isEncrypted {
    FMDatabaseQueue *queue = nil;
    if (isEncrypted) {
        queue = [FMEncryptDatabaseQueue databaseQueueWithPath:path];
    } else {
        queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return queue;
}

@end
