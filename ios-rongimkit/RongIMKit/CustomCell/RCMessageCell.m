//
//  RCMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/1/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageCell.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCUserInfoCacheManager.h"
#import "RCloudImageView.h"
#import "RCIMClient+Destructing.h"
#import "RCResendManager.h"

// 头像
#define PortraitImageViewTop 0

// 气泡
#define ContentViewBottom 14

NSString *const KNotificationMessageBaseCellUpdateCanReceiptStatus =
    @"KNotificationMessageBaseCellUpdateCanReceiptStatus";

@interface RCMessageCell ()

@property (nonatomic, strong) UILabel *hasReadLabel;

//- (void) configure;
- (void)setCellAutoLayout;

@end

// static int indexCell = 1;

@implementation RCMessageCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupMessageCellView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMessageCellView];
    }
    return self;
}
- (void)setupMessageCellView {
    _isDisplayNickname = NO;
    self.allowsSelection = YES;
    self.delegate = nil;

    self.portraitImageView = [[RCloudImageView alloc]
        initWithPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];

    self.messageContentView = [[RCContentView alloc] initWithFrame:CGRectZero];
    self.statusContentView = [[UIView alloc] initWithFrame:CGRectZero];

    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    [self.nicknameLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.nicknameLabel
        setTextColor:[RCKitUtility generateDynamicColor:[UIColor grayColor] darkColor:HEXCOLOR(0x707070)]];

    //点击头像
    UITapGestureRecognizer *portraitTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserPortaitEvent:)];
    portraitTap.numberOfTapsRequired = 1;
    portraitTap.numberOfTouchesRequired = 1;
    [self.portraitImageView addGestureRecognizer:portraitTap];

    UILongPressGestureRecognizer *portraitLongPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressUserPortaitEvent:)];
    [self.portraitImageView addGestureRecognizer:portraitLongPress];

    self.portraitImageView.userInteractionEnabled = YES;

    [self.baseContentView addSubview:self.portraitImageView];
    [self.baseContentView addSubview:self.messageContentView];
    [self.baseContentView addSubview:self.nicknameLabel];
    [self setPortraitStyle:[RCIM sharedRCIM].globalMessageAvatarStyle];

    self.statusContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    _statusContentView.backgroundColor = [UIColor clearColor];
    [self.baseContentView addSubview:_statusContentView];

    self.destructBtn.frame = CGRectMake(0, 0, 15, 15);
    [self.destructView addSubview:self.destructBtn];
    [self.messageContentView addSubview:self.destructView];

    self.messageFailedStatusView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//    [_messageFailedStatusView setImage:[RCKitUtility imageNamed:@"message_send_fail_status" ofBundle:@"RongCloud.bundle"]
