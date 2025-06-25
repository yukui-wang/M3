//
//  RCVoiceMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCVoiceMessageCell.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCVoicePlayer.h"
#import "RCIMClient+Destructing.h"

NSString *const kNotificationPlayVoice = @"kNotificationPlayVoice";

static NSTimer *s_previousAnimationTimer = nil;
static UIImageView *s_previousPlayVoiceImageView = nil;
static RCMessageDirection s_previousMessageDirection;
static long s_messageId = 0;
@interface RCMessageCell ()
- (void)messageDestructing;
@end
@interface RCVoiceMessageCell () <RCVoicePlayerObserver>
@property (nonatomic) long duration;

@property (nonatomic) CGSize voiceViewSize;

@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic) int animationIndex;
@property (nonatomic, strong) RCVoicePlayer *voicePlayer;

- (void)initialize;

- (void)scheduleAnimationOperation;
- (void)enableCurrentAnimationTimer;
- (void)disableCurrentAnimationTimer;
- (void)disablePreviousAnimationTimer;

- (void)startPlayingVoiceData;
- (void)stopPlayingVoiceData;
- (void)resetActiveEventInBackgroundMode;

- (void)tapBubbleBackgroundViewEvent:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation RCVoiceMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 40.0f;

    if (__messagecontentview_height < [RCIM sharedRCIM].globalMessagePortraitSize.height) {
        __messagecontentview_height = [RCIM sharedRCIM].globalMessagePortraitSize.height;
    }

    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.playVoiceView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.voiceDurationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.bubbleBackgroundView addSubview:self.playVoiceView];
    [self.bubbleBackgroundView addSubview:self.voiceDurationLabel];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];

    UITapGestureRecognizer *bubbleBackgroundViewTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBubbleBackgroundViewEvent:)];
    bubbleBackgroundViewTap.numberOfTapsRequired = 1;
    bubbleBackgroundViewTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:bubbleBackgroundViewTap];
    self.bubbleBackgroundView.userInteractionEnabled = YES;

    self.voicePlayer = [RCVoicePlayer defaultPlayer];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetActiveEventInBackgroundMode)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetByExtensionModelEvents)
                                                 name:@"RCKitExtensionModelResetVoicePlayingNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayingVoiceDataIfNeed:)
                                                 name:kNotificationStopVoicePlayer
                                               object:nil];
}

- (void)playVoiceNotification:(NSNotification *)notification {
    long messageId = [notification.object longValue];
    if (messageId == self.model.messageId) {
        [self playVoice];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    if (s_messageId == self.model.messageId) {
        if ((self.voicePlayer.isPlaying)) {
            [self disableCurrentAnimationTimer];
            [self enableCurrentAnimationTimer];
        }
    } else {
        [self disableCurrentAnimationTimer];
    }

    RCVoiceMessage *_voiceMessage = (RCVoiceMessage *)model.content;
    if (_voiceMessage) {
        self.duration = _voiceMessage.duration;
        self.voiceDurationLabel.text = [NSString stringWithFormat:@"%ld''", self.duration];
        [self.voiceDurationLabel setTextAlignment:NSTextAlignmentCenter];
    } else {
        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCVoiceMessage object");
    }

    CGFloat audioLength = self.duration;
    CGFloat audioBubbleWidth =
        kAudioBubbleMinWidth +
        (kAudioBubbleMaxWidth - kAudioBubbleMinWidth) * audioLength / [RCIM sharedRCIM].maxVoiceDuration;
    audioBubbleWidth = audioBubbleWidth > kAudioBubbleMaxWidth ? kAudioBubbleMaxWidth : audioBubbleWidth;

    CGRect messageContentViewRect = self.messageContentView.frame;
    [self.voiceUnreadTagView removeFromSuperview];
    self.voiceUnreadTagView.image = nil;
    [self.voiceUnreadTagView setHidden:YES];
    if (MessageDirection_RECEIVE == model.messageDirection) {
        messageContentViewRect.size.width = audioBubbleWidth + 38;
        self.messageContentView.frame = messageContentViewRect;
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, audioBubbleWidth, 40);
        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.playVoiceView.frame = CGRectMake(16, CGRectGetMidY(self.bubbleBackgroundView.frame) - 10, 20, 20);
        self.playVoiceView.image = [RCKitUtility imageNamed:@"from_voice" ofBundle:@"RongCloud.bundle"];
        self.voiceDurationLabel.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 40 - 9, 0, 40, 40);
        self.voiceDurationLabel.textAlignment = NSTextAlignmentRight;
        self.voiceDurationLabel.textColor = HEXCOLOR(0x939393);
        // self.voiceUnreadTagView.hidden=YES;
        if (ReceivedStatus_LISTENED != self.model.receivedStatus) {
            self.voiceUnreadTagView = [[UIImageView alloc] initWithFrame:CGRectZero];
            self.voiceUnreadTagView.backgroundColor = [UIColor clearColor];
            [self.voiceUnreadTagView setHidden:NO];
            [self.messageContentView addSubview:self.voiceUnreadTagView];
            self.voiceUnreadTagView.image = [RCKitUtility imageNamed:@"voice_unread" ofBundle:@"RongCloud.bundle"];
            CGFloat x = CGRectGetMaxX(self.bubbleBackgroundView.frame) + 5;
            CGFloat y = 6;
            self.voiceUnreadTagView.frame = CGRectMake(x, y + 9, 10, 10);
        }
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                         image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        self.voiceDurationLabel.textColor = RCDYCOLOR(0x3f81bc, 0xE0E0E0);
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, audioBubbleWidth, 40);
        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.playVoiceView.frame =
            CGRectMake(audioBubbleWidth - 20 - 16, CGRectGetMidY(self.bubbleBackgroundView.frame) - 10, 20, 20);
        self.playVoiceView.image = [RCKitUtility imageNamed:@"to_voice" ofBundle:@"RongCloud.bundle"];
        self.voiceDurationLabel.frame = CGRectMake(10, 0, 40, 40);
        self.voiceDurationLabel.textAlignment = NSTextAlignmentLeft;
        CGRect statusFrame = self.statusContentView.frame;
        statusFrame.origin.x = statusFrame.origin.x + 5;
        [self.statusContentView setFrame:statusFrame];
        [self.voiceUnreadTagView setHidden:YES];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                         image.size.height * 0.2, image.size.width * 0.8)];
        messageContentViewRect.size.width = audioBubbleWidth;
        messageContentViewRect.size.height = 40;
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
    }

    [self setDestructViewLayout];
}

