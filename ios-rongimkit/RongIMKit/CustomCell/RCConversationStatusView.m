//
//  RCConversationStatusView.m
//  RongIMKit
//
//  Created by 岑裕 on 16/9/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCConversationStatusView.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCIM.h"

@interface RCConversationStatusView ()

@property (nonatomic, strong) NSArray *constraints;
@property (nonatomic, strong) RCConversationModel *backupModel;

@end

@implementation RCConversationStatusView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubviewsLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviewsLayout];
    }
    return self;
}

- (void)initSubviewsLayout {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    self.conversationNotificationStatusView = [[UIImageView alloc] initWithFrame:CGRectMake(38, 3, 14, 14)];
    self.conversationNotificationStatusView.backgroundColor = [UIColor clearColor];
    self.conversationNotificationStatusView.image = IMAGE_BY_NAMED(@"block_notification");
    self.conversationNotificationStatusView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.conversationNotificationStatusView];

    self.messageReadStatusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.messageReadStatusView.backgroundColor = [UIColor clearColor];
    self.messageReadStatusView.image = IMAGE_BY_NAMED(@"message_read_status");
    self.messageReadStatusView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.messageReadStatusView];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationNotificationStatusView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageReadStatusView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}

- (void)updateReadStatus:(RCConversationModel *)model {
    if (model.draft.length == 0 && model.lastestMessageId > 0 &&
        model.lastestMessageDirection == MessageDirection_SEND && model.sentStatus == SentStatus_READ &&
        ((model.conversationType == ConversationType_PRIVATE &&
          [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(model.conversationType)]) ||
         model.conversationType == ConversationType_Encrypted)) {
        RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:model.lastestMessageId];
        if (msg && msg.messageUId && msg.messageUId.length > 0 &&
            ![msg.objectName isEqualToString:RCRecallNotificationMessageIdentifier]) {
            self.messageReadStatusView.hidden = NO;
        }
    }
}

- (void)updateNotificationStatus:(RCConversationModel *)model {
    self.conversationNotificationStatusView.hidden = YES;
    self.backupModel = model;
    if ([model isEqual:self.backupModel]) {
        if (model.blockStatus == DO_NOT_DISTURB) {
            self.conversationNotificationStatusView.hidden = NO;
        } else {
            self.conversationNotificationStatusView.hidden = YES;
        }
    }
    [self updateLayout];
}

- (void)updateLayout {
    if (self.constraints) {
        [self removeConstraints:self.constraints];
    }

    NSString *layoutFormat = nil;
    if (self.conversationNotificationStatusView.hidden) {
        layoutFormat = @"H:[_messageReadStatusView(12)]-5-|";
    } else {
        layoutFormat = @"H:[_messageReadStatusView(12)]-8-[_conversationNotificationStatusView(11)]-5-|";
    }
    self.constraints = [NSLayoutConstraint
        constraintsWithVisualFormat:layoutFormat
                            options:0
                            metrics:nil
                              views:NSDictionaryOfVariableBindings(_messageReadStatusView,
                                                                   _conversationNotificationStatusView)];
    [self addConstraints:self.constraints];

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)resetDefaultLayout:(RCConversationModel *)reuseModel {
    self.conversationNotificationStatusView.hidden = YES;
    self.messageReadStatusView.hidden = YES;
}

@end
