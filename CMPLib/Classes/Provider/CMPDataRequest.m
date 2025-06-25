//
//  MDataRequest.m
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPDataRequest.h"

@implementation CMPDataRequest

- (void)dealloc
{
    _delegate = nil;
    [_requestID release];
    _requestID = nil;
    [_requestParam release];
    _requestParam = nil;
    [_requestUrl release];
    _requestUrl = nil;
    
    [_userInfo release];
    _userInfo = nil;
    [_downloadDestinationPath release];
    _downloadDestinationPath = nil;
    
    [_uploadFilePath release];
    _uploadFilePath = nil;
    
    [_requestCookies release];
    _requestCookies = nil;
    
    [_requestMethod release];
    _requestMethod = nil;
    
    [_headers release];
    _headers = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestID = [[NSString uuid] copy];
        _httpShouldHandleCookies = YES;
    }
    return self;
}

- (id)initWithRequestID:(NSString *)aRequestID
{
    self = [super init];
    if (self) {
        if ([NSString isNotNull:aRequestID]){
            _requestID = [aRequestID copy];
        }
        else {
            _requestID = [[NSString uuid] copy];
        }
        _httpShouldHandleCookies = YES;
    }
    return self;
}

@end
