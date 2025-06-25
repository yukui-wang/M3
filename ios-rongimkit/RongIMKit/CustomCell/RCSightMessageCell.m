//
//  RCSightMessageCell.m
//  RongIMKit
//
//  Created by LiFei on 2016/12/5.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCSightMessageCell.h"
#import "RCKitCommonDefine.h"
#import "RCSightMessageProgressView.h"
#import "RCIMClient+Destructing.h"
#import "RCResendManager.h"

#define BurnBackGroundWidth 126
#define BurnBackGroundHeight 120

extern NSString *const RCKitDispatchDownloadMediaNotification;

@interface RCSightMessageCell ()
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *shadowMaskView;
@property (nonatomic, strong) UIView *playButtonView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *playImage;
@property (nonatomic, strong) UIImageView *burnPicture;
@property (nonatomic, strong) UILabel *burnLabel;
@property (nonatomic, strong) UILabel *destructDurationLabel;
@property (nonatomic, strong) UIImageView *burnBackgroundView;
@end

@implementation RCSightMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 0.0f;
    RCSightMessage *_sightMessage = (RCSightMessage *)model.content;

    CGSize imageSize = _sightMessage.thumbnailImage.size;
    //兼容240
    CGFloat rate = imageSize.width / imageSize.height;
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;

    if (imageSize.width != 0 && imageSize.height != 0) {
        if (rate > 1.0f) {
            imageWidth = 160;
            imageHeight = 160 / rate;
        } else {
            imageHeight = 160;
            imageWidth = 160 * rate;
        }
    } else {
        imageWidth = imageSize.width;
        imageHeight = imageSize.height;
    }
    //图片half
    imageSize = CGSizeMake(imageWidth, imageHeight);
    __messagecontentview_height = imageSize.height;
    if (model.content.destructDuration > 0) {
        __messagecontentview_height = BurnBackGroundHeight;
    } else {
        __messagecontentview_height = imageSize.height;
    }

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
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.thumbnailView.layer.masksToBounds = YES;
    [self.messageContentView addSubview:self.thumbnailView];

    self.burnBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.burnBackgroundView];

    self.burnPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 26)];
    self.burnPicture.userInteractionEnabled = NO;
    [self.burnBackgroundView addSubview:self.burnPicture];

    self.burnLabel = [[UILabel alloc] init];
    self.burnLabel.text = NSLocalizedStringFromTable(@"ClickToPlay", @"RongCloudKit", nil);
    self.burnLabel.font = [UIFont systemFontOfSize:12];
    self.burnLabel.userInteractionEnabled = NO;
    self.burnLabel.textAlignment = NSTextAlignmentCenter;
    [self.burnBackgroundView addSubview:self.burnLabel];

    self.destructDurationLabel = [[UILabel alloc] init];
    self.destructDurationLabel.userInteractionEnabled = NO;
    self.destructDurationLabel.font = [UIFont systemFontOfSize:12];
    [self.destructDurationLabel setTextAlignment:NSTextAlignmentRight];
    [self.destructDurationLabel setBackgroundColor:[UIColor clearColor]];
    self.destructDurationLabel.userInteractionEnabled = NO;
    [self.burnBackgroundView addSubview:self.destructDurationLabel];

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.thumbnailView addGestureRecognizer:longPress];
    //
    UITapGestureRecognizer *sightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSight:)];
    [self.thumbnailView addGestureRecognizer:sightTap];
    self.thumbnailView.userInteractionEnabled = NO;

    self.messageContentView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *burnLongPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(burnLongPressed:)];
    [self.messageContentView addGestureRecognizer:burnLongPress];
    //
    UITapGestureRecognizer *burnSightTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(burnTapSight:)];
    [self.messageContentView addGestureRecognizer:burnSightTap];

    //      UITapGestureRecognizer *progressViewTap =[[UITapGestureRecognizer alloc] initWithTarget:self
    //      action:@selector(tapPicture:)]; progressViewTap.numberOfTapsRequired = 1;
    //      progressViewTap.numberOfTouchesRequired = 1;
    //      [self.progressView addGestureRecognizer:progressViewTap];
    //      self.progressView.userInteractionEnabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadMediaStatus:)
                                                 name:RCKitDispatchDownloadMediaNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDownloadMediaStatus:(NSNotification *)notify {
    NSDictionary *statusDic = notify.userInfo;
    if (self.model.messageId == [statusDic[@"messageId"] longValue]) {
        if ([statusDic[@"type"] isEqualToString:@"progress"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.progressView isHidden]) {
                    [self.progressView setHidden:NO];
                    [self.progressView startIndeterminateAnimation];
                }
                [self.progressView setProgress:[statusDic[@"progress"] intValue] animated:YES];
            });
        } else if ([statusDic[@"type"] isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView stopIndeterminateAnimation];
                [self.progressView setHidden:YES];
                RCSightMessage *sightContent = (RCSightMessage *)self.model.content;
                [sightContent setValue:statusDic[@"mediaPath"] forKey:@"localPath"];
            });
        } else if ([statusDic[@"type"] isEqualToString:@"error"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self.progressView isHidden]) {
                    [self.progressView stopIndeterminateAnimation];
                    [self.progressView setHidden:YES];
                }

                UIViewController *rootVC = [RCKitUtility getKeyWindow].rootViewController;
                UIAlertController *alertController = [UIAlertController
                    alertControllerWithTitle:nil
                                     message:NSLocalizedStringFromTable(@"FileDownloadFailed", @"RongCloudKit", nil)
                              preferredStyle:UIAlertControllerStyleAlert];
                [alertController
                    addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action){
                                                     }]];
                [rootVC presentViewController:alertController animated:YES completion:nil];
            });
        }
    }
}

