/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

#import "CDVOrientation.h"
#import <CordovaLib/CDVViewController.h>
#import <objc/message.h>
#import <CMPLib/CMPBannerWebViewController.h>

@interface CDVOrientation () {}
@end

@implementation CDVOrientation

-(void)screenOrientation:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult;
    id firstObj = [command argumentAtIndex:0];
    if ([firstObj isKindOfClass:[NSArray class]] && ((NSArray *)firstObj).count) {
        firstObj = firstObj[0];
    }
    if (![firstObj isKindOfClass:[NSNumber class]]) {
        return;
    }
    NSInteger orientationMask = [firstObj integerValue];
    CDVViewController* vc = (CDVViewController*)self.viewController;
    CMPBannerWebViewController *webViewController = (CMPBannerWebViewController *)self.viewController;
    //禁用自动旋转
    if (orientationMask == 99) {
        webViewController.allowRotation = NO;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return ;
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    //修改bug OA-172937【小致】通过小致查询出来的协同数据，无法横屏显示
    //如果通过present推出的界面，点击按钮切换屏幕方向，会导致当前ViewController另外的方向会被拦截
    BOOL allowRotation = webViewController.allowRotation;
    if((orientationMask & 1) || allowRotation) {
        NSNumber *orient = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        if (@available(iOS 16.0, *)) {
            orient = [NSNumber numberWithInt:(1 << orient.intValue)];
        }
        [result addObject:orient];
    }
    if((orientationMask & 2) || allowRotation) {
        NSNumber *orient = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
        if (@available(iOS 16.0, *)) {
            orient = [NSNumber numberWithInt:(1 << orient.intValue)];
        }
        [result addObject:orient];
    }
    if((orientationMask & 4) || allowRotation) {
        NSNumber *orient = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        if (@available(iOS 16.0, *)) {
            orient = [NSNumber numberWithInt:(1 << orient.intValue)];
        }
        [result addObject:orient];
    }
    if((orientationMask & 8) || allowRotation) {
        NSNumber *orient = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        if (@available(iOS 16.0, *)) {
            orient = [NSNumber numberWithInt:(1 << orient.intValue)];
        }
        [result addObject:orient];
    }

    SEL selector = NSSelectorFromString(@"setSupportedOrientations:");

    if([vc respondsToSelector:selector]) {
        if (orientationMask != 15 || [UIDevice currentDevice] == nil) {
            ((void (*)(CDVViewController*, SEL, NSMutableArray*))objc_msgSend)(vc,selector,result);
        }

        if ([UIDevice currentDevice] != nil){
            NSNumber *value = nil;
            if (orientationMask != 15) {
                if(orientationMask == 8 || orientationMask == 12) {
                    value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
                } else if (orientationMask == 4){
                    value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
                } else if (orientationMask == 1 || orientationMask == 3) {
                    value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                } else if (orientationMask == 2) {
                    value = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
                }
            }
            if (value != nil) {
                if (@available(iOS 16.0, *)) {
                    SEL ss = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
                    if (vc && [vc respondsToSelector:ss]) {
                        [vc performSelector:ss];
                    }
                }
                [UIDevice newApiForSetOrientation:value.intValue];
            } else {
                webViewController.allowRotation = YES;
            }
        }

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsString:@"Error calling to set supported orientations"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}


-(void)isSupportAutoRotation:(CDVInvokedUrlCommand *)command{
    NSDictionary *arguments = [command.arguments lastObject];
    BOOL isSupportAutoRotation = [arguments[@"isSupportAutoRotation"] boolValue];
    ((CMPBannerWebViewController *)self.viewController).allowRotation = isSupportAutoRotation;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
