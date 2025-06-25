//
//  RCGIFMessageCell.m
//  RongIMKit
//
//  Created by liyan on 2018/12/20.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCGIFMessageCell.h"
#import "RCIM.h"
#import "RCKitUtility.h"
#import "RCIMClient+Destructing.h"
#import "RCGIFImage.h"
#import "RCKitCommonDefine.h"
#import "RCGIFMessageProgressView.h"
#import "RCGIFUtility.h"
#import "RCResendManager.h"

#define GIFLOADIMAGEWIDTH 36.0f
#define GIFLABLEWIGHT 40.0f
#define GIFLABLEHEIGHT 10.0f
#define BurnBackGroundWidth 126
#define BurnBackGroundHeight 120

@interface RCGIFMessageCell ()

@property (nonatomic, strong) RCMessageModel *currentModel;

@property (nonatomic, strong) RCGIFMessageProgressView *gifDownLoadPropressView;

@property (nonatomic, strong) UIButton *loadBackButton;

@property (nonatomic, strong) UIImageView *needLoadImageView;

@property (nonatomic, strong) UIImageView *loadingImageView;

@property (nonatomic, strong) UIImageView *loadfailedImageView;

@property (nonatomic, strong) UILabel *sizeLabel;

@property (nonatomic, strong) UIImageView *burnPicture;

@property (nonatomic, strong) UILabel *burnLabel;

@property (nonatomic, strong) UIImageView *burnBackgroundView;

- (void)initialize;

@end

@implementation RCGIFMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 0.0f;
    CGSize size = [RCGIFUtility calculatecollectionViewHeight:model];
    if (model.content.destructDuration > 0) {
        __messagecontentview_height = BurnBackGroundHeight;
    } else {
        __messagecontentview_height = size.height;
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
    [self.messageContentView addSubview:self.gifImageView];
    [self.messageContentView addSubview:self.loadBackButton];
    self.burnBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.burnBackgroundView];

    self.burnPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 26)];
    [self.burnBackgroundView addSubview:self.burnPicture];

    self.burnLabel = [[UILabel alloc] init];
    self.burnLabel.text = NSLocalizedStringFromTable(@"ClickToView", @"RongCloudKit", nil);
    self.burnLabel.font = [UIFont systemFontOfSize:12];
    self.burnLabel.textAlignment = NSTextAlignmentCenter;
    [self.burnBackgroundView addSubview:self.burnLabel];

    [self addGestureRecognizer];
    self.messageActivityIndicatorView = nil;
}

- (void)addGestureRecognizer {
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.gifImageView addGestureRecognizer:longPress];

    UITapGestureRecognizer *gifViewTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifViewTap:)];
    gifViewTap.numberOfTapsRequired = 1;
    gifViewTap.numberOfTouchesRequired = 1;
    [self.gifImageView addGestureRecognizer:gifViewTap];
    self.gifImageView.userInteractionEnabled = YES;

    UILongPressGestureRecognizer *burnLongPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(burnLongPressed:)];
    [self.burnBackgroundView addGestureRecognizer:burnLongPress];

    UITapGestureRecognizer *burnGifViewTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(burnGifViewTap:)];
    burnGifViewTap.numberOfTapsRequired = 1;
    burnGifViewTap.numberOfTouchesRequired = 1;
    [self.burnBackgroundView addGestureRecognizer:burnGifViewTap];
    self.burnBackgroundView.userInteractionEnabled = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)gifViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)burnGifViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

#pragma mark - setModel

