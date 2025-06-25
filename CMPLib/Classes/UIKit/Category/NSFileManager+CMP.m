//
//  NSFileManager+CMP.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/24.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "NSFileManager+CMP.h"
#import "SOSwizzle.h"

@implementation NSFileManager (CMP)

+ (void)load {
//    SOSwizzleInstanceMethod([self class], @selector(removeItemAtPath:error:), @selector(cmp_removeItemAtPath:error:));
}

-(BOOL)cmp_removeItemAtPath:(NSString *)path error:(NSError **)error
{
    NSLog(@"ks log --- %s -- path : %@",__FUNCTION__,path);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [self cmp_removeItemAtPath:path error:error];
    }
    return YES;
}

@end
