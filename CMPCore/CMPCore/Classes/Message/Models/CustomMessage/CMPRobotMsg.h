//
//  CMPRobotMsg.h
//  M3
//
//  Created by Shoujian Rao on 2022/2/24.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPRobotMsg : RCMessageContent

@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *pierceUrl;

@end

NS_ASSUME_NONNULL_END