//                              forState:UIControlStateNormal];
    [_messageFailedStatusView setImage:[UIImage imageNamed:@"sendMsg_failed_tip"]
    forState:UIControlStateNormal];
    [_messageFailedStatusView setImageEdgeInsets:UIEdgeInsetsMake(2.5, 0, 2.5, 5)];
    [self.statusContentView addSubview:_messageFailedStatusView];
    _messageFailedStatusView.hidden = YES;
    [_messageFailedStatusView addTarget:self
                                 action:@selector(didClickMsgFailedView:)
                       forControlEvents:UIControlEventTouchUpInside];

    [self.statusContentView addSubview:self.messageActivityIndicatorView];
    self.messageActivityIndicatorView.hidden = YES;
    self.messageHasReadStatusView = [[UIView alloc] initWithFrame:CGRectMake(9, 0, 25, 25)];
    UIImageView *hasReadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 12, 13)];
    hasReadView.contentMode = UIViewContentModeScaleAspectFill;
    [hasReadView setImage:IMAGE_BY_NAMED(@"message_read_status")];
    [self.messageHasReadStatusView addSubview:hasReadView];
    [self.statusContentView addSubview:self.messageHasReadStatusView];
    self.messageHasReadStatusView.hidden = YES;

    self.messageSendSuccessStatusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    UILabel *sendSuccessLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    //        sendSuccessLabel.text = NSLocalizedStringFromTable(@"MessageHasSend", @"RongCloudKit",
    //                                                           nil);
    sendSuccessLabel.font = [UIFont systemFontOfSize:14];
    sendSuccessLabel.textColor = HEXCOLOR(0x8c8c8c);
    [self.messageSendSuccessStatusView addSubview:sendSuccessLabel];
    [self.statusContentView addSubview:self.messageSendSuccessStatusView];
    self.messageSendSuccessStatusView.hidden = YES;

    [self.baseContentView addSubview:self.hasReadLabel];

    [self.baseContentView addSubview:self.receiptView];

    [self.baseContentView addSubview:self.receiptCountLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoUpdate:)
                                                 name:RCKitDispatchUserInfoUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupUserInfoUpdate:)
                                                 name:RCKitDispatchGroupUserInfoUpdateNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiptStatusUpdate:)
                                                 name:KNotificationMessageBaseCellUpdateCanReceiptStatus
                                               object:nil];

    __weak typeof(self) __blockself = self;
    [self.messageContentView registerFrameChangedEvent:^(CGRect frame) {
        if (__blockself.model) {
            if (__blockself.model.messageDirection == MessageDirection_SEND) {
                __blockself.statusContentView.frame =
                    CGRectMake(frame.origin.x - 10 - 25, frame.origin.y + (frame.size.height - 25) / 2.0f, 25, 25);
                __blockself.receiptCountLabel.frame = CGRectMake(
                    CGRectGetMinX(frame) - 50 - 4, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 10 - 20, 50, 20);
                ;
                CGSize receiptViewSize = __blockself.receiptView.frame.size;
                //防止多次刷新情况下，用户 APP 里面重设 receiptView.frame 被这里设置覆盖
                CGFloat receiptViewY = __blockself.receiptView.frame.origin.y ? __blockself.receiptView.frame.origin.y
                                                                              : frame.origin.y + 10;
                __blockself.receiptView.frame = CGRectMake(CGRectGetMinX(frame) - receiptViewSize.width - 4,
                                                           receiptViewY, receiptViewSize.width, receiptViewSize.height);

                __blockself.hasReadLabel.frame = CGRectZero;
            } else {
                __blockself.statusContentView.frame =
                    CGRectMake(CGRectGetMaxX(frame) - 30, frame.origin.y + (frame.size.height - 25) / 2.0f, 25, 25);
                __blockself.hasReadLabel.frame =
                    CGRectMake(CGRectGetMaxX(frame) + 4, CGRectGetMaxY(frame) - 25, 40, 25);
            }
        }

    }];
}
- (void)setPortraitStyle:(RCUserAvatarStyle)portraitStyle {
    _portraitStyle = portraitStyle;

    if (_portraitStyle == RC_USER_AVATAR_RECTANGLE) {
        self.portraitImageView.layer.cornerRadius = [[RCIM sharedRCIM] portraitImageViewCornerRadius];
    }
    if (_portraitStyle == RC_USER_AVATAR_CYCLE) {
        self.portraitImageView.layer.cornerRadius = [[RCIM sharedRCIM] globalMessagePortraitSize].height / 2;
    }
    self.portraitImageView.layer.masksToBounds = YES;
}
//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//
//}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    self.receiptView.hidden = YES;
    self.receiptCountLabel.hidden = YES;
    self.messageFailedStatusView.hidden = YES;
    if (model.readReceiptInfo.isReceiptRequestMessage && model.messageDirection == MessageDirection_SEND) {
        self.receiptCountLabel.hidden = NO;
        self.receiptCountLabel.userInteractionEnabled = YES;
        self.receiptCountLabel.text = [NSString
            stringWithFormat:NSLocalizedStringFromTable(@"readNum", @"RongCloudKit", nil), self.model.readReceiptCount];
    } else {
        self.receiptCountLabel.hidden = YES;
        self.receiptCountLabel.userInteractionEnabled = NO;
        self.receiptCountLabel.text = nil;
    }

    if (model.messageDirection == MessageDirection_SEND && model.sentStatus == SentStatus_SENT) {
        if (model.isCanSendReadReceipt) {
            self.receiptView.hidden = NO;
            self.receiptCountLabel.hidden = YES;
        } else {
            self.receiptView.hidden = YES;
            self.receiptCountLabel.hidden = NO;
        }
    }

    self.hasReadLabel.hidden = YES;
    self.messageSendSuccessStatusView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;

    _isDisplayNickname = model.isDisplayNickname;

    // DebugLog(@"%s", __FUNCTION__);
    //如果是客服，更换默认头像
    if (ConversationType_CUSTOMERSERVICE == model.conversationType) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            [self.portraitImageView
                setPlaceholderImage:[RCKitUtility imageNamed:@"portrait_kefu" ofBundle:@"RongCloud.bundle"]];

            model.userInfo = model.content.senderUserInfo;
            if (model.content.senderUserInfo != nil) {
                [self.portraitImageView setImageURL:[NSURL URLWithString:model.content.senderUserInfo.portraitUri]];
                [self.nicknameLabel setText:model.content.senderUserInfo.name];
            } else {
                [self.portraitImageView
                    setImage:[RCKitUtility imageNamed:@"portrait_kefu" ofBundle:@"RongCloud.bundle"]];
                [self.nicknameLabel setText:nil];
            }
        } else {
            RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:model.senderUserId];
            model.userInfo = userInfo;
            [self.portraitImageView
                setPlaceholderImage:[RCKitUtility imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
            if (userInfo) {
                [self.portraitImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
                [self.nicknameLabel setText:userInfo.name];
            } else {
                [self.portraitImageView setImageURL:nil];
                [self.nicknameLabel setText:nil];
            }
        }
    } else if (ConversationType_APPSERVICE == model.conversationType ||
               ConversationType_PUBLICSERVICE == model.conversationType) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            RCPublicServiceProfile *serviceProfile = nil;
            if ([RCIM sharedRCIM].publicServiceInfoDataSource) {
                serviceProfile = [[RCUserInfoCacheManager sharedManager] getPublicServiceProfile:model.targetId];
            } else {
                serviceProfile =
                    [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)model.conversationType
                                                           publicServiceId:model.targetId];
            }
            model.userInfo = model.content.senderUserInfo;
            if (serviceProfile) {
                [self.portraitImageView setImageURL:[NSURL URLWithString:serviceProfile.portraitUrl]];
                [self.nicknameLabel setText:serviceProfile.name];
            }
        } else {
            RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:model.senderUserId];
            model.userInfo = userInfo;
            if (userInfo) {
                [self.portraitImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
                [self.nicknameLabel setText:userInfo.name];
            } else {
                [self.portraitImageView setImageURL:nil];
                [self.nicknameLabel setText:nil];
            }
        }
    } else if (ConversationType_GROUP == model.conversationType) {
        RCUserInfo *userInfo =
            [[RCUserInfoCacheManager sharedManager] getUserInfo:model.senderUserId inGroupId:self.model.targetId];
        model.userInfo = userInfo;
        if (userInfo) {
            [self.portraitImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
            [self.nicknameLabel setText:userInfo.name];
        } else {
            [self.portraitImageView setImageURL:nil];
            [self.nicknameLabel setText:nil];
        }
    } else {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:model.senderUserId];
        model.userInfo = userInfo;
        if (userInfo) {
            if (model.conversationType != ConversationType_Encrypted) {
                [self.portraitImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
            }
            [self.nicknameLabel setText:userInfo.name];
        } else {
            [self.portraitImageView setImageURL:nil];
            [self.nicknameLabel setText:nil];
        }
    }

    [self setCellAutoLayout];
    [self messageDestructing];
}
- (void)setCellAutoLayout {

    _messageContentViewWidth = 200;
    // receiver
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.nicknameLabel.hidden = !self.isDisplayNickname;
        CGFloat portraitImageX = 10;
        self.portraitImageView.frame =
            CGRectMake(portraitImageX, PortraitImageViewTop, [RCIM sharedRCIM].globalMessagePortraitSize.width,
                       [RCIM sharedRCIM].globalMessagePortraitSize.height);
        self.nicknameLabel.frame =
            CGRectMake(portraitImageX + self.portraitImageView.bounds.size.width + 13, PortraitImageViewTop, 200, 14);

        CGFloat messageContentViewY = PortraitImageViewTop;
        if (self.isDisplayNickname) {
            messageContentViewY = PortraitImageViewTop + 12 + 4;
        }
        self.messageContentView.frame =
            CGRectMake(portraitImageX + self.portraitImageView.bounds.size.width + HeadAndContentSpacing,
                       messageContentViewY, _messageContentViewWidth,
                       self.baseContentView.bounds.size.height - (messageContentViewY + ContentViewBottom));
    } else { // owner
        self.nicknameLabel.hidden = YES;
        CGFloat portraitImageX =
            self.baseContentView.bounds.size.width - ([RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.portraitImageView.frame =
            CGRectMake(portraitImageX, PortraitImageViewTop, [RCIM sharedRCIM].globalMessagePortraitSize.width,
                       [RCIM sharedRCIM].globalMessagePortraitSize.height);

        self.messageContentView.frame = CGRectMake(
            self.baseContentView.bounds.size.width - (_messageContentViewWidth + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10),
            PortraitImageViewTop, _messageContentViewWidth,
            self.baseContentView.bounds.size.height - (ContentViewBottom + PortraitImageViewTop));
    }

    [self updateStatusContentView:self.model];
}

- (void)updateStatusContentView:(RCMessageModel *)model {
    self.messageSendSuccessStatusView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;
    self.messageActivityIndicatorView.hidden = YES;
    if (model.messageDirection == MessageDirection_RECEIVE) {
        self.statusContentView.hidden = YES;
        return;
    } else {
        self.statusContentView.hidden = NO;
    }
    __weak typeof(self) __blockSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{

        if (__blockSelf.model.sentStatus == SentStatus_SENDING) {
            __blockSelf.messageFailedStatusView.hidden = YES;
            __blockSelf.messageHasReadStatusView.hidden = YES;
            __blockSelf.messageSendSuccessStatusView.hidden = YES;
            if (__blockSelf.messageActivityIndicatorView) {
                __blockSelf.messageActivityIndicatorView.hidden = NO;
                if (__blockSelf.messageActivityIndicatorView.isAnimating == NO) {
                    [__blockSelf.messageActivityIndicatorView startAnimating];
                }
            }

        } else if (__blockSelf.model.sentStatus == SentStatus_FAILED) {
            __blockSelf.messageHasReadStatusView.hidden = YES;
            __blockSelf.messageSendSuccessStatusView.hidden = YES;
            if ([[RCResendManager sharedManager] needResend:model.messageId]) {
                __blockSelf.messageFailedStatusView.hidden = YES;
                if (__blockSelf.messageActivityIndicatorView) {
                    __blockSelf.messageActivityIndicatorView.hidden = NO;
                    if (__blockSelf.messageActivityIndicatorView.isAnimating == NO) {
                        [__blockSelf.messageActivityIndicatorView startAnimating];
                    }
                }
            } else {
                __blockSelf.messageFailedStatusView.hidden = NO;
                if (__blockSelf.messageActivityIndicatorView) {
                    __blockSelf.messageActivityIndicatorView.hidden = YES;
                    if (__blockSelf.messageActivityIndicatorView.isAnimating == YES) {
                        [__blockSelf.messageActivityIndicatorView stopAnimating];
                    }
                }
            }
        } else if (__blockSelf.model.sentStatus == SentStatus_CANCELED) {
            __blockSelf.messageFailedStatusView.hidden = YES;
            __blockSelf.messageHasReadStatusView.hidden = YES;
            __blockSelf.messageSendSuccessStatusView.hidden = YES;
            if (__blockSelf.messageActivityIndicatorView) {
                __blockSelf.messageActivityIndicatorView.hidden = YES;
                if (__blockSelf.messageActivityIndicatorView.isAnimating == YES) {
                    [__blockSelf.messageActivityIndicatorView stopAnimating];
                }
            }
        } else if (__blockSelf.model.sentStatus == SentStatus_SENT) {
            __blockSelf.messageFailedStatusView.hidden = YES;
            if (__blockSelf.messageActivityIndicatorView) {
                __blockSelf.messageActivityIndicatorView.hidden = YES;
                if (__blockSelf.messageActivityIndicatorView.isAnimating == YES) {
                    [__blockSelf.messageActivityIndicatorView stopAnimating];
                }
            }
            __blockSelf.messageSendSuccessStatusView.hidden = NO;

            if (model.isCanSendReadReceipt) {
                __blockSelf.receiptView.hidden = NO;
                __blockSelf.receiptCountLabel.hidden = YES;
            } else {
                __blockSelf.receiptView.hidden = YES;
                __blockSelf.receiptCountLabel.hidden = NO;
            }

        } //更新成已读状态
        else if (__blockSelf.model.sentStatus == SentStatus_READ && __blockSelf.isDisplayReadStatus &&
                 (__blockSelf.model.conversationType == ConversationType_PRIVATE ||
                  __blockSelf.model.conversationType == ConversationType_Encrypted)) {
            if (__blockSelf.model && __blockSelf.model.messageUId && __blockSelf.model.messageUId.length > 0) {
                __blockSelf.messageHasReadStatusView.hidden = NO;
            }
            __blockSelf.statusContentView.frame =
                CGRectMake(__blockSelf.messageContentView.frame.origin.x - 25,
                           __blockSelf.messageContentView.frame.size.height - ContentViewBottom, 10, 10);

            __blockSelf.messageFailedStatusView.hidden = YES;
            __blockSelf.messageSendSuccessStatusView.hidden = YES;
            if (__blockSelf.messageActivityIndicatorView) {
                __blockSelf.messageActivityIndicatorView.hidden = YES;
                if (__blockSelf.messageActivityIndicatorView.isAnimating == YES) {
                    [__blockSelf.messageActivityIndicatorView stopAnimating];
                }
            }
        }
    });
}

