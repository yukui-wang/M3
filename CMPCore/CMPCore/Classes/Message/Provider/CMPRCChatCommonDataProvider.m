//
//  CMPRCChatCommonDataProvider.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/13.
//

#import "CMPRCChatCommonDataProvider.h"
#import "CMPCookieTool.h"

@implementation CMPRCChatCommonDataProvider

-(void)fetchGroupsInfoByParams:(NSDictionary *)params result:(CommonResultBlk)result
{
    if (!params || params.count == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/uc/rong/groups/bygids"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestParam = [params yy_modelToJSONString];
    aDataRequest.userInfo = @{@"completion" : result};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchMemberOnlineStatus:(NSString *)mid result:(CommonResultBlk)result
{
    if (!mid || mid.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/uc/rong/onlineStatus/"] stringByAppendingString:mid];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.onlinestatus"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


-(void)fetchChatFileOperationPrivilegeByParams:(NSDictionary *)params
                                        result:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/uc/rong/validate/fileAuth?plat=mobile"];
    if(params && params.count){
        NSString *authType = params[@"authType"];
        if(authType){
            url = [url stringByAppendingFormat:@"&authType=%@",authType];
        }
        NSString *groupId = params[@"groupId"];
        if(groupId){
            url = [url stringByAppendingFormat:@"&groupId=%@",groupId];
        }
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.fileauth"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)checkChatFileIfExistById:(NSString *)fid groupId:(NSString *)gid result:(CommonResultBlk)result
{
    if (!fid || fid.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/uc/rest.do?method=checkGroupFile&fileId="] stringByAppendingFormat:@"%@&groupId=%@",fid,gid?:@""];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.chatfileexsit"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)fetchGroupUserListByGroupId:(NSString *)groupId completion:(CommonResultBlk)result {
    if (!groupId || groupId.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/groups/bygid/%@",groupId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.groupuserlist"};
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)fetchAllTopChatListWithCompletion:(CommonResultBlk)result {
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/chatmessage/top/getall"];
    NSString *jsessionId = [CMPCookieTool JSESSIONIDForUrl:url];
    if (!jsessionId || jsessionId.length == 0) return;
    //end
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.topchatlist"};
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)saveChatTopStateByCid:(NSString *)cid state:(NSInteger)state completion:(CommonResultBlk)result {
    if (!cid || cid.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/chatmessage/top/save"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"talkId" : cid,
                                 @"recordValue" : [NSString stringWithInt:state]
                                };
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.savechattop"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)saveLocalChatsTopStatesByValues:(NSArray *)values completion:(CommonResultBlk)result {
    if (!values || values.count == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/chatmessage/top/upload"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"data" : values};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.savechattopupload"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)signChatToUnreadByCid:(NSString *)cid isUnread:(BOOL)isUnread completion:(CommonResultBlk)result {
    if (!cid || cid.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/chatmessage/unreadstatus"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"talkId" : cid,@"recordValue":isUnread?@"1":@"0"};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.signchatunread"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)deleteChatByCid:(NSString *)cid completion:(CommonResultBlk)result {
    if (!cid || cid.length == 0) {
        return;
    }
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/chatmessage/remove"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"talkId" : cid};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"completion" : result,@"identifier":@"rcreq.deletechat"};
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
        if ([identifier isEqualToString:@"rcreq.chatfileexsit"]) {
            if ([aResponse.responseStr isEqualToString:@"\"ok\""]){
                completionBlk(@"1",nil,aResponse);
            }else{
                completionBlk(@"0",nil,aResponse);
            }
            return;
        }
        if ([identifier isEqualToString:@"rcreq.groupuserlist"]) {
            NSDictionary *responseDic = [[aResponse responseStr] JSONValue];
            if (responseDic) {
                NSString *status = responseDic[@"status"];
                if ([status isEqualToString:@"ok"]) {
                    NSDictionary *groupDic = responseDic[@"group"];
                    completionBlk(groupDic,nil,responseDic);
                }else{
                    NSError *err = [NSError errorWithDomain:@"response fail" code:-1 userInfo:nil];
                    completionBlk(nil,err,responseDic);
                }
            }
            return;
        }
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        if (responseObj) {
            NSString *status = [NSString stringWithFormat:@"%@",responseObj[@"status"]];
            if ([status isEqualToString:@"successed"]) {
                id dataObj = responseObj[@"data"] ? responseObj[@"data"]:responseObj;
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
