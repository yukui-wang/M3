//
//  MDataResponse.m
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPDataResponse.h"

@implementation CMPDataResponse

- (void)dealloc
{
	[_responseStr release];
    _responseStr = nil;
	[_responseData release];
    _responseData = nil;
    [_downloadDestinationPath release];
    _downloadDestinationPath = nil;
    [_responseHeaders release];
    _responseHeaders = nil;
	[super dealloc];
}

@end
