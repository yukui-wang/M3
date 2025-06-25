//
//  CMPRCChatViewModel.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/13.
//

#import "CMPRCChatViewModel.h"
#import "CMPRCChatCommonDataProvider.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import <CMPLib/NSString+CMPString.h>
#import "CMPRCGroupMemberObject.h"

@interface CMPRCChatViewModel()

@property (nonatomic,strong) CMPRCChatCommonDataProvider *dataProvider;

@end

@implementation CMPRCChatViewModel

-(void)fetchMemberOnlineStatus:(NSString *)mid result:(void(^)(NSDictionary *desDic,NSError *error, id ext))result
{
    if (!result) {
        return;
    }
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        result(nil,[NSError errorWithDomain:@"server version low" code:-1001 userInfo:nil],nil);
    }
    [self.dataProvider fetchMemberOnlineStatus:mid result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            result([CMPRCChatViewModel _desForOnlineResult:respData],nil,ext);
        }else{
            result(nil,error,ext);
        }
    }];
}

+(NSDictionary *)_desForOnlineResult:(id)resp
{
    if (!resp || ![resp isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    BOOL isOnline = NO;
    NSString *des = @"";
    
    NSString *mobileOnlineStatus = [NSString stringWithFormat:@"%@",resp[@"mobileOnlineStatus"]];
    NSString *pcOnlineStatus = [NSString stringWithFormat:@"%@",resp[@"pcOnlineStatus"]];
    NSString *webOnlineStatus = [NSString stringWithFormat:@"%@",resp[@"webOnlineStatus"]];
    
    //ks fix -- V5-37393【在线状态-M3】iOS 人员在线状态显示优先级有误 (致信端的优先级>移动端优先级>PC端优先级)
    if ([pcOnlineStatus isEqualToString:@"1"]) {
        isOnline = YES;
        des = SY_STRING(@"zx_loginstatus_client");
    }else if ([mobileOnlineStatus isEqualToString:@"1"]) {
        isOnline = YES;
        des = SY_STRING(@"zx_loginstatus_mobile");
    }else if ([webOnlineStatus isEqualToString:@"1"]) {
        isOnline = YES;
        des = SY_STRING(@"zx_loginstatus_web");
    }else{
        isOnline = NO;
        des = SY_STRING(@"zx_loginstatus_offline");
    }
    
//    int s1 = 0, s2 = 0, s3 = 0;
//    if ([NSString isNotNull:mobileOnlineStatus]) {
//        s1 = mobileOnlineStatus.intValue;
//    }
//    if ([NSString isNotNull:pcOnlineStatus]) {
//        s2 = pcOnlineStatus.intValue;
//    }
//    if ([NSString isNotNull:webOnlineStatus]) {
//        s3 = webOnlineStatus.intValue;
//    }
//
//    if ((s1+s2+s3) >= 2) {
//        isOnline = YES;
//        if (![pcOnlineStatus isEqualToString:@"1"]) {
//            des = SY_STRING(@"zx_loginstatus_mobile");
//        }else{
//            des = SY_STRING(@"zx_loginstatus_client");
//        }
//    }else if ([mobileOnlineStatus isEqualToString:@"1"]) {
//        isOnline = YES;
//        des = SY_STRING(@"zx_loginstatus_mobile");
//    }else if ([pcOnlineStatus isEqualToString:@"1"]) {
//        isOnline = YES;
//        des = SY_STRING(@"zx_loginstatus_client");
//    }else if ([webOnlineStatus isEqualToString:@"1"]) {
//        isOnline = YES;
//        des = SY_STRING(@"zx_loginstatus_web");
//    }else{
//        isOnline = NO;
//        des = SY_STRING(@"zx_loginstatus_offline");
//    }
    
    UIColor *color_icon = isOnline ? UIColorFromRGB(0x58DB72) : UIColorFromRGB(0x999999);
    UIColor *color_des = UIColorFromRGB(0x666666);
    
    return @{@"isOnline":@(isOnline),
             @"des":des,
             @"color_icon":color_icon,
             @"color_des":color_des};
}


-(void)fetchChatFileOperationPrivilegeByParams:(NSDictionary *)params
                                    completion:(void(^)(CMPRCGroupPrivilegeModel *privilege, NSError *error, id ext))completion
{
    if (!completion) return;
    [self.dataProvider fetchChatFileOperationPrivilegeByParams:params result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            BOOL canSendFile = [respData[@"sendfile"] boolValue];
            BOOL canRecieveFile = [respData[@"receivefile"] boolValue];
            CMPRCGroupPrivilegeModel *pri = [[CMPRCGroupPrivilegeModel alloc] init];
            pri.sendFile = canSendFile;
            pri.receiveFile = canRecieveFile;
            completion(pri,nil,ext);
        }else{
            CMPRCGroupPrivilegeModel *pri = [[CMPRCGroupPrivilegeModel alloc] init];
            pri.sendFile = YES;
            pri.receiveFile = YES;
            completion(pri,error,ext);
        }
    }];
}


-(void)checkChatFileIfExistById:(NSString *)fid
                        groupId:(NSString *)gid
                     completion:(void(^)(BOOL ifExsit,NSError *error, id ext))completion
{
    if (!completion) return;
    [self.dataProvider checkChatFileIfExistById:fid groupId:gid result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            completion([@"1" isEqualToString:respData],nil,ext);
        }else{
            completion(YES,error,ext);
        }
    }];
}


-(void)fetchGroupUserListByGroupId:(NSString *)groupId
                     completion:(void(^)(CMPRCGroupMemberObject *memberObj,NSError *error, id ext))completion
{
    if (!completion) return;
    [self.dataProvider fetchGroupUserListByGroupId:groupId completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData) {
            CMPRCGroupMemberObject *groupMember = [CMPRCGroupMemberObject yy_modelWithJSON:respData];
            completion(groupMember,nil,ext);
        }else{
            completion(nil,error,ext);
        }
    }];
}


-(CMPRCChatCommonDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPRCChatCommonDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
