//
//  CMPPCCreateGroupMessage.m
//  M3
//
//  Created by 程昆 on 2020/3/5.
//

#import "CMPPCCreateGroupMessage.h"

@implementation CMPPCCreateGroupMessage

/*!
 返回消息的存储策略
 */
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}


/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:CreateGroupTaskMsg";
}

@end
