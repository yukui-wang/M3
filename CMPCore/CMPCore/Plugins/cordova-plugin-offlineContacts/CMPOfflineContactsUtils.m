//
//  CMPOfflineContactsUtils.m
//  CMPCore
//
//  Created by wujiansheng on 2017/1/17.
//
//

#import "CMPOfflineContactsUtils.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPChatManager.h"
#import <CMPLib/CMPWebViewUrlUtils.h>

@implementation CMPOfflineContactsUtils

+ (BOOL)showOrganizationView:(UIViewController *)parentViewController
{
    //组织架构
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = kM3OrganizationUrl;
    aStr = [CMPWebViewUrlUtils handleUrl:aStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

+ (BOOL)showProjectTeamView:(UIViewController *)parentViewController
{
    // 项目组
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *url = [CMPWebViewUrlUtils handleUrl:kM3ProjectTeamUrl];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

+ (BOOL)showGroupChatView:(UIViewController *)parentViewController
{
   // 我的群聊
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr =[[CMPChatManager sharedManager] useRongCloud] ? kM3UCGroupListPageUrl : kM3UCGroupListUrl;
    aStr = [CMPWebViewUrlUtils handleUrl:aStr];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

+ (BOOL)showFrequentContactsView:(UIViewController *)parentViewController
{
   // 常用联系人
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = [CMPWebViewUrlUtils handleUrl:kM3FrequentContactsUrl];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

+ (BOOL)showSearchView:(UIViewController *)parentViewController
{
    // 搜索界面
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = [CMPWebViewUrlUtils handleUrl:kM3TodoSearchUrl];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

+ (BOOL)showRelatedView:(UIViewController *)parentViewController
{
    // 关联人员界面
    CMPBannerWebViewController *aController = [[CMPBannerWebViewController alloc] init];
    NSString *aStr = [CMPWebViewUrlUtils handleUrl:kM3RelatedContactsUrl];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:aStr]];
    aController.startPage = localHref;
    [parentViewController.navigationController pushViewController:aController animated:YES];
    [aController release];
    return YES;
}

@end