#pragma mark private

- (void)setDestructViewLayout {
}

- (void)messageDestructing {
    NSNumber *whisperMsgDuration =
        [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId];
    if (whisperMsgDuration == nil) {
        [self.destructBtn setTitle:@"" forState:UIControlStateNormal];
        [self.destructBtn setImage:[RCKitUtility imageNamed:@"fire_identify" ofBundle:@"RongCloud.bundle"]
                          forState:UIControlStateNormal];
    } else {
        NSDecimalNumber *subTime =
            [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", whisperMsgDuration]];
        NSDecimalNumber *divTime = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumberHandler *handel = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                scale:0
                                                                                     raiseOnExactness:NO
                                                                                      raiseOnOverflow:NO
                                                                                     raiseOnUnderflow:NO
                                                                                  raiseOnDivideByZero:NO];
        NSDecimalNumber *showTime = [subTime decimalNumberByDividingBy:divTime withBehavior:handel];
        [self.destructBtn setImage:nil forState:UIControlStateNormal];
        [self.destructBtn setTitle:[NSString stringWithFormat:@"%@", showTime] forState:UIControlStateNormal];
        [self setDestructViewLayout];
    }
}

- (void)tapUserPortaitEvent:(UIGestureRecognizer *)gestureRecognizer {
    __weak typeof(self) weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(didTapCellPortrait:)]) {
        [self.delegate didTapCellPortrait:weakSelf.model.senderUserId];
    }
}

