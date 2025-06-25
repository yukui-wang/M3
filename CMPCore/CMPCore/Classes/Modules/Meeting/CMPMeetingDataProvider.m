//
//  CMPMeetingDataProvider.m
//  M3
//
//  Created by Kaku Songu on 11/26/22.
//

#import "CMPMeetingDataProvider.h"

@implementation CMPMeetingDataProvider

-(void)fetchQuickMeetingEnableStateWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/meetingComponent/meetingInstantEnable"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)checkQuickMeetingConfigWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/meetingComponent/checkMeetingInstantConfig"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(void)fetchPersonalQuickMeetingConfigInfoWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/meetingComponent/findMeetingInstant"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)createOnTimeMeetingByMids:(NSArray *)mids result:(CommonResultBlk)result
{
    if (!mids || mids.count == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/meetingComponent/sendMeetingInstant"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestParam = [mids yy_modelToJSONString];
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)verifyOnTimeMeetingValidWithInfo:(NSDictionary *)meetInfo result:(CommonResultBlk)result
{
    if (!meetInfo || meetInfo.count == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/meetingComponent/sendMeetingInstant"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestParam = [meetInfo yy_modelToJSONString];
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)zxCreateOnTimeMeetingBySenderId:(NSString *)sid receiverIds:(NSArray *)receiverIds type:(NSString *)type link:(NSString *)link password:(NSString *)pwd result:(CommonResultBlk)result
{
    if (!receiverIds || receiverIds.count == 0) {
        return;
    }
    if (!type || type.length == 0) {
        return;
    }
    NSString *rstr = [receiverIds componentsJoinedByString:@","];
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/uc/rest.do?method=txMeetingCard"] stringByAppendingFormat:@"&receiverIds=%@&type=%@",rstr,type];
    if (sid && sid.length) {
        url = [url stringByAppendingFormat:@"&senderId=%@",sid];
    }
    if (link && link.length) {
        url = [url stringByAppendingFormat:@"&link=%@",link];
    }
    if (pwd && pwd.length) {
        url = [url stringByAppendingFormat:@"&pwd=%@",pwd];
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result?:nil,@"identifier":@"rcreq.createtxmeet"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {

    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSString *identifier = userInfo[@"identifier"];
    if (identifier && identifier.length) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        if (responseObj) {
            NSString *status = [NSString stringWithFormat:@"%@",responseObj[@"status"]];
            if ([status isEqualToString:@"successed"]) {
                id dataObj;
                if ([@"rcreq.createtxmeet" isEqualToString:identifier]){
                    dataObj = responseObj[@"txMeetinginfo"] ? responseObj[@"txMeetinginfo"]:responseObj;
                }else{
                    dataObj = responseObj[@"data"] ? responseObj[@"data"]:responseObj;
                }
                completionBlk(dataObj,nil,responseObj);
            }else{
                NSError *err = [NSError errorWithDomain:status code:-1001 userInfo:responseObj];
                completionBlk(nil,err,responseObj);
            }
        }else{
            NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    }else{
        [super providerDidFinishLoad:aProvider request:aRequest response:aResponse];
    }
}

@end
