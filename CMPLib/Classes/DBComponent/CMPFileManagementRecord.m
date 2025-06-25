//
//  CMPFileManagementRecord.m
//  CMPLib
//
//  Created by MacBook on 2019/10/14.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPFileManagementRecord.h"
#import "CMPFileManager.h"
#import "YYModel.h"
#import <CMPLib/FCFileManager.h>


@implementation CMPFileManagementRecord

- (NSString *)jsonString {
    return self.yy_modelToJSONString;
}

+ (instancetype)modelWithJsonString:(NSString *)jsonString {
    return [self yy_modelWithJSON:jsonString];
}


@end
