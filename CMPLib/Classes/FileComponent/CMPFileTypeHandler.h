//
//  CMPFileTypeHandler.h
//  M1Core
//
//  Created by xiang fei on 12-2-24.
//  Copyright (c) 2012年 Seeyon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPConstant.h"

//文件MIneType
typedef enum : NSUInteger {
    CMPFileMineTypeAll = 0,
    CMPFileMineTypeFile,
    CMPFileMineTypeImage,
    CMPFileMineTypeVideo,
    CMPFileMineTypeAudio,
    CMPFileMineTypeUnknown
} CMPFileMineType;

@interface CMPFileTypeHandler : NSObject

+ (NSInteger)fileType:(NSString *)fileName;
+ (NSString *)getFileIcon:(id)aObeject;
+ (NSString *)getSize:(long long) aSize;
+ (NSString *)fileMIMETypeWithName:(NSString *)fName;
+ (BOOL )isEqualPicture:(NSString *)title;
+ (BOOL)isPictureBySuffix:(NSString *)suffix;
+ (NSString *)loadAttachmentImageForPhone:(NSString *)fileName;
+ (NSString *)getFileMineTypeWithFilePath:(NSString *)filePath;
+ (NSString *)mineTypeWithPathExtension:(NSString *)pathExtension;
//根据minetype 判断文件分类
+ (NSInteger)fileMineTypeWithMineType:(NSString *)mineType;
@end
