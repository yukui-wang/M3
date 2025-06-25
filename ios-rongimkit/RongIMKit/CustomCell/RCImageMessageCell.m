//
//  RCImageMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCImageMessageCell.h"
#import "RCIM.h"
#import "RCKitUtility.h"
#import "RCIMClient+Destructing.h"
#import "RCKitCommonDefine.h"
#import "RCResendManager.h"

#define BurnBackGroundWidth 126
#define BurnBackGroundHeight 120

@interface RCImageMessageCell ()
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *shadowMaskView;
@property (nonatomic, strong) UIImageView *burnPicture;
@property (nonatomic, strong) UILabel *burnLabel;
@property (nonatomic, strong) UIImageView *burnBackgroundView;
- (void)initialize;

@end

@implementation RCImageMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 0.0f;
    RCImageMessage *_imageMessage = (RCImageMessage *)model.content;

    CGSize imageSize = [RCImageMessageCell caculateThumbnailImageSize:_imageMessage.thumbnailImage.size];

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
    self.pictureView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.pictureView.layer.masksToBounds = YES;
    [self.messageContentView addSubview:self.pictureView];

    self.burnBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.burnBackgroundView];

    self.burnPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 26)];
    [self.burnBackgroundView addSubview:self.burnPicture];

    self.burnLabel = [[UILabel alloc] init];
    self.burnLabel.text = NSLocalizedStringFromTable(@"ClickToView", @"RongCloudKit", nil);
    self.burnLabel.font = [UIFont systemFontOfSize:12];
    self.burnLabel.textAlignment = NSTextAlignmentCenter;
    [self.burnBackgroundView addSubview:self.burnLabel];

    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.pictureView addGestureRecognizer:longPress];

    UITapGestureRecognizer *pictureTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPicture:)];
    pictureTap.numberOfTapsRequired = 1;
    pictureTap.numberOfTouchesRequired = 1;
    [self.pictureView addGestureRecognizer:pictureTap];
    self.pictureView.userInteractionEnabled = YES;

    UILongPressGestureRecognizer *burnLongPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(burnLongPressed:)];
    [self.burnBackgroundView addGestureRecognizer:burnLongPress];

    UITapGestureRecognizer *burnPictureTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(burnTapPicture:)];
    burnPictureTap.numberOfTapsRequired = 1;
    burnPictureTap.numberOfTouchesRequired = 1;
    [self.burnBackgroundView addGestureRecognizer:burnPictureTap];
    self.burnBackgroundView.userInteractionEnabled = YES;

    self.progressView = [[RCImageMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //    UITapGestureRecognizer *progressViewTap =[[UITapGestureRecognizer alloc] initWithTarget:self
    //    action:@selector(tapPicture:)]; progressViewTap.numberOfTapsRequired = 1;
    //    progressViewTap.numberOfTouchesRequired = 1;
    //    [self.progressView addGestureRecognizer:progressViewTap];
    //    self.progressView.userInteractionEnabled = YES;

}

- (void)setMaskImage:(UIImage *)maskImage {
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];

        _maskView.frame = self.pictureView.bounds;
        self.pictureView.layer.mask = _maskView.layer;
        self.pictureView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.pictureView.bounds;
    }
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];

    _shadowMaskView.frame =
        CGRectMake(-0.2, -0.2, self.pictureView.frame.size.width + 1.2, self.pictureView.frame.size.height + 1.2);
    [self.messageContentView addSubview:_shadowMaskView];
    [self.messageContentView bringSubviewToFront:self.pictureView];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)tapPicture:(UIGestureRecognizer *)gestureRecognizer {

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)burnTapPicture:(UIGestureRecognizer *)gestureRecognizer {

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    if (self.model && self.model.messageId != model.messageId) {
        [self.progressView updateProgress:0];
    }
    [super setDataModel:model];
    self.pictureView.image = nil;
    //    self.shadowView = nil;
    self.shadowMaskView.image = nil;
    RCImageMessage *_imageMessage = (RCImageMessage *)model.content;
    if (_imageMessage) {
        if (_imageMessage.destructDuration > 0) {
            self.burnBackgroundView.hidden = NO;
            self.pictureView.frame = CGRectZero;
            CGRect messageContentViewRect = self.messageContentView.frame;
            if (MessageDirection_RECEIVE == self.messageDirection) {
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
                self.burnPicture.frame = CGRectMake(50, 36, 31, 25);
                self.burnLabel.frame = CGRectMake(0, 67, self.burnBackgroundView.frame.size.width, 17);
                self.burnLabel.textColor = HEXCOLOR(0xF4B50B);
                self.burnPicture.image = [RCKitUtility imageNamed:@"burnPictureForm" ofBundle:@"RongCloud.bundle"];
                self.messageActivityIndicatorView = nil;
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
                self.burnPicture.frame = CGRectMake(45, 36, 31, 25);
                self.burnLabel.frame = CGRectMake(0, 67, self.burnBackgroundView.frame.size.width, 17);
                self.burnLabel.textColor = HEXCOLOR(0xFFFFFF);
                self.burnPicture.image = [RCKitUtility imageNamed:@"burnPicture" ofBundle:@"RongCloud.bundle"];
            }
        } else {
            self.messageActivityIndicatorView = nil;
            //        self.pictureView.image = _imageMessage.thumbnailImage;
            self.burnBackgroundView.frame = CGRectZero;
            self.burnBackgroundView.hidden = YES;
            CGSize imageSize = [RCImageMessageCell caculateThumbnailImageSize:_imageMessage.thumbnailImage.size];
            CGRect messageContentViewRect = self.messageContentView.frame;
            self.pictureView.image = _imageMessage.thumbnailImage;
            UIImage *maskImage = nil;
            if (model.messageDirection == MessageDirection_RECEIVE) {
                messageContentViewRect.size.width = imageSize.width;
                messageContentViewRect.size.height = imageSize.height;
                self.messageContentView.frame = messageContentViewRect;
                maskImage = [RCKitUtility imageNamed:@"chat_from_bg_normal_img" ofBundle:@"RongCloud.bundle"];
                self.pictureView.frame = CGRectMake(0.5, 0.5, imageSize.width - 1, imageSize.height - 1);
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
                self.pictureView.frame = CGRectMake(0.5, 0.5, imageSize.width - 1, imageSize.height - 1);
                maskImage = [RCKitUtility imageNamed:@"chat_to_bg_normal_img" ofBundle:@"RongCloud.bundle"];
                maskImage = [maskImage resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8,
                                                                                    maskImage.size.width * 0.2,
                                                                                    maskImage.size.height * 0.2,
                                                                                    maskImage.size.width * 0.8)];
            }
            [self setMaskImage:maskImage];
        }
    } else {
        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCImageMessage object");
    }

    [self setAutoLayout];

    [self updateStatusContentView:self.model];
    if (model.sentStatus == SentStatus_SENDING || [[RCResendManager sharedManager] needResend:self.model.messageId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pictureView addSubview:_progressView];
            [self.progressView setFrame:self.pictureView.bounds];
            [self.progressView startAnimating];
            self.pictureView.userInteractionEnabled = NO;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView removeFromSuperview];
            self.pictureView.userInteractionEnabled = YES;
        });
    }

    [self setDestructViewLayout];
}

