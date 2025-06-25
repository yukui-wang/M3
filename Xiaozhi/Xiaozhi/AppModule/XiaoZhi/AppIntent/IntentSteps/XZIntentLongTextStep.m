//
//  XZIntentLongTextStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#define kLongTextEnd @"好了小致"

#import "XZIntentLongTextStep.h"


@interface XZIntentLongTextStep()

@property(nonatomic,strong)NSString *value;
@property(nonatomic,assign)BOOL skip;// 直接 “好了小致”

@end

@implementation XZIntentLongTextStep


- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        self.skip = YES;
    }
    return self;
}
- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    NSString *tempStr =  result;//[NSString stringWithFormat:@"%@%@",self.value ?self.value:@"",result];
    NSString *tmpStr = [SPTools deletePunc:tempStr];
    if (tmpStr.length > 3) {
        NSString *subfixString = [tmpStr substringFromIndex:(tmpStr.length - 4)];
        if ([SPTools stringCodeCompare:subfixString withString:kLongTextEnd distence:5]) {
            self.skip = YES;
            tempStr = [SPTools getMainText:tempStr];
            if (self.limit > 0 && tempStr.length > self.limit) {
                self.value = [tempStr substringToIndex:self.limit];
            }
            else {
                self.value = tempStr;
            }
        }
        else {
            self.value = tempStr;
        }
    }
    else {
        self.value = tempStr;
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
    if (self.value  && self.skip ) {
        return YES;
    }
//    if (self.required && self.value  && self.skip ) {
//        return YES;
//    }
//    if (!self.required  && self.skip ) {
//        return YES;
//    }
    return NO;
}

- (BOOL)isLongText {
    return YES;
}

- (BOOL)useUnit {
    return NO;
}

- (void)handleNormalizedValue:(id)value {
    self.value = value;
    self.displayValue = self.value;
}
@end
