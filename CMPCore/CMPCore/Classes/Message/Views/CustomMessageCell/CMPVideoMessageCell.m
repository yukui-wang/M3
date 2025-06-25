//
//  CMPVideoMessageCell.m
//  M3
//
//  Created by MacBook on 2019/12/23.
//

#import "CMPVideoMessageCell.h"
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/UIColor+Hex.h>
#import "CMPVideoMessage.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPDownloadIndicator.h>
#import <CMPLib/UIView+CMPView.h>
//#import "RCKitCommonDefine.h"
//#import "RCKitUtility.h"

extern NSString *const RCKitDispatchDownloadMediaNotification;

@interface CMPVideoMessageCell ()

@end

@implementation CMPVideoMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    
    CMPVideoMessage *videoMessage = (CMPVideoMessage *)model.content;
    CGSize size = [self getThumImageSizeWithVideoMessage:videoMessage];
    CGFloat __messagecontentview_height = size.height;
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
    [self.messageActivityIndicatorView removeFromSuperview];

    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    self.bubbleBackgroundView.layer.cornerRadius = 4;
    self.bubbleBackgroundView.layer.masksToBounds = YES;
    self.bubbleBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    self.playIconView.image = [UIImage imageNamed:@"rc_paly"];
    [self.bubbleBackgroundView addSubview:self.playIconView];
    self.playIconView.hidden = YES;
    
    self.progressView = [[CMPDownloadIndicator alloc]initWithFrame:CGRectMake(0, 0,40,40) type:kCMPFilledIndicator];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    [self.progressView setFillColor:[UIColor whiteColor]];
    [self.progressView setStrokeColor:[UIColor whiteColor]];
    [self.progressView setClosedIndicatorBackgroundStrokeColor:CMP_HEXCOLOR(0xACAEAF)];
    //self.progressView.radiusPercent = 0.45;
    [self.bubbleBackgroundView addSubview:self.progressView];
    [self.progressView loadIndicator];
    self.progressView.hidden = YES;
    
    UIView *gradientBgView = [[UIView alloc] init];
    [self.bubbleBackgroundView addSubview:gradientBgView];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    [gradientBgView.layer addSublayer:gradientLayer];
    gradientBgView.layoutSubviewsCallback = ^(UIView *superview) {
        gradientLayer.frame = CGRectMake(0, superview.cmp_height - 30, superview.cmp_width, 30);
    };
    
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.sizeLabel setFont:[UIFont systemFontOfSize:12.f weight:UIFontWeightRegular]];
    [self.bubbleBackgroundView addSubview:self.sizeLabel];
    self.sizeLabel.textColor = CMP_HEXCOLOR(0xFFFFFF);

    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.timeLabel setFont:[UIFont systemFontOfSize:12.f weight:UIFontWeightRegular]];
    [self.bubbleBackgroundView addSubview:self.timeLabel];
    self.timeLabel.textColor = CMP_HEXCOLOR(0xFFFFFF);
    self.timeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.timeLabel.hidden = NO;

    self.cancelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.cancelLabel.text = NSLocalizedStringFromTable(@"CancelSendFile", @"RongCloudKit", nil);
    self.cancelLabel.textColor = CMP_HEXCOLOR(0xFFFFFF);
    self.cancelLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
    [self.bubbleBackgroundView addSubview:self.cancelLabel];
    self.cancelLabel.hidden = YES;

    self.cancelSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.cancelSendButton setImage:[RCKitUtility imageNamed:@"cancelButton" ofBundle:@"RongCloud.bundle"]
                           forState:UIControlStateNormal];
    [self.cancelSendButton addTarget:self action:@selector(cancelSend) forControlEvents:UIControlEventTouchUpInside];
    [self.baseContentView addSubview:self.cancelSendButton];
    self.cancelSendButton.hidden = YES;

    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];

    UITapGestureRecognizer *messageTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessage:)];
    messageTap.numberOfTapsRequired = 1;
    messageTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:messageTap];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    
    [self.bubbleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
    }];
    [self.playIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bubbleBackgroundView);
        make.size.equalTo(CGSizeMake(42, 42));
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playIconView);
        make.size.equalTo(CGSizeMake(40, 40));
    }];
    [gradientBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.bubbleBackgroundView);
        make.height.equalTo(30);
    }];
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bubbleBackgroundView).offset(4);
        make.bottom.equalTo(self.bubbleBackgroundView).offset(-4);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self.bubbleBackgroundView).offset(-4);
    }];
    [self.cancelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(self.timeLabel);
    }];
    [self.cancelSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bubbleBackgroundView.mas_leading).offset(-10);
        make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(8);
        make.size.equalTo(CGSizeMake(18, 18));
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadMediaStatus:)
                                                 name:RCKitDispatchDownloadMediaNotification
                                               object:nil];
}

