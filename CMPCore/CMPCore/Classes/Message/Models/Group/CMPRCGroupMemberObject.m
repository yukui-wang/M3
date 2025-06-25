//
//  CMPRCGroupMemberObject.m
//  CMPCore
//
//  Created by CRMO on 2017/9/15.
//
//

#import "CMPRCGroupMemberObject.h"
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPConstant.h>
#import "RCIM+InfoCache.h"

@interface CMPRCGroupMemberObject()
@property (nonatomic, copy) NSString *allowNoticeStatus;
@property (nonatomic, assign) long displayPostStatus;
@end

@implementation CMPRCGroupMemberObject

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"n",
             @"groupID" : @"i",
             @"ownerName" : @"cn",
             @"createDate" : @"up",
             @"members" : @"ma",
             @"membersCount" : @"mc",
             @"ownerId" : @"ci",
             @"adminIds" : @"ai"
    };
}

- (NSArray<RCUserInfo *> *)allUserInfo {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *member in self.members) {
        if ([NSString isNull:member]) {
            NSLog(@"RC---CMPRCGroupMemberObject:allUserInfo:member is nil, member:%@", member);
            continue;
        }
        NSDictionary *memberDic = [member JSONValue];
        TYPE_CHECK_CONTINUE(memberDic, NSDictionary);
        NSString *name = memberDic[@"name"];
        NSString *userId = memberDic[@"id"];
        NSString *portrait =[CMPCore memberIconUrlWithId:userId];
        if ([NSString isNull:name] ||
            [NSString isNull:userId] ||
            [NSString isNull:portrait]) {
            NSLog(@"RC---CMPRCGroupMemberObject:allUserInfo:name/userId/portrait is nil, member:%@", member);
            continue;
        }
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portrait];
        [result addObject:userInfo];
    }
    return result;
}

- (CMPGroupType)enumGroupType {
    NSString *groupType = self.groupType;
    if ([groupType isEqualToString:@"DEPARTMENT"]) {
        return CMPGroupTypeDepartment;
    } else {
        return CMPGroupTypeOrdinary;
    }
}

-(BOOL)hasPermissionAtAll
{
    if (_allowNoticeStatus && [_allowNoticeStatus isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

//-(BOOL)isShowMemberPost
//{
//    if (_displayPostStatus == 1) {
//        return YES;
//    }
//    return NO;
//}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    //ks add 设置群成员信息map
    NSMutableDictionary *membersDic = [[NSMutableDictionary alloc] init];
    NSArray *ma = dictionary[@"ma"];
    if (ma && [ma isKindOfClass:[NSArray class]] && ma.count) {
        //{"sortId":"29","postName":"高级开发工程师","name":"郭金龙","id":"-6650499944156018294"}
        for (NSString *member in ma) {
            if ([NSString isNull:member]) {
                continue;
            }
            NSDictionary *memberInfo = [member JSONValue];
            if (memberInfo) {
                NSString *uid = memberInfo[@"id"];
                [membersDic setObject:memberInfo forKey:uid];
            }
        }
    }
    [dictionary setObject:membersDic forKey:@"membersDic"];
    //
    return dictionary;
}

@end
