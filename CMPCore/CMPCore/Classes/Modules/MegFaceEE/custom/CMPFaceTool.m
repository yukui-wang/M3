//
//  CMPFaceTool.m
//  M3
//
//  Created by Shoujian Rao on 2023/11/27.
//

#import "CMPFaceTool.h"

@implementation CMPFaceTool

+ (NSString *)stringValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *value = dic[key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    return nil;
}


+ (CGFloat)floatValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0.0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(floatValue)]) {
        CGFloat f = [value floatValue];
        return f;
    }
    return 0.0;
}

+ (NSInteger)integerValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

+ (long long)longLongValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(longLongValue)]) {
        return [value longLongValue];
    }
    return 0.0;
}

+ (NSDictionary *)dicValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *value = dic[key];
    if (value && [value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

+ (NSArray *)arrayValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *value = dic[key];
    if (value && [value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

+ (BOOL)boolValue:(NSDictionary *)dic forKey:(NSString *)key {
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSString *value = dic[key];
    if (value && [value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}
@end
