//
//  CMPPrintPlugin.m
//  M3
//
//  Created by CRMO on 2019/2/21.
//

#import "CMPPrintPlugin.h"
#import <CMPLib/CMPPrintTools.h>
#import "CMPDownloadFileManager.h"
#import <CMPLib/CMPFileManager.h>

@interface CMPPrintPlugin ()<CMPDownloadFileManagerDelegate>

@property (nonatomic,strong)CMPPrintTools *printTool;
@property (nonatomic,assign)long long maxFileSize;

@end

@implementation CMPPrintPlugin

- (void)print:(CDVInvokedUrlCommand *)command
{
    NSString *callbackId = command.callbackId;
    NSDictionary *arguments = [command.arguments lastObject];
    NSString *path = arguments[@"path"];
    NSString *fileType = arguments[@"fileType"];
    long long maxFileSize = [arguments[@"maxFileSize"] longLongValue];
    self.maxFileSize = maxFileSize;
    if ([NSString isNull:path]) {
        NSDictionary *errorDict = @{
                                    @"code" : @"5004",
                                    @"message" : @"打印失败",
                                    @"detail" : @"参数异常"
                                    };
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[errorDict JSONRepresentation]];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    // 根据path判断是否为本地文件
    if ([[NSURL URLWithString:path] isFileURL]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            // 打印
        } else {
            NSDictionary *errorDict = @{
                                        @"code" : @"5004",
                                        @"message" : @"打印失败",
                                        @"detail" : @"文件不存在"
                                        };
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[errorDict JSONRepresentation]];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    else {
        // 下载后再打印
        NSString *aTitle = [NSString stringWithFormat:@"%@.%@", [path md5String], fileType];
        NSDictionary *aDownloadDict = @{
                                    @"url" : path,
                                    @"title" : aTitle,
                                    @"isSaveToLocal" : @"0"
                                    };
         [[CMPDownloadFileManager defaultManager] downloadFileWithInfo:aDownloadDict callbackId:command.callbackId delegate:self];
    }
}

- (void)isCanPrint:(CDVInvokedUrlCommand *)command {
    NSDictionary *infoDic = @{
                              @"canPrint":[CMPFeatureSupportControl isSupportPrint] ? @1 : @0
                              };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:infoDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark CMPDownloadFileManagerDelegate

- (void)managerDidFinishDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    if (!_printTool) {
        _printTool = [[CMPPrintTools alloc] init];
    }
    NSString *aFilePath = [info objectForKey:@"target"];
    long long fileSize = [CMPFileManager fileSizeAtPath:aFilePath];
    if (fileSize > self.maxFileSize) {
        NSDictionary *errorDict = @{
                                    @"code" : @"5006",
                                    @"message" : @"打印失败",
                                    @"detail" : @"文件大小超过限制"
                                    };
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[errorDict JSONRepresentation]];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    [_printTool printWithFilePath:aFilePath webview:nil success:^{
        
    } fail:^(NSError *error) {
        
    }];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}
- (void)managerDidFailDownloadFile:(NSDictionary *)info callbackId:(NSString *)callbackId {
    NSDictionary *errorDict = @{
                                @"code" : @"5004",
                                @"message" : @"打印失败",
                                @"detail" : @""
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end
