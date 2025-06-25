//
//  CMPDeviceBindRequest.h
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPBaseRequest.h"

@interface CMPDeviceBindRequest : CMPBaseRequest

@property (strong, nonatomic) NSString *loginName;
@property (strong, nonatomic) NSString *clientName;
@property (strong, nonatomic) NSString *longClientName;
@property (strong, nonatomic) NSString *clientNum;
@property (strong, nonatomic) NSString *clientType;
@property (strong, nonatomic) NSString *login_mobliephone;

- (instancetype)initWithLoginName:(NSString *)loginName phone:(NSString *)phone serverUrl:(NSString *)url serverVersion:(NSString *)serverVersion serverContextPath:(NSString *)contextPath;

@end
