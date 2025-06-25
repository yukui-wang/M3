//
//  DownLoadPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/8/8.
//
//

#import "DownLoadPlugin.h"
#import "CMPDownloadFileManager.h"

@interface DownLoadPlugin()<CMPDownloadFileManagerDelegate>


@end

@implementation DownLoadPlugin

- (void)dealloc
{
    [[CMPDownloadFileManager defaultManager] removeDelegate:self];
    [super dealloc];
}

- (void)download:(CDVInvokedUrlCommand *)command
{
    NSDictionary *argumentsMap = [command.arguments firstObject];
    [[CMPDownloadFileManager defaultManager] downloadFileWithInfo:argumentsMap callbackId:command.callbackId delegate:self];
}

#pragma mark CMPDownloadFileManagerDelegate

- (void)managerDidFinishDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)managerDidFailDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end
