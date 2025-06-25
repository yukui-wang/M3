//
//  NSUserDefaults+CMP.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/24.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "NSUserDefaults+CMP.h"
#import "SOSwizzle.h"

@implementation NSUserDefaults (CMP)

+ (void)load {
//    SOSwizzleInstanceMethod([self class], @selector(removeObjectForKey:), @selector(cmp_removeObjectForKey:));
//    SOSwizzleInstanceMethod([self class], @selector(resetStandardUserDefaults), @selector(cmp_resetStandardUserDefaults));
}

-(void)cmp_removeObjectForKey:(NSString *)defaultName
{
    NSLog(@"ks log --- %s -- defaultName : %@",__FUNCTION__,defaultName);
    return [self cmp_removeObjectForKey:defaultName];
}

+(void)cmp_resetStandardUserDefaults
{
    NSLog(@"ks log --- %s",__FUNCTION__);
    return [self cmp_resetStandardUserDefaults];
}

@end
