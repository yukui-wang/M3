//
//  CMPFile.h
//  CMPCore
//
//  Created by youlin guo on 14-11-11.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPObject.h"
#import <CMPLib/CMPStringConst.h>

@interface CMPFile : CMPObject

+ (CMPFile *)fileWithPath:(NSString *)aPath;

@property (nonatomic, strong)NSString *fileID; // 文件id
@property (nonatomic, strong)NSString *fileName; // 文件名称
@property (nonatomic, strong)NSString *filePath; 
@property (nonatomic, strong)NSDictionary *userInfos;
@property (nonatomic, strong)NSMutableArray *requestCookies; // 请求cookies
@property (nonatomic, strong)NSString *from; // 来源
@property (nonatomic, strong)CMPFileFromType fromType; // 来源类型
@property (nonatomic, strong)NSString *lastModified; // 最后修改时间
@property (nonatomic, strong)NSString *origin; // 服务器地址
@property (nonatomic, strong) UIImage *image;

@end
