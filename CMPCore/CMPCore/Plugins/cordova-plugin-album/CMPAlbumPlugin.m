//
//  CMPAlbumPlugin.m
//  M3
//
//  Created by 程昆 on 2019/12/19.
//

#import "CMPAlbumPlugin.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/NSString+CMPString.h>

@interface CMPAlbumPlugin (){
    NSOperationQueue *_operationQueue;
}
@end

@implementation CMPAlbumPlugin

- (void)dealloc
{
    [_operationQueue cancelAllOperations];
    _operationQueue = nil;
}

- (void)getAlbumPictures:(CDVInvokedUrlCommand *)command
{
    NSDictionary *param = command.arguments.lastObject;
    NSInteger number = 9;//默认,与Android一致
    if([param isKindOfClass:[NSDictionary class]] && [param.allKeys containsObject:@"size"]) {
      number = [param[@"size"] integerValue];
    }
    PHAssetCollection *cameraRollCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    PHFetchResult<PHAsset *> *albumAssets = [PHAsset fetchAssetsInAssetCollection:cameraRollCollection options:nil];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = YES;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = NO;
    BOOL isMoreThanSize  = albumAssets.count > number;
    // 是否要原图
    BOOL original = YES;
    __block int i = 0;
    NSMutableArray *filesArr = [NSMutableArray array];
    if (albumAssets.count == 0 || number == 0) {
        [self hanldePluginResult:command.callbackId result:filesArr];
        return;
    }
    
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue addOperationWithBlock:^{
        [albumAssets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetMediaType fileType = asset.mediaType;
            CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) :  CGSizeMake(300, 300);
            if (fileType == PHAssetMediaTypeImage) {
                i++;
                if (isMoreThanSize && (i == number)) {
                    *stop = YES;
                }
                // 获取文件图片
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    NSLog(@"循环次数！！");
                    // result为文件图片
                    // info其他信息
                    if ([info[@"PHImageResultIsDegradedKey"] boolValue]) {
                        return;
                    }
                    NSMutableDictionary *fileItemDic = [self saveImgFile:result name:nil idx:idx];
                    [filesArr addObject:fileItemDic];
                    if (isMoreThanSize && (filesArr.count == number)) {
                        [self hanldePluginResult:command.callbackId result:filesArr];
                    }else if (!isMoreThanSize && filesArr.count == albumAssets.count) {
                        [self hanldePluginResult:command.callbackId result:filesArr];
                    }
                }];
            }
        }];
    }];
}

- (NSMutableDictionary *)saveImgFile:(UIImage *)result name:(NSString *)name idx:(NSUInteger)idx
{
    if (result == nil) {
        return [NSMutableDictionary dictionary];
    }
    NSString *fileName = [NSString stringWithFormat:@"cmp_iamge_%lu.png",(unsigned long)idx];
    NSString *filePath = [[CMPFileManager fileTempPath] stringByAppendingPathComponent:fileName];
    NSData *data = UIImagePNGRepresentation(result);
    [data writeToFile:filePath atomically:YES];
    NSString *size = [NSString stringWithLongLong:[CMPFileManager fileSizeAtPath:filePath]];
    NSMutableDictionary *fileItemDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"filepath" : filePath,
        @"fileSize": size,
        @"type": @"png",
        @"idx":@(idx)
    }];
    return fileItemDic;
}

- (void)hanldePluginResult:(NSString *)aCallbackId result:(NSMutableArray *)aResult
{
    NSMutableArray *removeArr = [NSMutableArray array];
    [aResult enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            [removeArr addObject:obj];
        }
    }];
    [aResult removeObjectsInArray:removeArr];
    [aResult sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2[@"idx"] compare:obj1[@"idx"]];
    }];
    NSDictionary *dic = @{
        @"files" : aResult
    };
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallbackId];
    }];
}

@end
