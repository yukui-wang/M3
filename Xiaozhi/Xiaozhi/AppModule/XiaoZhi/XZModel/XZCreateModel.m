//
//  XZCreateModel.m
//  M3
//
//  Created by wujiansheng on 2018/8/8.
//

#import "XZCreateModel.h"

@implementation XZCreateModel

- (void)dealloc {
    self.subject = nil;
    self.content = nil;
}

- (NSString *)submitUrl {
    return @"";
}

- (NSString *)showUrl {
    return @"";
}

- (NSDictionary *)requestParam {
    return nil;
}

- (NSDictionary *)speechInput {
    return nil;
}

- (id)initWithJsonFile:(NSDictionary *)dic {
    if (self = [super init]) {
    }
    return self;
}

- (void)setupWithUnitResult:(BUnitResult *)dic {
    
}

- (void)setSpeechString:(NSString *)str {
    
}

- (void)setSpeechMembers:(NSArray *)members {
    
}

@end
