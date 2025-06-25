//
//  CMPContactsSearchMemberResponse.m
//  M3
//
//  Created by CRMO on 2017/11/24.
//

#import "CMPContactsSearchMemberResponse.h"
#import <CMPLib/CMPFeatureSupportControl.h>

@implementation CMPContactsSearchMemberResponseChildren

+ (NSDictionary *)modelCustomPropertyMapper {
    NSMutableDictionary *mapDic = [NSMutableDictionary dictionary];
    mapDic[@"orgID"] = @"id";
    if (CMPFeatureSupportControl.isNeedMapSearchMemberResponse) {
        mapDic[@"img"] = @"Img";
        mapDic[@"t"] = @"T";
        mapDic[@"pId"] = @"PId";
        mapDic[@"dN"] = @"DN";
        mapDic[@"dId"] = @"DId";
        mapDic[@"i"] = @"I";
        mapDic[@"n"] = @"N";
        mapDic[@"pN"] = @"PN";
        mapDic[@"aId"] = @"AId";
    }
    return [mapDic copy];
}

@end

@implementation CMPContactsSearchMemberResponse

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"children" : [CMPContactsSearchMemberResponseChildren class]};
}

@end
