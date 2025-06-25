//
//  CMPBaseRequest.m
//  M3
//
//  Created by CRMO on 2017/11/20.
//

#import "CMPBaseRequest.h"

NSString * const kCMPRequestMethodPost = @"POST";
NSString * const kCMPRequestMethodGet = @"GET";

@implementation CMPBaseRequest

- (NSString *)requestUrl {
    return nil;
}

- (NSString *)requestMethod {
    return kCMPRequestMethodGet;
}

- (NSInteger)requestType {
    return kDataRequestType_Url;
}

- (BOOL)handleCookie {
    return YES;
}

@end
