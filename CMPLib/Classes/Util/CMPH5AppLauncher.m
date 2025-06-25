//
//  CMPH5AppLauncher.m
//  CMPLib
//
//  Created by CRMO on 2019/4/17.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPH5AppLauncher.h"
#import "CMPBannerWebViewController+Create.h"

static NSString * const kTransitPageUrl = @"http://cmp/v1.0.0/page/cmp-app-access.html";

@implementation CMPH5AppLauncher

+ (void)launchH5AppWithParam:(NSDictionary *)param
                inController:(UIViewController *)vc {
    [CMPBannerWebViewController pushWithUrl:kTransitPageUrl params:param toController:vc];
}

@end