- (void)longPressUserPortaitEvent:(UIGestureRecognizer *)gestureRecognizer {
    __weak typeof(self) weakSelf = self;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongPressCellPortrait:)]) {
            [self.delegate didLongPressCellPortrait:weakSelf.model.senderUserId];
        }
    }
}

- (void)imageMessageSendProgressing:(NSInteger)progress {
}

- (void)onReceiptStatusUpdate:(NSNotification *)notification {
    // 更新消息状态
    NSDictionary *statusDic = notification.object;
    NSUInteger conversationType = [statusDic[@"conversationType"] integerValue];
    NSString *targetId = statusDic[@"targetId"];
    long messageId = [statusDic[@"messageId"] longValue];
    if (self.model.conversationType == conversationType && [self.model.targetId isEqualToString:targetId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (messageId == self.model.messageId) {
                self.receiptView.hidden = NO;
                self.receiptCountLabel.hidden = YES;
                self.model.isCanSendReadReceipt = YES;
            } else {
                self.receiptView.hidden = YES;
                self.receiptCountLabel.hidden = NO;
                self.model.isCanSendReadReceipt = NO;
            }
        });
    }
}
- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {

    RCMessageCellNotificationModel *notifyModel = notification.object;

    if (self.model.messageId == notifyModel.messageId) {
        DebugLog(@"messageCellUpdateSendingStatusEvent >%@ ", notifyModel.actionName);
        if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_BEGIN]) {
            self.model.sentStatus = SentStatus_SENDING;
            [self updateStatusContentView:self.model];

        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
            if ([[RCResendManager sharedManager] needResend:self.model.messageId]) {
                self.model.sentStatus = SentStatus_SENDING;
                [self updateStatusContentView:self.model];
            } else {
                self.model.sentStatus = SentStatus_FAILED;
                [self updateStatusContentView:self.model];
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_CANCELED]) {
            self.model.sentStatus = SentStatus_CANCELED;
            [self updateStatusContentView:self.model];
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {
            [self imageMessageSendProgressing:notifyModel.progress];
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_HASREAD] &&
                   [[RCIM sharedRCIM]
                           .enabledReadReceiptConversationTypeList containsObject:@(self.model.conversationType)] &&
                   (self.model.conversationType == ConversationType_PRIVATE ||
                    self.model.conversationType == ConversationType_Encrypted)) {
            self.model.sentStatus = SentStatus_READ;
            [self updateStatusContentView:self.model];
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_READCOUNT] &&
                   [[RCIM sharedRCIM]
                           .enabledReadReceiptConversationTypeList containsObject:@(self.model.conversationType)] &&
                   (self.model.conversationType == ConversationType_GROUP ||
                    self.model.conversationType == ConversationType_DISCUSSION)) {
            self.receiptView.hidden = YES;
            self.receiptCountLabel.hidden = NO;
            self.receiptCountLabel.userInteractionEnabled = YES;
            self.receiptCountLabel.text = [NSString
                stringWithFormat:NSLocalizedStringFromTable(@"readNum", @"RongCloudKit", nil), notifyModel.progress];
            [self updateStatusContentView:self.model];
        }

    } else {
        if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.model.conversationType)] &&
            (self.model.conversationType == ConversationType_GROUP ||
             self.model.conversationType == ConversationType_DISCUSSION)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.receiptView.hidden = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.receiptView.hidden = YES;
            });
        }
    }
}

