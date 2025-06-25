//
//  MAccountAvailableEntity.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/11.
//
//

#import "MAccountAvailableEntity.h"
#import <CMPLib/JSON.h>

@implementation MAccountAvailableEntity
- (void)dealloc
{
    SY_RELEASE_SAFELY(_md5);
    SY_RELEASE_SAFELY(_setting);
    [super dealloc];
}

- (void)setSetting:(MAccountSetting *)setting{
    [_setting release];
    if ([setting isKindOfClass:[NSDictionary class]]) {
        _setting = [[MAccountSetting alloc] initWithDictionaryRepresentation:(NSDictionary *)setting];
    }
    else {
        _setting = [setting retain];
    }
}
@end
