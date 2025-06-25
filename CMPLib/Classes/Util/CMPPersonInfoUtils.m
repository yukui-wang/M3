//
//  CMPPersonInfoUtils.m
//  CMPLib
//
//  Created by youlin on 2016/9/28.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPPersonInfoUtils.h"
#import "CMPBannerWebViewController.h"
#import "CMPCachedUrlParser.h"
#import "CMPWebViewUrlUtils.h"

@implementation CMPPersonInfoUtils

+ (BOOL)showPersonInfoView:(NSString *)memberId
                      from:(NSString *)aFrom
                enableChat:(BOOL)enableChat
      parentViewController:(UIViewController *)parentViewController
             allowRotation:(BOOL)alllowRotation {
    NSString *enableChatStr = enableChat ? @"true" : @"false";
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = [NSString stringWithFormat:kM3MyPersonUrl, memberId, aFrom, enableChatStr];
    aStr = [CMPWebViewUrlUtils handleUrl:aStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    if (parentViewController.navigationController) {
          [parentViewController.navigationController pushViewController:aController animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aController];
        nav.definesPresentationContext = YES;
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [parentViewController presentViewController:nav animated:YES completion:nil];
        nav = nil;
    }
    return YES;
}

+ (void)jumpUserSettingFrom:(UIViewController *)viewController {
    UIViewController *aController = [CMPPersonInfoUtils userSettingViewController];
    if (viewController.navigationController) {
        [viewController.navigationController pushViewController:aController animated:YES];
    }else {
        [viewController presentViewController:aController animated:YES completion:nil];
    }
}

+ (UIViewController *)userSettingViewController {
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *url = [CMPWebViewUrlUtils handleUrl:kM3MyIndexUrl];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
    aController.startPage = localHref;
    return aController;
}

@end