- (void)didClickMsgFailedView:(UIButton *)button {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didTapmessageFailedStatusViewForResend:)]) {
            [self.delegate didTapmessageFailedStatusViewForResend:self.model];
        }
    }
}

#pragma mark - UserInfo Update
- (void)onUserInfoUpdate:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    if ([self.model.senderUserId isEqualToString:userInfoDic[@"userId"]]) {
        if (self.model.conversationType == ConversationType_GROUP) {
            //重新取一下混合的用户信息
            RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.model.senderUserId
                                                                             inGroupId:self.model.targetId];
            [self updateUserInfoUI:userInfo];
        } else if (self.model.messageDirection == MessageDirection_SEND) {
            [self updateUserInfoUI:userInfoDic[@"userInfo"]];
        } else if (self.model.conversationType != ConversationType_APPSERVICE &&
                   self.model.conversationType != ConversationType_PUBLICSERVICE) {
            if (self.model.conversationType == ConversationType_CUSTOMERSERVICE && self.model.content.senderUserInfo) {
                return;
            }
            [self updateUserInfoUI:userInfoDic[@"userInfo"]];
        }
    }
}

- (void)enableShowReceiptView:(UIButton *)sender {
    if (!self.model.messageUId) {
        RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:self.model.messageId];
        if (message) {
            [self sendMessageReadReceiptRequest:message.messageUId];
        }
    } else {
        [self sendMessageReadReceiptRequest:self.model.messageUId];
    }
}

