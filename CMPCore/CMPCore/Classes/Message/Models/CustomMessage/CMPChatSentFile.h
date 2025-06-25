//
//  CMPChatSentFile.h
//  M3
//
//  Created by MacBook on 2019/10/23.
//

#import <Foundation/Foundation.h>

@class RCFileMessage,RCImageMessage,CMPVideoMessage,RCGIFMessage;


NS_ASSUME_NONNULL_BEGIN

@interface CMPChatSentFile : NSObject

/* RCImageMessage */
@property (strong, nonatomic) RCImageMessage *imageMsg;
/* message */
@property (strong, nonatomic) RCFileMessage *fileMsg;
/* CMPVideoMessage */
@property (strong, nonatomic) CMPVideoMessage *videoMsg;
/* gifMessage */
@property (strong, nonatomic) RCGIFMessage *gifMsg;
/* dic */
@property (copy, nonatomic) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
