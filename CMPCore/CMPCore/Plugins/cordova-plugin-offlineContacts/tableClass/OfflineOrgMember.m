//
//  OfflineOrgMember.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "OfflineOrgMember.h"

@implementation OfflineOrgMember
- (void)dealloc
{
    SY_RELEASE_SAFELY(_workScope)
    [super dealloc];
}
@end
