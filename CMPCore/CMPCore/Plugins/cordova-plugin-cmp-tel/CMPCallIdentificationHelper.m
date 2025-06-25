//
//  CMPCallIdentificationHelper.m
//  M3
//
//  Created by CRMO on 2018/3/8.
//

#import "CMPCallIdentificationHelper.h"
#import "CMPCallDirectoryManager.h"
#import "CMPContactsManager.h"
#import "CMPPrivilegeManager.h"
#import "CMPCustomManager.h"

#if DEBUG
NSString * const CMPCallIdentificationPluginExtensionID = @"com.seeyon.m3.inhouse.dis.call";
NSString * const CMPCallIdentificationPluginAppGroupID = @"group.com.seeyon.m3.inhousedis";
#endif

#if RELEASE
NSString * const CMPCallIdentificationPluginExtensionID = @"com.seeyon.m3.inhouse.dis.call";
NSString * const CMPCallIdentificationPluginAppGroupID = @"group.com.seeyon.m3.inhousedis";
#endif

#if APPSTORE
NSString * const CMPCallIdentificationPluginExtensionID = @"com.seeyon.m3.appstore.new.phone.CallDirectory";
NSString * const CMPCallIdentificationPluginAppGroupID = @"group.com.seeyon.m3.appstore.new.phone.CallDirectory";
#endif

const NSInteger CMPCallIdentificationPluginErrorUnkown = 10000; // 未知错误
const NSInteger CMPCallIdentificationPluginErrorDisabled = 10001; // 设置权限没有开启
const NSInteger CMPCallIdentificationPluginErrorNoContacts = 10002; // 离线通讯录获取失败
const NSInteger CMPCallIdentificationPluginErrorOpen = 10003; // 开启失败
const NSInteger CMPCallIdentificationPluginErrorClose = 10003; // 关闭失败

@interface CMPCallIdentificationHelper()

@property (strong, nonatomic) CMPCallDirectoryManager *callDirectorymanager;
@property (assign, nonatomic) BOOL switchState;

@end

@implementation CMPCallIdentificationHelper

- (void)switchCallIdentification:(BOOL)state
                      completion:(void(^)(BOOL result, NSError *error))done {
    CMPPrivilege *pr = [CMPPrivilegeManager getCurrentUserPrivilege];
    BOOL addressBookPrivilege = pr.hasAddressBook;
    BOOL callIdentificationState = addressBookPrivilege && state;
    
    __weak typeof(self) weakself = self;
    [self.callDirectorymanager getEnableStatus:^(CXCallDirectoryEnabledStatus enabledStatus, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (done) {
                    NSError *error = [NSError errorWithDomain:SY_STRING(@"call_identification_unkown_error")
                                                         code:CMPCallIdentificationPluginErrorUnkown
                                                     userInfo:nil];
                    done(NO, error);
                }
                return;
            }
            
            if (enabledStatus == CXCallDirectoryEnabledStatusUnknown) {
                if (done) {
                    NSError *error = [NSError errorWithDomain:SY_STRING(@"call_identification_unkown_error")
                                                         code:CMPCallIdentificationPluginErrorUnkown
                                                     userInfo:nil];
                    done(NO, error);
                }
            } else if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
                if (done) {
                    NSError *error = [NSError errorWithDomain:@""
                                                         code:CMPCallIdentificationPluginErrorDisabled
                                                     userInfo:nil];
                    done(NO, error);
                }
                if (!state) { // 关闭时不判断权限
                    weakself.switchState = state;
                }
            } else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                if (callIdentificationState) {
                    [weakself writeMembersToCallkit:done];
                } else {
                    [weakself clearMembersInCallkit:done];
                }
                weakself.switchState = state;
            }
        });
    }];
}

/**
 将通讯录的人员信息写入callkit
 */
