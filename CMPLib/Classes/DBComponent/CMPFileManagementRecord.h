//
//  CMPFileManagementRecord.h
//  CMPLib
//
//  Created by MacBook on 2019/10/14.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CMPLib/CMPStringConst.h>
#import "CMPFileTypeHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPFileManagementRecord : NSObject

/* 文件id */
@property (copy, nonatomic) NSString *fileId;
/* 文件名 */
@property (copy, nonatomic) NSString *fileName;
/* 文件原始下载(zip) Url */
@property (copy, nonatomic) NSString *fileUrl;
/* 文件保存在本地的路径 */
@property (copy, nonatomic) NSString *filePath;
/* mimeType,如"image/png" */
@property (copy, nonatomic) NSString *fileType;
/* 文件大小，单位 B，由 H5 去格式化 */
@property (copy, nonatomic) NSString *fileSize;
/* 文件最后修改时间，long 型，由 H5 去格式化 */
@property (assign, nonatomic) long long lastModify;
/* 文件来源 */
@property (copy, nonatomic) NSString *from;
/* 文件来源类型，存储的是国家化来源的key */
@property (copy, nonatomic) CMPFileFromType fromType;
/* 是否被筛选标记过，用于重名文件筛选 */
@property (assign, nonatomic) BOOL isMarked;


/* origin */
@property (copy, nonatomic) NSString *origin;
/* 是否是来自致信 */
@property (assign, nonatomic) BOOL isUc;
/* 不显示的分享入口 : uc,wechat,dingding,qq,download,collect,other,print,screenDisplay*/
@property (strong, nonatomic) NSArray *notShowShareIcons;
@property (copy, nonatomic) NSString *iconPath; // 用于图片缩略图

- (NSString *)jsonString;
+ (instancetype)modelWithJsonString:(NSString *)jsonString;

//- (void)setFullFilePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
