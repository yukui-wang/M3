//
//  CMPImageHelper.m
//  CMPLib
//
//  Created by youlin on 2020/3/30.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPImageHelper.h"
#import <CMPLib/CMPFileManager.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CMPLib/CMPFileDownloadManager.h>
#import <UIKit/UIKit.h>
#import "CMPDevicePermissionHelper.h"
@interface CMPImageHelper() {
    NSInteger downloadCount;
    NSMutableArray *_downloadFileIDs;
}
@property (nonatomic, copy) void(^start)(void);
@property (nonatomic, copy) void(^success)(void);
@property (nonatomic, copy) void(^failed)(NSError *error);
@property (nonatomic, copy) void(^complete)(void);
@end

@implementation CMPImageHelper

- (void)dealloc
{
    for (NSString *aFileID in _downloadFileIDs) {
        [[CMPFileDownloadManager defaultManager] cancelDownloadWithFileId:aFileID];
    }
}

- (void)addFileId:(NSString *)aFileID
{
    if (!_downloadFileIDs) {
        _downloadFileIDs = [[NSMutableArray alloc] init];
    }
    [_downloadFileIDs addObject:aFileID];
}

- (void)saveToPhotoAlbum:(NSArray *)images start:(void(^)(void))start success:(void(^)(void))success failed:(void(^)(NSError *error))failed complete:(void(^)(void))complete
{
    self.start = start;
    self.success = success;
    self.failed = failed;
    self.complete = complete;
    NSInteger count = images.count;
    downloadCount = count;
    if (downloadCount > 0) {
        if (start) {
            start();
        }
    }
    // 获取相册权限
    [self getPhotoAlbumAuthorizationSuccess:^{
        for (NSDictionary *aDict in images) {
            NSString *aType = aDict[@"type"];
            if ([aType isEqualToString:@"image"]) {
                id obj = aDict[@"value"];
                if ([obj isKindOfClass:[UIImage class]]) {
                    [self saveImageToAlbum:(UIImage *)obj];
                }
                else if ([obj isKindOfClass:[NSData class]]) {
                    [self saveDataToAlbum:(NSData *)obj];
                }
                else {
                    NSString *aUrl = aDict[@"url"];
                    NSString *fileID = aUrl.sha1;
                    NSString *name = aDict[@"name"];
                    if ([NSString isNull:name]) {
                        name = [NSString stringWithFormat:@"%@.png", fileID];
                    }
                    [self addFileId:fileID];
                    [[CMPFileDownloadManager defaultManager] downloadWithFileID:fileID fileName:name lastModified:@"" url:aUrl start:^{
                        
                    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
                        
                    } success:^(NSString *localPath) {
                        UIImage *aImage = [UIImage imageWithContentsOfFile:localPath];
                        if (aImage) {
                            [self saveImageToAlbum:aImage];
                        }
                    } fail:^(NSError *error) {
                        [self handleFail:error];
                    }];
                }
            }
            else if ([aType isEqualToString:@"video"]) {
                NSString *filePath = aDict[@"filePath"];
                if ([NSString isNotNull:filePath] && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    continue;
                }
                NSString *aUrl = aDict[@"url"];
                NSString *name = aDict[@"name"];
                NSString *fileID = aUrl.sha1;
                if ([NSString isNull:name]) {
                    name = [NSString stringWithFormat:@"%@.mp4", fileID];
                }
                [self addFileId:fileID];
                [[CMPFileDownloadManager defaultManager] downloadWithFileID:fileID fileName:name lastModified:@"" url:aUrl start:^{
                    
                } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
                    
                } success:^(NSString *localPath) {
                    //保存视频到相册
                    NSString *path = [localPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    path = [path stringByRemovingPercentEncoding];
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                } fail:^(NSError *error) {
                    [self handleFail:error];
                }];
            }
        }
        
    } failed:^{
        // 没有权限
        if (failed) {
            failed(nil);
        }
        if (self.complete) {
            self.complete();
        }
    }];
}

- (void)saveDataToAlbum:(NSData *)data {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            CMPLog(@"保存视频到相册失败%@", error.localizedDescription);
            [self handleFail:error];
        }
        else {
            [self handleSuccess];
        }
    }];
}

- (void)saveImageToAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
}

- (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
    if (error) {
        CMPLog(@"保存视频到相册失败%@", error.localizedDescription);
        [self handleFail:error];
    }
    else {
        CMPLog(@"保存视频到相册成功");
        [self handleSuccess];
    }
}

/// 保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        CMPLog(@"保存视频到相册失败%@", error.localizedDescription);
        [self handleFail:error];
    }
    else {
        CMPLog(@"保存视频到相册成功");
        [self handleSuccess];
    }
}

- (void)handleSuccess {
    downloadCount --;
    if (downloadCount == 0) {
        if (self.complete) {
            self.complete();
        }
        if (self.success) {
            self.success();
        }
    }
}

- (void)handleFail:(NSError *)error {
    downloadCount --;
    if (downloadCount == 0) {
        if (self.complete) {
            self.complete();
        }
    }
    if (self.failed) {
        self.failed(error);
    }
}

- (void)getPhotoAlbumAuthorizationSuccess:(void(^)(void))success failed:(void(^)(void))failed {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        {
            NSString *app_Name = [[NSBundle mainBundle]
                                  objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_nophotos"),app_Name];
            [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"common_nophotostitle") messsage:alertTitle];
            if (failed) failed();
        }
            break;
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                if (status == PHAuthorizationStatusAuthorized) {
                    if (success) success();
                } else {
                    if (failed) failed();
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            if (success) success();
            break;
        case PHAuthorizationStatusLimited:
            if (success) success();
            break;
    }
}

@end
