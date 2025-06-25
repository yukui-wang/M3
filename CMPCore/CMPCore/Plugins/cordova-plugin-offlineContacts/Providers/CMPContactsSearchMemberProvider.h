//
//  CMPContactsSerachMemberProvider.h
//  M3
//
//  Created by CRMO on 2017/11/24.
//

#import "CMPContactsSearchMemberResponse.h"

typedef void(^CMPContactsSearchMemberProviderSuccess)(CMPContactsSearchMemberResponse *response);
typedef void(^CMPContactsSearchMemberProviderFail)(NSError *error);

@interface CMPContactsSearchMemberProvider : CMPObject

/**
 搜索行政组织人员

 @param accountID 单位ID
 @param keyword 关键词
 @param pageNumber 页数
 @param success 成功回调
 @param fail 失败回调
 */
- (void)searchWithAccountID:(NSString *)accountID
                    keyword:(NSString *)keyword
                 pageNumber:(NSUInteger)pageNumber
                    success:(CMPContactsSearchMemberProviderSuccess)success
                       fail:(CMPContactsSearchMemberProviderFail)fail;

/**
 搜索多维组织人员

 @param businessID 多维组织ID
 @param keyword 搜索关键词
 @param pageNumber 页数
 @param success 成功回调
 @param fail 失败回调
 */
- (void)searchScopeWithBusinessID:(NSString *)businessID
                          keyword:(NSString *)keyword
                       pageNumber:(NSUInteger)pageNumber
                          success:(CMPContactsSearchMemberProviderSuccess)success
                             fail:(CMPContactsSearchMemberProviderFail)fail;

- (void)cancel;

@end
