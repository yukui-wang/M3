//
//  RCNaviThread+Cer.m
//  SealTalk
//
//  Created by Sin on 2019/9/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCNaviThread+Cer.h"

@implementation RCNaviThread (Cer)
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //信任自签证书
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}
@end
