//
//  NSBundle+SOLocalization.m
//  Meeting
//
//  Created by mac-xtzx on 2019/5/30.
//  Copyright © 2019 iPEBG. All rights reserved.
//

#import "NSBundle+SOLocalization.h"
#import "SOLocalization.h"
#import "SOSwizzle.h"

@interface NSBundle (MJRefresh)

+ (instancetype)mj_refreshBundle;
+ (NSString *)mj_localizedStringForKey:(NSString *)key value:(NSString *)value;

@end

@implementation NSBundle (SOLocalization)

+ (void)load {
    SOSwizzleClassMethod([NSBundle class], @selector(mj_localizedStringForKey:value:), @selector(sol_localizedStringForKey:value:));
    SOSwizzleInstanceMethod([NSBundle class], @selector(localizedStringForKey:value:table:), @selector(cmp_sol_localizedStringForKey:value:table:));
}
    
+ (NSString *)sol_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    // 根据当前设置的语言获取对应的MJBundle
//    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mj_refreshBundle] pathForResource:[SOLocalization sharedLocalization].region ofType:@"lproj"]];
//    value = [bundle cmp_sol_localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

- (NSString *)cmp_sol_localizedStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)tableName {
    return  [[SOLocalization sharedLocalization] localizedStringForKey:key value:value inTable:tableName bundle:self];
}

@end
