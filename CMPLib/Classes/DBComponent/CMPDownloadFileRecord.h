//
//  CMPDownloadFileRecord.h
//  CMPLib
//
//  Created by wujiansheng on 16/9/12.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPDownloadFileRecord : CMPObject
@property(nonatomic, strong)NSString *fileId;
@property(nonatomic, strong)NSString *fileName;
@property(nonatomic, strong)NSString *localName;
@property(nonatomic, strong)NSString *fileSuffix;
@property(nonatomic, strong)NSString *savePath;
@property(nonatomic, strong)NSString *origin;//下载时的标示
@property(nonatomic, strong)NSString *modifyTime;
@property(nonatomic, strong)NSString *createDate; // 创建时间
@property(nonatomic, strong)NSString *downloadTime;
@property(nonatomic, strong)NSString *creatorName;
@property(nonatomic, strong)NSString *fileSize;
@property(nonatomic, strong)NSString *serverId;
@property(nonatomic, strong)NSString *extend1;//新文件管理新增字段
@property(nonatomic, strong)NSString *extend2;//新文件管理 from字段
@property(nonatomic, strong)NSString *extend3;
@property(nonatomic, strong)NSString *extend4;
@property(nonatomic, strong)NSString *extend5;

- (NSString *)fullLocalPath;

@end
