//
//  XZSendIMMsgIntent.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/27.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZSendIMMsgIntent.h"
#import "XZMainProjectBridge.h"
#import "XZCore.h"
#import "XZPinyinTool.h"
@implementation XZSendIMMsgIntent

- (void)handleMember:(CMPOfflineContactMember *)member
          memberName:(NSString *)name
             content:(NSString *)content {
    if (!self.member && member) {
        self.member = member;
    }
    if (![NSString isNull:content]) {
        self.content = content;
    }
    if (!self.member  && ![NSString isNull:name]) {
        [self handleMemberName:name];
    }
    else {
        [self checkResult];
    }
}

- (void)checkResult {
    BOOL showMember = NO;
    if (self.member && self.content) {
        //完成
        if (self.delegate && [self.delegate respondsToSelector:@selector(intentSendIMMsg:content:)]) {
            [self.delegate intentSendIMMsg:self.member content:self.content];
        }
    }
    else if (!self.member) {
       //提示选人
        [self clarifyText: @"好的,你想发给谁?"];
        showMember = YES;
    }
    else {
        //提示消内容
        [self clarifyText: @"好的,你想说什么?"];
    }
    [self needShowMember:showMember];
}

- (void)clarifyText:(NSString *)text {
    if (self.delegate && [self.delegate respondsToSelector:@selector(intentSendIMMsgClarifyText:)]) {
        [self.delegate intentSendIMMsgClarifyText:text];
    }
}

- (void)clarifyMembers:(XZOptionMemberParam *)param {
    if (self.delegate && [self.delegate respondsToSelector:@selector(intentSendIMMsgClarifyMembers:)]) {
        [self.delegate intentSendIMMsgClarifyMembers:param];
    }
}

- (void)needShowMember:(BOOL)show {
    if (self.delegate && [self.delegate respondsToSelector:@selector(intentSendIMMsgShowMember:)]) {
        [self.delegate intentSendIMMsgShowMember:show];
    }
}

- (BOOL)useUnit {
    if (!self.member) {
        return NO;
    }
    if (!self.content) {
        return NO;
    }
    return YES;
}

- (void)handleText:(NSString *)text {
    if ([NSString isNull:text]) {
        return;
    }
    if (!self.member) {
        [self handleMemberName:text];
    }
    else if (!self.content) {
        self.content = text;
        [self checkResult];
    }
}

- (void)handleSearchMemberResult:(NSArray *)result memberName:(NSString *)name {
    if (result.count == 0) {
        NSString *speak = @"我没找到这个人, 请重新说要发信息给谁？";
        [self clarifyText: speak];
        [self needShowMember:YES];
    }
    else if (result.count == 1) {
        self.member = [result firstObject];
        [self checkResult];
    }
    else {
        NSString *speak = [NSString stringWithFormat:@"第几位%@？", name];
        XZOptionMemberParam *param = [[XZOptionMemberParam alloc] init];
        param.speakContent = speak;
        param.showContent = speak;
        param.members = result;
        [self clarifyMembers:param];
    }
}

- (void)handleMemberName:(NSString *)name {
    __weak typeof(self) weakSelf = self;
    if ([XZCore sharedInstance].isM3ServerIsLater8) {
        [XZPinyinTool obtainMembersWithNameArray:@[name] memberType:XZSearchMemberType_Contact_BUnit complete:^(NSArray* memberArray, NSArray *defSelectArray) {
            [weakSelf handleSearchMemberResult:memberArray memberName:name];
        }];
        return;
    }

    [XZMainProjectBridge memberListForPinYin:name completion:^(NSArray *result) {
        [weakSelf handleSearchMemberResult:result memberName:name];
    }];
}

@end
