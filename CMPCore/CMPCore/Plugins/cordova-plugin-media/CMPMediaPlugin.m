//
//  CMPMediaPlugin.m
//  M3
//
//  Created by 程昆 on 2020/2/17.
//

#import "CMPMediaPlugin.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPAVPlayerViewController.h>
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/CMPAVPlayerDownloadView.h>
#import <CMPLib/CMPCameraViewController.h>
#import <CMPLib/CMPBaseWebViewController.h>
#import <CMPLib/CMPStringConst.h>


@interface CMPMediaPlugin()

/* 上次同一方法调用时间 */
@property (assign, nonatomic) NSTimeInterval lastCalledTimeInterval;

@end

@implementation CMPMediaPlugin

- (void)playVideo:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = command.arguments.lastObject;
    NSTimeInterval nowTimeInterval = NSDate.date.timeIntervalSince1970;
    if (nowTimeInterval - self.lastCalledTimeInterval < 2.f) {
        CMPLog(@"方法重复快速调用");
        self.lastCalledTimeInterval = nowTimeInterval;
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"重复快速调用方法"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPLog(@"--- calling --- CMPMediaPlugin.playVideo----");
    self.lastCalledTimeInterval = nowTimeInterval;
    
    if ([params isKindOfClass:NSDictionary.class]) {
        BOOL onlinePlay = [params[@"onlinePlay"] boolValue];//是否支持在线播放,true,false
        NSString *path = params[@"path"];//视频url，在线播放就是网络地址，否则就是本地地址
        NSString *imageUrl = params[@"imageUrl"];//封面图片
        NSString *fileName = params[@"filename"];//文件名
        NSString *from = params[@"from"];
        CMPFileFromType fromType = CMPFileFromTypeComeFromM3;
        /**
         videoMenu :{
         fileId:
         orifgin:
         lastModified:
         }
         */
        NSDictionary *videoMenuKey = params[@"videoMenuKey"];
        /**
         extData :{
         collect: true/false  是否支持收藏
         save: true/false  是否支持保存
         share: true/fasle  是否支持分享
         }
         */
        NSDictionary *extData = params[@"extData"];
        
        if ([NSString isNull:path]) {
            
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:17001],@"code",SY_STRING(@"attach_path_empty"),@"message",@"",@"detail", nil];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        
        CMPBaseWebViewController *controller = nil;
        if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
            controller = (CMPBaseWebViewController *)self.viewController;
        }
        
        if (onlinePlay) {
            CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
            playerVc.isOnlinePlay = YES;
            playerVc.url = [NSURL URLWithPathString:path];
            playerVc.isFromControllerAllowRotation = controller.allowRotation;
            playerVc.fromType = fromType;
            if ([NSString isNotNull:imageUrl]) {
                playerVc.audioCoverImageUrlStr = imageUrl;
            }
            [self.viewController presentViewController:playerVc animated:YES completion:nil];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        NSString *fileId = extData[@"fileId"];
        if ([NSString isNull:path]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"fileId为空"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        NSString *origin = extData[@"origin"];
        NSString *lastModified = extData[@"lastModified"];
        
        if ([NSString isNull:origin]) {
            origin = @"";
        }
        if ([NSString isNull:lastModified]) {
            lastModified = @"";
        }
        if ([NSString isNull:from]) {
            from = @"";
        }
        
        
        BOOL isShowCollect = [videoMenuKey[@"collect"] boolValue] && [CMPFeatureSupportControl isSupportCollect];;
        BOOL isShowShare = [videoMenuKey[@"share"] boolValue];
        BOOL isShowSave = [videoMenuKey[@"save"] boolValue];
        
        NSString *localPath = [self.downloadTool localPathWithFileID:fileId lastModified:lastModified];
        if ([NSString isNotNull:localPath] && [[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
            playerVc.palyType = CMPAVPlayerPalyTypeVideo;
            playerVc.isOnlinePlay = onlinePlay;
            playerVc.fileName = fileName;
            playerVc.from = from;
            playerVc.fromType = fromType;
            playerVc.fileId = fileId;
            playerVc.autoSave = YES;
            playerVc.url = [NSURL URLWithPathString:localPath];
            playerVc.canNotShare = !isShowShare;
            playerVc.canNotCollect = !isShowCollect;
            playerVc.canNotSave = !isShowSave;
            playerVc.isFromControllerAllowRotation = controller.allowRotation;
            [self.viewController presentViewController:playerVc animated:YES completion:nil];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        
        NSString *fileSize = extData[@"fileSize"];
        if ([NSString isNull:fileSize]) {
            fileSize = @"0";
        }
        
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        CMPAVPlayerDownloadView *downloadView = [[CMPAVPlayerDownloadView alloc] initWithFrame:keyWindow.bounds];
        [downloadView setFileSize:[fileSize longLongValue]];
        [downloadView setCoverImage:imageUrl];
        [keyWindow addSubview:downloadView];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(downloadView) weakDownloadView = downloadView;
        downloadView.closeBtnClicked = ^{
            [[weakSelf downloadTool] cancelDownload];
            [weakDownloadView removeFromSuperview];
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"下载取消"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        };
        
        [self.downloadTool downloadWithFileID:fileId fileName:fileName lastModified:lastModified start:^{
            [downloadView setProgress:0];
        } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [downloadView setRecievedSize:(long long)recieveBytes];
                [downloadView setFileSize:(long long)totalBytes];
                [downloadView setProgress:progress];
            });
            
            CMPLog(@"---下载进度----%f",progress);
        } success:^(NSString *localPath) {
            [downloadView setProgress:1.f];
            [downloadView removeFromSuperview];
            
            CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
            playerVc.palyType = CMPAVPlayerPalyTypeVideo;
            playerVc.isOnlinePlay = onlinePlay;
            playerVc.from = from;
            playerVc.fromType = fromType;
            playerVc.fileName = fileName;
            playerVc.fileId = fileId;
            playerVc.autoSave = YES;
            playerVc.canNotShare = !isShowShare;
            playerVc.canNotCollect = !isShowCollect;
            playerVc.canNotSave = !isShowSave;
            playerVc.url = [NSURL URLWithPathString:localPath];
            playerVc.isFromControllerAllowRotation = controller.allowRotation;
            [self.viewController presentViewController:playerVc animated:YES completion:nil];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } fail:^(NSError *error) {
            [downloadView removeFromSuperview];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"下载失败"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}


- (void)playAudio:(CDVInvokedUrlCommand*)command {
    NSDictionary *parameter = [command.arguments firstObject];
    NSTimeInterval nowTimeInterval = NSDate.date.timeIntervalSince1970;
    if (nowTimeInterval - self.lastCalledTimeInterval < 2.f) {
        CMPLog(@"方法重复快速调用");
        self.lastCalledTimeInterval = nowTimeInterval;
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"重复快速调用方法"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    self.lastCalledTimeInterval = nowTimeInterval;
    
    BOOL onlinePlay = [parameter[@"onlinePlay"] boolValue];
    NSString *path = parameter[@"path"];
    NSString *imageUrl = parameter[@"imageUrl"];
    NSString *filename = parameter[@"filename"];
    NSString *from = parameter[@"from"];
    NSDictionary *extData = parameter[@"extData"];
    NSDictionary *videoMemuKey = parameter[@"videoMenuKey"];
    CMPFileFromType fromType = CMPFileFromTypeComeFromM3;
    if ([NSString isNull:path]) {
        NSDictionary *errorDict= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:17001],@"code",SY_STRING(@"attach_path_empty"),@"message",@"",@"detail", nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPBaseWebViewController *controller = nil;
    if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
        controller = (CMPBaseWebViewController *)self.viewController;
    }
    
    if (onlinePlay) {
        CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
        playerVc.palyType = CMPAVPlayerPalyTypeAudio;
        playerVc.isOnlinePlay = YES;
        playerVc.url = [NSURL URLWithPathString:path];
        playerVc.isFromControllerAllowRotation = controller.allowRotation;
        if ([NSString isNotNull:imageUrl]) {
            playerVc.audioCoverImageUrlStr = imageUrl;
        }
        [self.viewController presentViewController:playerVc animated:YES completion:nil];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSString *fileId = extData[@"fileId"];
    if ([NSString isNull:fileId]) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"fileId为空"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSString *origin = extData[@"origin"];
    NSString *lastModified = extData[@"lastModified"];
    NSString *fileSize = extData[@"fileSize"];
    if ([NSString isNull:origin]) {
        origin = @"";
    }
    if ([NSString isNull:lastModified]) {
        lastModified = @"";
    }
    if ([NSString isNull:from]) {
        from = @"";
    }
    
    BOOL isShowCollect = [videoMemuKey[@"collect"] boolValue] && [CMPFeatureSupportControl isSupportCollect];
    BOOL isShowShare = [videoMemuKey[@"share"] boolValue];
    BOOL isShowSave = NO;
    
    NSString *localPath = [self.downloadTool localPathWithFileID:fileId lastModified:lastModified];
    if ([NSString isNotNull:localPath] && [[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
        playerVc.palyType = CMPAVPlayerPalyTypeAudio;
        playerVc.canNotShare = !isShowShare;
        playerVc.canNotCollect = !isShowCollect;
        playerVc.canNotSave = !isShowSave;
        // playerVc.msgModel = model;
        playerVc.from = from;
        playerVc.fromType = fromType;
        playerVc.fileName = filename;
        playerVc.fileId = fileId;
        playerVc.autoSave = NO;
        playerVc.url = [NSURL URLWithPathString:localPath];
        playerVc.isFromControllerAllowRotation = controller.allowRotation;
        [self.viewController presentViewController:playerVc animated:YES completion:nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    CMPAVPlayerDownloadView *downloadView = [[CMPAVPlayerDownloadView alloc] initWithFrame:keyWindow.bounds];
    downloadView.downloadType = CMPAVPlayerDownloadTypeAudio;
    [downloadView setFileSize:[fileSize longLongValue]];
    [downloadView setCoverImage:imageUrl];
    [keyWindow addSubview:downloadView];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(downloadView) weakDownloadView = downloadView;
    downloadView.closeBtnClicked = ^{
        [[weakSelf downloadTool] cancelDownload];
        [weakDownloadView removeFromSuperview];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"下载取消"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    
    
    [self.downloadTool downloadWithFileID:fileId fileName:filename lastModified:lastModified start:^{
        [downloadView setProgress:0];
    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [downloadView setRecievedSize:(long long)recieveBytes];
            [downloadView setProgress:progress];
            [downloadView setFileSize:(long long)totalBytes];
        });
        CMPLog(@"---下载进度----%f",progress);
    } success:^(NSString *localPath) {
        [downloadView setProgress:1.f];
        [downloadView removeFromSuperview];
        
        CMPAVPlayerViewController *playerVc = CMPAVPlayerViewController.alloc.init;
        playerVc.palyType = CMPAVPlayerPalyTypeAudio;
        playerVc.canNotShare = !isShowShare;
        playerVc.canNotCollect = !isShowCollect;
        playerVc.canNotSave = !isShowSave;
        playerVc.from = from;
        playerVc.fromType = fromType;
        playerVc.fileName = filename;
        playerVc.fileId = fileId;
        playerVc.autoSave = YES;
        playerVc.url = [NSURL URLWithPathString:localPath];
        playerVc.isFromControllerAllowRotation = controller.allowRotation;
        [self.viewController presentViewController:playerVc animated:YES completion:nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } fail:^(NSError *error) {
        [downloadView removeFromSuperview];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"下载失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (CMPDownloadAttachmentTool *)downloadTool {
    CMPDownloadAttachmentTool *tool = objc_getAssociatedObject(self, @selector(downloadTool));
    if (!tool) {
        tool = [[CMPDownloadAttachmentTool alloc] init];
        objc_setAssociatedObject(self, @selector(downloadTool), tool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tool;
}

- (void)takePicture:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = command.arguments.lastObject;
    
    if (![params isKindOfClass:NSDictionary.class]) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    BOOL pictureEnable = [params[@"pictureEnable"] boolValue];//是否有拍照
    BOOL videoEnable = [params[@"videoEnable"] boolValue];//是否有拍视频
    if (!pictureEnable && !videoEnable) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"pictureEnable和videoEnable不能同时为false"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    
    CGFloat videoMaxLength = [params[@"videoMaxLength"] floatValue];//拍摄视频最长时长
    
    CMPCameraViewController *cameraVc = [CMPCameraViewController.alloc init];
    cameraVc.isNotShowTakePhoto = !pictureEnable;
    cameraVc.isNotShowTakeVideo = !videoEnable;
    cameraVc.videoMaxTime = videoMaxLength;
    cameraVc.usePhoto1Clicked = ^(NSString *imgPath, NSDictionary *videoInfo) {
        NSMutableDictionary *retParam = NSMutableDictionary.dictionary;
        retParam[@"success"] = @"true";
        NSMutableDictionary *file = NSMutableDictionary.dictionary;
            if ([NSString isNotNull:imgPath]) {
            file[@"filepath"] = imgPath;
            NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
            file[@"fileSize"] = @(imgData.length);
            file[@"type"] = imgPath.pathExtension;
        }
        else
        {
            NSString *path = [videoInfo[@"videoUrl"] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            file[@"filepath"] = path;
            file[@"fileSize"] = videoInfo[@"fileSize"];
            file[@"type"] = path.pathExtension;
        }
        NSArray *files = @[file];
        retParam[@"files"] = files;
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:retParam.copy];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    [self.viewController presentViewController:cameraVc animated:YES completion:nil];
    
}

@end