- (void)sendMessageReadReceiptRequest:(NSString *)messageUId {
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:self.model.messageId];
    if (message) {
        if (!messageUId || [messageUId isEqualToString:@""]) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [[RCIMClient sharedRCIMClient] sendReadReceiptRequest:message
            success:^{
                weakSelf.model.isCanSendReadReceipt = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.receiptView.hidden = YES;
                    weakSelf.receiptCountLabel.hidden = NO;
                    weakSelf.receiptCountLabel.userInteractionEnabled = YES;
                    weakSelf.receiptCountLabel.text =
                        [NSString stringWithFormat:NSLocalizedStringFromTable(@"readNum", @"RongCloudKit", nil), 0];
                    if (!weakSelf.model.readReceiptInfo) {
                        weakSelf.model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                    }
                    weakSelf.model.readReceiptInfo.isReceiptRequestMessage = YES;
                    if ([weakSelf.delegate respondsToSelector:@selector(didTapNeedReceiptView:)]) {
                        [weakSelf.delegate didTapNeedReceiptView:weakSelf.model];
                    }
                });
            }
            error:^(RCErrorCode nErrorCode) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *tip = NSLocalizedStringFromTable(@"SendReadReceiptRequestFailed", @"RongCloudKit", nil);
                    if (tip.length > 0 && ![tip isEqualToString:@"SendReadReceiptRequestFailed"]) {
                        UIViewController *rootVC = [RCKitUtility getKeyWindow].rootViewController;
                        UIAlertController *alertController = [UIAlertController
                            alertControllerWithTitle:nil
                                             message:NSLocalizedStringFromTable(@"SendReadReceiptRequestFailed",
                                                                                @"RongCloudKit", nil)
                                      preferredStyle:UIAlertControllerStyleAlert];
                        [rootVC presentViewController:alertController animated:YES completion:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                                       dispatch_get_main_queue(), ^{
                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                       });
                    }
                });
            }];
    }
}

