//
//  CMPRobotAtMsg.h
//  M3
//
//  Created by Shoujian Rao on 2022/2/24.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPRobotAtMsg : RCMessageContent
@property (nonatomic, copy) NSString *noticeMemberId;
@property (nonatomic, copy) NSString *noticeMemberName;
@property (nonatomic, copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
