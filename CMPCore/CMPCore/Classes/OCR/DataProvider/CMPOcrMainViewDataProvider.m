//
//  CMPOcrMainViewDataProvider.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import "CMPOcrMainViewDataProvider.h"
#import "CMPCommonManager.h"

@implementation CMPOcrMainViewDataProvider

-(void)fetchCommonModulesWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion) {
        return;
    }
    BOOL history = [params[@"history"] boolValue];
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/ai/user/reimbursement/v1/template/often"] stringByAppendingFormat:@"?history=%@",(history?@"true":@"false")];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(void)fetchAllModulesWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion || !params) {
        return;
    }
    BOOL history = [params[@"history"] boolValue];
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/ai/user/reimbursement/v1/template/all"] stringByAppendingFormat:@"?history=%@",(history?@"true":@"false")];
    BOOL auth = [params[@"auth"] boolValue];
    if (auth) {
        url = [url stringByAppendingFormat:@"&auth=true"];
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)updateModulesListWithParams:(NSArray *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!params) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/user/reimbursement/v1/template/update"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(void)fetchPackageListWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion || !params) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/reimbursement/package/v1/list"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)wakeupPC:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    NSString *templateId = params[@"templateId"];
    NSString *sourceId = [params[@"sourceId"] stringValue];
//    NSString *summaryId = params[@"summaryId"];
    NSString *formId = params[@"formId"];
    
    NSString *url = [CMPCore fullUrlForPath:@"/collaboration/collaboration.do?method=newColl&from=templateNewColl&projectId=-1&sourceType=aiOCRAwake&isOcr=true"];
    if (templateId.length) {
        url = [url stringByAppendingFormat:@"&templateId=%@",templateId];
    }
    if (formId.length) {
        url = [url stringByAppendingFormat:@"&formId=%@",formId];
    }
//    if (summaryId.length) {
//        url = [url stringByAppendingFormat:@"&summaryId=%@",summaryId];
//    }
    if (sourceId.length) {
        url = [url stringByAppendingFormat:@"&sourceId=%@",sourceId];
    }
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  characterSetWithCharactersInString:@"/:&=?"].invertedSet];
    
    NSString *urlPrex = [CMPCore fullUrlForPath:@"/rest/uc/rong/autopierce?url="];
    url = [urlPrex stringByAppendingString:url];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest isEncodeUrl:YES];
}

-(void)checkPackageIfCanCommitWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion || !params || !(params[@"packageId"])) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/ai/reimbursement/package/v1/submit/check/%@",params[@"packageId"]];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};

//    aDataRequest.requestParam = [params JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)checkWakeUpIfCanCommitWithPackageId:(NSString *)packageId completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!packageId) {
        return;
    }
    //ai/ocr/application/v1/wake
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/ai/ocr/application/v1/wake/%@",packageId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};

//    aDataRequest.requestParam = [params JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}
-(void)checkWakeUpIfCanCommitWithInvoiceIdList:(NSArray *)invoiceIdList completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (invoiceIdList.count <= 0) {
        return;
    }
    //ai/ocr/application/v1/wake
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/ai/ocr/application/v1/wake"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};

//    aDataRequest.requestParam = [params JSONRepresentation];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdList options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)checkPackageIfCanCommitWithInvoiceIds:(NSArray *)invoiceIds
                                  templateId:(NSString *)templateId
                                      formId:(NSString *)formId
                                  completion:(void(^)(id respData,NSError *error,id ext))completion{
    if (invoiceIds.count<=0) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/ai/reimbursement/package/v1/submit/check"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};

    aDataRequest.requestParam = [@{
        @"invoiceIds":invoiceIds?:@[],
        @"templateId":templateId?:@"",
        @"formId":formId?:@""
    } JSONRepresentation];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)deleteRepeatWithInvoiceIdList:(NSArray *)invoiceIdList completion:(void(^)(id respData,NSError *error,id ext))completion
{
    NSString *url = [NSString stringWithFormat:@"%@?option.n_a_s=1",[CMPCore fullUrlPathMapForPath:@"/rest/ai/reimbursement/package/v1/submit/deleteRepeatInvoice"]];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:invoiceIdList options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    aDataRequest.requestParam = strJson;//仅字符串数组的json

    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)deletePackageWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion{
    if (!params||!params[@"pid"]) {
        return;
    }
    NSString *pid = params[@"pid"];
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/ai/reimbursement/package/v1/delete/"] stringByAppendingString:pid];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    if (completion) {
        aDataRequest.userInfo = @{@"completion" : completion};
    }
    aDataRequest.requestParam = [params JSONRepresentation];
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}



-(void)fetchDefaultPackageIdWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!completion) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/ai/reimbursement/package/v1/default"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : completion};
//    aDataRequest.requestID = @"CMPOcrMainViewDataProvider_commonModules";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
    [CMPCommonManager updateReachableServer:nil];
    // end
    
//    NSString *requestID = aRequest.requestID;
    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSDictionary *responseObj = [aResponse.responseStr JSONValue];
    if (responseObj) {
        if ([responseObj[@"status"] respondsToSelector:@selector(stringValue)]) {
            NSString *success = [responseObj[@"status"] stringValue];
            if ([success isEqual:@"successed"]) {
                completionBlk(nil,nil,responseObj);
            }else{
                NSError *err = [NSError errorWithDomain:responseObj[@"message"] code:1 userInfo:nil];
                completionBlk(nil,err,responseObj);
            }
            return;
        }
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
