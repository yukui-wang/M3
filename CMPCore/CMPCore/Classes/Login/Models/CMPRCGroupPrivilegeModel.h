//
//  CMPRCGroupPrivilegeModel.h
//  M3
//
//  Created by CRMO on 2018/7/4.
//

#import "CMPBaseResponse.h"

@interface CMPRCGroupPrivilegeModel : CMPBaseResponse

@property (strong, nonatomic) NSDictionary *data;

/** 发送文件权限 **/
@property (assign, nonatomic) BOOL sendFile;
/** 接收文件权限 **/
@property (assign, nonatomic) BOOL receiveFile;

@end
