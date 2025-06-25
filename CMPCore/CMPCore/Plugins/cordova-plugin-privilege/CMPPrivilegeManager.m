//
//  CMPPrivilegeManager.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import "CMPPrivilegeManager.h"
#import "CMPLocalDataPlugin.h"

#define kIdentifierName_CMPPrivilege @"kIdentifierName_CMPPrivilege"

@implementation CMPPrivilegeManager

+ (CMPPrivilege *)getCurrentUserPrivilege
{
    NSData *data = [CMPLocalDataPlugin readDataWithIdentifier:kIdentifierName_CMPPrivilege isGlobal:NO];
    if (data) {
        CMPPrivilege *config = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return config;
    }
    return [[[CMPPrivilege alloc]init]autorelease];
}

+ (void)setCurrentUserPrivilegeWithConfig:(CMPPrivilege *)config
{
    if (config) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:config];
        [CMPLocalDataPlugin writeDataWithIdentifier:kIdentifierName_CMPPrivilege data:data isGlobal:NO];
        
    }else{
        NSLog(@"CMPPrivilegePlugin...config参数不存在");
    }
}

@end