- (void)tapMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    CMPVideoMessage *videoMessage = (CMPVideoMessage *)self.model.content;
    self.timeLabel.text = videoMessage.showTime;
    self.sizeLabel.text = [CMPVideoMessageCell getReadableStringForFileSize:videoMessage.size] ;
    self.bubbleBackgroundView.image = videoMessage.videoThumImage;
    [self setAutoLayout];
}

- (void)setAutoLayout {
    CGRect messageContentViewRect = self.messageContentView.frame;
    CGSize thumImageSize = [CMPVideoMessageCell getThumImageSizeWithVideoMessage:(CMPVideoMessage *)self.model.content];
    messageContentViewRect.size.width = thumImageSize.width;
    messageContentViewRect.size.height = thumImageSize.height;

    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.progressView.hidden = YES;
        self.playIconView.hidden = NO;
        self.cancelSendButton.hidden = YES;
        self.timeLabel.hidden = NO;
        self.messageContentView.frame = messageContentViewRect;
    } else {
        self.progressView.hidden = YES;
        if (self.model.sentStatus == SentStatus_CANCELED) {
            [self displayCancelLabel];
            self.progressView.hidden = YES;
            self.playIconView.hidden = NO;
            self.cancelSendButton.hidden = YES;
        }
        if (self.model.sentStatus == SentStatus_SENDING) {
            self.progressView.hidden = NO;
            self.playIconView.hidden = YES;
            self.cancelSendButton.hidden = NO;
            self.timeLabel.hidden = NO;
        }
        if (self.model.sentStatus == SentStatus_SENT || self.model.sentStatus == SentStatus_FAILED ||
            self.model.sentStatus == SentStatus_RECEIVED) {
            self.progressView.hidden = YES;
            self.playIconView.hidden = NO;
            self.cancelSendButton.hidden = YES;
            self.timeLabel.hidden = NO;
        }
        messageContentViewRect.origin.x = self.baseContentView.frame.size.width -
                                          (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 6) -
                                          messageContentViewRect.size.width;
        self.messageContentView.frame = messageContentViewRect;
    }

}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    RCMessageCellNotificationModel *notifyModel = notification.object;
    NSInteger progress = notifyModel.progress;
 
    if (self.model.messageId == notifyModel.messageId) {
        if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_BEGIN]) {
            self.model.sentStatus = SentStatus_SENDING;
            [self updateStatusContentView:self.model];
            [self updateProgressView:progress];
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
            self.model.sentStatus = SentStatus_FAILED;
            [self updateStatusContentView:self.model];
            [self updateProgressView:progress];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cancelSendButton setHidden:YES];
            });
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
                [self updateProgressView:progress];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cancelSendButton setHidden:YES];
            });
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {
            [self updateProgressView:progress];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageActivityIndicatorView.hidden = YES;
                self.cancelSendButton.hidden = NO;
            });
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_CANCELED]) {
            self.model.sentStatus = SentStatus_CANCELED;
            [self updateStatusContentView:self.model];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cancelSendButton setHidden:YES];
                self.progressView.hidden = YES;
                self.playIconView.hidden = NO;
                [self displayCancelLabel];
            });
        } else if (self.model.sentStatus == SentStatus_READ && self.isDisplayReadStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                self.playIconView.hidden = NO;
                [self.progressView updateWithTotalBytes:1 downloadedBytes:0];
                self.messageHasReadStatusView.hidden = NO;
                self.messageFailedStatusView.hidden = YES;
                self.messageSendSuccessStatusView.hidden = YES;
                self.model.sentStatus = SentStatus_READ;
                [self updateStatusContentView:self.model];
            });
        }
    }
}

