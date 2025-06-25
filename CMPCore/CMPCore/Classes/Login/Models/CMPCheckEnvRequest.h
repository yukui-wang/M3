//
//  CMPCheckEnvRequest.h
//  M3
//
//  Created by CRMO on 2017/12/6.
//

#import "CMPBaseRequest.h"

@interface CMPCheckEnvRequest : CMPBaseRequest

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *cmpVersion;
@property (strong, nonatomic) NSString *client;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *port;

@end
