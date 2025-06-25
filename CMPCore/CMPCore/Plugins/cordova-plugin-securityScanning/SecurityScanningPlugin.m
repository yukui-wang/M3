//
//  SecurityScanningPlugin.m
//  M3
//
//  Created by 程昆 on 2019/6/13.
//

#import "SecurityScanningPlugin.h"
#import <CMPLib/CMPCore.h>
#import "CMPLocalAuthenticationTools.h"
#import "CMPLocalAuthenticationState.h"
#import <CMPLib/CMPSafeUtils.h>

@implementation SecurityScanningPlugin

- (void)checkGesture:(CDVInvokedUrlCommand *)command {
    
    NSInteger aState = [CMPCore sharedInstance].currentUser.gestureMode;
    NSDictionary *resultDic = @{
                                @"pass":[NSNumber numberWithInteger:aState]
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)checkFingerprint:(CDVInvokedUrlCommand *)command {
    ////{"faceID":{"login":1,"salary":1},"touchID":{"login":1,"salary":1}}
    NSString *state = [CMPLocalAuthenticationState stateJson];
    NSDictionary *stateDic = [state JSONValue];
    NSInteger aState = [stateDic[@"touchID"][@"login"] integerValue];
    NSDictionary *resultDic = @{
                                @"pass":[NSNumber numberWithInteger:aState]
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
    
}

- (void)checkFaceID:(CDVInvokedUrlCommand *)command {
    NSString *state = [CMPLocalAuthenticationState stateJson];
    NSDictionary *stateDic = [state JSONValue];
    NSInteger aState = [stateDic[@"faceID"][@"login"] integerValue];
    NSDictionary *resultDic = @{
                                @"pass":[NSNumber numberWithInteger:aState]
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)checkHttps:(CDVInvokedUrlCommand *)command {
    BOOL isHttps = [[CMPCore sharedInstance].serverurl hasPrefix:@"https"];
    NSNumber *aState = isHttps ? @1 : @0;
    NSDictionary *resultDic = @{
                                @"pass":aState
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)checkProxy:(CDVInvokedUrlCommand *)command {
    NSNumber *aState = [CMPSafeUtils checkHTTPEnable] ? @0 : @1;
    NSDictionary *resultDic = @{
                                @"pass":aState
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)checkTmpFile:(CDVInvokedUrlCommand *)command {
    [self dispatchAsyncToChild:^{
        NSString *downloadPath = [self documentFullPathWithName:@"File/Download"];
        float downloadFileSize = [SecurityScanningPlugin folderSizeAtPath:downloadPath];
        NSNumber *aState = downloadFileSize ? @0 : @1;
        NSDictionary *resultDic = @{
                                    @"pass":aState
                                    };
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [self dispatchAsyncToMain:^{
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
    
}

- (void)checkRoot:(CDVInvokedUrlCommand *)command {
    NSNumber *aState = [CMPSafeUtils isJailbreak] ? @0 : @1;
    NSDictionary *resultDic = @{
                                @"pass":aState
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)checkNotification:(CDVInvokedUrlCommand *)command {
    NSNumber *aState = ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIRemoteNotificationTypeNone) ? @0 : @1;
    NSDictionary *resultDic = @{
                                @"pass":aState
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


#pragma mark - ToolMethod

- (NSString *)documentFullPathWithName:(NSString *)aName {
    if (!aName) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains((NSDocumentDirectory), NSUserDomainMask, YES);
    NSString *aSpath =[paths objectAtIndex:0];
    return [aSpath stringByAppendingPathComponent:aName];
}

// 遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath {
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
        folderSize += [SecurityScanningPlugin fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

// 单个文件的大小
+ (long long)fileSizeAtPath:(NSString*) filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//- (void)clearTmpFile:(CDVInvokedUrlCommand *)command {
//    NSDictionary *arguments = [command.arguments lastObject];
//    NSString *path = arguments[@"value"];
//
//}


@end
