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

#import "CDVIntentAndNavigationFilter.h"
#import "CDV.h"
#import <WebKit/WebKit.h>

@interface CDVIntentAndNavigationFilter ()

@property (nonatomic, readwrite) NSMutableArray* allowIntents;
@property (nonatomic, readwrite) NSMutableArray* allowNavigations;
@property (nonatomic, readwrite) CDVWhitelist* allowIntentsWhitelist;
@property (nonatomic, readwrite) CDVWhitelist* allowNavigationsWhitelist;

@end

@implementation CDVIntentAndNavigationFilter

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString:@"allow-navigation"]) {
        [self.allowNavigations addObject:attributeDict[@"href"]];
    }
    if ([elementName isEqualToString:@"allow-intent"]) {
        [self.allowIntents addObject:attributeDict[@"href"]];
    }
}

- (void)parserDidStartDocument:(NSXMLParser*)parser
{
    // file: url <allow-navigations> are added by default
    self.allowNavigations = [[NSMutableArray alloc] initWithArray:@[ @"file://" ]];
    // no intents are added by default
    self.allowIntents = [[NSMutableArray alloc] init];
    // 添加自定义 by guoyl
    NSArray *aStrArray = @[@"*",@":",@"ays", @"p", @"li",@"a"];
    NSString *vaule = [[[aStrArray reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    [self.allowNavigations addObject:vaule];
    [self.allowIntents addObject:vaule];
}

- (void)parserDidEndDocument:(NSXMLParser*)parser
{
    self.allowIntentsWhitelist = [[CDVWhitelist alloc] initWithArray:self.allowIntents];
    self.allowNavigationsWhitelist = [[CDVWhitelist alloc] initWithArray:self.allowNavigations];
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    NSAssert(NO, @"config.xml parse error line %ld col %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
}

#pragma mark CDVPlugin

- (void)pluginInitialize
{
    if ([self.viewController isKindOfClass:[CDVViewController class]]) {
        [(CDVViewController*)self.viewController parseSettingsWithParser:self];
    }
}

+ (CDVIntentAndNavigationFilterValue) filterUrl:(NSURL*)url intentsWhitelist:(CDVWhitelist*)intentsWhitelist navigationsWhitelist:(CDVWhitelist*)navigationsWhitelist
{
    // a URL can only allow-intent OR allow-navigation, if both are specified,
    // only allow-navigation is allowed
    
    BOOL allowNavigationsPass = [navigationsWhitelist URLIsAllowed:url logFailure:NO];
    BOOL allowIntentPass = [intentsWhitelist URLIsAllowed:url logFailure:NO];
    
    if (allowNavigationsPass && allowIntentPass) {
        return CDVIntentAndNavigationFilterValueNavigationAllowed;
    } else if (allowNavigationsPass) {
        return CDVIntentAndNavigationFilterValueNavigationAllowed;
    } else if (allowIntentPass) {
        return CDVIntentAndNavigationFilterValueIntentAllowed;
    }
    
    return CDVIntentAndNavigationFilterValueNoneAllowed;
}

- (CDVIntentAndNavigationFilterValue) filterUrl:(NSURL*)url
{
    return [[self class] filterUrl:url intentsWhitelist:self.allowIntentsWhitelist navigationsWhitelist:self.allowNavigationsWhitelist];
}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(WKNavigationType)navigationType
{
    NSString* allowIntents_whitelistRejectionFormatString = @"ERROR External navigation rejected - <allow-intent> not set for url='%@'";
    NSString* allowNavigations_whitelistRejectionFormatString = @"ERROR Internal navigation rejected - <allow-navigation> not set for url='%@'";
    
    NSURL* url = [request URL];
    CDVIntentAndNavigationFilterValue filterValue = [self filterUrl:url];
    
    switch (filterValue) {
        case CDVIntentAndNavigationFilterValueNavigationAllowed:
            return YES;
        case CDVIntentAndNavigationFilterValueIntentAllowed:
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            return NO;
        case CDVIntentAndNavigationFilterValueNoneAllowed:
            // allow-navigation attempt failed for sure
            NSLog(@"%@", [NSString stringWithFormat:allowNavigations_whitelistRejectionFormatString, [url absoluteString]]);
            // anchor tag link means it was an allow-intent attempt that failed as well
            if (WKNavigationTypeLinkActivated == navigationType) {
                NSLog(@"%@", [NSString stringWithFormat:allowIntents_whitelistRejectionFormatString, [url absoluteString]]);
            }
            return NO;
    }
}

@end
