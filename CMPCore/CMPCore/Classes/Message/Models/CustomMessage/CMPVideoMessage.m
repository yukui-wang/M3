//
//  CMPVideoMessage.m
//  M3
//
//  Created by MacBook on 2019/12/23.
//

#import "CMPVideoMessage.h"
#import <CMPLib/NSData+Base64.h>
#import <CMPLib/NSString+CMPString.h>

@implementation CMPVideoMessage

- (NSData *)encode {
    NSData *superData = [super encode];
    __autoreleasing NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:superData options:kNilOptions error:&error];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    self.base64 = [NSData base64Encode:UIImageJPEGRepresentation(self.videoThumImage, 0.5)] ;
    [dataDict setObject:[NSNumber numberWithInteger:self.timeDuration] forKey:@"timeDuration"];
    [dataDict setObject:self.base64 forKey:@"base64"];
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        [super decodeWithData:data];
        
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:kNilOptions
                                          error:&error];
        if (dictionary) {
            self.timeDuration = [dictionary[@"timeDuration"] integerValue];
            self.base64 = dictionary[@"base64"];
            self.videoThumImage = [UIImage imageWithData:[NSData base64Decode:self.base64]];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

+ (instancetype)messageWithFile:(NSString *)localPath {
    RCFileMessage *fileMessage = [super messageWithFile:localPath];
    CMPVideoMessage *videoMessage = [[self alloc] init];
    videoMessage.name = fileMessage.name;
    videoMessage.size = fileMessage.size;
    videoMessage.type = fileMessage.type;
    videoMessage.fileUrl = fileMessage.fileUrl;
    videoMessage.localPath = fileMessage.localPath;
    videoMessage.extra = fileMessage.extra;
    videoMessage.senderUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    return videoMessage;
}

- (void)setTimeDuration:(NSInteger)timeDuration {
    _timeDuration = timeDuration;
    _showTime = [NSString timeFormatted:_timeDuration / 1000];
}


// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return @"[视频]";
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:VideoMsg";
}

@end
