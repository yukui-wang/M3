//
//  XZM3RequestManager.h
//  M3
//
//  Created by wujiansheng on 2019/3/8.
//

#import <Foundation/Foundation.h>


@interface XZM3RequestManager : NSObject

+ (instancetype)sharedInstance;


- (NSString *)requestWithUrl:(NSString *)url
                      params:(NSDictionary *)params
                    userInfo:(NSDictionary*)userInfo
               handleCookies:(BOOL)handleCookies
                      method:(NSString *)method
                     success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                        fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock;
- (NSString *)getRequestWithUrl:(NSString *)url
                         params:(NSDictionary *)params
                        success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                           fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock;
- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                            fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock;
- (NSString *)postRequestWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                   handleCookies:(BOOL)handleCookies
                         success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                            fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock;

- (NSString *)downloadFileWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                        localPath:(NSString *)localPath
                          success:(void(^)(NSString *response,NSDictionary* userInfo))successBlock
                             fail:(void(^)(NSError *error,NSDictionary* userInfo))failedBlock;
- (void)cancelAllRequest;
- (void)cancelWithRequestId:(NSString *)requestId;

@end