- (void)setMaskImage:(UIImage *)maskImage {
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];

        _maskView.frame = self.thumbnailView.bounds;
        self.thumbnailView.layer.mask = _maskView.layer;
        self.thumbnailView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.thumbnailView.bounds;
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];

    _shadowMaskView.frame =
        CGRectMake(self.thumbnailView.frame.origin.x - 0.5, self.thumbnailView.frame.origin.y - 0.5,
                   self.thumbnailView.frame.size.width + 1, self.thumbnailView.frame.size.height + 1);
    [self.messageContentView addSubview:_shadowMaskView];
    [self.messageContentView bringSubviewToFront:self.thumbnailView];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    self.thumbnailView.image = nil;
    self.shadowMaskView.image = nil;
    RCSightMessage *_imageMessage = (RCSightMessage *)model.content;
    if (_imageMessage) {
        if (_imageMessage.destructDuration && _imageMessage.destructDuration > 0) {
            NSInteger minutes = _imageMessage.duration / 60;
            NSInteger seconds = round(_imageMessage.duration - minutes * 60);
            if (seconds == 60) {
                minutes += 1;
                seconds = 0;
            }
            NSString *durationText = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
            self.destructDurationLabel.text = durationText;
            self.burnBackgroundView.hidden = NO;
            self.burnBackgroundView.frame = CGRectZero;
            self.thumbnailView.frame = CGRectZero;
            self.shadowMaskView.frame = CGRectZero;
            CGRect messageContentViewRect = self.messageContentView.frame;
            if (MessageDirection_RECEIVE == self.messageDirection) {
                self.messageActivityIndicatorView = nil;
                messageContentViewRect.size.width = BurnBackGroundWidth;
                messageContentViewRect.size.height = BurnBackGroundHeight;
                self.messageContentView.frame = messageContentViewRect;
                self.burnBackgroundView.frame = CGRectMake(0, 0, BurnBackGroundWidth, BurnBackGroundHeight);
                self.burnBackgroundView.image =
                    [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
                UIImage *image = self.burnBackgroundView.image;
                self.burnBackgroundView.image = [self.burnBackgroundView.image
                    resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                 image.size.height * 0.2, image.size.width * 0.2)];
                self.burnPicture.frame = CGRectMake(54, 38, 22, 22);
                self.burnLabel.frame = CGRectMake(0, 67, self.burnBackgroundView.frame.size.width, 17);
                self.burnLabel.textColor = HEXCOLOR(0xF4B50B);
                self.burnPicture.image =
                    [RCKitUtility imageNamed:@"burn_video_picture_form" ofBundle:@"RongCloud.bundle"];
                [self.destructDurationLabel setTextColor:HEXCOLOR(0xF4B50B)];
            } else {
                messageContentViewRect.size.width = BurnBackGroundWidth;
                messageContentViewRect.size.height = BurnBackGroundHeight;
                messageContentViewRect.origin.x =
                    self.baseContentView.bounds.size.width -
                    (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width +
                     HeadAndContentSpacing);
                self.messageContentView.frame = messageContentViewRect;
                self.burnBackgroundView.frame = CGRectMake(0, 0, BurnBackGroundWidth, BurnBackGroundHeight);
                self.burnBackgroundView.image =
                    [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
                UIImage *image = self.burnBackgroundView.image;
                CGRect statusFrame = self.statusContentView.frame;
                statusFrame.origin.x = statusFrame.origin.x + 5;
                [self.statusContentView setFrame:statusFrame];
                self.burnBackgroundView.image = [self.burnBackgroundView.image
                    resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                 image.size.height * 0.2, image.size.width * 0.8)];
                self.burnPicture.frame = CGRectMake(49, 38, 22, 22);
                self.burnLabel.frame = CGRectMake(0, 67, self.burnBackgroundView.frame.size.width, 17);
                self.burnLabel.textColor = HEXCOLOR(0xFFFFFF);
                self.burnPicture.image =
                    [RCKitUtility imageNamed:@"burn_video_picture_to" ofBundle:@"RongCloud.bundle"];
                [self.destructDurationLabel setTextColor:[UIColor whiteColor]];
            }
            CGSize sizeString = [self.destructDurationLabel.text
                sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
            NSInteger xoffset = self.model.messageDirection == MessageDirection_SEND ? -10 : -2;
            NSInteger yOffset = -4;
            CGRect durationLabelFrame =
                CGRectMake(self.burnBackgroundView.bounds.size.width - sizeString.width + xoffset,
                           self.burnBackgroundView.bounds.size.height - sizeString.height + yOffset, sizeString.width,
                           sizeString.height);
            self.destructDurationLabel.frame = durationLabelFrame;
        } else {
            //        self.pictureView.image = _imageMessage.thumbnailImage;
            self.messageActivityIndicatorView = nil;
            self.burnBackgroundView.frame = CGRectZero;
            self.burnBackgroundView.hidden = YES;
            CGSize imageSize = _imageMessage.thumbnailImage.size;
            //兼容240
            CGFloat rate = imageSize.width / imageSize.height;
            CGFloat imageWidth = 0;
            CGFloat imageHeight = 0;

            if (imageSize.width != 0 && imageSize.height != 0) {
                if (rate > 1.0f) {
                    imageWidth = 160;
                    imageHeight = 160 / rate;
                } else {
                    imageHeight = 160;
                    imageWidth = 160 * rate;
                }
            } else {
                imageWidth = imageSize.width;
                imageHeight = imageSize.height;
            }
            //图片half

            NSInteger minutes = _imageMessage.duration / 60;
            NSInteger seconds = round(_imageMessage.duration - minutes * 60);
            if (seconds == 60) {
                minutes += 1;
                seconds = 0;
            }
            NSString *durationText = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];

            self.durationLabel.text = durationText;
            imageSize = CGSizeMake(imageWidth, imageHeight);
            CGRect messageContentViewRect = self.messageContentView.frame;
            self.thumbnailView.image = _imageMessage.thumbnailImage;
            UIImage *maskImage = nil;
            if (model.messageDirection == MessageDirection_RECEIVE) {
                messageContentViewRect.size.width = imageSize.width;
                messageContentViewRect.size.height = imageSize.height;
                self.messageContentView.frame = messageContentViewRect;
                maskImage = [RCKitUtility imageNamed:@"chat_from_bg_normal_sight" ofBundle:@"RongCloud.bundle"];

                self.thumbnailView.frame = CGRectMake(0.5, 0.5, imageSize.width - 1, imageSize.height - 1);
                maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8,
                                                                                    maskImage.size.width * 0.8,
                                                                                    maskImage.size.height * 0.2,
                                                                                    maskImage.size.width * 0.2)];



            } else {
                messageContentViewRect.size.width = imageSize.width;
                messageContentViewRect.size.height = imageSize.height;
                messageContentViewRect.origin.x =
                    self.baseContentView.bounds.size.width -
                    (imageSize.width + HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
                self.messageContentView.frame = messageContentViewRect;
                self.thumbnailView.frame = CGRectMake(0.5, 0.5, imageSize.width - 1, imageSize.height - 1);
                maskImage = [RCKitUtility imageNamed:@"chat_to_bg_normal_sight" ofBundle:@"RongCloud.bundle"];
                maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8,
                                                                                    maskImage.size.width * 0.2,
                                                                                    maskImage.size.height * 0.2,
                                                                                    maskImage.size.width * 0.8)];


            }
            [self setMaskImage:maskImage];
            if (self.progressView.superview) {
                [self.progressView removeFromSuperview];
            }
            self.progressView = [[RCSightMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [self.progressView setHidden:YES];
            self.progressView.progressTintColor = [UIColor whiteColor];
            [self.thumbnailView addSubview:self.progressView];
        }
    } else {
        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCImageMessage object");
    }

    [self updateStatusContentView:self.model];

    NSInteger xoffset = model.messageDirection == MessageDirection_SEND ? -4 : 4;
    [self.playImage setCenter:CGPointMake(self.thumbnailView.bounds.size.width / 2 + xoffset,
                                          self.thumbnailView.bounds.size.height / 2)];
    self.progressView.center = self.playImage.center;
    xoffset = model.messageDirection == MessageDirection_SEND ? -10 : -2;
    CGRect durationLabelBgFrame =
        CGRectMake(0, self.thumbnailView.bounds.size.height - 21, self.thumbnailView.bounds.size.width, 21);
    self.durationLabel.superview.frame = durationLabelBgFrame;
    self.durationLabel.frame =
        CGRectMake(0, 0, durationLabelBgFrame.size.width + xoffset, durationLabelBgFrame.size.height);
    if (model.sentStatus == SentStatus_SENDING || [[RCResendManager sharedManager] needResend:self.model.messageId]) {
        [self.playButtonView setHidden:YES];
        [self.progressView startIndeterminateAnimation];
        [self.progressView setHidden:NO];
        self.thumbnailView.userInteractionEnabled = NO;
    } else {
        [self.playButtonView setHidden:NO];
        [self.progressView stopIndeterminateAnimation];
        [self.progressView setHidden:YES];
        self.thumbnailView.userInteractionEnabled = YES;
    }

    [self setDestructViewLayout];
}