- (void)onGroupUserInfoUpdate:(NSNotification *)notification {
    if (self.model.conversationType == ConversationType_GROUP) {
        NSDictionary *groupUserInfoDic = (NSDictionary *)notification.object;
        if ([self.model.targetId isEqualToString:groupUserInfoDic[@"inGroupId"]] &&
            [self.model.senderUserId isEqualToString:groupUserInfoDic[@"userId"]]) {
            //重新取一下混合的用户信息
            RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.model.senderUserId
                                                                             inGroupId:self.model.targetId];
            [self updateUserInfoUI:userInfo];
        }
    }
}

- (void)updateUserInfoUI:(RCUserInfo *)userInfo {
    self.model.userInfo = userInfo;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo.portraitUri.length > 0) {
            [weakSelf.portraitImageView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
        }
        [weakSelf.nicknameLabel setText:userInfo.name];
    });
}

- (void)clickReceiptCountView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapReceiptCountView:)]) {
        if (self.receiptCountLabel.text != nil) {
            [self.delegate didTapReceiptCountView:self.model];
        }
        return;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 向后兼容
- (UIButton *)groupAndDiscussionReceiptView {
    return self.receiptView;
}
- (void)setGroupAndDiscussionReceiptView:(UIButton *)groupAndDiscussionReceiptView {
    self.receiptView = groupAndDiscussionReceiptView;
}
- (UILabel *)groupAndDiscussionReceiptCountView {
    return self.receiptCountLabel;
}
- (void)setGroupAndDiscussionReceiptCountView:(UILabel *)groupAndDiscussionReceiptCountView {
    self.receiptCountLabel = groupAndDiscussionReceiptCountView;
}

#pragma mart - lazy load
- (UIButton *)receiptView {
    if (!_receiptView) {
        _receiptView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 19)];
        _receiptView.contentEdgeInsets = UIEdgeInsetsMake(5, 9.5, 0, 0);
        [_receiptView setImage:[RCKitUtility imageNamed:@"receipt" ofBundle:@"RongCloud.bundle"]
                      forState:UIControlStateNormal];
        [_receiptView setImage:[RCKitUtility imageNamed:@"receipt_hover" ofBundle:@"RongCloud.bundle"]
                      forState:UIControlStateHighlighted];
        _receiptView.hidden = YES;
        [_receiptView addTarget:self
                         action:@selector(enableShowReceiptView:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _receiptView;
}

- (UILabel *)receiptCountLabel {
    if (!_receiptCountLabel) {
        _receiptCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, 10, 50, 20)];
        _receiptCountLabel.textAlignment = NSTextAlignmentRight;
        _receiptCountLabel.font = [UIFont systemFontOfSize:10.0f];
        _receiptCountLabel.textColor = RCDYCOLOR(0x96c4ec, 0x007acc);

        _receiptCountLabel.hidden = YES;
        UITapGestureRecognizer *clickReceiptCountView =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReceiptCountView:)];
        [_receiptCountLabel addGestureRecognizer:clickReceiptCountView];
    }
    return _receiptCountLabel;
}

