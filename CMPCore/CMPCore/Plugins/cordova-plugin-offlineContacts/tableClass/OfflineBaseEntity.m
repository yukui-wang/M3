//
//  OfflineBaseEntity.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "OfflineBaseEntity.h"

@implementation OfflineBaseEntity
- (void)dealloc
{
    SY_RELEASE_SAFELY(_m);
    SY_RELEASE_SAFELY(_n);
    SY_RELEASE_SAFELY(_t);
    [super dealloc];
}
@end
