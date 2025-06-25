//
//  XZIntentMultiMemberIdStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentMultiMemberIdStep.h"

@interface XZIntentMultiMemberIdStep()

@property(nonatomic,strong)NSString *value;
@property(nonatomic,strong)NSMutableArray *memberIdArray;//去重

@end

@implementation XZIntentMultiMemberIdStep

- (NSString *)guideWord {
    if (self.errorMsg) {
        return self.errorMsg;
    }
    if (_value) {
        return kIntentChoosedPersonMsg;
    }
    return _guideWord;
}

- (NSMutableArray *)memberIdArray {
    if (!_memberIdArray) {
        _memberIdArray = [[NSMutableArray alloc] init];
    }
    return _memberIdArray;
}

- (NSString *)errorMsgWithName:(NSString *)name {
    return kIntentChoosePersonMutErrorMsg;
}

- (void)handleMembers:(NSArray *)array {
    CMPOfflineContactMember *member = [array firstObject];
    if (!self.originalValue) {
        self.originalValue = [SPTools memberNameWithName:member.name];
    }
    NSString *normalized = self.value? (NSString *)self.value:@"";
    for (CMPOfflineContactMember *member in array) {
        if (![self.memberIdArray containsObject:member.orgID]) {
            [self.memberIdArray addObject:member.orgID];
            normalized = normalized.length > 0 ?[NSString stringWithFormat:@"%@,",normalized]:@"";
            normalized = [NSString stringWithFormat:@"%@%@",normalized,[self memberToIdStr:member]];
            NSString *temp = self.displayValue = self.displayValue.length > 0 ?[NSString stringWithFormat:@"%@,",self.displayValue]:@"";
            self.displayValue = [NSString stringWithFormat:@"%@%@",temp,member.name];
        }
    }
    self.value = normalized;
    self.tempValue = nil;
    self.errorMsg = nil;
    self.skip = NO;
}

- (NSString *)stringValue {
    return self.value;
}

- (id)normalizedValue {
    return self.value;
}


- (BOOL)canNext {
    if (self.required && self.value.length > 0 && self.skip) {
        return YES;
    }
    if (!self.required) {
        return YES;
    }
    return NO;
}

- (BOOL)canNextForCreate {
    if (self.required && self.value.length > 0  && self.skip ) {
        return YES;
    }
    if (!self.required  && self.skip ) {
        return YES;
    }
    return NO;
}

- (BOOL)isMultiSelectMember {
    return YES;
}

- (BOOL)useUnit {
    return NO;
//
//    if (self.value || self.tempValue) {
//        return NO;
//    }
//    return YES;
}

@end
