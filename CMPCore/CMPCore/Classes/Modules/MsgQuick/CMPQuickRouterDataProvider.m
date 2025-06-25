//
//  CMPQuickRouterDataProvider.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/11.
//

#import "CMPQuickRouterDataProvider.h"

@implementation CMPQuickRouterDataProvider

-(void)fetchQuickItemsWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/m3/entry/fast"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result?:nil};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

@end
