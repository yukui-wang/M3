//
//  CMPAddressModel.m
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/12/5.
//  Copyright © 2018 yaowei. All rights reserved.
//

#import "CMPAddressModel.h"

@implementation CMPProvinceModel

- (id)copyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
@end


@implementation CMPCityModel
- (id)copyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
@end


@implementation CMPAreaModel
- (id)copyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    CMPProvinceModel * model = [[CMPProvinceModel allocWithZone:zone] init];
    model.code = self.code;
    model.name = self.name;
    model.index = self.index;
    return model;
}
@end

@implementation CMPResultModel
@end
