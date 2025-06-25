//
//  CMPSelectContactViewController.h
//  M3
//
//  Created by youlin guo on 2018/2/2.
//

#import <CMPLib/CMPBannerViewController.h>
#import <RongIMKit/RongIMKit.h>
#import "CMPMessageObject.h"

#define kDidForwardSucess @"kDidForwardV5MsgToRCMsgSucess"
#define kDidForwardFail @"kDidForwardV5MsgToRCMsgFail"

#define kDidOneByOneForwardSucess @"kDidOneByOneForwardSucess"

typedef NS_ENUM(NSInteger, CMPForwardSourceType) {
    CMPForwardSourceTypeOnlySingleMessage,
    CMPForwardSourceTypeSingleMessages,
    CMPForwardSourceTypeMergeMessage,
    CMPForwardSourceTypeOther
};

typedef void (^CompleteBlock)(NSArray *conversationList);

@interface CMPSelectContactViewController : CMPBannerViewController

/* 分享至致信的数据字典 */
@property (strong, nonatomic) NSDictionary *shareToUcDic;
///* 是否是外部分享 */
//@property (assign, nonatomic) BOOL isSharedFromOtherApps;
/* filePath */
@property (copy, nonatomic) NSString *filePath;
/* 多文件分享路径 */
@property (strong, nonatomic) NSArray *filePaths;

@property(nonatomic, retain) RCMessageModel *msgModel;
@property(nonatomic, copy) NSString *targetId;//聊天界面传,当前会话ID
@property (nonatomic, copy) void (^forwardSucessWithMsgObj)(CMPMessageObject *msgObj, NSArray *fileList);//转发成功
@property (nonatomic, copy) void(^forwardSucessWithMsgObjExt)(NSArray *cids,id ext);
@property (nonatomic, copy) void (^forwardSucess)(void);//转发成功
@property (nonatomic, copy) void (^forwardFail)(NSInteger errorCode);//转发失败
@property (nonatomic, copy) void (^forwardCancel)(void);//转发取消
@property (nonatomic, copy) void (^willForwardMsg)(NSString *targetId);//即将转发

@property(nonatomic, strong) NSArray<RCMessageModel *> *selectedMessages;
@property (nonatomic, assign) CMPForwardSourceType forwardSource;
@property (nonatomic, copy) CompleteBlock getSelectContactFinishBlock;

@property (nonatomic) RCConversationType conversationType;//当前会话的会话类型

//处理发起聊天的插件，如果是转发状态，则返回yes
+ (BOOL)handleUCStartChatPage:(NSString*)chatId bGroup:(BOOL)group chatTitle:(NSString*)title;
- (void)showForwardView:(CMPMessageObject*)object;
+(void)cleanStatic;

@end
