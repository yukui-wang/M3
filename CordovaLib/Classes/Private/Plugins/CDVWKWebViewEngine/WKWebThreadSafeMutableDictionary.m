//
//  WKWebThreadSafeMutableDictionary.m
//  CordovaLib
//
//  Created by wujiansheng on 2020/7/9.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "WKWebThreadSafeMutableDictionary.h"

@interface WKWebThreadSafeMutableDictionary () 
@property (assign, nonatomic) CFMutableDictionaryRef dictionary;
@property (assign, nonatomic) dispatch_queue_t syncQueue;
@end

@implementation WKWebThreadSafeMutableDictionary

- (id)init {
    self = [super init];
    if (self) {
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, numItems, &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (id)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
    self = [self init];
    if (self) {
        for (NSInteger idx = 0; idx < cnt; idx++) {
            CFDictionaryAddValue(_dictionary, (__bridge const void *)(keys[idx]),
                                 (__bridge const void *)(objects[idx]));
        }
    }
    return self;
}

- (void)dealloc {
    if (_dictionary) {
        CFRelease(_dictionary);
        _dictionary = NULL;
    }
}

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(self.syncQueue, ^{
        count = CFDictionaryGetCount(self.dictionary);
    });
    return count;
}

- (id)objectForKey:(id)aKey {
    if (!aKey) {
        return nil;
    }
    __block id result = nil;
    dispatch_sync(self.syncQueue, ^{
        result = CFDictionaryGetValue(self.dictionary, (__bridge const void *)(aKey));
    });
    return result;
}

- (NSEnumerator *)keyEnumerator {
    __block id result = nil;
    dispatch_sync(self.syncQueue, ^{
        result = [(__bridge id)self.dictionary keyEnumerator];
    });
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject || !aKey)
        return;
    dispatch_barrier_sync(self.syncQueue, ^{
        CFDictionarySetValue(self.dictionary, (__bridge const void *)aKey, (__bridge const void *)anObject);
    });
}

- (void)removeObjectForKey:(id)aKey {
    if (!aKey)
        return;
    dispatch_barrier_sync(self.syncQueue, ^{
        CFDictionaryRemoveValue(self.dictionary, (__bridge const void *)aKey);
    });
}

#pragma mark Optional

- (void)removeAllObjects {
    dispatch_barrier_sync(self.syncQueue, ^{
        CFDictionaryRemoveAllValues(self.dictionary);
    });
}

#pragma mark - Private

- (dispatch_queue_t)syncQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.seeyon.WKWebThreadSafeMutableDictionary", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

@end
