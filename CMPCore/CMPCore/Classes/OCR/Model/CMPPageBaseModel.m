//
//  CMPPageBaseModel.m
//  M3
//
//  Created by Kaku Songu on 12/14/21.
//

#import "CMPPageBaseModel.h"

@implementation CMPPageBaseModel

-(instancetype)init
{
    if (self = [super init]) {
        _pageNo = 0;
        _pageSize = 30;
    }
    return self;
}

@end