+ (CGSize)caculateThumbnailImageSize:(CGSize)imageSize {
    //图片消息最小值为 100 X 100，最大值为 240 X 240
    // 重新梳理规则，如下：
    // 1、宽高任意一边小于 100 时，如：20 X 40 ，则取最小边，按比例放大到 100 进行显示，如最大边超过240 时，居中截取 240
    // 进行显示
    // 2、宽高都小于 240 时，大于 100 时，如：120 X 140 ，则取最长边，按比例放大到 240 进行显示
    // 3、宽高任意一边大于240时，分两种情况：
    //(1）如果宽高比没有超过 2.4，等比压缩，取长边 240 进行显示。
    //(2）如果宽高比超过 2.4，等比缩放（压缩或者放大），取短边 100，长边居中截取 240 进行显示。
    CGFloat imageMaxLength = 120;
    CGFloat imageMinLength = 50;
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGSizeMake(imageMaxLength, imageMinLength);
    }
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageSize.width < imageMinLength || imageSize.height < imageMinLength) {
        if (imageSize.width < imageSize.height) {
            imageWidth = imageMinLength;
            imageHeight = imageMinLength * imageSize.height / imageSize.width;
            if (imageHeight > imageMaxLength) {
                imageHeight = imageMaxLength;
            }
        } else {
            imageHeight = imageMinLength;
            imageWidth = imageMinLength * imageSize.width / imageSize.height;
            if (imageWidth > imageMaxLength) {
                imageWidth = imageMaxLength;
            }
        }
    } else if (imageSize.width < imageMaxLength && imageSize.height < imageMaxLength &&
               imageSize.width >= imageMinLength && imageSize.height >= imageMinLength) {
        if (imageSize.width > imageSize.height) {
            imageWidth = imageMaxLength;
            imageHeight = imageMaxLength * imageSize.height / imageSize.width;
        } else {
            imageHeight = imageMaxLength;
            imageWidth = imageMaxLength * imageSize.width / imageSize.height;
        }
    } else if (imageSize.width >= imageMaxLength || imageSize.height >= imageMaxLength) {
        if (imageSize.width > imageSize.height) {
            if (imageSize.width / imageSize.height < imageMaxLength / imageMinLength) {
                imageWidth = imageMaxLength;
                imageHeight = imageMaxLength * imageSize.height / imageSize.width;
            } else {
                imageHeight = imageMinLength;
                imageWidth = imageMinLength * imageSize.width / imageSize.height;
                if (imageWidth > imageMaxLength) {
                    imageWidth = imageMaxLength;
                }
            }
        } else {
            if (imageSize.height / imageSize.width < imageMaxLength / imageMinLength) {
                imageHeight = imageMaxLength;
                imageWidth = imageMaxLength * imageSize.width / imageSize.height;
            } else {
                imageWidth = imageMinLength;
                imageHeight = imageMinLength * imageSize.height / imageSize.width;
                if (imageHeight > imageMaxLength) {
                    imageHeight = imageMaxLength;
                }
            }
        }
    }
    return CGSizeMake(imageWidth, imageHeight);
}

