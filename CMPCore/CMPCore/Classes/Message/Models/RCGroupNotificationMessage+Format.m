//
//  RCGroupNotificationMessage+Format.m
//  CMPCore
//
//  Created by CRMO on 2017/8/4.
//
//

#import "RCGroupNotificationMessage+Format.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/JSON.h>
#import <CMPLib/CMPCore.h>
#import "CMPRCGroupNotificationObject.h"

@implementation RCGroupNotificationMessage(Format)

- (NSString *)groupNotification {
    NSString *message = nil;
    
    NSDictionary *extraDic = [self.extra JSONValue];
    NSDictionary *jsonDic = [self.data JSONValue];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:extraDic];
    [dictionary addEntriesFromDictionary:jsonDic];
    
    if (dictionary.count == 0 || !dictionary) {
        return nil;
    }
    
    NSString *nickName = [dictionary[@"operatorNickname"] isKindOfClass:[NSString class]]? dictionary[@"operatorNickname"]: nil;
    NSString *groupName = dictionary[@"targetGroupName"] ? dictionary[@"targetGroupName"] : dictionary[@"groupName"];
    
    if ([self.operatorUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        nickName = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    }
    if ([self.operation isEqualToString:@"Create"]) { // 创建群组 例：张三发起群聊“致信群组”。
        message = [NSString stringWithFormat:@"%@%@“%@”。", nickName, SY_STRING(@"msg_createGroup"), groupName];
    } else if ([self.operation isEqualToString:@"Add"]) {  // 邀请人 例：你已加入群聊“致信群组”。
        message = [NSString stringWithFormat:@"%@“%@”。", SY_STRING(@"msg_joinGroup"), groupName];
    } else if ([self.operation isEqualToString:@"Quit"]) { // 退出群 例：王五退出群聊“致信群组”。
        message = [NSString stringWithFormat:@"%@%@“%@”。", nickName, SY_STRING(@"msg_quitGroup"), groupName];
    } else if ([self.operation isEqualToString:@"Kicked"]) { // 你已被踢出群聊“致信群组”。
        message = [NSString stringWithFormat:@"%@“%@”。", SY_STRING(@"msg_kickedGroup"), groupName];
    } else if ([self.operation isEqualToString:@"Rename"]) {
        message = self.message;
    } else if ([self.operation isEqualToString:@"Dismiss"]) { // 群聊“致信群组”已解散
        message = [NSString stringWithFormat:SY_STRING(@"msg_dismissGroup"), groupName];
    } else if ([self.operation isEqualToString:@"Replacement"]) { // 群主转移 例：你已成为群聊“致信群组”的群主
        message = [NSString stringWithFormat:SY_STRING(@"msg_changeGroupManager"), groupName];
    } else if ([self.operation isEqualToString:@"Rebulletin"]) { // 群公告变更
        message = SY_STRING(@"msg_rebulletin");
    } else if ([self.operation isEqualToString:CMPRCGroupNotificationOperationSetAdmin]) { //被设置为群管理员 例子:某某把你设置为群聊"产品部"的管理员
        message = [NSString stringWithFormat:SY_STRING(@"msg_set_admin"),nickName,groupName];
    } else if ([self.operation isEqualToString:CMPRCGroupNotificationOperationUnSetAdmin]) { //被取消管理员权 例子:某某撤销了你群聊"产品部"的管理员权限
        message = [NSString stringWithFormat:SY_STRING(@"msg_unset_admin"),nickName,groupName];
    }
    return message;
}

