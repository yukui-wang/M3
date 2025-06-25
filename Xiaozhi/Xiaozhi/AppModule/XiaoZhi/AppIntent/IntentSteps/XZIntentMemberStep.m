//
//  XZIntentMemberStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kMembersEnd @"下一步"
#define kMembersChooseCancel @"取消"

#import "XZIntentMemberStep.h"
#import "XZMainProjectBridge.h"
#import "XZMainProjectBridge.h"
#import "XZCore.h"
#import "XZPinyinTool.h"
#import "XZM3RequestManager.h"
@interface XZIntentMemberStep()
@property(nonatomic,strong)NSDictionary *value;

@end

@implementation XZIntentMemberStep

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.skip = NO;
    }
    return self;
}
- (NSString *)guideWord {
    if (self.errorMsg) {
        return self.errorMsg;
    }
    return _guideWord;
}

- (NSString *)memberToIdStr:(CMPOfflineContactMember *)member {
    if (!member) {
        return nil;
    }
    return [NSString stringWithFormat:@"Member|%@",member.orgID];
}

- (NSDictionary *)memberToDictionary:(CMPOfflineContactMember *)member {
    if (!member) {
        return nil;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (![NSString isNull:member.orgID]) {
        [dic setObject:member.orgID forKey:kIntentMemberKey_Id];
    }
    if (![NSString isNull:member.name]) {
        [dic setObject:member.name forKey:kIntentMemberKey_Name];
    }
    [dic setObject:kIntentMemberTypeValue_Member forKey:kIntentMemberKey_Type];
    if (![NSString isNull:member.postName]) {
        [dic setObject:member.postName forKey:kIntentMemberKey_Post];
    }
    if (![NSString isNull:member.accountId]) {
        [dic setObject:member.accountId forKey:kIntentMemberKey_Account];
    }
    return dic;
    /*{"id":"人员id","name":"人员名称","type":"Member","post":"岗位名称","account":"单位id"}*/
}

- (NSString *)errorMsgWithName:(NSString *)name {
    return kIntentChoosePersonErrorMsg;
}

+ (NSTextCheckingResult *)firstMatchInString:(NSString *)command pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *checkResult = [regex firstMatchInString:command options:NSMatchingReportProgress range:NSMakeRange(0, [command length])];
    return checkResult;
}

- (NSString *)value:(NSString *)command result:(NSTextCheckingResult *)checkResult index:(NSInteger)index {
    NSRange range = [checkResult rangeAtIndex:index];
    if (range.location != NSNotFound) {
        return [command substringWithRange:range];
    }
    return @"";
}
- (void)handleSearchMemberResult:(NSArray *)memberArray defaultSelectArray:(NSArray *)selectArray name:(NSString *)name complete:(void(^)(void))complete{
    if (memberArray.count == 0) {
        self.errorMsg = [self errorMsgWithName:name];
        if (complete) {
            complete();
        }
    }
    else if (memberArray.count == 1) {
        [self handleMembers:memberArray];
        if (complete) {
            complete();
        }
    }
    else {
        //重名人员，请选择
        self.tempValue = memberArray;
        BOOL isMut = [self isMultiSelectMember];
        XZIntentStepClarifyMemberParam *param = [[XZIntentStepClarifyMemberParam alloc] init];
        param.members = memberArray;
        param.defaultSelectArray = selectArray;
        param.name = name;
        param.target = self.key;
        param.isMultipleSelection = isMut;
        if (self.delegate && [self.delegate respondsToSelector:@selector(intentStepShpuldClarifyMembers:)]) {
            [self.delegate intentStepShpuldClarifyMembers:param];
        }
    }
}


- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    NSInteger index = -1;
    self.skip = NO;
    if (self.tempValue) {
        index = [[XZDateUtils convertChineseNumberToArabicNumber:result] integerValue]-1;
    }
    if ([self.slot isEqualToString:kIntentSlot_Person] && [result isEqualToString:kIntentMember_Me]) {
        [self handleMembers:@[[self currentUser]]];
    }
    else if ([result isEqualToString:kMembersEnd]) {
        self.tempValue = nil;
        self.skip = YES;
    }
    else if ([result isEqualToString:kMembersChooseCancel]) {
        self.tempValue = nil;
    }
    else if (self.tempValue && index  > 0 ) {
        NSArray *array = self.tempValue;
        if (index < array.count) {
            CMPOfflineContactMember *member = array[index];
            [self handleMembers:@[member]];
            self.tempValue = nil;
        }
    }
    else {
        //通过名字查询人员
        if ([XZCore sharedInstance].isM3ServerIsLater8) {
            //新版本
            __weak typeof(self) weakSelf = self;
            [XZPinyinTool obtainMembersWithNameArray:@[result] memberType:XZSearchMemberType_Flow_Native complete:^(NSArray* memberArray, NSArray *defSelectArray) {
                [weakSelf handleSearchMemberResult:memberArray defaultSelectArray:defSelectArray name:result complete:complete];
            }];
        }
        else {
            //老版本 离线通讯录中查询
            if (!self.originalValue) {
                self.originalValue = result;
            }
            __weak typeof(self) weakSelf = self;
            [XZMainProjectBridge memberListForNameArray:@[result] isFlow:YES completion:^(NSArray *memberArray) {
                [weakSelf handleSearchMemberResult:memberArray defaultSelectArray:nil name:result complete:complete];
            }];
        }
        return;
    }
    complete();
}

- (void)handleUnitResult:(NSArray *)nameArray complete:(void(^)(void))complete {
    NSString *name = [nameArray firstObject];
    if ([XZCore sharedInstance].isM3ServerIsLater8) {
        //新版本
        __weak typeof(self) weakSelf = self;
        [XZPinyinTool obtainMembersWithNameArray:nameArray memberType:XZSearchMemberType_Flow_BUnit complete:^(NSArray* memberArray, NSArray *defSelectArray) {
            [weakSelf handleSearchMemberResult:memberArray defaultSelectArray:defSelectArray name:name complete:complete];
        }];
    }
    else {
        //老版本 离线通讯录中查询
        if (!self.normalizedValue || ![nameArray containsObject:self.originalValue]) {
            if (!self.originalValue) {
                self.originalValue = [nameArray firstObject];
            }
            if ([XZMainProjectBridge contactsIsUpdating]) {
                self.errorMsg = kXZContactsDowloading;
                complete();
                return;
            }
            __weak typeof(self) weakSelf = self;
            [XZMainProjectBridge memberListForNameArray:nameArray isFlow:YES completion:^(NSArray *memberArray) {
                [weakSelf handleSearchMemberResult:memberArray defaultSelectArray:nil name:name complete:complete];
            }];
        }
        else {
            complete();
        }
    }
}

- (void)handleMembers:(NSArray *)array {
    CMPOfflineContactMember *member = [array firstObject];
    if (!self.originalValue) {
        self.originalValue = [SPTools memberNameWithName:member.name];
    }
    self.value = [self memberToDictionary:member];
    self.displayValue = member.name;
    self.tempValue = nil;
    self.errorMsg = nil;
}

- (NSString *)stringValue {
    return [SPTools dictionaryToJson:self.value];
}

- (id)normalizedValue {
    return self.value;
}

- (BOOL)canNext {
    if (self.required && self.value) {
        return YES;
    }
    if (!self.required) {
        return YES;
    }
    return NO;
}

- (BOOL)canNextForCreate {
    return [self canNext];
}

- (BOOL)isChooseMember {
    return YES;
}

@end
