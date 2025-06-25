//
//  CMPContactsResult.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/14.
//
//

#import "CMPContactsResult.h"

@implementation CMPContactsResult

-(void)dealloc
{
    SY_RELEASE_SAFELY(_keyList)
    SY_RELEASE_SAFELY(_dataDic)
    SY_RELEASE_SAFELY(_allMemberList)
    [super dealloc];
}
@end
