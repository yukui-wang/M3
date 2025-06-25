//
//  CMPSelectContactManager.m
//  M3
//
//  Created by Shoujian Rao on 2023/9/5.
//

#import "CMPSelectContactManager.h"
#import <CMPLib/CMPCustomAlertView.h>

#import "CMPRCSystemImMessage.h"
#import "CMPRCTransmitMessage.h"
#import "CMPBusinessCardMessage.h"
#import "M3-Swift.h"
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSDate+CMPDate.h>
#import "CMPRCChatViewController.h"
#import "RCMessageModel+Type.h"
#import "CMPChatManager.h"
#import "CMPSelectMultipleContactViewController.h"
@interface CMPSelectContactManager()



@property(nonatomic,strong) NSArray * selectedMessageArr;
@property(nonatomic,assign) NSInteger conversationType;

@end

@implementation CMPSelectContactManager

+ (instancetype)sharedInstance{
    static CMPSelectContactManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPSelectContactManager alloc] init];
    });
    return instance;
}

- (NSMutableDictionary *)selectedContact{
    if(!_selectedContact){
        _selectedContact = [NSMutableDictionary new];
    }
    return _selectedContact;
}

- (NSMutableArray *)selectedCidArr{
    if(!_selectedCidArr){
        _selectedCidArr = [NSMutableArray new];
    }
    return _selectedCidArr;
}


- (BOOL)addSelectContact:(NSString *)cid name:(NSString *)name type:(NSInteger)type subType:(NSInteger)subType{
    if(cid.length<=0){
        return NO;
    }
    if(![self canSelectContact]){
        return NO;
    }
    
    NSDictionary *dict = @{
        @"cid":cid,
        @"name":name?:@"",
        @"type":@(type),
        @"subType":@(subType),
    };
    [self.selectedContact setValue:dict forKey:cid];
    [self.selectedCidArr addObject:cid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_SelectContactChanged object:nil];
    
    return YES;
}

- (void)delSelectContact:(NSString *)cid{
    if(cid.length<=0){
        return;
    }
    [self.selectedContact removeObjectForKey:cid];
    [self.selectedCidArr removeObject:cid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_SelectContactChanged object:cid];
}