- (void)setDestructViewLayout {
    RCSightMessage *_imageMessage = (RCSightMessage *)self.model.content;
    if (_imageMessage.destructDuration > 0) {
        self.destructView.hidden = NO;
        [self.messageContentView bringSubviewToFront:self.destructView];
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.destructView.frame = CGRectMake(CGRectGetMaxX(self.burnBackgroundView.frame) - 4.5,
                                                 CGRectGetMinY(self.burnBackgroundView.frame) - 2.5, 21, 12);
        } else {
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.burnBackgroundView.frame) - 7.5,
                                                 CGRectGetMinY(self.burnBackgroundView.frame) - 2.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
    }
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 21)];
        [_durationLabel setTextAlignment:NSTextAlignmentRight];
        [_durationLabel setBackgroundColor:[UIColor clearColor]];
        [_durationLabel setTextColor:[UIColor whiteColor]];
        [_durationLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _durationLabel;
}

- (UIImageView *)playImage {
    if (!_playImage) {
        _playImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        UIImage *image = [RCKitUtility imageNamed:@"sight_message_icon" ofBundle:@"RongCloud.bundle"];
        _playImage.image = image;
    }
    return _playImage;
}

- (UIView *)playButtonView {
    if (!_playButtonView) {
        _playButtonView = [[UIView alloc] initWithFrame:self.thumbnailView.bounds];
        [_playButtonView addSubview:self.playImage];
        [_playButtonView setBackgroundColor:[UIColor clearColor]];
        [_playButtonView setAlpha:0.7f];
        [self.thumbnailView addSubview:_playButtonView];
        UIImageView *backgroudView =
            [[UIImageView alloc] initWithFrame:CGRectMake(0, self.thumbnailView.bounds.size.height - 21,
                                                          self.thumbnailView.bounds.size.width, 21)];
        backgroudView.image = [RCKitUtility imageNamed:@"player_shadow_bottom" ofBundle:@"RongCloud.bundle"];
        [_playButtonView addSubview:backgroudView];
        [backgroudView addSubview:self.durationLabel];
    }
    return _playButtonView;
}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {

    RCMessageCellNotificationModel *notifyModel = notification.object;

    NSInteger progress = notifyModel.progress;

    if (self.model.messageId == notifyModel.messageId) {
        DebugLog(@"messageCellUpdateSendingStatusEvent >%@ ", notifyModel.actionName);
        if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_BEGIN]) {
            self.model.sentStatus = SentStatus_SENDING;
            [self updateStatusContentView:self.model];

            [self.progressView startIndeterminateAnimation];
            [self.progressView setHidden:NO];
            self.thumbnailView.userInteractionEnabled = NO;

        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
            if ([[RCResendManager sharedManager] needResend:self.model.messageId]) {
                self.model.sentStatus = SentStatus_SENDING;
                [self updateStatusContentView:self.model];

                [self.progressView startIndeterminateAnimation];
                [self.progressView setHidden:NO];
                self.thumbnailView.userInteractionEnabled = NO;
            } else {
                self.model.sentStatus = SentStatus_FAILED;
                [self updateStatusContentView:self.model];
                [self.playButtonView setHidden:NO];
                [self.progressView stopIndeterminateAnimation];
                [self.progressView setHidden:YES];
                self.thumbnailView.userInteractionEnabled = YES;
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
                [self.playButtonView setHidden:NO];
                [self.progressView stopIndeterminateAnimation];
                [self.progressView setHidden:YES];
                self.thumbnailView.userInteractionEnabled = YES;
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {
            float pro = progress / 100.0f;
            [self.progressView setProgress:pro animated:YES];
        } else if (self.model.sentStatus == SentStatus_READ && self.isDisplayReadStatus) {
            [self.progressView stopIndeterminateAnimation];
            [self.progressView setHidden:YES];
            self.thumbnailView.userInteractionEnabled = YES;
            self.messageHasReadStatusView.hidden = NO;
            self.messageFailedStatusView.hidden = YES;
            self.messageSendSuccessStatusView.hidden = YES;
            self.model.sentStatus = SentStatus_READ;
            [self updateStatusContentView:self.model];
            self.statusContentView.frame =
                CGRectMake(self.thumbnailView.frame.origin.x - 20, self.thumbnailView.frame.size.height - 18, 18, 18);
        }
    }
}

- (void)tapSight:(UIGestureRecognizer *)gestureRecognizer {

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)burnTapSight:(UIGestureRecognizer *)gestureRecognizer {

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.thumbnailView];
    }
}

- (void)burnLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.burnBackgroundView];
    }
}

@end
