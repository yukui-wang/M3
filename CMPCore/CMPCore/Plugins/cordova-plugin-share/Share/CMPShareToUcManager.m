//
//  CMPShareToUcManager.m
//  M3
//
//  Created by MacBook on 2019/12/2.
//

#import "CMPShareToUcManager.h"
#import "CMPMessageForwardView.h"
#import "CMPRCChatViewController.h"
#import "CMPSelectContactViewController.h"
#import "CMPVideoMessage.h"

#import <CMPLib/CMPFileTypeHandler.h>
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/YBImageBrowserTipView.h>
#import <CMPLib/CMPNavigationController.h>

@interface CMPShareToUcManager()

/* forwardView */
@property (weak, nonatomic) CMPMessageForwardView *forwardView;
/* chatVc */
@property (strong, nonatomic) CMPRCChatViewController *chatVc;

@end
@implementation CMPShareToUcManager

+ (instancetype)manager {
    return [[self alloc] init];
}

#pragma mark - 分享到致信

#pragma mark 文件分享到致信

- (void)showForwardMessageViewWithFilePath:(NSString *)filePath inVC:(UIViewController *)inVC {
    NSString *content = @"";
    NSString *fileSize = @"";
    UIImage *thumbnailImage = nil;
    
    NSString *mineType = [CMPFileTypeHandler getFileMineTypeWithFilePath:filePath];
    NSString *judgeType = mineType.pathComponents.firstObject;
    
    RCMessageContent *msg = nil;
    if ([judgeType isEqualToString:@"image"]) {
        RCImageMessage *imgMsg = [RCImageMessage messageWithImage: [UIImage imageWithContentsOfFile:filePath]];
        thumbnailImage = imgMsg.thumbnailImage;
        msg = imgMsg;
    }else {
        RCFileMessage *fileMsg = [RCFileMessage messageWithFile:filePath];
        content = fileMsg.name;
        NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:fileMsg.type];
        thumbnailImage = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];
        fileSize = [RCKitUtility getReadableStringForFileSize:fileMsg.size];
        msg = fileMsg;
        if ([judgeType isEqualToString:@"video"]) {
            CGFloat videoTime = [CMPCommonTool getVideoTimeByUrlString:filePath];
            UIImage *thumbImage = [CMPCommonTool getScreenShotImageFromVideoUrl:filePath size:CGSizeMake(202, 202)];
            CMPVideoMessage *videoMessage = [CMPVideoMessage messageWithFile:filePath];
            videoMessage.timeDuration = videoTime;
            videoMessage.videoThumImage = thumbImage;
            
            if (!videoMessage.name) {
                videoMessage.name = filePath.lastPathComponent;
            }
            if (!videoMessage.localPath) {
                videoMessage.localPath = filePath;
            }
            
            msg = videoMessage;
        }
        
    }
    
    CMPMessageForwardView *forwardView = [[CMPMessageForwardView alloc] initWithFrame: inVC.view.bounds];
    _forwardView = forwardView;
    [inVC.view addSubview:_forwardView];
    _forwardView.isFileAssitance = YES;
    __weak typeof(self) weakSelf = self;
    SyFaceDownloadObj *iconObj = [[SyFaceDownloadObj alloc] init];
    iconObj.serverId = [CMPCore sharedInstance].serverID;
    iconObj.memberId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    iconObj.downloadUrl = [CMPCore memberIconUrlWithId:iconObj.memberId];
    
    [_forwardView setHeadIcon:iconObj];
    [_forwardView setName:SY_STRING(@"msg_fileass")];
    [_forwardView setContent:content];
    [_forwardView setThumbnailImage:thumbnailImage fileSize:fileSize];
    
    
    _forwardView.selectedBlock = ^(NSString *str,BOOL isCheck){
        [MBProgressHUD cmp_showProgressHUD];
        
        [weakSelf sendMsgToFileAssisWthMsg:msg filePath:filePath];
        
        if (str.length) {
            RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
            [weakSelf sendMsgToFileAssisWthMsg:msgNews filePath:filePath];
        }
        
    };
}

