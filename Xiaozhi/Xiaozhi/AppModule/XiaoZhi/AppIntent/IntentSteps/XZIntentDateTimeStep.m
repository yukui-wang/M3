//
//  XZIntentDateTimeStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentDateTimeStep.h"
#import "XZDateUtils.h"

@interface XZIntentDateTimeStep()

@property(nonatomic,strong)NSString *value;
@property(nonatomic,strong)NSString *defaultValue;

@end
@implementation XZIntentDateTimeStep

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.defaultValue = [SPTools stringValue:dic forKey:@"defaultValue"];
       
    }
    return self;
}

- (void)handleOriginalValue:(NSString *)aVaule {
    NSString *dateTimeStr = [XZDateUtils obtainFormatDateTime:aVaule hasTime:YES interval:self.isSearchStep];
    if ([NSString isNull:dateTimeStr]) {
        return;
    }
    if ([dateTimeStr rangeOfString:@"#"].location != NSNotFound) {
        NSArray *array = [dateTimeStr componentsSeparatedByString:@"#"];
        if (!self.currentLoc ||[self.currentLoc isEqualToString:@"1"]) {
            self.value = array[0];
            self.pairValue = array[1];
        }
        else {
            self.value = array[1];
            self.pairValue = array[0];
        }
    }
    else {
        if ([self isAllDay:aVaule] && [dateTimeStr rangeOfString:@" 00:00"].location != NSNotFound) {
            //整天 添加23:59
            dateTimeStr = [dateTimeStr replaceCharacter:@"00:00" withString:@"23:59"];
        }
        self.value = dateTimeStr;
    }
}
- (BOOL)isAllDay:(NSString *)aVaule {
    if ([aVaule containsString:@"点"]||
        [aVaule containsString:@"时"]) {
        //时间工具已处理，不在处理了
        return NO;
    }
    if ([self.currentLoc isEqualToString:@"2"] ) {
        return YES;
    }
    return NO;
}


- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    [self handleOriginalValue:result];
    
    self.displayValue = [XZDateUtils localDateString:self.value hasTime:YES];
    if (complete) {
        complete();
    }
}

- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete {
    if (result && result.count >0) {
        NSString *timeStr = result.firstObject;
        if (result.count >1) {
            timeStr = [NSString stringWithFormat:@"%@到%@",timeStr,result.lastObject];
            [self handleNativeResult:timeStr complete:complete];
        }
        else {
            [self handleNativeResult:timeStr complete:complete];
        }
    }
}


- (void)handlePairValue:(NSString *)pairVaule {
    if (!self.value) {
        self.value = pairVaule;
        self.displayValue = [XZDateUtils localDateString:self.value hasTime:YES];
    }
}


- (NSString *)stringValue {
    return self.value;
}

- (id)normalizedValue {
    return self.value;
}

- (id)normalizeDefauleValue {
    if (!self.value && ![NSString isNull:self.defaultValue]) {
        [self handleOriginalValue:self.defaultValue];
    }
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
    long long result = [XZDateUtils timestampFormDate:self.value dateFormat:kDateFormate_YYYY_MM_DD_HHMM];
    return result;
}
- (void)handleNormalizedValue:(id)value {
    [self handlePairValue:value];
}

@end
