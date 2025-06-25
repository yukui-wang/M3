//
//  RCCombineMessageUtility.h
//  RongIMKit
//
//  Created by liyan on 2019/8/26.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCCombineMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCCombineMessageUtility : NSObject

+ (NSString *)getCombineMessageSummaryTitle:(RCCombineMessage *)message;

+ (NSString *)getCombineMessagePreviewVCTitle:(RCCombineMessage *)message;

+ (NSString *)getCombineMessageSummaryContent:(RCCombineMessage *)message;

+ (BOOL)allSelectedCombineForwordMessagesAreLegal:(NSArray *)allSelectedMessages;

+ (BOOL)allSelectedOneByOneForwordMessagesAreLegal:(NSArray *)allSelectedMessages;

@end

NS_ASSUME_NONNULL_END
