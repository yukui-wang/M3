//
//  CMPCheckEnvironmentModel.h
//  M3
//
//  Created by CRMO on 2017/11/3.
//

#import <CMPLib/CMPObject.h>

@interface CMPCheckEnvironmentModel : CMPObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *serverVersion;
@property (nonatomic, strong) NSString *serverID;
@property (nonatomic, strong) NSDictionary *updateServer;

- (BOOL)requestSuccess;

@end
