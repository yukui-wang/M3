//
//  CMPFaceTool.h
//  M3
//
//  Created by Shoujian Rao on 2023/11/27.
//

#import <Foundation/Foundation.h>


@interface CMPFaceTool : NSObject
//接口数据处理 防NSNull
+ (NSString *)stringValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (CGFloat)floatValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSInteger)integerValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (long long)longLongValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSDictionary *)dicValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (NSArray *)arrayValue:(NSDictionary *)dic forKey:(NSString *)key;
+ (BOOL)boolValue:(NSDictionary *)dic forKey:(NSString *)key;

@end

