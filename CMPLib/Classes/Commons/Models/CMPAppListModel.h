//
//  CMPAppListModel.h
//  M3
//
//  Created by CRMO on 2017/11/6.
//

#import <CMPLib/CMPObject.h>

#pragma mark-
#pragma mark-Data

@interface CMPAppListData :CMPObject
@property (nonatomic , copy) NSString              * appShortAddress;
@property (nonatomic , assign) NSInteger              isThird;
@property (nonatomic , copy) NSString              * appType;
@property (nonatomic , copy) NSString              * tags;
@property (nonatomic , copy) NSString              * bizMenuId;
@property (nonatomic , copy) NSString              * updateDate;
@property (nonatomic , copy) NSString              * isShow;
@property (nonatomic , copy) NSString              * bundleIdentifier;
@property (nonatomic , copy) NSString              * gotoParam;
@property (nonatomic , copy) NSString              * bundleName;
@property (nonatomic , copy) NSString              * urlSchemes;
@property (nonatomic , copy) NSString              * isUpdate;
@property (nonatomic , copy) NSString              * version;
@property (nonatomic , copy) NSString              * cmpShellVersion;
@property (nonatomic , copy) NSString              * iconUrl;
@property (nonatomic , copy) NSString              * domain;
@property (nonatomic , copy) NSString              * entry;
@property (nonatomic , copy) NSString              * jsUrl;
@property (nonatomic , copy) NSString              * appName;
@property (nonatomic , copy) NSString              * appJoinAddress;
@property (nonatomic , assign) NSInteger              sortNum;
@property (nonatomic , assign) NSInteger              isPreset;
@property (nonatomic , copy) NSString              * appId;
@property (nonatomic , copy) NSString              * unSelect;
@property (nonatomic , copy) NSString              * serverIdentifier;
@property (nonatomic , assign) NSInteger              hasPlugin;
@property (nonatomic , copy) NSString              * md5;
@property (nonatomic , copy) NSString              * desc;
@end

#pragma mark-
#pragma mark-CMPAppListModel
@interface CMPAppListModel :CMPObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , copy) NSString              * message;
@property (nonatomic , copy) NSArray<CMPAppListData *>              * data;
@property (nonatomic , assign) NSInteger              time;
@property (nonatomic , copy) NSString              * version;

- (BOOL)requestSuccess;
@end

#pragma mark-
#pragma mark-新版本

@interface CMPAppType_2 :NSObject
@property (nonatomic , assign) NSInteger              appTypeId;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              sort;
@property (nonatomic , assign) NSInteger              appCount;
@property (nonatomic , assign) NSInteger              edit;
@property (nonatomic , assign) NSInteger              key;
@property (nonatomic , assign) NSInteger              accountId;

@end

@interface CMPAppListM3AppType_2 :NSObject
@property (nonatomic , assign) NSInteger              appTypeId;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              sort;
@property (nonatomic , assign) NSInteger              appCount;
@property (nonatomic , assign) NSInteger              edit;
@property (nonatomic , assign) NSInteger              key;
@property (nonatomic , assign) NSInteger              accountId;

@end

@interface CMPAppList_2 :NSObject
@property (nonatomic , copy) NSString              * appShortAddress;
@property (nonatomic , assign) NSInteger              isThird;
@property (nonatomic , copy) NSString              * appType;
@property (nonatomic , copy) NSString              * tags;
@property (nonatomic , copy) NSString              * bizMenuId;
@property (nonatomic , copy) NSString              * updateDate;
@property (nonatomic , copy) NSString              * isShow;
@property (nonatomic , copy) NSString              * bundleIdentifier;
@property (nonatomic , copy) NSString              * gotoParam;
@property (nonatomic , copy) NSString              * bundleName;
@property (nonatomic , copy) NSString              * urlSchemes;
@property (nonatomic , copy) NSString              * isUpdate;
@property (nonatomic , strong) CMPAppListM3AppType_2              * m3AppType;
@property (nonatomic , copy) NSString              * version;
@property (nonatomic , copy) NSString              * cmpShellVersion;
@property (nonatomic , copy) NSString              * iconUrl;
@property (nonatomic , copy) NSString              * domain;
@property (nonatomic , copy) NSString              * entry;
@property (nonatomic , copy) NSString              * jsUrl;
@property (nonatomic , copy) NSString              * appName;
@property (nonatomic , copy) NSString              * appJoinAddress;
@property (nonatomic , assign) NSInteger              sortNum;
@property (nonatomic , assign) NSInteger              isPreset;
@property (nonatomic , copy) NSString              * appId;
@property (nonatomic , copy) NSString              * unSelect;
@property (nonatomic , copy) NSString              * serverIdentifier;
@property (nonatomic , assign) NSInteger              hasPlugin;
@property (nonatomic , copy) NSString              * packageType;
@property (nonatomic , copy) NSString              * md5;
@property (nonatomic , copy) NSString              * desc;
@property (nonatomic , copy) NSString              * appkey;
@property (nonatomic , copy) NSString              * uniqueId;
@property (nonatomic , copy) NSString              * otherApppId;
@property (nonatomic , copy) NSString              * localAppId;//如果otherApppId有值则=otherApppId，否则=appId


@end

@interface CMPAppListData_2 :NSObject
@property (nonatomic , strong) CMPAppListM3AppType_2              * appType;
@property (nonatomic , copy) NSArray<CMPAppList_2 *>              * appList;
@end

@interface CMPAppListModel_2 :CMPObject
@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , copy) NSArray<CMPAppListData_2 *>              * data;
@property (nonatomic , copy) NSString              * message;
@property (nonatomic , assign) NSInteger              time;
@property (nonatomic , copy) NSString              * version;

- (CMPAppList_2 *)appInfoWithType:(NSString *)type ID:(NSString *)ID;
- (CMPAppList_2 *)appInfoWithType:(NSString *)type bundleName:(NSString *)bundleName;
- (CMPAppList_2 *)appInfoWithType:(NSString *)type bundleName:(NSString *)bundleName appId:(NSString *)appId;
- (CMPAppList_2 *)appInfoWithBizId:(NSString *)bizId;
- (CMPAppList_2 *)appInfoWithAppId:(NSString *)appId;//appId适合cip集成的远程、本地应用
@end