- (NSString *)messageList {
    NSString *message = nil;
    
    NSData *jsonData = [self.data dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData == nil) {
        return nil;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *operatorUserId = [dictionary[@"operatorUserId"] isKindOfClass:[NSString class]]? dictionary[@"operatorUserId"]:nil;
    NSString *nickName = [dictionary[@"operatorNickname"] isKindOfClass:[NSString class]]? dictionary[@"operatorNickname"]: nil;
    NSArray *targetUserNickName = [dictionary[@"targetUserDisplayNames"] isKindOfClass:[NSArray class]]? dictionary[@"targetUserDisplayNames"]: nil;
    NSArray *targetUserIds = [dictionary[@"targetUserIds"] isKindOfClass:[NSArray class]]? dictionary[@"targetUserIds"]: nil;
    BOOL isMeOperate = NO;
    if ([self.operatorUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        isMeOperate = YES;
        nickName = NSLocalizedStringFromTable(@"You", @"RongCloudKit", nil);
    }
    if ([self.operation isEqualToString:@"Create"]) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupCreated", @"RongCloudKit", nil),nickName];
    } else if ([self.operation isEqualToString:@"Add"]) {
        if (targetUserNickName.count == 0) {
            message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil),nickName];
        } else {
            NSMutableString *names = [[NSMutableString alloc] init];
            NSMutableString *userIdStr = [[NSMutableString alloc] init];
            for (NSUInteger index = 0; index < targetUserNickName.count; index++) {
                [names appendString:targetUserNickName[index]];
                if (index != targetUserNickName.count - 1) {
                    [names appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
                }
            }
            for (NSUInteger index = 0; index < targetUserIds.count; index++) {
                [userIdStr appendString:targetUserIds[index]];
                if (index != targetUserNickName.count - 1) {
                    [userIdStr appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
                }
            }
            if ([operatorUserId isEqualToString:userIdStr]) {
                message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoin", @"RongCloudKit", nil),nickName];
            }
            else
            {
                if(targetUserIds.count > targetUserNickName.count) {
                    names = [NSMutableString stringWithFormat:@"%@%@",names,NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
                }
                message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupInvited", @"RongCloudKit", nil),nickName,names];
                
                if ([targetUserIds containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
                    message = [NSString stringWithFormat:NSLocalizedStringFromTable(isMeOperate ? @"GroupHaveInvited" : @"GroupInvited", @"RongCloudKit", nil),
                    nickName, NSLocalizedString(@"you", nil)];
                }
                
                //ks fix -- V5-37416
                NSDictionary *extraDic = [self.extra JSONValue];
                if (extraDic && [extraDic isKindOfClass:NSDictionary.class]) {
                    NSString *groupType = [NSString stringWithFormat:@"%@",extraDic[@"groupType"]].uppercaseString;
                    if ([@"DEPARTMENT" isEqualToString:groupType]) {
                        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupJoinNoLe", @"RongCloudKit", nil),names];
                    }
                }
                //ks end
                
                //通过扫描二维码加入群聊
                if ([self.operatorUserId isEqualToString:@"7004378101471200365"]) {
                    message = [NSString stringWithFormat:@"%@%@",names,NSLocalizedString(@"rc_scan_code_join_group", nil)];
                }
            }
        }
    } else if ([self.operation isEqualToString:@"Quit"]) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupQuit", @"RongCloudKit", nil),nickName];
    } else if ([self.operation isEqualToString:@"Kicked"]) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (NSUInteger index = 0; index < targetUserNickName.count; index++) {
            [names appendString:targetUserNickName[index]];
            if (index != targetUserNickName.count - 1) {
                [names appendString:NSLocalizedStringFromTable(@"punctuation", @"RongCloudKit", nil)];
            }
        }
        if(targetUserIds.count > targetUserNickName.count) {
            names = [NSMutableString stringWithFormat:@"%@%@",names,NSLocalizedStringFromTable(@"GroupEtc", @"RongCloudKit", nil)];
        }
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupRemoved", @"RongCloudKit", nil),nickName,names];
    } else if ([self.operation isEqualToString:@"Rename"]) {
        NSString *groupName = [dictionary[@"targetGroupName"] isKindOfClass:[NSString class]]?dictionary[@"targetGroupName"]: nil;
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupChanged", @"RongCloudKit", nil),nickName,groupName];
    } else if ([self.operation isEqualToString:@"Dismiss"]) {
        message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"GroupDismiss", @"RongCloudKit", nil),nickName];
    } else if ([self.operation isEqualToString:@"Replacement"]) {
        message = [self replacementMessage];
    } else if ([self.operation isEqualToString:@"Rebulletin"]) { // 群公告变更
        message = SY_STRING(@"msg_rebulletin");
    } else if ([self.operation isEqualToString:@"SetAdmin"]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"msg_you_set_admin", nil),targetUserNickName.firstObject];
        //ks fix -- V5-36419
        NSString *curMid = [CMPCore sharedInstance].userID;
        if (![curMid isEqualToString:operatorUserId]) {
            message = [NSString stringWithFormat:NSLocalizedString(@"msg_someone_set_admin", nil),nickName,targetUserNickName.firstObject];
        }
    } else if ([self.operation isEqualToString:@"UnSetAdmin"]) {
        message = [NSString stringWithFormat:NSLocalizedString(@"msg_you_unset_admin", nil),targetUserNickName.firstObject];
        //ks fix -- V5-36419
        NSString *curMid = [CMPCore sharedInstance].userID;
        if (![curMid isEqualToString:operatorUserId]) {
            message = [NSString stringWithFormat:NSLocalizedString(@"msg_someone_unset_admin", nil),nickName,targetUserNickName.firstObject];
        }
    } else {
        //ks fix -- 致信部门群转普通群的通知
        //convertDept2SimpleGroup
        //convertSimple2DeptGroup
        //如果下面的发现有问题，可以单独判断operation
        message = self.message;
    }
    return message;
}

- (NSString *)replacementMessage {
    NSString *extra = self.extra;
    NSDictionary *extraDic = [extra JSONValue];
    if (!extraDic || ![extraDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [NSString stringWithFormat:SY_STRING(@"msg_replacement"), extraDic[@"creatorName"]];
}

@end