- (BOOL)canSelectContact{
    if(self.selectedCidArr.count>=10){
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *tip = @"最多可选择10个会话";
//            NSString *btnTitle = @"确定";
            NSString *tip = SY_STRING(@"excess_quantity");//最多可选择10个会话
            NSString *btnTitle = SY_STRING(@"common_ok");//确定
            id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:tip preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:nil otherButtonTitles:@[btnTitle] handler:^(NSInteger buttonIndex, id  _Nullable value) {
                
            }];
            [alert setTheme:CMPTheme.new];
            [alert show];
        });
        return NO;
    }
    return YES;
}
- (void)showForwardView:(NSArray *)targetArr toView:(UIView *)view inVC:(UIViewController *)VC{
    if (!_sendView) {
        CGRect rect = view.bounds;
        _sendView = [[CMPMessageMultipleForwardView alloc] initWithFrame: CGRectMake(0, 0, rect.size.width, rect.size.height) withTargetArr:targetArr];
    }
    _sendView.targetArr = targetArr;
    self.vc = VC;
    [view addSubview:_sendView];
    
    NSString *content = @"";
    UIImage *thumbnailImage = nil;
    NSString *fileSize = @"";
    if ([_msgModel.content isKindOfClass:[RCTextMessage class]] ||
        [_msgModel.content isKindOfClass:[CMPRCSystemImMessage class]]) {//文本或系统消息
        RCTextMessage *textMsg = (RCTextMessage*)_msgModel.content;
        content = textMsg.content;
    }
    else if ([_msgModel.content isKindOfClass:[RCFileMessage class]]) {//文件消息
        RCFileMessage *fileMsg = (RCFileMessage*)_msgModel.content;
        content = [SY_STRING(@"msg_file") stringByAppendingString:fileMsg.name];
        NSString *fileTypeIcon = [RCKitUtility getFileTypeIcon:fileMsg.type];
        thumbnailImage = [RCKitUtility imageNamed:fileTypeIcon ofBundle:@"RongCloud.bundle"];
        fileSize = [RCKitUtility getReadableStringForFileSize:fileMsg.size];
    }
    else if ([_msgModel.content isKindOfClass:[RCImageMessage class]]) {//图片消息
        RCImageMessage *imgMsg = (RCImageMessage*)_msgModel.content;
        thumbnailImage = imgMsg.thumbnailImage;
        content = SY_STRING(@"msg_image");
    }
    else if ([_msgModel.content isKindOfClass:[RCVoiceMessage class]]) {//音频
        content = SY_STRING(@"msg_voice");
        
    }
    else if ([_msgModel.content isKindOfClass:[RCLocationMessage class]]) {//位置
        RCLocationMessage *message = (RCLocationMessage *)_msgModel.content;
        content =  NSLocalizedStringFromTable(@"RC:LBSMsg", @"RongCloudKit", nil);
        content = [NSString stringWithFormat:@"%@%@",content,message.locationName];
    }
    else if ([_msgModel.content isKindOfClass:[CMPRCTransmitMessage class]]) {
        CMPRCTransmitMessage *textMsg = (CMPRCTransmitMessage*)_msgModel.content;
        content = textMsg.content;
    }
    else if ([_msgModel.content isKindOfClass:[CMPCombineMessage class]]) {//组合消息
        CMPCombineMessage *textMsg = (CMPCombineMessage*)_msgModel.content;
        content = textMsg.title;
        content = [NSString stringWithFormat:@"「%@」%@",SY_STRING(@"rc_merge_message_forward"),content];
    }
    else if (_forwardSource == CMPForwardSourceTypeSingleMessages) {//转发单个消息
        content = [NSString stringWithFormat:SY_STRING(@"total_message"),(unsigned long)self.selectedMessages.count] ;
        content = [NSString stringWithFormat:@"「%@」%@",SY_STRING(@"rc_single_messages_forward"),content];
    }
    else if ([_msgModel.content isKindOfClass:[CMPBusinessCardMessage class]]) {//业务卡片
        CMPBusinessCardMessage *cardMessage = (CMPBusinessCardMessage*)_msgModel.content;
        content = [NSString stringWithFormat:@"%@ %@",SY_STRING(@"rc_msg_business_card"),cardMessage.name] ;
    }
    
    //显示转发的图片或没有图片
    [_sendView setThumbnailImage:thumbnailImage fileSize:fileSize];
    
    if ([content isKindOfClass:NSString.class]) {
        [_sendView setContent:content];
    }
    
    __weak typeof(self) weakSelf = self;
    _sendView.cancelBlock = ^{
        [weakSelf.sendView removeFromSuperview];
        weakSelf.sendView = nil;
    };

    _sendView.selectedBlock = ^(NSString *str,BOOL isCheck){
        [weakSelf.sendView removeFromSuperview];
        weakSelf.sendView = nil;
        
        NSMutableArray *selArr = [NSMutableArray array];
        for (NSDictionary *target in targetArr) {
            NSString *cid = target[@"cid"];
            NSString *name = target[@"name"];
            NSInteger type = [target[@"type"] integerValue];
            NSInteger subType = [target[@"subType"] integerValue];
            CMPMessageObject *contact = [CMPMessageObject new];
            contact.cId = cid;
            contact.appName = name;
            contact.type = type;
            contact.subtype = subType;
            
            [selArr addObject:contact];
        }
        [weakSelf getSelectContactFinish:selArr content:str isChecked:isCheck];
    };
    
    //协同等h5页面发起的发送到致信
//    if (self.shareToUcDic) {
//        NSString *title = self.shareToUcDic[@"title"];
//        content = title;
//        BOOL allowCheckedOutside = [self.shareToUcDic[@"params"][@"isShowFlow"] boolValue];
//        if (allowCheckedOutside) {
//            _sendView.allowCheckedOutside = allowCheckedOutside;
//        }
//    }
    
    //文件预览分享到致信，只是显示文件个数
//    if (_filePaths.count) {
//        _sendView.fileCount = _filePaths.count;
//    }
    
    //名称
//    [_sendView setName:@"名称"];
    
}
- (void)getSelectContactFinish:(NSArray*)userList content:(NSString*)str isChecked:(BOOL)isChecked
{
//    if (self.filePaths) {
//        if(self.forwardSucessWithMsgObj){
//            self.forwardSucessWithMsgObj(userList.firstObject, self.filePaths);
//            if (![NSString isNull:str]) {
//                RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
//                [self sendForwardMsg:msgNews tag:userList.firstObject isChecked:isChecked];
//            }
//        }
//        return;
//    }
    
//    _totalForwardTag = [NSString isNull:str] ?userList.count :userList.count*2;
    
    NSArray *vcArr = self.vc.navigationController.viewControllers;
    CMPRCChatViewController *chatVC;
    CMPSelectContactViewController *contactVC;
    if (INTERFACE_IS_PAD) {
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:CMPSelectContactViewController.class]){
                contactVC = (CMPSelectContactViewController *)vc;
                self.selectedMessageArr = [contactVC.selectedMessages mutableCopy];
                self.conversationType = contactVC.conversationType;
            }
        }
    }else{
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:CMPRCChatViewController.class]){
                chatVC = (CMPRCChatViewController *)vc;
                self.selectedMessageArr = [chatVC.selectedMessages mutableCopy];
                self.conversationType = chatVC.conversationType;
            }
        }
    }
    
    if (!self.selectedMessageArr.count) {
        self.selectedMessageArr = [self.selectedMessages mutableCopy];
    }
    
    if (INTERFACE_IS_PAD) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMultipleSelectMsgSent" object:nil];//通知聊天列表取消多选状态
        [contactVC.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        if ([self.vc isKindOfClass:CMPSelectMultipleContactViewController.class]) {
            CMPSelectMultipleContactViewController *mVC = (CMPSelectMultipleContactViewController *)self.vc;
            if (mVC.forwardSucess) {
                mVC.forwardSucess();//CMPChatPlugin->msgSendTo的回调（群文件多选转发）
            }
        }
    } else {
        chatVC.allowsMessageCellSelection = NO;//聊天列表取消多选状态
        [self.vc.navigationController popToViewController:chatVC animated:YES];
        if ([self.vc isKindOfClass:CMPSelectMultipleContactViewController.class]) {
            CMPSelectMultipleContactViewController *mVC = (CMPSelectMultipleContactViewController *)self.vc;
            if (mVC.forwardSucess) {
                mVC.forwardSucess();//CMPChatPlugin->msgSendTo的回调（群文件多选转发）
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (userList.count > 0) {
            CGFloat delay = 0.2;
            for (NSInteger i = 0; i < userList.count; i++) {
                CMPMessageObject *msgTag = userList[i];
                RCMessageContent *msg = self.msgModel.content;
                if (self.forwardSource == CMPForwardSourceTypeOnlySingleMessage) {
                    
                    __weak typeof(self) weakSelf = self;
                    [self sendForwardMsg:msg tag:msgTag isChecked:isChecked completion:^(BOOL success) {
                        
                        if (![NSString isNull:str]) {
                            RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
                            
                            [NSThread sleepForTimeInterval:delay];
                            [weakSelf sendForwardMsg:msgNews tag:msgTag isChecked:isChecked completion:^(BOOL success) {
                                
                            }];
                        }
                    }];
                    
                    [NSThread sleepForTimeInterval:delay];
                    
                    
                }
                if (self.forwardSource == CMPForwardSourceTypeSingleMessages || self.forwardSource == CMPForwardSourceTypeMergeMessage) {
                    RCConversation *conversation = [[RCConversation alloc] init];
                    conversation.conversationType = (RCConversationType)msgTag.subtype;
                    conversation.targetId = msgTag.cId;
                    
                    RCConversation *senderConversation = [[RCConversation alloc] init];
                    senderConversation.conversationType = (RCConversationType)msgTag.subtype;
                    senderConversation.targetId = self.targetId;
                        
                    NSArray *conversationList = @[conversation,senderConversation];
                    
                    if (conversationList) {
                        NSInteger type = self.forwardSource == CMPForwardSourceTypeMergeMessage ? 1 : 0;
                        if (type == 0) {//type==0逐条转发，type==1合并转发
                            NSMutableArray *mutableConversationList = [conversationList mutableCopy];
                            [mutableConversationList removeLastObject];
                            conversationList = [mutableConversationList copy];
                        }
                        
                        //self.conversationType会话类型
                        __weak typeof(self) weakSelf = self;
                        
                        [[RCForwardManager sharedInstance] doForwardMessageList:self.selectedMessageArr conversationList:conversationList isCombine:type == 0 ? NO : YES forwardConversationType:self.conversationType completed:^(BOOL success) {
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
                            });
                            
                            if (![NSString isNull:str]) {
                                RCTextMessage *msgNews = [RCTextMessage messageWithContent:str];
                                
                                [weakSelf sendForwardMsg:msgNews tag:msgTag isChecked:isChecked completion:^(BOOL success) {
                                    
                                }];
                                [NSThread sleepForTimeInterval:delay];
                            }
                            
                        }];
                        [NSThread sleepForTimeInterval:delay];
                        
                        //ks fix V5-9969 iOS端M3的群文件，从A群转发到B群，B群的群文件里不显示该文件
                        for (RCMessageModel *msgModel in self.selectedMessageArr) {
                            if ([msgModel isFileMessage] || [msgModel isVideoMessage]) {
                                RCFileMessage *fileMsg = (RCFileMessage *)(msgModel.content);
                                [[CMPChatManager sharedManager] forwardFile:fileMsg.remoteUrl type:0 target:conversation.targetId completion:^(id result, NSError *error) {
                                    if (error) {
                                    }
                                }];
                            }
                        }
                    }

                }
                
            }
        }
    });
    
    
}


