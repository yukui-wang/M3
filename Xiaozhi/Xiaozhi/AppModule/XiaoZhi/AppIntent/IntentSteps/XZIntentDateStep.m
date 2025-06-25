//
//  XZIntentDateStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZIntentDateStep.h"
#import "XZDateUtils.h"

@interface XZIntentDateStep()

@property(nonatomic,strong)NSString *value;
@property(nonatomic,strong)NSString *defaultValue;

@end

@implementation XZIntentDateStep

- (id)initWithDic:(NSDictionary *)dic {
    
    if (self = [super initWithDic:dic]) {
        self.defaultValue = [SPTools stringValue:dic forKey:@"defaultValue"];
    }
    return self;
}

- (void)handleOriginalValue:(NSString *)aVaule {
    NSString *dateStr = [XZDateUtils obtainFormatDateTime:aVaule hasTime:NO interval:self.isSearchStep];
    if ([NSString isNull:dateStr]) {
        return;
    }
    if ([dateStr rangeOfString:@"#"].location != NSNotFound) {
        NSArray *array = [dateStr componentsSeparatedByString:@"#"];
        NSString *date0 = array[0];
        if (date0.length > 10) {
            date0 = [date0 substringToIndex:10];
        }
        NSString *date1 = array[1];
        if (date1.length > 10) {
            date1 = [date1 substringToIndex:10];
        }
        if (!self.currentLoc ||[self.currentLoc isEqualToString:@"1"]) {
            self.value = date0;
            self.pairValue = date1;
        }
        else {
            self.value = date1;
            self.pairValue = date0;
        }
    }
    else {
        self.value = dateStr.length > 10 ? [dateStr substringToIndex:10]: dateStr;
    }
}

- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    [self handleOriginalValue:result];
    self.displayValue = [XZDateUtils localDateString:self.value hasTime:NO];
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
        self.displayValue = [XZDateUtils localDateString:self.value hasTime:NO];
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
    return self.value?YES:NO;
}

- (long long)numberValue {
    long long result = [XZDateUtils timestampFormDate:self.value dateFormat:kDateFormate_YYYY_MM_DD];
    return result;
}

- (void)handleNormalizedValue:(id)value {
    [self handlePairValue:value];
}
@end
