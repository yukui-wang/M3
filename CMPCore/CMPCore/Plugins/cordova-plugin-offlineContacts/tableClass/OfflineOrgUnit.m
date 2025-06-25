//
//  OfflineOrgUnit.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "OfflineOrgUnit.h"

@implementation OfflineOrgUnit
- (void)dealloc
{
    SY_RELEASE_SAFELY(_pa)
    [super dealloc];
}
@end