- (void)updateProgressView:(NSUInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.model.sentStatus == SentStatus_SENDING) {
            self.progressView.hidden = NO;
            self.playIconView.hidden = YES;
            [self.progressView updateWithTotalBytes:1 downloadedBytes:(float)progress / 100.f];
            self.cancelSendButton.hidden = NO;
        } else {
            self.progressView.hidden = YES;
            self.playIconView.hidden = NO;
        }
    });
}

- (void)updateDownloadProgressView:(NSUInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = NO;
        self.playIconView.hidden = YES;
        [self.progressView updateWithTotalBytes:1 downloadedBytes:(float)progress / 100.f];
        if (progress == 100) {
            self.progressView.hidden = YES;
            self.playIconView.hidden = NO;
        }
    });
}

- (void)cancelSend {
    if ([self.delegate respondsToSelector:@selector(didTapCancelUploadButton:)]) {
        [self.delegate didTapCancelUploadButton:self.model];
    }
}

- (void)displayCancelLabel {
    self.cancelLabel.hidden = NO;
    self.timeLabel.hidden = YES;
}

- (void)updateDownloadMediaStatus:(NSNotification *)notify {
    NSDictionary *statusDic = notify.userInfo;
    if (self.model.messageId == [statusDic[@"messageId"] longValue]) {
        if ([statusDic[@"type"] isEqualToString:@"success"]) {
            RCFileMessage *fileMessage = (RCFileMessage *)self.model.content;
            fileMessage.localPath = statusDic[@"mediaPath"];
        }
    }
}

+ (CGSize)getThumImageSizeWithVideoMessage:(CMPVideoMessage *)message {
    CGSize thumImageSize = message.videoThumImage.size;
    CGFloat thumImageWidth = thumImageSize.width;
    CGFloat thumImageHeight = thumImageSize.height;
    //CGFloat maxSide = MAX(thumImageWidth, thumImageHeight);
    CGFloat aspectRatio = thumImageWidth/thumImageHeight;
    
    if (!thumImageWidth || !thumImageHeight) {
        return CGSizeMake(100, 100);
    }
    
    CGFloat width;
    CGFloat height;
    if (aspectRatio >= 0.5 && aspectRatio <= 2) {
        if (thumImageWidth >= thumImageHeight) {
            width = 200;
            height = width / aspectRatio;
        } else {
            height = 200;
            width = height * aspectRatio;
        }
    } else if (aspectRatio > 2) {
        height = 100;
        width = height * aspectRatio;
        if (width >= 200) {
            width = 200;
        }
    } else {
        width = 100;
        height = width / aspectRatio;
        if (height >= 200) {
            height = 200;
        }
    }
    return CGSizeMake(width, height);
    
//    if (maxSide < 100) {
//        CGFloat width;
//        CGFloat height;
//        if (aspectRatio > 1) {
//            width = 100;
//            height = 100 / aspectRatio;
//        } else {
//            height = 100;
//            width = 100 * aspectRatio;
//        }
//        return CGSizeMake(width, height);
//    }
//    else {
//        return thumImageSize;
//    }
}

+ (NSString *)getReadableStringForFileSize:(long long)byteSize {
    if (byteSize < 0) {
        return @"0 B";
    } else if (byteSize < 1024) {
        return [NSString stringWithFormat:@"%lld B", byteSize];
    } else if (byteSize < 1024 * 1024) {
        double kSize = (double)byteSize / 1024;
        return [NSString stringWithFormat:@"%.0f KB", kSize];
    } else if (byteSize < 1024 * 1024 * 1024){
        double kSize = (double)byteSize / (1024 * 1024);
        return [NSString stringWithFormat:@"%.0f MB", kSize];
    } else {
        double kSize = (double)byteSize / (1024 * 1024 * 1024);
        return [NSString stringWithFormat:@"%.0f GB", kSize];
    }
}

@end
