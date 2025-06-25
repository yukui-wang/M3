//
//  ZipArchiveUtils.m
//  SeeyonCore
//
//  Created by administrator on 11-6-17.
//  Copyright 2011 北京致远协创软件有限公司. All rights reserved.
//

#import "ZipArchiveUtils.h"
#import "zlib.h"
#import "ZipArchive.h"

#define kDownloadFileEncryptionKey		@"Ojojagoajogoi&%%#@!@*"


@implementation ZipArchiveUtils

+ (BOOL)zipArchive:(NSString *)aSourcePath 
		   zipPath:(NSString *)aZipPath  {
    NSLog(@"测试压缩路径zipedPath:%@",aZipPath);
	ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
  	BOOL ret = [zip CreateZipFile2:aZipPath Password:kDownloadFileEncryptionKey];
	if (ret) {
        BOOL isDirectory = NO;
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:aSourcePath isDirectory:&isDirectory];
        if (!fileExist) {
            //文件不存在直接返回
            NSLog(@"压缩文件不存在");
            return NO;
        }
        
        if (isDirectory) {
            NSArray *fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aSourcePath error:nil];
            for (NSString *fileName in fileContents) {
                NSString *filePath = [aSourcePath stringByAppendingPathComponent:fileName];
                ret = [zip addFileToZip:filePath newname:fileName];
            }
        }else{
            NSString *fileName = [aSourcePath lastPathComponent];
            ret = [zip addFileToZip:aSourcePath newname:fileName];
        }
	}
	ret = [zip CloseZipFile2];
//	[zip release];
	return ret;
}

+ (BOOL)unZipArchive:(NSString *)aZipPath unzipto:(NSString *)aUnzipto{
	ZipArchive *zip = [[ZipArchive alloc] init];
	BOOL ret = NO;
	if([zip UnzipOpenFile:aZipPath Password:kDownloadFileEncryptionKey]) {
		ret = [zip UnzipFileTo:aUnzipto overWrite:YES];
		[zip UnzipCloseFile];
	}
	[zip release];
	return ret;
}
+ (BOOL)unZipArchiveNOPassword:(NSString *)aZipPath unzipto:(NSString *)aUnzipto{
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = NO;
    if([zip UnzipOpenFile:aZipPath]) {
        ret = [zip UnzipFileTo:aUnzipto overWrite:YES];
        [zip UnzipCloseFile];
    }
    [zip release];
    return ret;
}

@end
