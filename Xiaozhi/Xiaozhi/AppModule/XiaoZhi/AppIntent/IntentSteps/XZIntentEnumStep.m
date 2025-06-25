//
//  XZIntentEnumStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentEnumStep.h"

@interface XZIntentEnumStep()
@property(nonatomic, strong)NSDictionary *slotEnum;
@property(nonatomic, strong)NSString *customSlotDict;
@property(nonatomic, strong)NSString *value;
@end

@implementation XZIntentEnumStep

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.slotEnum = [SPTools dicValue:dic forKey:@"slotEnum"];
        self.customSlotDict = [SPTools stringValue:dic forKey:@"customSlotDict"];
    }
    return self;
}
- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    if ([self.slotEnum.allKeys containsObject:result]) {
        self.value = self.slotEnum[result];
    }
    else if ([self.slotEnum.allValues containsObject:result]) {
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

- (void)handleNormalizedValue:(id)value {
    self.value = value;
    self.displayValue = self.value;
}
@end
