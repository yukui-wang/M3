//
//  CMPH5ConfigModel.m
//  CMPLib
//
//  Created by CRMO on 2019/1/3.
//  Copyright © 2019 CMPCore. All rights reserved.
//

#import "CMPH5ConfigModel.h"

@implementation CMPH5ConfigModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"commonAppBlackList" : @"blackListOfShowCommonAppEntry"
             };
}

@end
