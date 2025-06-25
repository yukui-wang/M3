//
//  XZIntentTextStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentTextStep.h"

@interface XZIntentTextStep()

@property(nonatomic,strong)NSString *value;

@end

@implementation XZIntentTextStep

- (void)handleNativeResult:(NSString *)resultTemp complete:(void(^)(void))complete {
    NSString *result = resultTemp;
    if ([self.slot isEqualToString:kBUnit_Key_Title]) {
        //干掉标题开头和结尾的"的"
        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"的"]];
    }
    if ([self.slot isEqualToString:kIntentSlot_Person] && [result isEqualToString:kIntentMember_Me]) {
        self.value = [[self currentUser] name];
    }
    else if (self.limit > 0 && result.length > self.limit) {
        self.value = [result substringToIndex:self.limit];
    }
    else {
        self.value = result;
    }
    self.displayValue = self.value;
    if (complete) {
        complete();
    }
}

- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete {
    [self handleNativeResult:[result firstObject] complete:complete];
}

- (void)handleMembers:(NSArray *)array {
    CMPOfflineContactMember *member = [array firstObject];
    self.value = [SPTools memberNameWithName:member.name];//todo
}

- (NSString *)stringValue {
    return self.value;
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
    return self.value ? YES : NO;
}

- (BOOL)useUnit {
    return NO;
}

- (void)handleNormalizedValue:(id)value {
    self.value = value;
    self.displayValue = self.value;
}

@end
