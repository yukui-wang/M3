//
//  EGOImageLoadConnection.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 12/1/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RCloudImageLoadConnection.h"
#import "RCDownloadHelper.h"
#import <RongIMLib/RCStatusDefine.h>

@implementation RCloudImageLoadConnection
@synthesize imageURL = _imageURL, response = _response, delegate = _delegate, timeoutInterval = _timeoutInterval;

#if __EGOIL_USE_BLOCKS
@synthesize handlers;
#endif

- (instancetype)initWithImageURL:(NSURL *)aURL delegate:(id)delegate {
    if ((self = [super init])) {
        _imageURL = aURL;
        self.delegate = delegate;
        _responseData = [[NSMutableData alloc] init];
        self.timeoutInterval = 30;

#if __EGOIL_USE_BLOCKS
        handlers = [[NSMutableDictionary alloc] init];
#endif
    }

    return self;
}

- (void)start {
    RCDownloadHelper *downloadHelper = [RCDownloadHelper new];
    [downloadHelper getDownloadFileToken:MediaType_IMAGE
                           completeBlock:^(NSString *_Nonnull token) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self startDownload:token];
                               });
                           }];
}

- (void)startDownload:(NSString *)token {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:self.timeoutInterval];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"authorization"];
    }
    request.timeoutInterval = 10;
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)cancel {
    [_connection cancel];
}

- (NSData *)responseData {
    return _responseData;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection != _connection)
        return;
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection != _connection)
        return;
    self.response = response;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection != _connection)
        return;

    if ([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]) {
        [self.delegate imageLoadConnectionDidFinishLoading:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection != _connection)
        return;

    if ([self.delegate respondsToSelector:@selector(imageLoadConnection:didFailWithError:)]) {
        [self.delegate imageLoadConnection:self didFailWithError:error];
    }
}

- (BOOL)connection:(NSURLConnection *)connection
    canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {

    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
         forAuthenticationChallenge:challenge];
}

- (void)dealloc {
    self.response = nil;
    self.delegate = nil;

#if __EGOIL_USE_BLOCKS
    [handlers release], handlers = nil;
#endif

#if !__has_feature(objc_arc)
    [_connection release];
    [_imageURL release];
    [_responseData release];
    _connection = nil;
    _imageURL = nil;
    _responseData = nil;
    [super dealloc];
#else
    _connection = nil;
    _imageURL = nil;
    _responseData = nil;
#endif
}

@end
