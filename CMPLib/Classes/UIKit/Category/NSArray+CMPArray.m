//
//  NSArray+CMPArray.m
//  CMPLib
//
//  Created by Harllan on 2019/9/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "NSArray+CMPArray.h"

@implementation NSArray (CMPArray)

- (instancetype)cmp_convertArrar {
    if (!self || self.count == 0) {
        return self;
    }
    
    NSMutableArray *convertedArr = [NSMutableArray array];
    
    for (NSInteger i = self.count - 1; i >= 0; i--) {
        [convertedArr addObject:self[i]];
    }
    
    if ([self isMemberOfClass: NSClassFromString(@"__NSArrayM")]) {
        return [NSArray arrayWithArray:convertedArr];
    }
    return convertedArr;
}

@end
