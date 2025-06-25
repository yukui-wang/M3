//
//  CMPAttachmentDataProvider.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/18.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPAttachmentDataProvider.h"

@implementation CMPAttachmentDataProvider

-(void)fetchAttaPreviewConfigWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/officeTrans/config"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchAttaPreviewUrlWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion ||!params) {
        return;
    }
    NSString *fileId = params[@"fileId"];
    if (!fileId || !fileId.length) {
        return;
    }
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/officeTrans/allowTrans/"] stringByAppendingString:fileId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)shareAttaActionLogType:(NSInteger)acttype withParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!params) {
        return;
    }

    NSString *urlPath = acttype == 2 ? @"/rest/uc/rong/log/fileDownload" : @"/rest/uc/rong/log/fileUpload";
    NSString *targetType = [NSString stringWithFormat:@"%@",params[@"targetType"]];
    NSString *targetName = [NSString stringWithFormat:@"%@",params[@"targetName"]];
    NSString *fileName = [NSString stringWithFormat:@"%@",params[@"fileName"]];
    NSString *url = [[CMPCore fullUrlPathMapForPath:urlPath] stringByAppendingFormat:@"?targetType=%@&targetName=%@&fileName=%@",targetType,targetName,fileName];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    if (completion) {
        aDataRequest.userInfo = @{@"completion" : completion};
    }
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {

    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    if (responseObj) {
        NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
        if ([code isEqualToString:@"0"]) {
            id respData = responseObj[@"data"];
            completionBlk(respData,nil,responseObj);
        }else{
            NSString *msg = responseObj[@"message"];
            NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }else{
        NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
        completionBlk(nil,err,responseObj);
    }
}


- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
    NSDictionary *userInfo = aRequest.userInfo;
    
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (completionBlk) {
        completionBlk(nil,error,nil);
    }
}

@end
