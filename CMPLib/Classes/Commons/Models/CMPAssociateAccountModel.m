//
//  CMPAssociateAccountModel.m
//  M3
//
//  Created by CRMO on 2018/6/13.
//

#import "CMPAssociateAccountModel.h"

@implementation CMPAssociateAccountModel

+ (NSString *)generateGroupID {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSString *groupID = [NSString stringWithFormat:@"%lu", (unsigned long)now];
    return groupID;
}

@end