- (void)setDestructViewLayout {
    RCVoiceMessage *_voiceMessage = (RCVoiceMessage *)self.model.content;
    if (_voiceMessage.destructDuration > 0) {
        self.destructView.hidden = NO;
        [self.messageContentView bringSubviewToFront:self.destructView];
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5,
                                                 CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 21, 12);
        } else {
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.bubbleBackgroundView.frame) - 7.5,
                                                 CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
    }
}

// todo cyenux
- (void)resetByExtensionModelEvents {
    [self stopPlayingVoiceData];
    [self disableCurrentAnimationTimer];
}

#pragma mark - stop and disable timer during background mode.
- (void)resetActiveEventInBackgroundMode {
    [self stopPlayingVoiceData];
    [self disableCurrentAnimationTimer];
}

- (void)stopPlayingVoiceDataIfNeed:(NSNotification *)notification {
    long messageId = [notification.object longValue];
    if (messageId == self.model.messageId) {
        [self disableCurrentAnimationTimer];
        [self startBurn];
    }
}

/**
 *  @override, implement the playing animation indicator after tapping voice message cell.
 *
 *  @param gestureRecognizer, UITapGestureRecognizer that added for bubbleBackgroundView in super class.
 */
- (void)tapBubbleBackgroundViewEvent:(UIGestureRecognizer *)gestureRecognizer {
    DebugLog(@"%s", __FUNCTION__);

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)playVoice {
    if (self.voiceUnreadTagView) {
        self.voiceUnreadTagView.hidden = YES;
        [self.voiceUnreadTagView removeFromSuperview];
        self.voiceUnreadTagView = nil;
    }
    //    if (self.model.receivedStatus != ReceivedStatus_LISTENED) {
    [[RCIMClient sharedRCIMClient] setMessageReceivedStatus:self.model.messageId
                                             receivedStatus:ReceivedStatus_LISTENED];
    //    }
    self.model.receivedStatus = ReceivedStatus_LISTENED;
    [self disablePreviousAnimationTimer];

    if (self.model.messageId == s_messageId) {
        if (self.voicePlayer.isPlaying) {
            [self.voicePlayer stopPlayVoice];
            [self startBurn];
        } else {
            [self startPlayingVoiceData];
            [self stopBurn];
        }
    } else {
        [self startPlayingVoiceData];
        [self stopBurn];
    }
}

- (void)startBurn {
    RCVoiceMessage *voiceMessage = (RCVoiceMessage *)self.model.content;
    if (self.model.messageDirection == MessageDirection_RECEIVE && voiceMessage.destructDuration > 0) {
        [[RCIMClient sharedRCIMClient]
            messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.model.messageId]];
    }
}

