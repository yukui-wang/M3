//
//  CMPRCChatViewController.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/22.
//
//

#import <RongIMKit/RongIMKit.h>
#import "CMPRCBlockObject.h"

@class CMPGeneralBusinessMessageCell;

@interface CMPRCChatViewController : RCConversationViewController

/* 多文件发送时的多文件路径 */
@property (copy, nonatomic) NSArray *filePaths;

/* 群组信息 */
@property (nonatomic,strong)CMPRCGroupMemberObject *groupInfo;
@property (nonatomic,strong) NSArray<RCUserInfo *> *groupMemberList;

- (void)generalBusinessMessageCell:(CMPGeneralBusinessMessageCell *)cell didSelectedButton:(NSUInteger)index quickprocessRequestParam:(NSDictionary *)quickprocessRequestParam;

///文件发送
- (void)sendLocalFilesWithExtra:(NSDictionary *)extra mediaModel:(RCMediaMessageContent *)mediaModel;

/// 发送多文件分享过来的文件
- (void)sendFiesWtihFilePaths;

- (void)resetTitle:(NSString *)title;

///* willForward */
//@property (copy, nonatomic) void(^willForward)(void);
///* forwarSuccess */
//@property (copy, nonatomic) void(^forwardSuccess)(void);

@end
