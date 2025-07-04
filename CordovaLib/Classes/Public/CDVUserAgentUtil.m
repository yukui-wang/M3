/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVUserAgentUtil.h"

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

// #define VerboseLog NSLog
#define VerboseLog(...) do {} while (0)

static NSString* const kCdvUserAgentKey = @"Cordova-User-Agent";
static NSString* const kCdvUserAgentVersionKey = @"Cordova-User-Agent-Version";

static NSString* gOriginalUserAgent = nil;
static NSInteger gNextLockToken = 0;
static NSInteger gCurrentLockToken = 0;
static NSMutableArray* gPendingSetUserAgentBlocks = nil;

@implementation CDVUserAgentUtil

+ (NSString*)originalUserAgent
{
    if (gOriginalUserAgent == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppLocaleDidChange:)
                                                     name:NSCurrentLocaleDidChangeNotification object:nil];

        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString* localeStr = [[NSLocale currentLocale] localeIdentifier];
        // Record the model since simulator can change it without re-install (CB-5420).
        NSString* model = [UIDevice currentDevice].model;
        NSString* systemAndLocale = [NSString stringWithFormat:@"%@ %@ %@", model, systemVersion, localeStr];

        NSString* cordovaUserAgentVersion = [userDefaults stringForKey:kCdvUserAgentVersionKey];
        gOriginalUserAgent = [userDefaults stringForKey:kCdvUserAgentKey];
        BOOL cachedValueIsOld = ![systemAndLocale isEqualToString:cordovaUserAgentVersion];

        if ((gOriginalUserAgent == nil) || cachedValueIsOld) {
            static WKWebView* sampleWebView = nil;
            sampleWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            // todo原来是同步
             __block BOOL finished = NO;
            [sampleWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                gOriginalUserAgent = result;
                [userDefaults setObject:gOriginalUserAgent forKey:kCdvUserAgentKey];
                [userDefaults setObject:systemAndLocale forKey:kCdvUserAgentVersionKey];
                [userDefaults synchronize];
                sampleWebView = nil;
                finished = YES;
            }];
            while (!finished) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
    }
    return gOriginalUserAgent;
}

+ (void)onAppLocaleDidChange:(NSNotification*)notification
{
    // TODO: We should figure out how to update the user-agent of existing WKWebViews when this happens.
    // Maybe use the PDF bug (noted in setUserAgent:).
    gOriginalUserAgent = nil;
}

+ (void)acquireLock:(void (^)(NSInteger lockToken))block
{
    gCurrentLockToken = 0;
    if (gCurrentLockToken == 0) {
        gCurrentLockToken = ++gNextLockToken;
        VerboseLog(@"Gave lock %d", gCurrentLockToken);
        block(gCurrentLockToken);
    } else {
        if (gPendingSetUserAgentBlocks == nil) {
            gPendingSetUserAgentBlocks = [[NSMutableArray alloc] initWithCapacity:4];
        }
        VerboseLog(@"Waiting for lock");
        [gPendingSetUserAgentBlocks addObject:block];
    }
}

+ (void)releaseLock:(NSInteger*)lockToken
{
    if (*lockToken == 0) {
        return;
    }
//    NSAssert(gCurrentLockToken == *lockToken, @"Got token %ld, expected %ld", (long)*lockToken, (long)gCurrentLockToken);
//
//    VerboseLog(@"Released lock %d", *lockToken);
    if ([gPendingSetUserAgentBlocks count] > 0) {
        void (^block)() = [gPendingSetUserAgentBlocks objectAtIndex:0];
        [gPendingSetUserAgentBlocks removeObjectAtIndex:0];
        gCurrentLockToken = ++gNextLockToken;
        NSLog(@"Gave lock %ld", (long)gCurrentLockToken);
        block(gCurrentLockToken);
    } else {
        gCurrentLockToken = 0;
    }
    *lockToken = 0;
}

+ (void)setUserAgent:(NSString*)value lockToken:(NSInteger)lockToken
{
    NSAssert(gCurrentLockToken == lockToken, @"Got token %ld, expected %ld", (long)lockToken, (long)gCurrentLockToken);
    VerboseLog(@"User-Agent set to: %@", value);

    // Setting the UserAgent must occur before a WKWebView is instantiated.
    // It is read per instantiation, so it does not affect previously created views.
    // Except! When a PDF is loaded, all currently active WKWebViews reload their
    // User-Agent from the NSUserDefaults some time after the DidFinishLoad of the PDF bah!
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:value, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

@end
