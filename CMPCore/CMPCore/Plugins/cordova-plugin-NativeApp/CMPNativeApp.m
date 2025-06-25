//
//  CMPNativeApp.m
//  M3
//
//  Created by MacBook on 2019/11/28.
//

#import "CMPNativeApp.h"
#import "CMPShareManager.h"

@implementation CMPNativeApp

- (void)openScreenDisplay:(CDVInvokedUrlCommand *)command {
    [CMPShareManager.sharedManager showScreenMirrorTipsView];
}

@end