- (void)stopBurn {
    RCVoiceMessage *voiceMessage = (RCVoiceMessage *)self.model.content;
    if (self.model.messageDirection == MessageDirection_RECEIVE && voiceMessage.destructDuration > 0) {
        [[RCIMClient sharedRCIMClient]
            messageStopDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.model.messageId]];
        if ([self respondsToSelector:@selector(messageDestructing)]) {
            [self performSelector:@selector(messageDestructing) withObject:nil afterDelay:NO];
        }
    }
}

- (void)stopPlayingVoice {
    if (self.model.messageId == s_messageId) {
        if (self.voicePlayer.isPlaying) {
            [self stopPlayingVoiceData];
            [self disableCurrentAnimationTimer];
        }
    }
}

// override
- (void)msgStatusViewTapEventHandler:(id)sender {

    // to do something.
}

- (void)startPlayingVoiceData {
    RCVoiceMessage *_voiceMessage = (RCVoiceMessage *)self.model.content;

    if (_voiceMessage.wavAudioData) {

        /**
         *  if the previous voice message is playing, then
         *  stop it and reset the prevoius animation timer indicator
         */
        //        [self stopPlayingVoiceData];

        //        BOOL bPlay = [self.voicePlayer playVoice:[@(self.model.messageId) stringValue]
        //                                       voiceData:_voiceMessage.wavAudioData
        //                                        observer:self];

        BOOL bPlay = [self.voicePlayer playVoice:self.model.conversationType
                                        targetId:self.model.targetId
                                       messageId:self.model.messageId
                                       direction:self.model.messageDirection
                                       voiceData:_voiceMessage.wavAudioData
                                        observer:self];
        // if failed to play the voice message, reset all indicator.
        if (!bPlay) {
            [self stopPlayingVoiceData];
            [self disableCurrentAnimationTimer];
        } else {
            [self enableCurrentAnimationTimer];
        }
        s_messageId = self.model.messageId;
    } else {
        DebugLog(@"[RongIMKit]: RCVoiceMessage.voiceData is NULL");
    }
}
- (void)stopPlayingVoiceData {
    if (self.voicePlayer.isPlaying) {
        [self.voicePlayer stopPlayVoice];
    }
}
- (void)enableCurrentAnimationTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(scheduleAnimationOperation)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];

    s_previousAnimationTimer = self.animationTimer;
    s_previousPlayVoiceImageView = self.playVoiceView;
    s_previousMessageDirection = self.model.messageDirection;
}

/**
 *  Implement the animation operation
 */
- (void)scheduleAnimationOperation {
    DebugLog(@"%s", __FUNCTION__);

    self.animationIndex++;

    NSString *_playingIndicatorIndex;

    if (MessageDirection_SEND == self.model.messageDirection) {
        _playingIndicatorIndex = [NSString stringWithFormat:@"to_voice_%d", (self.animationIndex % 4)];
    } else {
        _playingIndicatorIndex = [NSString stringWithFormat:@"from_voice_%d", (self.animationIndex % 4)];
    }
    DebugLog(@"_playingIndicatorIndex > %@", _playingIndicatorIndex);
    self.playVoiceView.image = [RCKitUtility imageNamed:_playingIndicatorIndex ofBundle:@"RongCloud.bundle"];
}

- (void)disableCurrentAnimationTimer {
    if (self.animationTimer && [self.animationTimer isValid]) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.animationIndex = 0;
    }
    /**
     *  reset the original image
     */
    if (MessageDirection_SEND == self.model.messageDirection) {
        self.playVoiceView.image = [RCKitUtility imageNamed:@"to_voice" ofBundle:@"RongCloud.bundle"];
    } else {
        self.playVoiceView.image = [RCKitUtility imageNamed:@"from_voice" ofBundle:@"RongCloud.bundle"];
    }
}
- (void)disablePreviousAnimationTimer {
    if (s_previousAnimationTimer && [s_previousAnimationTimer isValid]) {
        [s_previousAnimationTimer invalidate];
        s_previousAnimationTimer = nil;

        /**
         *  reset the previous playVoiceView indicator image
         */
        if (s_previousPlayVoiceImageView) {
            if (MessageDirection_SEND == s_previousMessageDirection) {
                s_previousPlayVoiceImageView.image = [RCKitUtility imageNamed:@"to_voice" ofBundle:@"RongCloud.bundle"];
            } else {
                s_previousPlayVoiceImageView.image =
                    [RCKitUtility imageNamed:@"from_voice" ofBundle:@"RongCloud.bundle"];
            }
            s_previousPlayVoiceImageView = nil;
            s_previousMessageDirection = 0;
        }
    }
}

#pragma mark RCVoicePlayerObserver
- (void)PlayerDidFinishPlaying:(BOOL)isFinish {
    if (isFinish) {
        [self disableCurrentAnimationTimer];
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(NSError *)error {
    [self disableCurrentAnimationTimer];
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

- (void)dealloc {
    [self disableCurrentAnimationTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
