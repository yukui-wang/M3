//
//  XZIntentNumberStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentNumberStep.h"

@interface XZIntentNumberStep()

@property(nonatomic,strong)NSString *value;

@end

@implementation XZIntentNumberStep

- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    self.value = [XZDateUtils convertChineseNumberToArabicNumber:result];
    self.displayValue = self.value;
    if (complete) {
        complete();
    }
}

- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete {
    self.value = [result firstObject];//直接用百度返回即可OA-185288 【小致】查询统计报表数据筛选问题
    self.displayValue = self.value;
    if (complete) {
        complete();
    }
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

- (long long)numberValue {
    return self.value.longLongValue;
}

- (void)handleNormalizedValue:(id)value {
    self.value = value;
    self.displayValue = self.value;
}

@end
