//
//  XZIntentTimestampStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentTimestampStep.h"

@interface XZIntentTimestampStep()

@property(nonatomic,strong)NSString *value;
@property(nonatomic,strong)NSString *defaultValue;
@property(nonatomic,strong)NSString *errorMsg;


@end

@implementation XZIntentTimestampStep

- (NSString *)guideWord {
    if (self.errorMsg) {
        return self.errorMsg;
    }
    return _guideWord;
}
- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.defaultValue = [SPTools stringValue:dic forKey:@"defaultValue"];
    }
    return self;
}

- (void)handleOriginalValue:(NSString *)aVaule {
    self.errorMsg = nil;
    NSString *timestamp =  [XZDateUtils obtainTimestamp:aVaule hasTime:YES interval:self.isSearchStep];
    if ([NSString isNull:timestamp]) {
        return;
    }
    if ([timestamp rangeOfString:@"#"].location != NSNotFound) {
        NSArray *array = [timestamp componentsSeparatedByString:@"#"];
        if (!self.currentLoc ||[self.currentLoc isEqualToString:@"1"]) {
            self.value = array[0];
            self.pairValue = array[1];
        }
        else {
            self.value = array[1];
            self.pairValue = array[0];
        }
        self.displayValue = [XZDateUtils dateStrFormTimestamp:self.value.longLongValue dateFormat:kDateFormate_YYYY_MM_DD_HHMM];
    }
    else {
        self.value = timestamp;
        self.displayValue = [XZDateUtils dateStrFormTimestamp:self.value.longLongValue dateFormat:kDateFormate_YYYY_MM_DD_HHMM];
        if ([self isAllDay:aVaule]) {
            //整天 添加23:59
            self.displayValue = [self.displayValue replaceCharacter:@"00:00" withString:@"23:59"];
            long long  t = [timestamp longLongValue];
            t += (24*3600-1)*1000;
            self.value = [NSString stringWithLongLong:t];
        }
        //OA-196384【小致】申请会议室时，分开输入的时间段为“明天九点”和“今天十点”，最后也能够申请成功
        if ([self.currentLoc isEqualToString:@"2"] && self.delegate && [self.delegate respondsToSelector:@selector(pairStepForKey:)]) {
            //交换时间 结束时间早于开始时间
            XZIntentTimestampStep *beginStep = [self.delegate pairStepForKey:self.pairKey];
            long long valueNum = self.value.longLongValue;
            if (valueNum >0 && valueNum <= beginStep.value.longLongValue) {
                self.errorMsg = [NSString stringWithFormat:@"%@必须大于%@，请继续录入",self.displayName,beginStep.displayName];
                self.value = nil;
                self.displayValue = nil;
                return;
            }
        }
    }
    //格式化时间显示
    self.displayValue = [XZDateUtils localDateString:self.displayValue hasTime:YES];
}

- (BOOL)isAllDay:(NSString *)aVaule {
    if ([aVaule containsString:@"点"]||
        [aVaule containsString:@"时"]) {
         //时间工具已处理，不在处理了
        return NO;
    }
    if ([self.currentLoc isEqualToString:@"2"] && [self.displayValue rangeOfString:@"00:00"].location != NSNotFound) {
        return YES;
    }
     return NO;
}


- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    [self handleOriginalValue:result];
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
        self.displayValue = [XZDateUtils dateStrFormTimestamp:self.value.longLongValue dateFormat:kDateFormate_YYYY_MM_DD_HHMM];
        //格式化时间显示
        self.displayValue = [XZDateUtils localDateString:self.displayValue hasTime:YES];
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
    return self.value.longLongValue;
}

- (void)handleNormalizedValue:(id)value {
    [self handlePairValue:value];
}
@end