- (void)setDataModel:(RCMessageModel *)model {
    [self resetSubViews];
    if (!model) {
        return;
    }
    [super setDataModel:model];
    self.currentModel = model;
    __block RCGIFMessage *gifMessage = (RCGIFMessage *)model.content;
    [self calculateContenViewSize:gifMessage];
    if (gifMessage.destructDuration > 0) {
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
        } else {
            messageContentViewRect.size.width = BurnBackGroundWidth;
            messageContentViewRect.size.height = BurnBackGroundHeight;
            messageContentViewRect.origin.x =
                self.baseContentView.bounds.size.width -
                (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width +
                 HeadAndContentSpacing);
            self.messageContentView.frame = messageContentViewRect;
            self.burnBackgroundView.frame = CGRectMake(0, 0, BurnBackGroundWidth, BurnBackGroundHeight);
            self.burnBackgroundView.image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
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
        self.burnBackgroundView.hidden = YES;
    }
    //需要根据用户设置的大小去决定是否自动下载
    NSInteger maxAutoSize = [RCIM sharedRCIM].GIFMsgAutoDownloadSize;
    NSString *localPath = [RCUtilities getCorrectedFilePath:gifMessage.localPath];
    if (localPath && [RCFileUtility isFileExist:localPath]) {
        [self showGifImageView:localPath];
    } else {
        if (gifMessage.remoteUrl.length > 0 && gifMessage.gifDataSize > maxAutoSize * 1024) {
            //超过限制，需要点击下载
            [self showView:self.needLoadImageView];
        } else {
            //没超过限制，自动下载
            [self downLoadGif];
        }
    }

    [self updateStatusContentView:self.model];
    if (model.sentStatus == SentStatus_SENDING || [[RCResendManager sharedManager] needResend:self.model.messageId]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.gifImageView addSubview:_progressView];
            [self.progressView setFrame:self.gifImageView.bounds];
            [self.progressView startAnimating];
            self.gifImageView.userInteractionEnabled = NO;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView removeFromSuperview];
            self.gifImageView.userInteractionEnabled = YES;
        });
    }
    [self setDestructViewLayout];
}

- (void)calculateContenViewSize:(RCGIFMessage *)gifMessage {
    CGSize gifSize = [RCGIFUtility calculatecollectionViewHeight:self.currentModel];

    CGRect messageContentViewRect = self.messageContentView.frame;
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
    } else {
        if (gifMessage.destructDuration <= 0) {
            messageContentViewRect.origin.x =
                self.baseContentView.bounds.size.width -
                (gifSize.width + HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        }
    }
    messageContentViewRect.size = CGSizeMake(gifSize.width, gifSize.height);
    self.messageContentView.frame = messageContentViewRect;
    self.gifImageView.frame = CGRectMake(0, 0, gifSize.width, gifSize.height);
    self.loadBackButton.frame = self.gifImageView.frame;
}

- (void)didClickLoadBackButton:(UIButton *)button {
    if (!self.needLoadImageView.hidden) {
        [self downLoadGif];
        return;
    } else if (!self.loadfailedImageView.hidden) {
        [self downLoadGif];
        return;
    }
}

- (void)downLoadGif {
    [self showView:self.loadingImageView];
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] downloadMediaMessage:weakSelf.currentModel.messageId
        progress:^(int progress) {
            if (weakSelf.gifDownLoadPropressView.hidden) {
                [weakSelf showView:weakSelf.gifDownLoadPropressView];
            }
            [weakSelf.gifDownLoadPropressView setProgress:progress];
        }
        success:^(NSString *mediaPath) {
            [weakSelf showView:weakSelf.gifImageView];
            [weakSelf showGifImageView:mediaPath];
        }
        error:^(RCErrorCode errorCode) {
            [weakSelf showView:weakSelf.loadfailedImageView];
        }
        cancel:^{
            [weakSelf showView:weakSelf.needLoadImageView];
        }];
}

- (void)showGifImageView:(NSString *)localPath {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:[RCUtilities getCorrectedFilePath:localPath]];
        RCGIFImage *gifImage = [RCGIFImage animatedImageWithGIFData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (gifImage) {
                if (self.model.content.destructDuration > 0) {
                    weakSelf.gifImageView.hidden = YES;
                    weakSelf.burnBackgroundView.hidden = NO;
                } else {
                    weakSelf.burnBackgroundView.hidden = YES;
                    weakSelf.gifImageView.hidden = NO;
                    weakSelf.gifImageView.animatedImage = gifImage;
                }
            } else {
                DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCGIFMessage object");
            }
        });
    });
}

