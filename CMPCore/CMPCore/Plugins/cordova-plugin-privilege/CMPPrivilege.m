//
//  CMPPrivilege.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import "CMPPrivilege.h"

#define kPrivilegeKey_hasColNew @"kPrivilegeKey_hasColNew"
#define kPrivilegeKey_hasAddressBook @"kPrivilegeKey_hasAddressBook"
#define kPrivilegeKey_hasIndexPlugin @"kPrivilegeKey_hasIndexPlugin"

@implementation CMPPrivilege

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.hasColNew forKey:kPrivilegeKey_hasColNew];
    [aCoder encodeBool:self.hasAddressBook forKey:kPrivilegeKey_hasAddressBook];
    [aCoder encodeBool:self.hasIndexPlugin forKey:kPrivilegeKey_hasIndexPlugin];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.hasColNew = [aDecoder decodeBoolForKey:kPrivilegeKey_hasColNew];
        self.hasAddressBook = [aDecoder decodeBoolForKey:kPrivilegeKey_hasAddressBook];
        self.hasIndexPlugin = [aDecoder decodeBoolForKey:kPrivilegeKey_hasIndexPlugin];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.hasColNew = NO;
    }
    return self;
}

@end
