//
//  CMPFileStatusReceiptMessage.h
//  CMPCore
//
//  Created by CRMO on 2017/9/14.
//
//

#import <RongIMKit/RongIMKit.h>

typedef NS_ENUM(NSInteger, CMPFileStatusReceipt) {
    CMPFileStatusReceiptNotDownload = 0,
    CMPFileStatusReceiptSending = 1,
    CMPFileStatusReceiptSendSuc = 2,
    CMPFileStatusReceiptOtherDownloadSuc = 4,
    CMPFileStatusReceiptSendFail = -1,
    CMPFileStatusReceiptSendCancel = -3
};

@interface CMPFileStatusReceiptMessage : RCMessageContent

/**
 额外信息
 */
@property (nonatomic, strong) NSString *extra;

/**
 消息类型：RC:OaMsg
 */
@property (nonatomic, strong) NSString *fileStatusReceipt;

@property (nonatomic, strong) NSString *msgUId;

@property (nonatomic, assign) CMPFileStatusReceipt status;

@end