#pragma mark -
- (void)setDestructViewLayout {
    RCGIFMessage *_imageMessage = (RCGIFMessage *)self.model.content;
    if (_imageMessage.destructDuration > 0) {
        self.destructView.hidden = NO;
        UIView *view = self.burnBackgroundView;
        [self.messageContentView bringSubviewToFront:self.destructView];
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.destructView.frame =
                CGRectMake(CGRectGetMaxX(view.frame) - 4.5, CGRectGetMinY(view.frame) - 2.5, 21, 12);
        } else {
            self.destructView.frame =
                CGRectMake(CGRectGetMinX(view.frame) - 7.5, CGRectGetMinY(view.frame) - 2.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
    }
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
                [self.gifImageView addSubview:_progressView];
                [self.progressView setFrame:self.gifImageView.bounds];
                [self.progressView startAnimating];
                self.gifImageView.userInteractionEnabled = NO;
            });

        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
            if ([[RCResendManager sharedManager] needResend:self.model.messageId]) {
                self.model.sentStatus = SentStatus_SENDING;
                [self updateStatusContentView:self.model];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.gifImageView addSubview:_progressView];
                    [self.progressView setFrame:self.gifImageView.bounds];
                    [self.progressView startAnimating];
                    self.gifImageView.userInteractionEnabled = NO;
                });

            } else {
                self.model.sentStatus = SentStatus_FAILED;
                [self updateStatusContentView:self.model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView stopAnimating];
                    [self.progressView removeFromSuperview];
                    self.gifImageView.userInteractionEnabled = YES;
                });
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressView stopAnimating];
                    [self.progressView removeFromSuperview];
                    self.gifImageView.userInteractionEnabled = YES;
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
                self.gifImageView.userInteractionEnabled = YES;
                self.messageHasReadStatusView.hidden = NO;
                self.messageFailedStatusView.hidden = YES;
                self.messageSendSuccessStatusView.hidden = YES;
                self.model.sentStatus = SentStatus_READ;
                [self updateStatusContentView:self.model];
                self.statusContentView.frame =
                    CGRectMake(self.gifImageView.frame.origin.x - 20, self.gifImageView.frame.size.height - 18, 18, 18);

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
        [self.delegate didLongTouchMessageCell:self.model inView:self.gifImageView];
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

#pragma mark - showViews
- (void)showView:(UIView *)showView {
    showView.center = self.loadBackButton.center;
    if (self.loadBackButton.hidden) {
        self.loadBackButton.hidden = NO;
    }
    self.sizeLabel.center =
        CGPointMake(self.loadBackButton.center.x, self.loadBackButton.center.y + 10 + GIFLOADIMAGEWIDTH / 2);
    RCGIFMessage *gifMessage = (RCGIFMessage *)self.model.content;

    NSString *size = [self getGIFSize:gifMessage.gifDataSize];
    if (size.length > 0) {
        self.sizeLabel.hidden = NO;
        self.sizeLabel.text = size;
    }
    switch (showView.tag) {
    case 1:
        self.needLoadImageView.hidden = NO;
        self.loadingImageView.hidden = YES;
        self.gifDownLoadPropressView.hidden = YES;
        self.loadfailedImageView.hidden = YES;
        [self stopAnimation];

        break;
    case 2:
        self.needLoadImageView.hidden = YES;
        self.loadingImageView.hidden = NO;
        self.gifDownLoadPropressView.hidden = YES;
        self.loadfailedImageView.hidden = YES;
        [self startAnimation];
        break;
    case 3:
        self.needLoadImageView.hidden = YES;
        self.loadingImageView.hidden = YES;
        self.gifDownLoadPropressView.hidden = NO;
        self.loadfailedImageView.hidden = YES;
        [self stopAnimation];

        break;
    case 4:
        self.needLoadImageView.hidden = YES;
        self.loadingImageView.hidden = YES;
        self.gifDownLoadPropressView.hidden = YES;
        self.loadfailedImageView.hidden = NO;
        [self stopAnimation];

        break;
    default:
        self.needLoadImageView.hidden = YES;
        self.loadingImageView.hidden = YES;
        self.gifDownLoadPropressView.hidden = YES;
        self.loadfailedImageView.hidden = YES;
        self.loadBackButton.hidden = YES;
        self.sizeLabel.hidden = YES;
        self.gifImageView.animatedImage = nil;
        break;
    }
}

- (NSString *)getGIFSize:(CGFloat)size {
    NSString *GIFSize = nil;
    if (size / 1024 / 1024 < 1) {
        GIFSize = [NSString stringWithFormat:@"%dK", (int)size / 1024];
    } else {
        GIFSize = [NSString stringWithFormat:@"%0.2fM", size / 1024 / 1024];
    }

    return GIFSize;
}

