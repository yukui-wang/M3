//
//  CMPPartTimeProvider.m
//  M3
//
//  Created by CRMO on 2018/6/26.
//

#import "CMPPartTimeProvider.h"
#import <CMPLib/CMPDataProvider.h>

NSString * const kGetPartTimeListUrl = @"/rest/m3/individual/concurrent/account";
NSString * const kSwitchPartTimeUrl = @"/rest/m3/login/change/account";

@interface CMPPartTimeProvider()<CMPDataProviderDelegate>
@property (nonatomic, copy) NSString *partTimeListRequestID;
@property (nonatomic, copy) NSString *switchPartTimeRequestID;
@end

@implementation CMPPartTimeProvider

- (void)partTimeListCompletion:(CMPPartTimeListDoneBlock)block {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kGetPartTimeListUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"block" : [block copy]};
    self.partTimeListRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)switchPartTimeWithAccountID:(NSString *)accountID
                         completion:(CMPPartTimeSwitchDoneBlock)block {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPath:kSwitchPartTimeUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"accountId" : accountID};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"block" : [block copy]};
    self.switchPartTimeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([self.partTimeListRequestID isEqualToString:aRequest.requestID]) {
        CMPPartTimeListDoneBlock block = aRequest.userInfo[@"block"];
        NSMutableArray *partTimes = [NSMutableArray array];
        NSDictionary *responseDic = [aResponse.responseStr JSONValue];
        if (responseDic && [responseDic isKindOfClass:[NSDictionary class]]) {
            NSArray *dataArray = responseDic[@"data"];
            for (NSDictionary *dataDic in dataArray) {
                if (dataDic && [dataDic isKindOfClass:[NSDictionary class]]) {
                    NSNumber *accountIDNum = dataDic[@"id"];
                    NSString *accountID = [accountIDNum stringValue];
                    NSString *accountName = dataDic[@"name"];
                    NSString *accountShortName = dataDic[@"shortName"];
                    if (![NSString isNull:accountID] &&
                        ![NSString isNull:accountName] &&
                        ![NSString isNull:accountShortName]) {
                        CMPPartTimeModel *model = [[CMPPartTimeModel alloc] init];
                        model.accountID = accountID;
                        model.accountName = accountName;
                        model.accountShortName = accountShortName;
                        model.serverID = [CMPCore sharedInstance].serverID;
                        model.userID = [CMPCore sharedInstance].userID;
                        [partTimes addObject:model];
                    }
                }
            }
        }
        
        if (block) {
            block(partTimes, nil);
        }
    } else if ([self.switchPartTimeRequestID isEqualToString:aRequest.requestID]) {
        CMPPartTimeSwitchDoneBlock block = aRequest.userInfo[@"block"];
        CMPPartTimeModel *model = nil;
        NSDictionary *responseDic = [aResponse.responseStr JSONValue];

        NSInteger code = [responseDic[@"code"] integerValue];
        NSString *message = responseDic[@"message"];;
        if (code != 200 && code != 0) {
            NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
            if (block) {
                block(nil, error);
            }
            return;
        }
        
        if (responseDic && [responseDic isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = responseDic[@"data"];
            NSDictionary *accountDic = dataDic[@"account"];
            if (accountDic && [accountDic isKindOfClass:[NSDictionary class]]) {
                NSNumber *accountIDNum = accountDic[@"id"];
                NSString *accountID = [accountIDNum respondsToSelector:@selector(stringValue)]?[accountIDNum stringValue]:@"";
                NSString *accountName = accountDic[@"name"];
                NSString *accountShortName = accountDic[@"shortName"];
                NSString *accountCode = accountDic[@"code"];
                if (![NSString isNull:accountID] &&
                    ![NSString isNull:accountName] &&
                    ![NSString isNull:accountShortName]) {
                    model = [[CMPPartTimeModel alloc] init];
                    model.accountID = accountID;
                    model.accountName = accountName;
                    model.accountShortName = accountShortName;
                    model.accountCode = accountCode;
                    model.serverID = [CMPCore sharedInstance].serverID;
                    model.userID = [CMPCore sharedInstance].userID;
                }
            }
            NSDictionary *memberDic = dataDic[@"memberPost"];
            if (memberDic && [memberDic isKindOfClass:[NSDictionary class]]) {
                
                NSString *departmentID = [memberDic[@"depId"] respondsToSelector:@selector(stringValue)]?[memberDic[@"depId"] stringValue]:@"";
                NSString *postID = [memberDic[@"postId"] respondsToSelector:@selector(stringValue)]?[memberDic[@"postId"] stringValue]:@"";
                NSString *levelID = [memberDic[@"levelId"] respondsToSelector:@selector(stringValue)]?[memberDic[@"levelId"] stringValue]:@"";
                model.departmentID = departmentID;
                model.postID = postID;
                model.levelID = levelID;
            }
        }
        
        if (block) {
            block(model, nil);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([self.partTimeListRequestID isEqualToString:aRequest.requestID]) {
        CMPPartTimeListDoneBlock block = aRequest.userInfo[@"block"];
        if (block) {
            block(nil, error);
        }
    } else if ([self.switchPartTimeRequestID isEqualToString:aRequest.requestID]) {
        CMPPartTimeSwitchDoneBlock block = aRequest.userInfo[@"block"];
        if (block) {
            block(nil, error);
        }
    }
}

@end
