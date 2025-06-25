//
//  CMPOcrPackageModel.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import "CMPOcrPackageModel.h"

@implementation CMPOcrPackageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"pid" : @"id"};
}

@end

@implementation CMPOcrPackageTipModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"unDistinguishCount" : @"extraInfo.unDistinguishCount"};
}

@end

@implementation CMPOcrPackageClassifyModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"rPackageList" : [CMPOcrPackageModel class],
    };
}

@end
