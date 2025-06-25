//
//  CMPImpAlertViewModel.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/8/29.
//

#import "CMPImpAlertViewModel.h"
#import <CMPLib/CMPBaseDataProvider.h>
#import <CMPLib/SDWebImageDownloader.h>

@interface CMPImpAlertDataProvider : CMPBaseDataProvider

-(void)fetchDatasWithResult:(CommonResultBlk)result;
-(void)fetchShareImageWithGid:(NSString *)gid downloadPath:(NSString *)downloadPath result:(CommonResultBlk)result;

@end

@implementation CMPImpAlertDataProvider

-(void)fetchDatasWithResult:(CommonResultBlk)result
{
    if (!result) {
        return;
    }
    NSString *url = [CMPCore fullUrlPathMapForPath:@"/rest/m3/message/classification"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result?:nil,@"identifier":@"impmsg.fetchDatas"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchDetailWithGid:(NSString *)gid result:(CommonResultBlk)result
{
    if (!gid || !result) {
        return;
    }
    NSString *url = [[CMPCore fullUrlPathMapForPath:@"/rest/greeting/getGreeting/"] stringByAppendingString:gid];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"completion" : result?:nil,@"identifier":@"impmsg.fetchDetail"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)fetchShareImageWithGid:(NSString *)gid downloadPath:(NSString *)downloadPath result:(CommonResultBlk)result
{
    if (!gid || !downloadPath || !result) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@%@",[CMPCore fullUrlPathMapForPath:@"/rest/m3/greeting/share/image?greetingId="],gid,@"&width=550&height=708"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_FileDownload;
    aDataRequest.downloadDestinationPath = downloadPath;
    aDataRequest.userInfo = @{@"completion" : result?:nil,@"identifier":@"impmsg.fetchShareImage"};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {

    NSDictionary *userInfo = aRequest.userInfo;
    void(^completionBlk)(id respData,NSError *err,id ext) = [userInfo objectForKey:@"completion"];
    
    if (!completionBlk) {
        return;
    }
    
    NSString *identifier = userInfo[@"identifier"];
    if (aRequest.requestType == kDataRequestType_Url && identifier && identifier.length) {
        NSDictionary *responseObj = [aResponse.responseStr JSONValue];
        if (responseObj) {
            NSString *code = [NSString stringWithFormat:@"%@",responseObj[@"code"]];
            if ([code isEqualToString:@"200"]) {
                id respData = responseObj[@"data"];
                if ([@"impmsg.fetchDatas" isEqualToString:identifier]) {
                    respData = responseObj;
                }
                completionBlk(respData,nil,responseObj);
            }else{
                NSString *msg = [NSString stringWithFormat:@"%@",responseObj[@"message"]];
                NSError *err = [NSError errorWithDomain:msg code:[code integerValue] userInfo:nil];
                completionBlk(nil,err,responseObj);
            }
        }else{
            NSError *err = [NSError errorWithDomain:@"response null" code:-1 userInfo:nil];
            completionBlk(nil,err,responseObj);
        }
    } else {
        [super providerDidFinishLoad:aProvider request:aRequest response:aResponse];
    }
}

@end

@interface CMPImpAlertViewModel()

@property (nonatomic,strong) CMPImpAlertDataProvider *dataProvider;

@end

@implementation CMPImpAlertViewModel

-(void)fetchImpMsgs:(void(^)(NSArray *datas, NSError *err))completion
{
    if (!completion) return;
    [self.dataProvider fetchDatasWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            NSArray *greetingArr = respData[@"greeting"];
            if (greetingArr && [greetingArr isKindOfClass:NSArray.class]) {
                completion(greetingArr,error);
                return;
            }else{
                completion(nil,nil);
                return;
            }
        }
        completion(respData,error);
    }];
}

-(void)fetchImpMsgDetailByGid:(NSString *)gid completion:(void(^)(NSDictionary *datas, NSError *err))completion
{
    if (!gid || !completion) return;
    [self.dataProvider fetchDetailWithGid:gid result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        completion(respData,error);
    }];
}

-(void)fetchImpMsgShareImageByGid:(NSString *)gid completion:(void(^)(NSData *data,NSString *localPath, NSError *err))completion
{
    if (!gid || !completion) return;
    NSString *path = [CMPImpAlertViewModel shareImageLocalPathWithGreetingId:gid];
    [self.dataProvider fetchShareImageWithGid:gid downloadPath:path result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            completion(data,path,nil);
        } else {
            completion(nil,path,error);
        }
    }];
}

-(CMPImpAlertDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPImpAlertDataProvider alloc] init];
    }
    return _dataProvider;
}

+(NSString *)shareImageLocalPathWithGreetingId:(NSString *)greetingId
{
    if (!greetingId) return nil;
    NSString *aDoucumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tag = @"greetingImages";
    NSString *serId = [CMPCore sharedInstance].serverID;
    NSString *uid = [CMPCore sharedInstance].userID;
    NSString *path = [[[aDoucumentPath stringByAppendingPathComponent:tag] stringByAppendingPathComponent:serId] stringByAppendingPathComponent:uid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *s = [path stringByAppendingFormat:@"/%@.png",greetingId];
    return s;
}

@end
