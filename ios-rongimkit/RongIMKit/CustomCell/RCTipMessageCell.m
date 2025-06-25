//
//  RCTipMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/1/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCTipMessageCell.h"
#import "RCKitUtility.h"
#import "RCUserInfoCacheManager.h"
#import "RCKitCommonDefine.h"
#import "RCReeditMessageManager.h"
@interface RCTipMessageCell () <RCAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableSet *relatedUserIdList;

@property (nonatomic, strong) UILabel *reeditLabel;

@end

@implementation RCTipMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {

    RCMessageContent *notification = model.content;
    NSString *localizedMessage = [RCKitUtility formatMessage:notification
                                                    targetId:model.targetId
                                            conversationType:model.conversationType
                                                isAllMessage:YES];
    CGFloat maxMessageLabelWidth = collectionViewWidth - 30 * 2;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:localizedMessage
                                                    font:[UIFont systemFontOfSize:14.f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 6);

    CGFloat __height = __labelSize.height;

    __height += extraHeight;

    return CGSizeMake(collectionViewWidth, __height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipMessageLabel = [RCTipLabel greyTipLabel];
        self.tipMessageLabel.backgroundColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xc9c9c9) darkColor:HEXCOLOR(0x232323)];
        self.tipMessageLabel.textColor = RCDYCOLOR(0xffffff, 0x707070);
        self.tipMessageLabel.delegate = self;
        self.tipMessageLabel.userInteractionEnabled = YES;
        [self.baseContentView addSubview:self.tipMessageLabel];
        self.tipMessageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    RCMessageContent *content = model.content;

    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;

    self.relatedUserIdList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchUserInfoUpdateNotification object:nil];

    if ([content isMemberOfClass:[RCDiscussionNotificationMessage class]]) {
        self.relatedUserIdList = [self getRelatedUserIdList:content];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUserInfoUpdate:)
                                                     name:RCKitDispatchUserInfoUpdateNotification
                                                   object:nil];

        self.tipMessageLabel.text = [RCKitUtility formatMessage:content
                                                       targetId:model.targetId
                                               conversationType:model.conversationType
                                                   isAllMessage:YES];
    } else if ([content isMemberOfClass:[RCGroupNotificationMessage class]]) {
        NSString *localizedMessage = [RCKitUtility formatMessage:content
                                                        targetId:model.targetId
                                                conversationType:model.conversationType
                                                    isAllMessage:YES];
        self.tipMessageLabel.text = localizedMessage;
    } else if ([content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *notification = (RCInformationNotificationMessage *)content;
        NSString *localizedMessage = [RCKitUtility formatMessage:notification
                                                        targetId:model.targetId
                                                conversationType:model.conversationType
                                                    isAllMessage:YES];
        self.tipMessageLabel.text = localizedMessage;
    } else if ([content isMemberOfClass:[RCRecallNotificationMessage class]]) {
        self.relatedUserIdList = [self getRelatedUserIdList:content];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUserInfoUpdate:)
                                                     name:RCKitDispatchUserInfoUpdateNotification
                                                   object:nil];
        RCRecallNotificationMessage *notification = (RCRecallNotificationMessage *)content;
        NSString *localizedMessage = [RCKitUtility formatMessage:notification
                                                        targetId:self.model.targetId
                                                conversationType:self.model.conversationType
                                                    isAllMessage:YES];
        self.tipMessageLabel.text = localizedMessage;
    }

    NSString *__text = self.tipMessageLabel.text;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                    font:[UIFont systemFontOfSize:14.0f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 10, __textSize.height + 6);
    if ([content isMemberOfClass:[RCRecallNotificationMessage class]]) {
        [self.reeditLabel removeFromSuperview];
        if ([self canReeditMessage]) {
            CGSize buttonTitleSize =
                [RCKitUtility getTextDrawingSize:NSLocalizedStringFromTable(@"RecallEdit", @"RongCloudKit", nil)
                                            font:[UIFont systemFontOfSize:14.0f]
                                 constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
            self.reeditLabel = [[UILabel alloc] init];
            self.reeditLabel.text = NSLocalizedStringFromTable(@"RecallEdit", @"RongCloudKit", nil);
            self.reeditLabel.userInteractionEnabled = YES;
            self.reeditLabel.textColor = [RCKitUtility getCMPThemeSkinColor];//  RCDYCOLOR(0x0099ff, 0x0099ff);
            self.reeditLabel.font = [UIFont systemFontOfSize:14.f];
            UITapGestureRecognizer *tapGestureRecognizer =
                [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reeditAction:)];
            [self.reeditLabel addGestureRecognizer:tapGestureRecognizer];

            CGRect frame = CGRectMake(
                (self.baseContentView.bounds.size.width - __labelSize.width - buttonTitleSize.width) / 2.0f - 5, 0,
                __labelSize.width + 10 + buttonTitleSize.width, __labelSize.height);
            self.reeditLabel.frame =
                CGRectMake(frame.size.width - buttonTitleSize.width - 7, 1, buttonTitleSize.width, 22);

            self.tipMessageLabel.frame = frame;
            self.tipMessageLabel.textAlignment = NSTextAlignmentLeft;
            self.tipMessageLabel.text = [NSString stringWithFormat:@"  %@", self.tipMessageLabel.text];
            [self.tipMessageLabel addSubview:self.reeditLabel];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateRecallStatus:)
                                                         name:RCKitNeedUpdateRecallStatusNotification
                                                       object:nil];
        } else {
            self.tipMessageLabel.textAlignment = NSTextAlignmentCenter;
            self.tipMessageLabel.frame =
                CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f - 5, 0,
                           __labelSize.width + 10, __labelSize.height);
        }
    } else {
        self.tipMessageLabel.textAlignment = NSTextAlignmentCenter;
        self.tipMessageLabel.frame = CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f - 5,
                                                0, __labelSize.width + 10, __labelSize.height);
    }
}

- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    urlString = [RCKitUtility checkOrAppendHttpForUrl:urlString];
    if ([self.delegate respondsToSelector:@selector(didTapUrlInMessageCell:model:)]) {
        [self.delegate didTapUrlInMessageCell:urlString model:self.model];
        return;
    }
}

- (void)reeditAction:(UITapGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] != UIGestureRecognizerStateEnded) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didTapReedit:)]) {
        [self.delegate didTapReedit:self.model];
    }
}

/**
 Tells the delegate that the user did select a link to an address.

 @param label The label whose link was selected.
 @param addressComponents The components of the address for the selected link.
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents {
}

/**
 Tells the delegate that the user did select a link to a phone number.

 @param label The label whose link was selected.
 @param phoneNumber The phone number for the selected link.
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    if (!phoneNumber) {
        NSLog(@"didSelectLinkWithPhoneNumber phoneNumber 是 nil");
        return;
    }
    NSString *number = [@"tel://" stringByAppendingString:phoneNumber];
    if ([self.delegate respondsToSelector:@selector(didTapPhoneNumberInMessageCell:model:)]) {
        [self.delegate didTapPhoneNumberInMessageCell:number model:self.model];
        return;
    }
}

- (void)attributedLabel:(RCAttributedLabel *)label didTapLabel:(NSString *)content {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (NSMutableSet *)getRelatedUserIdList:(RCMessageContent *)content {
    if ([content isKindOfClass:[RCDiscussionNotificationMessage class]]) {
        RCDiscussionNotificationMessage *messageContent = (RCDiscussionNotificationMessage *)content;
        NSMutableSet *relatedUserIdList = [[NSMutableSet alloc] init];
        if (messageContent.operatorId) {
            [relatedUserIdList addObject:messageContent.operatorId];
        }

        if (messageContent.type == RCInviteDiscussionNotification ||
            messageContent.type == RCRemoveDiscussionMemberNotification) {
            NSArray *targetUserList = [[messageContent.extension
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                componentsSeparatedByString:@","];
            if (targetUserList && targetUserList.count > 0) {
                [relatedUserIdList addObjectsFromArray:targetUserList];
            }
        }
        return relatedUserIdList;
    } else if ([content isKindOfClass:[RCRecallNotificationMessage class]]) {
        RCRecallNotificationMessage *messageContent = (RCRecallNotificationMessage *)content;
        NSMutableSet *relatedUserIdList = [[NSMutableSet alloc] init];
        if (messageContent.operatorId) {
            [relatedUserIdList addObject:messageContent.operatorId];
        }
        return relatedUserIdList;
    } else {
        return nil;
    }
}

- (void)onUserInfoUpdate:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;

    //    RCUserInfo *userInfo = userInfoDic[@"userInfo"];
    if ([self.relatedUserIdList containsObject:userInfoDic[@"userId"]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDataModel:self.model];
        });
    }
}

- (void)updateRecallStatus:(NSNotification *)notification {
    NSDictionary *dict = notification.object;
    long messageId = [dict[@"messageId"] longValue];
    if (messageId == self.model.messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:RCKitNeedUpdateRecallStatusNotification
                                                          object:nil];
            [self setDataModel:self.model];
        });
    }
}

// 判断是否可以重新编辑，可编辑时间从 RCIM 中的 reeditDuration 获取
- (BOOL)canReeditMessage {
    RCRecallNotificationMessage *recallMessage = (RCRecallNotificationMessage *)self.model.content;
    long long cTime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long interval = cTime - recallMessage.recallActionTime;
    //ks fix V5-8240 iOS-非文字和表情消息撤回后不应该显示重新编辑
    if ([recallMessage.originalObjectName isEqualToString:@"RC:QuoteMessage"]) {
        interval = cTime - recallMessage.recallTime;
    }
    BOOL canReedit = NO;
    NSUInteger reeditDuration = [RCIM sharedRCIM].reeditDuration * 1000;
    if (reeditDuration > 0 && interval > 0 && interval <= reeditDuration &&
        (self.messageDirection == MessageDirection_SEND)) {
        canReedit = YES;
        [[RCReeditMessageManager defaultManager] addReeditDuration:interval messageId:self.model.messageId];
    }
    return canReedit;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
