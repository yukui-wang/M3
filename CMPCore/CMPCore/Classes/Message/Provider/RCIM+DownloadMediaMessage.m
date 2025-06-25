//
//  RCIM+DownloadMediaMessage.m
//  M3
//
//  Created by 程昆 on 2020/1/3.
//

#import "RCIM+DownloadMediaMessage.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPFileManager.h>

@implementation RCIM(DownloadMediaMessage)
@dynamic downloadingFileIds,downloadTool;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int progress))progressBlock
                     success:(void (^)(NSString *mediaPath))successBlock
                       error:(void (^)(RCErrorCode errorCode))errorBlock
                      cancel:(void (^)(void))cancelBlock {
    if ([self.downloadingFileIds.allKeys containsObject:@(messageId)]) {
        return;
    }
    
    [self.downloadingFileIds setObject:[cancelBlock copy] forKey:@(messageId)];
   
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    RCMediaMessageContent *content = (RCMediaMessageContent *)message.content;
    NSString *remoteUrl = content.remoteUrl;
    NSString *fileId = nil;
    if ([remoteUrl.lowercaseString hasPrefix:@"https"] || [remoteUrl.lowercaseString hasPrefix:@"http"]) {
        fileId = [CMPCommonTool getSourceIdWithUrl:remoteUrl];
    } else {
        fileId = remoteUrl;
    }
    
    NSString *fileName = content.name ?: [NSString stringWithFormat:@"file_cache_%@",fileId];
    fileId = [fileId appendHtmlUrlParam:@"ucFlag" value:@"yes"];
    
    [self.downloadTool downloadWithFileID:fileId fileName:fileName lastModified:@"" start:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *statusDic = @{ @"messageId" : @(messageId), @"type" : @"start" };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitDispatchDownloadMediaNotification"
                                                  object:nil
                                                  userInfo:statusDic];
        });
    } progressUpdate:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *statusDic =
                @{ @"messageId" : @(messageId),
                   @"type" : @"progress",
                   @"progress" : @(progress * 100) };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitDispatchDownloadMediaNotification"
                                                                object:nil
                                                              userInfo:statusDic];
            if (progressBlock) {
                progressBlock(progress * 100);
            }
        });
    } success:^(NSString *mediaPath) {
        [self.downloadingFileIds removeObjectForKey:@(messageId)];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *statusDic = @{ @"messageId" : @(messageId), @"type" : @"success", @"mediaPath" : mediaPath };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitDispatchDownloadMediaNotification"
                                                                object:nil
                                                              userInfo:statusDic];
            if (successBlock) {
                successBlock(mediaPath);
            }
        });
    } fail:^(NSError *error) {
        [self.downloadingFileIds removeObjectForKey:@(messageId)];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *statusDic = @{ @"messageId" : @(messageId), @"type" : @"error", @"errorCode" : @(ERRORCODE_TIMEOUT) };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitDispatchDownloadMediaNotification"
                                                                object:nil
                                                              userInfo:statusDic];
            if (errorBlock) {
                errorBlock(ERRORCODE_TIMEOUT);
            }
        });
    }];
}

- (BOOL)cancelDownloadMediaMessage:(long)messageId {
    if (![self.downloadingFileIds.allKeys containsObject:@(messageId)]) {
        return NO;
    }
    
    RCMediaMessageContent *content = (RCMediaMessageContent *)[[RCIMClient sharedRCIMClient] getMessage:messageId].content;
    NSString *fileId = [content.remoteUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
    [self.downloadTool cancelDownloadWithFileId:fileId];
    [self.downloadingFileIds removeObjectForKey:@(messageId)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *statusDic = @{ @"messageId" : @(messageId), @"type" : @"cancel" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitDispatchDownloadMediaNotification"
                                                            object:nil
                                                          userInfo:statusDic];
        void (^cancelBlock)(void) = [self.downloadingFileIds objectForKey:@(messageId)];
        if (cancelBlock) {
            cancelBlock();
        }
    });
    return YES;
}

#pragma clang diagnostic push

- (NSMutableDictionary *)downloadingFileIds {
    NSMutableDictionary *dictionary = objc_getAssociatedObject(self, @selector(downloadingFileIds));
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(downloadingFileIds), dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dictionary;
}

- (CMPDownloadAttachmentTool *)downloadTool {
    CMPDownloadAttachmentTool *tool = objc_getAssociatedObject(self, @selector(downloadTool));
    if (!tool) {
        tool = [[CMPDownloadAttachmentTool alloc] init];
        objc_setAssociatedObject(self, @selector(downloadTool), tool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tool;
}

@end


@interface RCMediaMessageContent(DownloadMediaMessage)

@end

@implementation RCMediaMessageContent(DownloadMediaMessage)

- (NSString *)localPath {
    NSString *localPath = objc_getAssociatedObject(self, @selector(localPath));
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
       return localPath;
    } else {
        localPath = nil;
    }
    if (!localPath) {
        NSString *fileId = [self.remoteUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
        localPath = [[RCIM sharedRCIM].downloadTool localPathWithFileID:fileId lastModified:@""];
        objc_setAssociatedObject(self, @selector(localPath), localPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return localPath;
}

-(void)setLocalPath:(NSString *)localPath {
    objc_setAssociatedObject(self, @selector(localPath), localPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface RCFileMessage(DownloadMediaMessage)

@end

@implementation RCFileMessage(DownloadMediaMessage)

- (NSString *)localPath {
    NSString *localPath = objc_getAssociatedObject(self, @selector(localPath));
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
       return localPath;
    } else {
        localPath = nil;
    }
    if (!localPath) {
        NSString *fileId = [self.remoteUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
        localPath = [[RCIM sharedRCIM].downloadTool localPathWithFileID:fileId lastModified:@""];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        localPath = [[CMPFileManager fileTempPath] stringByAppendingFormat:@"/%@",self.name];
    }
    objc_setAssociatedObject(self, @selector(localPath), localPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return localPath;
}

-(void)setLocalPath:(NSString *)localPath {
    objc_setAssociatedObject(self, @selector(localPath), localPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


