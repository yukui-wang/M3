//
//  CMPContactsSerachMemberProvider.m
//  M3
//
//  Created by CRMO on 2017/11/24.
//

#import "CMPContactsSearchMemberProvider.h"
#import <CMPLib/CMPDataProvider.h>

static NSString * const kSuccessBlock = @"success";
static NSString * const kFailBlock = @"fail";

static NSString * const kCMPSearchMemberUrl = @"/rest/addressbook/searchMember?pageNo=%d&pageSize=%d";
static NSString * const kCMPSearchMemberDefaultType = @"Name,Telnum";
static NSUInteger const kCMPSearchMemberDefaultPageSize = 20;
//static NSString * const kCMPScopeSearchMemberDefaultType = @"5";

@interface CMPContactsSearchMemberProvider()<CMPDataProviderDelegate>
@property (copy, nonatomic) NSString *searchRequestID;
@property (copy, nonatomic) NSString *searchScopeRequestID;
@end

@implementation CMPContactsSearchMemberProvider

- (void)searchWithAccountID:(NSString *)accountID
                    keyword:(NSString *)keyword
                 pageNumber:(NSUInteger)pageNumber
                    success:(CMPContactsSearchMemberProviderSuccess)success
                       fail:(CMPContactsSearchMemberProviderFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPathFormat:kCMPSearchMemberUrl, (int)pageNumber, (int)kCMPSearchMemberDefaultPageSize];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"accId" : accountID ?: @"",
                                 @"key" : keyword ?: @"",
                                 @"type" : kCMPSearchMemberDefaultType};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{kSuccessBlock : success,
                              kFailBlock : fail};
    self.searchRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)searchScopeWithBusinessID:(NSString *)businessID
                          keyword:(NSString *)keyword
                       pageNumber:(NSUInteger)pageNumber
                          success:(CMPContactsSearchMemberProviderSuccess)success
                             fail:(CMPContactsSearchMemberProviderFail)fail {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPathFormat:kCMPSearchMemberUrl, (int)pageNumber, (int)kCMPSearchMemberDefaultPageSize];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"accId" : businessID,
                                 @"type" : kCMPSearchMemberDefaultType,
                                 @"key" : keyword};
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{kSuccessBlock : success,
                              kFailBlock : fail};
    self.searchScopeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)cancel {
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.searchRequestID];
    [[CMPDataProvider sharedInstance] cancelWithRequestId:self.searchScopeRequestID];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    CMPContactsSearchMemberProviderSuccess successBlock = aRequest.userInfo[kSuccessBlock];
    CMPContactsSearchMemberResponse *response = [CMPContactsSearchMemberResponse yy_modelWithJSON:aResponse.responseStr];
    if (successBlock) {
        successBlock(response);
    }
    if ([aRequest.requestID isEqualToString:self.searchRequestID]) {
        
    } else if ([aRequest.requestID isEqualToString:self.searchScopeRequestID]) {
        
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    CMPContactsSearchMemberProviderFail failBlock = aRequest.userInfo[kFailBlock];
    if (failBlock) {
        failBlock(error);
    }
}

@end
