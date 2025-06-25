//
//  CMPClearMsgRemoteTextMessage.h
//  M3
//
//  Created by Shoujian Rao on 2024/5/16.
//

#import <RongIMLib/RongIMLib.h>

#define CMPClearMsgRemoteTextMessageIdentifier @"RC:CustomRemoteMsg"

@interface CMPClearMsgRemoteTextMessage : RCMessageContent<NSCoding>
@property (nonatomic, strong) NSString *content;
+ (instancetype)messageWithContent:(NSString *)content;

@end

