//
//  CMPOfflineFile.h
//  CMPLib
//
//  Created by wujiansheng on 16/9/7.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import "CMPObject.h"

@interface CMPOfflineFileRecord : CMPObject
@property(nonatomic, copy)NSString *fileId;
@property(nonatomic, copy)NSString *fileName;
@property(nonatomic, copy)NSString *localName;
@property(nonatomic, copy)NSString *fileSuffix;
@property(nonatomic, copy)NSString *savePath;
@property(nonatomic, copy)NSString *origin;//下载时的标示
@property(nonatomic, copy)NSString *modifyTime;
@property(nonatomic, copy)NSString *createDate; // 创建时间
@property(nonatomic, copy)NSString *downloadTime;
@property(nonatomic, copy)NSString *creatorName;
@property(nonatomic, copy)NSString *fileSize;
@property(nonatomic, copy)NSString *serverId;
@property(nonatomic, copy)NSString *ownerId;
@property(nonatomic, copy)NSString *extend1;//新文件管理 图片缩略图路径
@property(nonatomic, copy)NSString *extend2;//新文件管理 from字段
@property(nonatomic, copy)NSString *extend3;//新文件管理 fromType; // 来源类型
@property(nonatomic, copy)NSString *extend4;//新文件管理 mineType
@property(nonatomic, copy)NSString *extend5;
- (NSString *)fullLocalPath;

@end
