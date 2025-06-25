//
//  CMPOcrMainDataProvider.h
//  M3
//
//  Created by 张艳 on 2021/12/13.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMPOcrBaseSuccessBlock) (NSString *response,NSDictionary *userInfo);

typedef void(^CMPOcrBaseFailBlock) (NSError *response,NSDictionary *userInfo);

@interface CMPOcrMainDataProvider : CMPObject

+ (instancetype)sharedInstance;

- (NSString *)requestWithUrl:(NSString *)url
                      params:(NSDictionary *)params
                    userInfo:(NSDictionary *)userInfo
               handleCookies:(BOOL)handleCookies
                      method:(NSString *)method
                     success:(CMPOcrBaseSuccessBlock)successBlock
                        fail:(CMPOcrBaseFailBlock)failedBlock;

- (NSString *)getRequestWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(CMPOcrBaseSuccessBlock)successBlock
                           fail:(CMPOcrBaseFailBlock)failedBlock;

- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(CMPOcrBaseSuccessBlock)successBlock
                            fail:(CMPOcrBaseFailBlock)failedBlock;

- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                   handleCookies:(BOOL)handleCookies
                         success:(CMPOcrBaseSuccessBlock)successBlock
                            fail:(CMPOcrBaseFailBlock)failedBlock;

- (NSString *)downloadFileWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                        localPath:(NSString *)localPath
                          success:(CMPOcrBaseSuccessBlock)successBlock
                             fail:(CMPOcrBaseFailBlock)failedBlock;

- (void)cancelAllRequest;

- (void)cancelWithRequestId:(NSString *)requestId;
@end

NS_ASSUME_NONNULL_END
