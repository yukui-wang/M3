//
//  CMPFaceErrorModel.m
//  M3
//
//  Created by Shoujian Rao on 2023/10/12.
//

#import "CMPFaceErrorModel.h"

@implementation CMPFaceErrorModel

+ (CMPFaceErrorModel *)errCode:(NSInteger)errCode errMsg:(NSString *)errMsg errEnum:(NSString *)errEnum{
    CMPFaceErrorModel *err = [CMPFaceErrorModel new];
    err.errCode = errCode;
    err.errMsg = errMsg;
    err.errEnum = errEnum;
    return err;
}

+ (CMPFaceErrorModel *)errFromNSError:(NSError *)error{
    CMPFaceErrorModel *err = [CMPFaceErrorModel new];
    err.errCode = error.code;
    err.errMsg = error.description;
    err.errEnum = @"";
    return err;
}

@end
