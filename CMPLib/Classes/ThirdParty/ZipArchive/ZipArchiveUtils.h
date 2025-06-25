//
//  ZipArchiveUtils.h
//  SeeyonCore
//
//  Created by administrator on 11-6-17.
//  Copyright 2011 北京致远协创软件有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZipArchiveUtils : NSObject {

}

// 压缩文件 (单个文件夹或单个文件)
+ (BOOL)zipArchive:(NSString *)aSourcePath
           zipPath:(NSString *)aZipPath;

// 解压文件 (只针对单个文件)
+ (BOOL)unZipArchive:(NSString *)aZipPath unzipto:(NSString *)aUnzipto;
+ (BOOL)unZipArchiveNOPassword:(NSString *)aZipPath unzipto:(NSString *)aUnzipto;

@end
