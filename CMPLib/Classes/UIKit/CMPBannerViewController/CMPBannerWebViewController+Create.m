//
//  CMPBannerWebViewController+Create.m
//  CMPLib
//
//  Created by CRMO on 2018/10/18.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPBannerWebViewController+Create.h"
#import "CMPCachedUrlParser.h"
#import <CMPLib/CMPNavigationController.h>

@implementation CMPBannerWebViewController (Create)

+ (void)pushWithUrl:(NSString *)url toNavigation:(UINavigationController *)navigation {
    CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
    NSString *urlStr = [url urlCFEncoded];
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
    viewController.startPage = localHref;
    viewController.hideBannerNavBar = NO;
    [navigation pushViewController:viewController animated:YES];
}

+ (void)pushWithUrl:(NSString *)url
             params:(NSDictionary *)params
       toController:(UIViewController *)controller {
    CMPBannerWebViewController *viewController = [CMPBannerWebViewController bannerWebViewWithUrl:url params:params];
    
    if (!viewController) {
        return;
    }
    
    if (controller.navigationController) {
        [controller.navigationController pushViewController:viewController animated:YES];
    } else {
        CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:viewController];
        [controller presentViewController:nav animated:YES completion:nil];
    }
}

+ (CMPBannerWebViewController *)bannerWebViewWithUrl:(NSString *)url params:(NSDictionary *)params {
    return [self p_bannerWebView1WithUrl:url params:params isParamJson:YES];
}


/// params以对象的形式传入
+ (CMPBannerWebViewController *)bannerWebView1WithUrl:(NSString *)url params:(NSDictionary *)params {
    return [self p_bannerWebView1WithUrl:url params:params isParamJson:NO];
}


+ (CMPBannerWebViewController *)p_bannerWebView1WithUrl:(NSString *)url params:(NSDictionary *)params isParamJson:(BOOL)isParamJson {
    CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
    NSString *urlStr = [url urlCFEncoded];
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
    
    if ([NSString isNull:localHref]) {
        DDLogError(@"zl---[%s]localHref为空", __FUNCTION__);
        return nil;
    }
    
    id p = params;
    if (isParamJson) {
        p = params.JSONRepresentation;
    }
    
    viewController.startPage = localHref;
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = NO;
    viewController.pageParam = @{@"url" : localHref,
                                 @"param" : p };
    return viewController;
}



@end
