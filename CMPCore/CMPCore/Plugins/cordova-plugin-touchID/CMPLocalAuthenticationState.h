//
//  CMPLocalAuthenticationState.h
//  M3
//
//  Created by CRMO on 2019/1/18.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocalAuthenticationState : CMPObject

@property (assign, nonatomic) BOOL enableLoginTouchID;
@property (assign, nonatomic) BOOL enableLoginFaceID;

+ (void)updateWithJson:(NSString *)json;
+ (NSString *)stateJson;
+(BOOL)updateFaceID:(BOOL)open;
+(BOOL)updateTouchID:(BOOL)open;

@end

NS_ASSUME_NONNULL_END