- (void)startAnimation {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation {
    if (self.loadfailedImageView) {
        [self.loadingImageView.layer removeAnimationForKey:@"rotationAnimation"];
    }
}

#pragma mark - subviews

- (void)resetSubViews {
    self.gifImageView.animatedImage = nil;
    [self.gifDownLoadPropressView setProgress:0];
    self.loadBackButton.hidden = YES;
    self.needLoadImageView.hidden = YES;
    self.loadingImageView.hidden = YES;
    self.gifDownLoadPropressView.hidden = YES;
    self.loadfailedImageView.hidden = YES;
    self.sizeLabel.text = nil;
    self.sizeLabel.hidden = YES;
}

- (RCGIFImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[RCGIFImageView alloc] initWithFrame:CGRectZero];
        _gifImageView.layer.masksToBounds = YES;
        [_gifImageView setContentMode:UIViewContentModeScaleAspectFill];
        _gifImageView.tag = 5;
    }
    return _gifImageView;
}

- (RCImageMessageProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[RCImageMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        ;
    }
    return _progressView;
}

- (UIButton *)loadBackButton {
    if (!_loadBackButton) {
        _loadBackButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _loadBackButton.backgroundColor = RGBCOLOR(216, 216, 216);
        [_loadBackButton addTarget:self
                            action:@selector(didClickLoadBackButton:)
                  forControlEvents:(UIControlEventTouchUpInside)];
        _loadBackButton.hidden = YES;
    }
    return _loadBackButton;
}

- (UIImageView *)needLoadImageView {
    if (!_needLoadImageView) {
        _needLoadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GIFLOADIMAGEWIDTH, GIFLOADIMAGEWIDTH)];
        _needLoadImageView.image = [RCKitUtility imageNamed:@"gif_needload" ofBundle:@"RongCloud.bundle"];
        _needLoadImageView.hidden = YES;
        _needLoadImageView.tag = 1;
        _needLoadImageView.userInteractionEnabled = NO;
        [self.loadBackButton addSubview:_needLoadImageView];
    }
    return _needLoadImageView;
}

- (UIImageView *)loadingImageView {
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GIFLOADIMAGEWIDTH, GIFLOADIMAGEWIDTH)];
        _loadingImageView.image = [RCKitUtility imageNamed:@"gif_loading" ofBundle:@"RongCloud.bundle"];
        _loadingImageView.hidden = YES;
        _loadingImageView.tag = 2;
        _loadingImageView.userInteractionEnabled = NO;
        [self.loadBackButton addSubview:_loadingImageView];
    }
    return _loadingImageView;
}

- (RCGIFMessageProgressView *)gifDownLoadPropressView {
    if (!_gifDownLoadPropressView) {
        _gifDownLoadPropressView = [[RCGIFMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _gifDownLoadPropressView.backgroundColor =
            [UIColor colorWithPatternImage:[RCKitUtility imageNamed:@"gif_loadprogress" ofBundle:@"RongCloud.bundle"]];
        _gifDownLoadPropressView.tag = 3;
        _gifDownLoadPropressView.hidden = YES;
        _gifDownLoadPropressView.userInteractionEnabled = NO;
        [self.loadBackButton addSubview:_gifDownLoadPropressView];
    }
    return _gifDownLoadPropressView;
}

- (UIImageView *)loadfailedImageView {
    if (!_loadfailedImageView) {
        _loadfailedImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, GIFLOADIMAGEWIDTH, GIFLOADIMAGEWIDTH)];
        _loadfailedImageView.image = [RCKitUtility imageNamed:@"gif_loadfailed" ofBundle:@"RongCloud.bundle"];
        _loadfailedImageView.hidden = YES;
        _loadfailedImageView.tag = 4;
        _loadfailedImageView.userInteractionEnabled = NO;
        [self.loadBackButton addSubview:_loadfailedImageView];
    }
    return _loadfailedImageView;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GIFLABLEWIGHT, GIFLABLEHEIGHT)];
        _sizeLabel.font = [UIFont systemFontOfSize:10];
        _sizeLabel.numberOfLines = 1;
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.hidden = YES;
        [self.loadBackButton addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

@end
