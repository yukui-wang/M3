//
//  CMPMassNotificationProvider.h
//  M3
//
//  Created by 程昆 on 2019/1/17.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPMassNotificationProvider : CMPObject

/**
 标记小广播消息已读
 */
- (void)readedMessage;

@end

NS_ASSUME_NONNULL_END