- (void)sendForwardMsg:(RCMessageContent*)msg tag:(CMPMessageObject*)msgTag isChecked:(BOOL)isChecked completion:(void(^)(BOOL))completion
{
    RCConversationType chatType = (RCConversationType)msgTag.subtype;
//    if (self.shareToUcDic) {//如果是分享组件调起的话，就直接转通过发送卡片的形式进行发送
//        __weak typeof(self) weakSelf = self;
//        if (msg) {//如果是文本消息就发送文本消息
//            [[RCIMClient sharedRCIMClient] sendMessage:chatType targetId:msgTag.cId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
//                //不使用 weak, 因为使用weak 本控制器不被释放
//                [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
//            } error:^(RCErrorCode nErrorCode, long messageId) {
//                //不使用 weak, 因为使用weak 本控制器不被释放
//                [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
//            }];
//            return;
//        }
//        //这里是BusinessMessage
//        NSString *receiverIds = msgTag.cId;
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.shareToUcDic[@"params"]];
//        params[@"isForward"] = [NSString stringWithFormat:@"%d",isChecked];
//        //        params[@"isShowFlow"] = nil;
//        [[CMPMessageManager sharedManager] sendBusinessMessageWithParam:params receiverIds:receiverIds  success:^(NSString * _Nonnull messageId,id _Nonnull data) {
//            NSString *status = data[@"status"];
//            if ([status isEqualToString:@"failed"]) {
//                if (weakSelf.forwardFail) {
//                    weakSelf.forwardFail(-1);
//                }
//                return;
//            }
//            if (weakSelf.forwardSucess) {
//                weakSelf.forwardSucess();
//            }
//            if (weakSelf.forwardSucessWithMsgObj) {
//                weakSelf.forwardSucessWithMsgObj(msgTag, self.filePaths);
//            }
//        } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
//            if (weakSelf.forwardFail) {
//                weakSelf.forwardFail(-1);
//            }
//        }];
//        return;
//    }
    
    // 任务消息、催办消息
    if ([msg isKindOfClass:[CMPRCSystemImMessage class]]) {
        CMPRCSystemImMessage *systemImMessage = (CMPRCSystemImMessage*)msg;
        CMPRCTransmitMessage *traMsg = [[CMPRCTransmitMessage alloc] init];
        CMPRCSystemImMessageExtraMessage *extraMessage = systemImMessage.extraData.message;
        traMsg.sendName = [extraMessage.extra objectForKey:@"managers"];
        NSString *sendTime = extraMessage.t;
        sendTime = [[sendTime componentsSeparatedByString:@"."] firstObject];
        NSDate *sendDate = [CMPDateHelper dateFromStr:sendTime dateFormat:kDateFormate_yyyy_mm_dd_HH_mm];
        traMsg.sendTime = [sendDate cmp_millisecondStr];
        traMsg.mobilePassURL = extraMessage.mMl;
        if (systemImMessage.category == RCSystemImMessageCategoryTask) {
            traMsg.title = @"任务通知";
            traMsg.sendName = [extraMessage.extra objectForKey:@"managers"];
        } else if (systemImMessage.category == RCSystemImMessageCategoryColHasten) {
            traMsg.title = @"催办通知";
            traMsg.sendName = extraMessage.sn;
        }
        
        traMsg.appId = systemImMessage.appId;
        traMsg.extra = @"";
        traMsg.actionType = extraMessage.at;
        traMsg.content = systemImMessage.content;
        traMsg.PCPassURL = extraMessage.ml;
        traMsg.type = extraMessage.mt;
        msg = traMsg;
    }
    
    NSDictionary *extraDic = nil;
    //调用不影响ui发送，因为发生的对象不是当前ui不要关心
    if ([msg respondsToSelector:@selector(setExtra:)]) {
        NSString *chatTitle = msgTag.appName;
        if ([NSString isNull:chatTitle]) {
            chatTitle = @"";
        }
        extraDic = [NSDictionary dictionaryWithObjectsAndKeys:chatTitle, @"toName", [NSString uuid], @"msgId", msgTag.cId, @"toId", [CMPCore sharedInstance].userID, @"userId", [CMPCore sharedInstance].currentUser.name, @"userName" ,@"iOS",@"from_c",nil];
        [msg performSelector:@selector(setExtra:) withObject:[extraDic JSONRepresentation]];
    }
    
    if (![NSString isNull:self.targetId] && [msgTag.cId isEqualToString:self.targetId]) {
        //如果选择的是当前聊天的页面，当前界面转发给当前的人，就是重复一次   方便迅速刷新
        [[RCIM sharedRCIM] sendMessage:chatType targetId:self.targetId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
            completion(YES);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
            completion(NO);
        }];
    }
    else {
        [[RCIMClient sharedRCIMClient] sendMessage:chatType targetId:msgTag.cId content:msg pushContent:@"" pushData:nil success:^(long messageId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardSucess object:nil];
            completion(YES);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidForwardFail object:[NSNumber numberWithInteger:nErrorCode]];
            completion(NO);
        }];
    }
}

@end
