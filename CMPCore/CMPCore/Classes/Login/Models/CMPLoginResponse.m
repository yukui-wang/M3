//
//  CMPLoginModel.m
//  M3
//
//  Created by CRMO on 2017/11/3.
//

#import "CMPLoginResponse.h"

@implementation CMPLoginResponse

- (BOOL)requestSuccess {
    if ([self.code isEqualToString:@"200"] || [self.code isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}

@end

#pragma mark - data -

@implementation CMPLoginData

@end

#pragma mark - currentMember -

@implementation CMPLoginResponseCurrentMember

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @"id"};
}

@end

#pragma mark - config -

@implementation CMPLoginResponseConfig

@end