- (void)writeMembersToCallkit:(void(^)(BOOL result, NSError *error))done {
    __weak typeof(self) weakself = self;
    
    [[CMPContactsManager defaultManager] allMemberInAz:^(CMPContactsResult *result) {
        if (!result.sucessfull) {
            if (done) {
                NSError *error = [NSError errorWithDomain:SY_STRING(@"call_identification_contacts_error")
                                                     code:CMPCallIdentificationPluginErrorNoContacts
                                                 userInfo:nil];
                done(NO, error);
            }
            return;
        }
        
        for (CMPOfflineContactMember *member in result.allMemberList) {
            NSString *label = [self labelWithName:member.name
                                         postName:member.postName];
            NSString *phone = member.mobilePhone;
            
            if ([NSString isNull:label] ||
                [NSString isNull:phone]) {
                //                NSLog(@"CallKit---不合规数据：name:%@,postName:%@,mobilePhone:%@", member.name, member.postName, member.mobilePhone);
                continue;
            }
            
            if ([member.orgID isEqualToString:[CMPCore sharedInstance].userID]) { // 排除自己
                continue;
            }
            
            if ([weakself.callDirectorymanager addPhoneNumber:phone label:label]) {
                //                NSLog(@"CallKit---写入成功：name:%@,postName:%@,mobilePhone:%@", member.name, member.postName, member.mobilePhone);
            } else {
                //                NSLog(@"CallKit---写入失败：name:%@,postName:%@,mobilePhone:%@", member.name, member.postName, member.mobilePhone);
            }
        }
        
        // 有权限，调用reload
        [weakself.callDirectorymanager reload:^(NSError *error) {
            if (error) {
                NSLog(@"CallKit---reload失败：error:%@", error);
                if (done) {
                    NSError *error = [NSError errorWithDomain:SY_STRING(@"call_identification_open_fail")
                                                         code:CMPCallIdentificationPluginErrorOpen
                                                     userInfo:nil];
                    done(NO, error);
                }
            } else {
                if (done) {
                    done(YES, nil);
                }
            }
        }];
    }];
}

/**
 清空callkit中的数据
 */
- (void)clearMembersInCallkit:(void(^)(BOOL result, NSError *error))done {
    [self.callDirectorymanager clearAllData:^(NSError *error) {
        if (error) {
            NSLog(@"CallKit---clearAllData失败：error:%@", error);
            if (done) {
                NSError *error = [NSError errorWithDomain:SY_STRING(@"call_identification_close_fail")
                                                     code:CMPCallIdentificationPluginErrorClose
                                                 userInfo:nil];
                done(NO, error);
            }
        } else {
            if (done) {
                done(YES, nil);
            }
        }
    }];
}

- (void)reloadCallIdentification {
    [self switchCallIdentification:self.switchState completion:^(BOOL result, NSError *error) {
        NSLog(@"callkit---reloadCallIdentification结果：%d", result);
    }];
}

- (void)closeCallIdentification {
    [self switchCallIdentification:NO completion:^(BOOL result, NSError *error) {
        NSLog(@"callkit---reloadCallIdentification结果：%d", result);
    }];
}

#pragma mark-
#pragma mark Private

/**
 获取来电识别的标签
 两种情况：
 1.岗位 姓名
 2.姓名
 
 @param name 姓名
 @param postName 岗位
 @return
 */
- (NSString *)labelWithName:(NSString *)name postName:(NSString *)postName {
    if ([NSString isNull:name]) {
        return nil;
    }
    
    if ([NSString isNull:postName]) {
        return name;
    }
    
    return [NSString stringWithFormat:@"%@ %@", name, postName];
}

+ (NSString *)userDefaultsKey {
    NSString *userID = [CMPCore sharedInstance].userID;
    NSString *serverID = [CMPCore sharedInstance].serverID;
    return [NSString stringWithFormat:@"CMPCallIdentificationPlugin_%@_%@", userID, serverID];
}

#pragma mark-
#pragma mark-Getter & Setter

- (BOOL)switchState {
    NSString *key = [CMPCallIdentificationHelper userDefaultsKey];
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    BOOL result = [value boolValue];
    return result;
}

- (void)setSwitchState:(BOOL)switchState {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:switchState] forKey:[CMPCallIdentificationHelper userDefaultsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CMPCallDirectoryManager *)callDirectorymanager {
    if (!_callDirectorymanager) {
#if CUSTOM
        NSString *callid = [CMPCustomManager sharedInstance].cusModel.callExtensionBundleId;
        NSString *groupid = [CMPCustomManager sharedInstance].cusModel.appGroupId;
        _callDirectorymanager = [[CMPCallDirectoryManager alloc] initWithExtensionIdentifier:callid ApplicationGroupIdentifier:groupid];
#else
        _callDirectorymanager = [[CMPCallDirectoryManager alloc] initWithExtensionIdentifier:CMPCallIdentificationPluginExtensionID
                                                                  ApplicationGroupIdentifier:CMPCallIdentificationPluginAppGroupID];
#endif
    }
    return _callDirectorymanager;
}

@end
