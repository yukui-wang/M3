//
//  XZObtainOptionStep.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/24.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZObtainOptionStep.h"
@interface XZObtainOptionStep ()
@property(nonatomic, strong)NSString *tempValue;
@property(nonatomic, strong)NSString *value;

@end

@implementation XZObtainOptionStep

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super initWithDic:dic]) {
        NSDictionary *optionConfig = [SPTools dicValue:dic forKey:@"obtainConfig"];
        self.obtainConfig = [[XZObtainOptionConfig alloc] initWithDic:optionConfig];
    }
    return self;
}

- (void)handleNativeResult:(NSString *)result complete:(void(^)(void))complete {
    if ([self.slot isEqualToString:kBUnit_Key_Title]) {
        //干掉标题开头和结尾的"的"
        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"的"]];
    }
    self.tempValue = result;
    self.displayValue = self.tempValue;
}

- (void)handleUnitResult:(NSArray *)result complete:(void(^)(void))complete {
    [self handleNativeResult: [result firstObject] complete:complete];
}

- (id)normalizedValue {
    return self.value;
}
- (BOOL)canNext {
    if (self.normalizedValue) {
        return YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(obtainOptionConfigParam)]) {
        NSDictionary *dic = [self.delegate obtainOptionConfigParam];
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (XZObtainOptionConfigParam *param in self.obtainConfig.obtainParams) {
            id obj = dic[param.key];
            if ([param.key isEqualToString:self.key]) {
                obj = self.tempValue;
            }
            if (obj) {
                [temp setObject:obj forKey:param.key];
            }
            else if (param.required) {
                //参数不全，还需询问
                return NO;
            }
        }
        [temp addEntriesFromDictionary:self.obtainConfig.obtainExtData];
        if ([self.delegate respondsToSelector:@selector(needRequestObtainOption:param:intentStep:)]) {
            [self.delegate needRequestObtainOption:self.obtainConfig param:temp intentStep:self];
            self.guideWord = @"";
        }
    }
    return NO;
}

- (BOOL)canNextForCreate {
    return [self canNext];
}

- (void)handleOptionValue:(NSDictionary *)params {
    self.value = params[self.key];
    self.displayValue = self.value;
}


- (void)handleNormalizedValue:(id)value {
    self.value = value;
    self.displayValue = self.value;
}
- (void)handleTempValue {
    [self handleNormalizedValue:self.tempValue];
}
@end
