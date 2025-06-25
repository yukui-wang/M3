//
//  SignMapPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/4.
//
//

#import "CMPLocationMarkPlugin.h"
#import "AppDelegate.h"
#import "CMPSignViewController.h"
#import <CMPLib/SDWebImageDownloader.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPFileManager.h>

NSString * const CMPLocationMarkPluginMapApi = @"http://restapi.amap.com/v3/staticmap?location=%@,%@&zoom=%@&scale=%@&size=%@&markers=mid,,A:%@,%@&key=%@";

@interface CMPLocationMarkPlugin ()<CMPSignViewControllerDelegate>

@property (nonatomic, copy) NSString *callbackId;
@property (strong, nonatomic) NSDictionary *resultDict;
@property (assign, nonatomic) BOOL showMap;
@property (strong, nonatomic) NSString *zoom;
@property (strong, nonatomic) NSString *scale;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) CMPSignViewController *signViewController;

@end

@implementation CMPLocationMarkPlugin

- (void)markLocation:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    NSDictionary *argumentsMap = [command.arguments firstObject];
    self.showMap = [argumentsMap[@"showMap"] boolValue];
    NSDictionary *extData = argumentsMap[@"extData"];
    if (extData && [extData isKindOfClass:[NSDictionary class]]) {
        self.zoom = extData[@"zoom"];
        self.scale = extData[@"scale"];
        self.size = extData[@"size"];
    }
    
    if ([NSString isNull:self.zoom]) {
        self.zoom = @"16";
    }
    if ([NSString isNull:self.scale]) {
        self.scale = @"1";
    }
    if ([NSString isNull:self.size]) {
        self.size = @"408*240";
    }
                                             
    self.signViewController = [[CMPSignViewController alloc] init];
    self.signViewController.delegate = self;
    [self.viewController presentViewController:self.signViewController animated:YES completion:nil];
}

- (void)sendSuccessResult {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.resultDict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [self dispatchAsyncToMain:^{
        [self.signViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)sendFailResultWithCode:(NSNumber *)code message:(NSString *)message {
    NSDictionary *errorDict = @{@"code" : code ,
                                @"message" : message,
                                @"detail" : @""};
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    [self dispatchAsyncToMain:^{
        [self.signViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark-
#pragma mark CMPSignViewControllerDelegate

- (void)signViewViewControllerDidCancel:(CMPSignViewController *)aViewController {
    [self sendFailResultWithCode:[NSNumber numberWithInteger:29002] message:SY_STRING(@"common_cancelLabeling")];
}

- (void)signViewViewControllerDidFail:(CMPSignViewController *)aViewController failError:(NSError *)error {
    [self sendFailResultWithCode:[NSNumber numberWithInteger:error.code] message:error.localizedDescription];
}

- (void)signViewViewController:(CMPSignViewController *)aViewController
                   withAddress:(SyAddress *)aAddress
               currentLoaction:(CLLocation *)aLocation
         withWebViewCommandKey:(NSString *)aWebViewCommandKey {
    self.resultDict = [aAddress deaultAddressDictionary];
    
    if (!self.showMap) {
        [self sendSuccessResult];
        return;
    }
    
    // 经度
    NSString *longtitude = self.resultDict[@"lbsLongitude"];
    // 纬度
    NSString *latitude = self.resultDict[@"lbsLatitude"];
    NSString *key = [CMPCommonManager lbsWebAPIKey];
    NSString *mapApi = [NSString stringWithFormat:CMPLocationMarkPluginMapApi, longtitude, latitude, self.zoom, self.scale, self.size, longtitude, latitude, key];
    NSURL *url = [NSURL URLWithString:mapApi];
    
    __weak __typeof(self)weakSelf = self;
    // 调用高德API，生成静态图片
    [[SDWebImageDownloader sharedDownloader]
     downloadImageWithURL:url
     options:SDWebImageDownloaderHighPriority
     progress:nil
     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         if (!image || !data || error) {
             [strongSelf sendFailResultWithCode:[NSNumber numberWithInteger:29002] message:@"高德地图API调用失败"];
             return;
         }
         NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
         NSString *tempPath = [CMPFileManager fileTempPath];
         NSString *tempName = [NSString stringWithFormat:@"map_%f", now];
         NSString *imagePath = [tempPath stringByAppendingPathComponent:tempName];
         BOOL result = [data writeToFile:imagePath atomically:YES];
         if (result) {
             [strongSelf.resultDict setValue:[NSString stringWithFormat:@"file://%@", imagePath] forKey:@"mapImagePath"];
             [strongSelf sendSuccessResult];
         } else {
             [strongSelf sendFailResultWithCode:[NSNumber numberWithInteger:29002] message:@"文件写入失败"];
         }
     }];
}

@end
