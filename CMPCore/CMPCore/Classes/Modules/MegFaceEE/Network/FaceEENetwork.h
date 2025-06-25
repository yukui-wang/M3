//
//  FaceEENetwork.h
//  FaceIDFaceAuth
//
//  Created by Megvii on 2021/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccess)(NSInteger statusCode, NSDictionary*_Nullable responseObject, NSString *_Nullable errorHint);
typedef void(^RequestFailure)(NSInteger statusCode, NSError*_Nullable error);

@interface FaceEENetwork : NSObject

@property (nonatomic, strong) NSString *pushClientId;

+ (instancetype)singleton;

- (void)credentialWithUserName:(NSString *)userName skipVerification:(BOOL)skipVerification clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

- (void)createBizInfoWithmessage:(NSDictionary *)message clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

- (void)createQrCodeWithBizInfoToken:(NSString *)bizInfoToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

- (void)getEnterpriseMessageWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;

//获取用户信息
- (void)check_usernames:(NSArray *)userNameStrArr clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret endpoint:(NSString *)endpoint success:(RequestSuccess)successBlock failure:(RequestFailure)failureBlock;
@end

NS_ASSUME_NONNULL_END
