//
//  XZIntentMultiMemberStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentMultiMemberStep.h"
@interface XZIntentMultiMemberStep()
@property(nonatomic,strong)NSMutableArray *value;
@property(nonatomic,strong)NSMutableArray *memberIdArray;//去重

@end

@implementation XZIntentMultiMemberStep

- (NSString *)guideWord {
    if (self.errorMsg) {
        return self.errorMsg;
    }
    if (_value.count > 0) {
        return kIntentChoosedPersonMsg;
    }
    return _guideWord;
}

- (NSMutableArray *)value {
    if (!_value) {
        _value = [[NSMutableArray alloc] init];
    }
    return _value;
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
    for (CMPOfflineContactMember *member in array) {
        if (![self.memberIdArray containsObject:member.orgID]) {
            [self.memberIdArray addObject:member.orgID];
            [self.value addObject:[self memberToDictionary:member]];
            NSString *temp = self.displayValue = self.displayValue.length > 0 ?[NSString stringWithFormat:@"%@,",self.displayValue]:@"";
            self.displayValue = [NSString stringWithFormat:@"%@%@",temp,member.name];
        }
    }
    self.tempValue = nil;
    self.errorMsg = nil;
    self.skip = NO;
}

- (NSString *)stringValue {
    return [SPTools dictionaryToJson:(NSDictionary *)self.value] ;
}

- (id)normalizedValue {
    if (self.value.count >0) {
        return self.value;
    }
    return nil;
}

- (BOOL)canNext {
    if (self.required && self.value.count > 0 && self.skip) {
        return YES;
    }
    if (!self.required) {
        return YES;
    }
    return NO;
}

- (BOOL)canNextForCreate {
    if (self.required && self.value.count > 0  && self.skip ) {
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

//    if (self.value.count > 0 || self.tempValue) {
//        return NO;
//    }
//    return YES;
}


@end
