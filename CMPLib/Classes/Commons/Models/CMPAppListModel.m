//
//  CMPAppListModel.m
//  M3
//
//  Created by CRMO on 2017/11/6.
//

#import "CMPAppListModel.h"

@implementation CMPAppListData

@end

@implementation CMPAppListModel

- (BOOL)requestSuccess {
    if (self.code == 200 &&
        [self.message isEqualToString:@"success"]) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [CMPAppListData class]};
}

@end

#pragma mark-
#pragma mark-新版本

@implementation CMPAppType_2

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"appTypeId" : @"id"};
}

@end

@implementation CMPAppListM3AppType_2

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"appTypeId" : @"id"};
}

@end

@implementation CMPAppList_2
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"appkey" : @"id"};
}
@end

@implementation CMPAppListData_2
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"appList" : [CMPAppList_2 class]};
}
@end

@implementation CMPAppListModel_2

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [CMPAppListData_2 class]};
}

- (CMPAppList_2 *)appInfoWithType:(NSString *)type ID:(NSString *)ID {
    NSArray *appDataList = self.data;
    for (CMPAppListData_2 *listData in appDataList) {
        for (CMPAppList_2 *appList in listData.appList) {
            if ([appList.appId isEqualToString:ID] &&
                [appList.appType isEqualToString:type]) {
                return appList;
            }
        }
    }
    return nil;
}

- (CMPAppList_2 *)appInfoWithType:(NSString *)type bundleName:(NSString *)bundleName {
    NSArray *appDataList = self.data;
    for (CMPAppListData_2 *listData in appDataList) {
        for (CMPAppList_2 *appList in listData.appList) {
            if ([appList.bundleName isEqualToString:bundleName] &&
                [appList.appType isEqualToString:type]) {
                return appList;
            }
        }
    }
    return nil;
}

- (CMPAppList_2 *)appInfoWithType:(NSString *)type bundleName:(NSString *)bundleName appId:(NSString *)appId {
    NSArray *appDataList = self.data;
    for (CMPAppListData_2 *listData in appDataList) {
        for (CMPAppList_2 *appList in listData.appList) {
            NSString *localAppId = [appList.otherApppId isKindOfClass:NSString.class] && appList.otherApppId.length ? appList.otherApppId : appList.appId;
            
            if ([appId isEqualToString:localAppId]
                && [appList.bundleName isEqualToString:bundleName]
                && [appList.appType isEqualToString:type]) {
                appList.localAppId = localAppId;
                return appList;
            }
        }
    }
    return nil;
}

- (CMPAppList_2 *)appInfoWithBizId:(NSString *)bizId{
    NSArray *appDataList = self.data;
    for (CMPAppListData_2 *listData in appDataList) {
        for (CMPAppList_2 *appList in listData.appList) {
            NSString *localAppId = [appList.otherApppId isKindOfClass:NSString.class] && appList.otherApppId.length ? appList.otherApppId : appList.appId;
            if ([bizId isEqualToString:localAppId]) {
                return appList;
            }
        }
    }
    return nil;
}

- (CMPAppList_2 *)appInfoWithAppId:(NSString *)appId{
    NSArray *appDataList = self.data;
    for (CMPAppListData_2 *listData in appDataList) {
        for (CMPAppList_2 *appList in listData.appList) {
            if ([appList.appId isEqualToString:appId]) {
                return appList;
            }
        }
    }
    return nil;
}

@end
