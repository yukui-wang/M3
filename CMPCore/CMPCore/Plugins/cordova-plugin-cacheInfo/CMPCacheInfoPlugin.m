//
//  CMPCacheInfoPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/7/30.
//
//

#import "CMPCacheInfoPlugin.h"
#import <CMPLib/CMPCommonDBProvider.h>
#import <CMPLib/NSObject+Thread.h>
@implementation CMPCacheInfoPlugin

// 单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

// 遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath
{
    if (!folderPath) {
        return 0;
    }
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [CMPCacheInfoPlugin fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (NSString *)documentFullPathWithName:(NSString *)aName
{
    if (!aName) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains((NSDocumentDirectory), NSUserDomainMask, YES);
    NSString *aSpath =[paths objectAtIndex:0];
    return [aSpath stringByAppendingPathComponent:aName];
}

- (void)getCacheLength:(CDVInvokedUrlCommand *)command
{
    [self dispatchAsyncToChild:^{
        NSString *httpCachePath = [self documentFullPathWithName:@"httpCache"];
        NSString *faceImagePath = [self documentFullPathWithName:@"File/FaceImagePath"];
        NSString *tempPath = [self documentFullPathWithName:@"File/temp"];
        NSString *downloadPath = [self documentFullPathWithName:@"File/Download"];
        
        //        NSString *tmpDir = NSTemporaryDirectory();OA-109366门户前端【IOS端】：设置界面更改设置和清除缓存后退出登录，登录页点击登录后进入解锁界面，该界面未正确显示人员头像
        float aHttpCacheSize = [CMPCacheInfoPlugin folderSizeAtPath:httpCachePath];
        float downloadFileSize = [CMPCacheInfoPlugin folderSizeAtPath:downloadPath];
        float faceImageFileSize = [CMPCacheInfoPlugin folderSizeAtPath:faceImagePath];
        float tempFileSize = [CMPCacheInfoPlugin folderSizeAtPath:tempPath];
        
        float tmpSize = 0.0;// [CMPCacheInfoPlugin folderSizeAtPath:tmpDir];
        float tSize = aHttpCacheSize + downloadFileSize + tmpSize+faceImageFileSize+tempFileSize;
        NSString *cacheString = [NSString stringWithFormat:@"%.1fM",tSize];
        if ([cacheString isEqualToString:@"0.0M"]) {
            cacheString = @"0M";
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:cacheString];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (NSError *)deleteFolder:(NSString *)aPath
{
    __block NSError* error = nil;
    NSFileManager *aFileManager = [NSFileManager defaultManager];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:nil];
    if (exists) {
        [aFileManager removeItemAtPath:aPath error:&error];
    }
    return error;
}

- (void)clearCache:(CDVInvokedUrlCommand *)command {
    [self dispatchAsyncToChild:^{
        //清除WebView的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        NSString *httpCachePath = [self documentFullPathWithName:@"httpCache"];
        NSString *faceImagePath = [self documentFullPathWithName:@"File/FaceImagePath"];
        NSString *tempPath = [self documentFullPathWithName:@"File/temp"];
        NSString *downloadPath = [self documentFullPathWithName:@"File/Download"];
        
        //        NSString *tmpDir = NSTemporaryDirectory(); OA-109366门户前端【IOS端】：设置界面更改设置和清除缓存后退出登录，登录页点击登录后进入解锁界面，该界面未正确显示人员头像
        __block NSError* error = nil;
        error = [self deleteFolder:httpCachePath];
        error = [self deleteFolder:faceImagePath];
        error = [self deleteFolder:tempPath];
        error = [self deleteFolder:downloadPath];
        //清除缓存的同时要把数据库中的 头像 数据清空
        [[CMPCommonDBProvider sharedInstance] clearTableForClearCache];
        //        error = [self deleteFolder:tmpDir];
        CDVPluginResult *pluginResult = nil;
        if (error) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:11001],@"code",SY_STRING(@"common_deleteCacheFail"),@"message",@"",@"detail", nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clearCache success"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
