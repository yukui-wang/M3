//
//  CMPPrivilegeManager.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/28.
//
//

#import <Foundation/Foundation.h>
#import "CMPPrivilege.h"

@interface CMPPrivilegeManager : NSObject

+(CMPPrivilege *)getCurrentUserPrivilege;
+(void)setCurrentUserPrivilegeWithConfig:(CMPPrivilege *)config;

@end