- (UILabel *)hasReadLabel {
    if (!_hasReadLabel) {
        _hasReadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _hasReadLabel.font = [UIFont systemFontOfSize:9.0f];
        _hasReadLabel.textColor = HEXCOLOR(0x96c4ec);
        _hasReadLabel.text = NSLocalizedStringFromTable(@"read", @"RongCloudKit", nil);
        _hasReadLabel.hidden = YES;
    }
    return _hasReadLabel;
}

- (UIView *)destructView {
    if (!_destructView) {
        _destructView = [[UIView alloc] init];
        _destructView.backgroundColor = [UIColor clearColor];
        _destructView.hidden = YES;
    }
    return _destructView;
}

- (UIButton *)destructBtn {
    if (_destructBtn == nil) {
        _destructBtn = [[UIButton alloc] init];
        [_destructBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _destructBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _destructBtn.backgroundColor = [UIColor whiteColor];
        _destructBtn.layer.cornerRadius = 7.5f;
        _destructBtn.layer.masksToBounds = YES;
        _destructBtn.userInteractionEnabled = NO;
        _destructBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    }
    return _destructBtn;
}

- (UIActivityIndicatorView *)messageActivityIndicatorView {
    if (!_messageActivityIndicatorView) {
        if (@available(iOS 13.0, *)) {
            _messageActivityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _messageActivityIndicatorView =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    return _messageActivityIndicatorView;
}

@end
