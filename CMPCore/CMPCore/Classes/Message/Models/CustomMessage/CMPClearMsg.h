//
//  CMPClearMsg.h
//  M3
//
//  Created by Shoujian Rao on 2022/11/1.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPClearMsg : RCMessageContent
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *title;
@end

NS_ASSUME_NONNULL_END
