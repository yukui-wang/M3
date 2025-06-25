//
//  CMPLoginAccountModel.m
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPLoginAccountModel.h"
#import "NSString+CMPString.h"
#import <CMPLib/NSObject+YYModel.h>

@implementation CMPLoginAccountModel

- (NSString *)pushConfig {
    if (!_pushConfig) {
        _pushConfig = @"";
    }
    return _pushConfig;
}

- (CMPLoginAccountModelLoginType)loginType {
    if ([NSString isNull:self.extend4]) {
        return CMPLoginAccountModelLoginTypeLegacy;
    }
    return [self.extend4 integerValue];
}

- (NSString *)extend10 {
    if (!_extend10) {
        _extend10 = [[[CMPLoginAccountExtraDataModel alloc] init] yy_modelToJSONString];
    }
    return _extend10;
}

- (CMPLoginAccountExtraDataModel *)extraDataModel {
    return [CMPLoginAccountExtraDataModel yy_modelWithJSON:self.extend10];
}

@end


@implementation CMPLoginAccountExtraDataModel


@end
