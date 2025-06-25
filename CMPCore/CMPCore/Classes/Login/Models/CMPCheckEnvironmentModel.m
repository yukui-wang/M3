//
//  CMPCheckEnvironmentModel.m
//  M3
//
//  Created by CRMO on 2017/11/3.
//

#import "CMPCheckEnvironmentModel.h"

@implementation CMPCheckEnvironmentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"code" : @"code",
             @"message" : @"message",
             @"serverVersion" : @"data.version",
             @"serverID" : @"data.identifier",
             @"updateServer" : @"data.updateServer"};
}

- (BOOL)requestSuccess {
    if ([self.code isEqualToString:@"200"] &&
        [self.message isEqualToString:@"success"]) {
        return YES;
    }
    return NO;
}

@end
