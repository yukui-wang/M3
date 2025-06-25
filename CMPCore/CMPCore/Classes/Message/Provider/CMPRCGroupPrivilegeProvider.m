//
//  CMPRCGroupPrivilegeProvider.m
//  M3
//
//  Created by CRMO on 2018/7/4.
//

#import "CMPRCGroupPrivilegeProvider.h"
#import <CMPLib/CMPDataProvider.h>

static NSString * const kCMPRCGroupPrivilegeUrl = @"/rest/m3/individual/zx/getGroupAuth";

@interface CMPRCGroupPrivilegeProvider()<CMPDataProviderDelegate>
@end

@implementation CMPRCGroupPrivilegeProvider

- (void)rcGroupPrivilegeWithGroupID:(NSString *)groupID
                           memberID:(NSString *)memberID
                         completion:(RequestRCGroupPrivilegeDidFinish)block {
    //判断版本，7.0SP1以下则不需要调此接口，默认直接返回有权限
    if (![CMPCore sharedInstance].serverIsLaterV7_0_SP1) {
        CMPRCGroupPrivilegeModel *model = [CMPRCGroupPrivilegeModel new];
        model.receiveFile = YES;
        model.sendFile = YES;
        block(model,nil);
        return;
    }
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kCMPRCGroupPrivilegeUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"groupId" : groupID,
                                 @"memberId" : memberID,
                                 @"groupAuthType" : @""};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"block" : [block copy]};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    RequestRCGroupPrivilegeDidFinish block = aRequest.userInfo[@"block"];
    if (!block) {
        return;
    }
    
    CMPRCGroupPrivilegeModel *privilege = [CMPRCGroupPrivilegeModel yy_modelWithJSON:aResponse.responseStr];
    if (!privilege) {
        NSError *error = [NSError errorWithDomain:@"返回数据异常" code:0 userInfo:nil];
        block(nil, error);
        return;
    }
    NSDictionary *data = privilege.data;
    NSDictionary *sendfileDic = data[@"SENDFILE"];
    NSDictionary *receivefileDic = data[@"RECEIVEFILE"];
    NSNumber *sendfile = sendfileDic[@"data"];
    NSNumber *receivefile = receivefileDic[@"data"];
    privilege.receiveFile = [receivefile boolValue];
    privilege.sendFile = [sendfile boolValue];
    block(privilege, nil);
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    RequestRCGroupPrivilegeDidFinish block = aRequest.userInfo[@"block"];
    if (block) {
        block(nil, error);
    }
}
@end
