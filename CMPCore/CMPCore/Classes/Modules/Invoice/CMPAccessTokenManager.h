//
//  CMPAccessTokenManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/16.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAccessTokenManager : CMPObject

+(NSDictionary *)generateNewAccessTokenByParams:(NSDictionary *)params;
+(BOOL)verifyAccessTokenExperied:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
