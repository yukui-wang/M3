//
//  MAccountSetting.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "MAccountSetting.h"

@implementation MAccountSetting
- (void)dealloc
{
    SY_RELEASE_SAFELY(_viewScopeList);
    SY_RELEASE_SAFELY(_keyInfoList);
    [super dealloc];
}
@end
