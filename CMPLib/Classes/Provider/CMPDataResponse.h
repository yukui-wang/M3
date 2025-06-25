//
//  MDataResponse.h
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPDataResponse : CMPObject

@property (nonatomic, retain)NSString *responseStr; // 返回的数据
@property (nonatomic, retain)NSData *responseData; // 返回二进制数据
@property (nonatomic, retain)NSString *downloadDestinationPath; //文件下载路径
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, assign) NSInteger responseStatusCode;//请求响应码

@end
