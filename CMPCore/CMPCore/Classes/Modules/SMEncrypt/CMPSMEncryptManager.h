//
//  CMPSMEncryptManager.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/2/22.
//

#import <CMPLib/CMPObject.h>
#import <GMObjC/GMObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPSMEncryptManager : CMPObject

@property (nonatomic,copy) NSString *sm4Key;
@property (nonatomic,strong) NSArray *sm2KeyPair;

+(instancetype)shareInstance;

-(NSString *)encryptText:(NSString *)text;
-(NSString *)decryptText:(NSString *)text;
//-(NSData *)encryptData:(NSData *)data;
//-(NSData *)decryptData:(NSData *)data;
+(NSString *)mixStr;

@end

NS_ASSUME_NONNULL_END
