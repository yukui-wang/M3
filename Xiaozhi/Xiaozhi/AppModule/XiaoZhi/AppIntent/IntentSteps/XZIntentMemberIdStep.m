//
//  XZIntentMemberIdStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentMemberIdStep.h"
@interface XZIntentMemberIdStep()
@property(nonatomic,strong)NSString *value;
@end

@implementation XZIntentMemberIdStep

- (NSString *)guideWord {
    if (self.errorMsg) {
        return self.errorMsg;
    }
    return _guideWord;
}

- (void)handleMembers:(NSArray *)array {
    CMPOfflineContactMember *member = [array firstObject];
    if (!self.originalValue) {
        self.originalValue = [SPTools memberNameWithName:member.name];
    }
    self.value = [self memberToIdStr:member];
    self.displayValue = member.name;
    self.tempValue = nil;
    self.errorMsg = nil;
}

- (NSString *)stringValue {
    return self.value;
}

- (id)normalizedValue {
    return self.value;
}

- (BOOL)canNext {
    if (self.required && self.value.length > 0 ) {
        return YES;
    }
    if (!self.required && !self.errorMsg) {
        return YES;
    }
    return NO;
}

- (BOOL)canNextForCreate {
  
    return [self canNext];
}


@end
