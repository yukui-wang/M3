//
//  CMPFilePlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/1.
//
//

#import "CMPFilePlugin.h"
#import <CMPLib/CMPFileTypeHandler.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/NSData+Base64.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/NSObject+Thread.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPDevicePermissionHelper.h>


@interface CMPFilePlugin ()

@property(nonatomic, copy)NSString *base64CallbackId;

@end

@implementation CMPFilePlugin

- (void)dealloc
{
    self.base64CallbackId = nil;
    [super dealloc];
}

- (void)getFileInfo:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSArray *aFileList = [argumentsMap objectForKey:@"filepath"];
    NSMutableArray *aResult = [[[NSMutableArray alloc] init] autorelease];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *aFilePath in aFileList) {
        NSString *aStr = [aFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:aStr error:&error];
        if (fileAttributes != nil) {
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
            NSNumber *aFileSize = [fileAttributes objectForKey:NSFileSize];
            NSString *aFileType = [aFilePath pathExtension];
            NSString *aLastModified = @"";//[fileAttributes objectForKey:NSFileModificationDate];
            [mDict setObject:aFileSize forKey:@"fileSize"];
            [mDict setObject:aFileType forKey:@"type"];
            [mDict setObject:aFilePath forKey:@"filepath"];
            [mDict setObject:aLastModified forKey:@"lastModified"];
            [aResult addObject:mDict];
            [mDict release];
        }
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:aResult];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)saveBase64:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    NSString *type = [argumentsMap objectForKey:@"type"];
    
    if (type && [CMPFileTypeHandler fileType:type.uppercaseString]==kFileType_Image) {
        //图片保存
        AVAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
        {
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:20001],@"code",SY_STRING(@"common_noPermissionAlbums"),@"message",@"",@"detail", nil];
            NSString *app_Name = [[NSBundle mainBundle]
                                  objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            
            NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_nophotos"),app_Name];
            [CMPDevicePermissionHelper showAlertWithTitle:SY_STRING(@"common_nophotostitle") messsage:alertTitle];
            
            
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return ;
        }
        self.base64CallbackId = command.callbackId;

        NSString *base64 = [argumentsMap objectForKey:@"base64"];
        NSData *base64Data = [NSData base64Decode:base64];
        UIImage* image = [UIImage imageWithData:base64Data];
        [CMPCommonTool.sharedTool savePhotoWithImage:image target:self action:@selector(image:didFinishSavingWithError:contextInfo:)];
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code],@"code",error.description,@"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:result callbackId:self.base64CallbackId];

    }else{
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:SY_STRING(@"common_mobileAlbums"),@"target", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:result callbackId:self.base64CallbackId];
    }
}

- (void)readLocalFile:(CDVInvokedUrlCommand *)command {
    [self dispatchAsyncToChild:^{
        NSDictionary *argumentsMap = [command.arguments firstObject];
        NSString *url = [argumentsMap objectForKey:@"url"];
        NSURL *aUrl = [NSURL URLWithString:url];
        NSString *localPath = [CMPCachedUrlParser cachedPathWithUrl:aUrl];
        localPath = [NSURL URLWithString:localPath].path;
        NSLog(@"readLocalFile-log-begin");
        [argumentsMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"readLocalFile-%@=%@",key,obj);
        }];
        NSLog(@"readLocalFile-localPath=%@",localPath);
        if ([NSString isNull:localPath]) {
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:404],@"code",@"文件url错误",@"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            NSLog(@"readLocalFile-error=文件url错误");
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:localPath]) {
            // 文件不存在
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:404],@"code",@"文件不存在",@"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            NSLog(@"readLocalFile-error=文件不存在");
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:localPath error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue] / 1024 / 1024;
        // 如果文件大于5M，报错
        if (size > 5) {
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:503],@"code",@"文件大于5M",@"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            NSLog(@"readLocalFile-error=文件大于5M");
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        
        NSError *error = nil;
        NSString *fileContent = [NSString stringWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"readLocalFile-error=%@",error);
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:404],@"code",error.description,@"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
        NSLog(@"readLocalFile-fileContent=%@",fileContent);
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fileContent];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        NSLog(@"readLocalFile-log-end");
    }];
}


@end