- (void)setDestructViewLayout {
    RCImageMessage *_imageMessage = (RCImageMessage *)self.model.content;
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

- (void)setAutoLayout {
    // DebugLog(@"image cell set model finish >%@",[NSDate date]);
}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {

    RCMessageCellNotificationModel *notifyModel = notification.object;

    NSInteger progress = notifyModel.progress;

    if (self.model.messageId == notifyModel.messageId) {
        DebugLog(@"messageCellUpdateSendingStatusEvent >%@ ", notifyModel.actionName);
        if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_BEGIN]) {
            self.model.sentStatus = SentStatus_SENDING;
            [self updateStatusContentView:self.model];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pictureView addSubview:_progressView];
                [self.progressView setFrame:self.pictureView.bounds];
                [self.progressView startAnimating];
                self.pictureView.userInteractionEnabled = NO;
            });

        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
            if ([[RCResendManager sharedManager] needResend:self.model.messageId]) {
                self.model.sentStatus = SentStatus_SENDING;
                [self updateStatusContentView:self.model];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pictureView addSubview:_progressView];
                    [self.progressView setFrame:self.pictureView.bounds];
                    [self.progressView startAnimating];
                    self.pictureView.userInteractionEnabled = NO;
                });
            } else {
                self.model.sentStatus = SentStatus_FAILED;
                [self updateStatusContentView:self.model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView stopAnimating];
                    [self.progressView removeFromSuperview];
                    self.pictureView.userInteractionEnabled = YES;
                });
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView stopAnimating];
                    [self.progressView removeFromSuperview];
                    self.pictureView.userInteractionEnabled = YES;
                });
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView updateProgress:progress];
            });
        } else if (self.model.sentStatus == SentStatus_READ && self.isDisplayReadStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView stopAnimating];
                [self.progressView removeFromSuperview];
                self.pictureView.userInteractionEnabled = YES;
                self.messageHasReadStatusView.hidden = NO;
                self.messageFailedStatusView.hidden = YES;
                self.messageSendSuccessStatusView.hidden = YES;
                self.model.sentStatus = SentStatus_READ;
                [self updateStatusContentView:self.model];
                self.statusContentView.frame =
                    CGRectMake(self.pictureView.frame.origin.x - 20, self.pictureView.frame.size.height - 18, 18, 18);

            });
        }
    }
}

// override
- (void)msgStatusViewTapEventHandler:(id)sender {
    //[super msgStatusViewTapEventHandler:sender];

    // to do something.
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.pictureView];
    }
}

- (void)burnLongPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        DebugLog(@"long press end");
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.burnBackgroundView];
    }
}

@end