/// 显示 选择联系人 view  文件
- (void)showSelectContactViewWithFilePaths:(NSArray *)filePaths inVC:(UIViewController *)inVC willForwardMsg:(void(^)(void))willForwardMsg forwardSucess:(void(^)(void))forwardSucess forwardSucessWithMsgObj:(void(^)(CMPMessageObject *msgObj, NSArray *fileList))forwardSucessforwardSucessWithMsgObj forwardFailed:(void(^)(void))forwardFailed {
    CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
    NSString *filePath = filePaths.firstObject;
    NSString *mineType = [CMPFileTypeHandler getFileMineTypeWithFilePath:filePath];
    NSString *judgeType = mineType.pathComponents.firstObject;
    
    RCMessageModel *msgModel = RCMessageModel.alloc.init;
    if ([judgeType isEqualToString:@"image"]) {
        RCImageMessage *imgMsg = [RCImageMessage messageWithImage: [UIImage imageWithContentsOfFile:filePath]];
        msgModel.content = imgMsg;
    }else if ([judgeType isEqualToString:@"video"]) {
        CGFloat videoTime = [CMPCommonTool getVideoTimeByUrlString:filePath];
        UIImage *thumbImage = [CMPCommonTool getScreenShotImageFromVideoUrl:filePath size:CGSizeMake(202, 202)];
        CMPVideoMessage *videoMessage = [CMPVideoMessage messageWithFile:filePath];
        videoMessage.timeDuration = videoTime;
        videoMessage.videoThumImage = thumbImage;
        
        if (!videoMessage.name) {
            videoMessage.name = filePath.lastPathComponent;
        }
        if (!videoMessage.localPath) {
            videoMessage.localPath = filePath;
        }
        msgModel.content = videoMessage;
    }else {
        RCFileMessage *fileMsg = [RCFileMessage messageWithFile:filePath];
        msgModel.content = fileMsg;
    }
    
//    selectVC.isSharedFromOtherApps = YES;
    selectVC.msgModel = msgModel;
    selectVC.forwardSource = CMPForwardSourceTypeOnlySingleMessage;
    selectVC.disableGestureBack = NO;
    selectVC.filePath = filePath;
    selectVC.filePaths = filePaths;
    
    __weak typeof(selectVC) weakSelectVc = selectVC;
    //即将转发
    selectVC.willForwardMsg = ^(NSString *targetId) {
        if (willForwardMsg) {
            willForwardMsg();
        }
    };
    
    //转发成功
    if (forwardSucess) {
        selectVC.forwardSucess = ^{
//            [UIApplication.sharedApplication.keyWindow yb_showHookTipView:SY_STRING(@"common_send_success")];
            forwardSucess();
        };
    }
    
    //转发成功
    if (forwardSucessforwardSucessWithMsgObj) {
        selectVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
            forwardSucessforwardSucessWithMsgObj(msgObj, fileList);
            weakSelectVc.forwardSucessWithMsgObj = nil;
        };
    }
    //转发取消
    selectVC.forwardCancel = ^{
//        [weakSelf closeClicked];
    };
    //转发失败
    selectVC.forwardFail = ^(NSInteger errorCode) {
        [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"common_send_fail")];
        if (forwardFailed) {
            forwardFailed();
        }
    };
     if (INTERFACE_IS_PAD || inVC.navigationController == nil) {
        CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
        [inVC presentViewController:nav animated:YES completion:nil];
     } else {
        [inVC.navigationController pushViewController:selectVC animated:YES];
     }
}

/// 显示 选择联系人 view 非文件
- (void)showSelectContactViewInVC:(UIViewController *)inVC param:(NSDictionary *)param willForwardMsg:(void(^)(void))willForwardMsg forwardSucess:(void(^)(CMPMessageObject *msgObj))forwardSucess forwardFailed:(void(^)(void))forwardFailed {
    
    CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
    
    RCMessageModel *msgModel = RCMessageModel.alloc.init;
    
    selectVC.msgModel = msgModel;
    selectVC.forwardSource = CMPForwardSourceTypeOnlySingleMessage;
    selectVC.disableGestureBack = NO;
    selectVC.shareToUcDic = param;
    
    //即将转发
    __weak typeof(selectVC) weakSelectVc = selectVC;
    selectVC.willForwardMsg = ^(NSString *targetId) {
        [MBProgressHUD cmp_showProgressHUD];
        if (willForwardMsg) {
            willForwardMsg();
        }
    };
    //转发成功
    
    selectVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
        if (forwardSucess) {
            forwardSucess(msgObj);
            weakSelectVc.forwardSucessWithMsgObj = nil;
        }
    };
    //转发取消
    selectVC.forwardCancel = ^{
//        [weakSelf closeClicked];
    };
    //转发失败
    
    selectVC.forwardFail = ^(NSInteger errorCode) {
        [[UIApplication sharedApplication].keyWindow yb_showForkTipView:SY_STRING(@"common_send_fail")];
        if (forwardFailed) {
            forwardFailed();
        }
    };
    
    if (INTERFACE_IS_PAD) {
        CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
        [inVC presentViewController:nav animated:YES completion:nil];
    } else {
        [inVC.navigationController pushViewController:selectVC animated:YES];
    }
}

#pragma mark - 文件助手文件发送相关

- (void)sendMsgToFileAssisWthMsg:(RCMessageContent *)msg filePath:(NSString *)filePath {
    NSMutableDictionary *extraDic = NSMutableDictionary.dictionary;
    NSString *cId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    //调用不影响ui发送，因为发生的对象不是当前ui不要关心
    if ([msg respondsToSelector:@selector(setExtra:)]) {
        NSString *chatTitle = SY_STRING(@"msg_fileass");
        
        extraDic[@"toName"] = chatTitle;
        extraDic[@"msgId"] = [NSString uuid];
        extraDic[@"userId"] = [CMPCore sharedInstance].userID;
        extraDic[@"userName"] = [CMPCore sharedInstance].currentUser.name;
        extraDic[@"toId"] = cId;
        if (![msg isKindOfClass: RCTextMessage.class]) {
            extraDic[@"fileName"] = filePath.lastPathComponent;
        }
        
        [msg performSelector:@selector(setExtra:) withObject:[extraDic JSONRepresentation]];
        
    }
    
    //发送文件、图片
    if (![msg isKindOfClass: RCTextMessage.class]) {
        _chatVc = CMPRCChatViewController.alloc.init;
        _chatVc.targetId = cId;
        _chatVc.conversationType = ConversationType_PRIVATE;
        [_chatVc sendLocalFilesWithExtra:extraDic mediaModel: (RCMediaMessageContent *)msg];
        return;
    }
    
    //发送文字消息
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:cId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
}

@end
