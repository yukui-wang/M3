//
//  CMPTabBarProvider.m
//  M3
//
//  Created by CRMO on 2017/11/13.
//

#import "CMPTabBarProvider.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import "CMPTabBarAttribute.h"
#import "CMPTabBarItemAttribute.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPLoginConfigInfoModel.h"

NSString * const kCMPTabBarProviderCacheFolder = @"tabBar";

@interface CMPTabBarProvider()<CMPDataProviderDelegate>
@end

@implementation CMPTabBarProvider

- (void)dealloc {
    [super dealloc];
}

- (void)appClick:(NSString *)appId appName:(NSString *)appName uniqueId:(NSString *)uniqueId{
    if ([NSString isNull:appId]) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/m3/statistics/appClick"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSDictionary *params = @{
        @"appId":appId?:@"",
        @"appName":appName?:@"",
        @"uniqueId":uniqueId?:@""
    };
    aDataRequest.requestParam = [params JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


#pragma mark-
#pragma mark-API

- (CMPTabBarItemAttributeList *)tabBarItemList {
    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
    CMPLoginConfigInfoModel_2 *config = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:currentUser.configInfo];
    CMPTabBarItemAttributeList *tabBarItemAttributes = [[[CMPTabBarItemAttributeList alloc] init] autorelease];
    tabBarItemAttributes.navBarList = config.tabBar.tabbarList;
    return tabBarItemAttributes;
}
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
}

@end
