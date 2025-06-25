//
//  OfflineRelationship.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "OfflineRelationship.h"

@implementation OfflineRelationship
- (void)dealloc
{
    SY_RELEASE_SAFELY(_m)
    [super dealloc];
}
@end
