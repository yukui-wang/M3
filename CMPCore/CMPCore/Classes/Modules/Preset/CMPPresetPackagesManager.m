//
//  CMPPresetPackagesManager.m
//  M3
//
//  Created by Kaku Songu on 10/13/23.
//

#import "CMPPresetPackagesManager.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/ZipArchive.h>
#import <CMPLib/CMPAppManager.h>

#define kPresetPackagesServerHost @"host"
#define kPresetPackagesServerPort @"port"

@implementation CMPPresetPackagesManager

+(BOOL)ifNeedPresetHandle
{
    return NO;
    CMPServerModel *curServer = [CMPCore sharedInstance].currentServer;
    if (curServer) {
        if ([curServer.host containsString:kPresetPackagesServerHost]
            && [curServer.port isEqualToString:kPresetPackagesServerPort]) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)isCMPScheme{
    return YES;
}

+(NSArray *)handleServerAppList:(NSArray *)serverList movedComplete:(void(^)(BOOL success))movedComplete
{
    if (!serverList) {
        if (movedComplete) movedComplete(NO);
        return @[];
    }
    if (![CMPPresetPackagesManager ifNeedPresetHandle]) {
        if (movedComplete) movedComplete(NO);
        return serverList;
    }
    NSString *mainBundleZipPath = [[NSBundle mainBundle] pathForResource:@"m3files.zip" ofType:nil];
    if (!mainBundleZipPath) {
        if (movedComplete) movedComplete(NO);
        return serverList;
    }
    //1.将总应用包解压到cache目录下
    NSString *cachePath_parent = [CMPAppManager cmpAppCachePath];
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL ret = NO;
    if([zip UnzipOpenFile:mainBundleZipPath]) {
        ret = [zip UnzipFileTo:cachePath_parent overWrite:YES];
        [zip UnzipCloseFile];
    }
    if (!ret) {
        NSLog(@"m3files解压失败");
        if (movedComplete) movedComplete(NO);
        return serverList;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *_m3filesPath = [cachePath_parent stringByAppendingPathComponent:@"m3files"];
    if (![fileManager fileExistsAtPath:_m3filesPath]){
        NSLog(@"m3files文件夹不存在");
        if (movedComplete) movedComplete(NO);
        return serverList;
    }
    //2.遍历serverlist，将根据list里面的应用信息，定位到上面解压的m3files文件夹下的应用包
    //调用方法CMPAppManager storeAppWithZipPath
    //m3files文件夹下没找到的应用包放到数组里作为返回值返回供后续下载
    NSMutableArray *arr = [NSMutableArray array];
    NSString *m3Path = [_m3filesPath stringByAppendingPathComponent:@"m3"];
    NSString *v5Path = [_m3filesPath stringByAppendingPathComponent:@"v5"];
    
    NSError *_err;
    NSArray *_m3arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:m3Path error:&_err];
    if (_err) {
        if (movedComplete) movedComplete(NO);
        return serverList;
    }
    //数组里删掉了commons，不知为什么加载本地commons包，页面显示会出错
//    NSArray *m3AppNames = @[@"cmp",@"inspect",@"filemanage",@"application",@"message",@"my",@"search",@"todo"];
    NSMutableArray *m3AppNames = [NSMutableArray arrayWithArray:_m3arr];
    if ([m3AppNames containsObject:@"commons.zip"]) {
        [m3AppNames removeObject:@"commons.zip"];
    }
    for (NSDictionary *serverAppInfo in serverList) {
        NSString *appId = [serverAppInfo objectForKey:@"appId"];
        NSString *appName = [serverAppInfo objectForKey:@"appName"];
        NSString *md5 = [serverAppInfo objectForKey:@"md5"];
        NSString *aTitle = [NSString stringWithFormat:@"%@.zip", ([m3AppNames containsObject:[appName stringByAppendingString:@".zip"]] ? appName : appId)];
        NSString *_p1 = [([m3AppNames containsObject:[appName stringByAppendingString:@".zip"]] ? m3Path : v5Path) stringByAppendingPathComponent:aTitle];
        NSLog(@"p1p1:%@",_p1);
        if ([fileManager fileExistsAtPath:_p1]) {
            NSError *err = [CMPAppManager storeAppWithZipPath:_p1 md5:md5 restAppsMap:NO];
            if (err) {
                NSLog(@"store err:%@",err.domain);
            }
        }else{
            NSLog(@"local not find:%@",_p1);
            [arr addObject:serverAppInfo];
        }
    }
    if (movedComplete) movedComplete(YES);
    return arr;
}

@end
