//
//  RCCombineMessageCell.m
//  RongIMKit
//
//  Created by liyan on 2019/8/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCCombineMessageCell.h"
#import "RCIMClient+Destructing.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCCombineMessageUtility.h"
#import "RCResendManager.h"

#define RCCOMBINECELLWIDTH 230.0f
#define RCCOMBINECELLHEIGHT (32.0f + 16.0f * 2 + 1)
#define RCCOMBINELABLEOFFSET 10.0f
#define RCCOMBINEARROWWIDTH 5.0f
#define RCCOMBINELABLEHEIGHT 16.0f

@interface RCCombineMessageCell ()

@property (nonatomic, strong) UIImageView *maskView;

@property (nonatomic, strong) UIImageView *shadowMaskView;

@property (nonatomic, strong) UILabel *lineLable;

@property (nonatomic, strong) RCMessageModel *currentModel;

@end

@implementation RCCombineMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    RCCombineMessage *combineMessage = (RCCombineMessage *)model.content;
    __messagecontentview_height = [RCCombineMessageCell calculateCellHeight:combineMessage];
    if (__messagecontentview_height < [RCIM sharedRCIM].globalMessagePortraitSize.height) {
        __messagecontentview_height = [RCIM sharedRCIM].globalMessagePortraitSize.height;
    }
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(RCCombineMessage *)combineMessage {
    CGFloat height = RCCOMBINECELLHEIGHT;
    for (int i = 0; i < combineMessage.summaryList.count; i++) {
        NSString *summary = [combineMessage.summaryList objectAtIndex:i];
        CGSize size = [RCKitUtility getTextDrawingSize:summary font:[UIFont systemFontOfSize:12] constrainedSize:CGSizeMake(RCCOMBINECELLWIDTH - 25, 9999)];
        height += size.height;
        if (height > RCCOMBINECELLHEIGHT + RCCOMBINELABLEHEIGHT * 4) {
            height = RCCOMBINECELLHEIGHT + RCCOMBINELABLEHEIGHT * 4;
            break;
        }
    }
    return height;
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
    [self.messageContentView addSubview:self.backView];
    [self.backView addSubview:self.titleLabel];
    [self.backView addSubview:self.contentLabel];
    [self.backView addSubview:self.lineLable];
    [self.backView addSubview:self.historyLabel];
    [self addGestureRecognizer];
}

- (void)addGestureRecognizer {
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.backView addGestureRecognizer:longPress];

    UITapGestureRecognizer *backViewTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap:)];
    backViewTap.numberOfTapsRequired = 1;
    backViewTap.numberOfTouchesRequired = 1;
    [self.backView addGestureRecognizer:backViewTap];
    self.backView.userInteractionEnabled = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)backViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

#pragma mark - setModel
- (void)setDataModel:(RCMessageModel *)model {
    if (!model) {
        return;
    }
    [super setDataModel:model];
    self.currentModel = model;
    [self resetSubViews];
    RCCombineMessage *combineMessage = (RCCombineMessage *)model.content;
    [self calculateContenViewSize:combineMessage];
    NSString *title = [RCCombineMessageUtility getCombineMessageSummaryTitle:combineMessage];
    self.titleLabel.text = title;
    NSString *summaryContent = [RCCombineMessageUtility getCombineMessageSummaryContent:combineMessage];
    self.contentLabel.text = summaryContent;
    [self updateStatusContentView:self.model];
    [self setDestructViewLayout];
}

- (void)resetSubViews {
    self.titleLabel.text = nil;
    self.contentLabel.text = nil;
}

- (void)calculateContenViewSize:(RCCombineMessage *)combineMessage {
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage *maskImage = nil;
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
        maskImage = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        maskImage = [maskImage
            resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.8,
                                                         maskImage.size.height * 0.2, maskImage.size.width * 0.2)];
    } else {
        maskImage = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        maskImage = [maskImage
            resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.2,
                                                         maskImage.size.height * 0.2, maskImage.size.width * 0.8)];
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width -
            (RCCOMBINECELLWIDTH + HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
    }
    CGFloat messageContentViewHeight;
    messageContentViewHeight = [RCCombineMessageCell calculateCellHeight:combineMessage];
    messageContentViewRect.size = CGSizeMake(RCCOMBINECELLWIDTH, messageContentViewHeight);
    self.messageContentView.frame = messageContentViewRect;
    [self autoLayoutSubViews];
    [self setMaskImage:maskImage];
}

- (void)autoLayoutSubViews {
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
        self.backView.frame =
            CGRectMake(RCCOMBINEARROWWIDTH + RCCOMBINELABLEOFFSET, 0,
                       self.messageContentView.frame.size.width - RCCOMBINEARROWWIDTH - RCCOMBINELABLEOFFSET * 2,
                       self.messageContentView.frame.size.height);
    } else {
        self.backView.frame = CGRectMake(RCCOMBINELABLEOFFSET, 0, self.messageContentView.frame.size.width -
                                                                      RCCOMBINEARROWWIDTH - RCCOMBINELABLEOFFSET * 2,
                                         self.messageContentView.frame.size.height);
    }
    self.titleLabel.frame = CGRectMake(0, 5, self.backView.frame.size.width, RCCOMBINELABLEHEIGHT);
    self.contentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 2, self.backView.frame.size.width,
                                         self.messageContentView.frame.size.height - RCCOMBINECELLHEIGHT);
    self.lineLable.frame = CGRectMake(0, CGRectGetMaxY(self.contentLabel.frame) + 10, self.backView.frame.size.width,
                                      1 / [UIScreen mainScreen].scale);
    self.historyLabel.frame =
        CGRectMake(0, CGRectGetMaxY(self.lineLable.frame) + 5, self.backView.frame.size.width, RCCOMBINELABLEHEIGHT);
}

- (void)setDestructViewLayout {
    RCCombineMessage *combineMessage = (RCCombineMessage *)self.model.content;
    if (combineMessage.destructDuration > 0 &&
        [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId]) {
        self.destructView.hidden = NO;
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.messageHasReadStatusView.frame = CGRectMake(9, 0, 25, 25);
            self.destructView.frame = CGRectMake(CGRectGetMaxX(self.backView.frame) + 4.5,
                                                 CGRectGetMaxY(self.backView.frame) - 13 - 8.5, 21, 12);
        } else {
            self.messageHasReadStatusView.frame = CGRectMake(9 - 24, 0, 25, 25);
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.backView.frame) - 25.5,
                                                 CGRectGetMaxY(self.backView.frame) - 13 - 8.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
        self.messageHasReadStatusView.frame = CGRectMake(9, 0, 25, 25);
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
            } else {
                self.model.sentStatus = SentStatus_FAILED;
            }
            [self updateStatusContentView:self.model];
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
            if (self.model.sentStatus != SentStatus_READ) {
                self.model.sentStatus = SentStatus_SENT;
                [self updateStatusContentView:self.model];
            }
        } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {

        } else if (self.model.sentStatus == SentStatus_READ && self.isDisplayReadStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{

                self.messageHasReadStatusView.hidden = NO;
                self.messageFailedStatusView.hidden = YES;
                self.messageSendSuccessStatusView.hidden = YES;
                self.model.sentStatus = SentStatus_READ;
                [self updateStatusContentView:self.model];
                self.statusContentView.frame =
                    CGRectMake(self.backView.frame.origin.x - 20, self.backView.frame.size.height - 18, 18, 18);

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
        [self.delegate didLongTouchMessageCell:self.model inView:self.backView];
    }
}

- (void)setMaskImage:(UIImage *)maskImage {
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];

        _maskView.frame = self.messageContentView.bounds;
        self.messageContentView.layer.mask = _maskView.layer;
        self.messageContentView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.messageContentView.bounds;
    }
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];

    _shadowMaskView.frame = CGRectMake(-0.2, -0.2, self.messageContentView.frame.size.width + 0.5,
                                       self.messageContentView.frame.size.height + 0.5);
    [self.messageContentView addSubview:_shadowMaskView];
    [self.messageContentView bringSubviewToFront:self.backView];
}

#pragma mark - lazyload
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.userInteractionEnabled = NO;
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [RCKitUtility generateDynamicColor:RGBCOLOR(38, 38, 38) darkColor:HEXCOLOR(0xe0e0e0)];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor =
            [RCKitUtility generateDynamicColor:RGBCOLOR(153, 153, 153) darkColor:HEXCOLOR(0xc3c3c8)];
    }
    return _contentLabel;
}

- (UILabel *)lineLable {
    if (!_lineLable) {
        _lineLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLable.backgroundColor = RGBCOLOR(216, 216, 216);
    }
    return _lineLable;
}

- (UILabel *)historyLabel {
    if (!_historyLabel) {
        _historyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _historyLabel.font = [UIFont systemFontOfSize:12];
        _historyLabel.numberOfLines = 1;
        _historyLabel.textAlignment = NSTextAlignmentLeft;
        _historyLabel.backgroundColor = [UIColor clearColor];
        _historyLabel.textColor =
            [RCKitUtility generateDynamicColor:RGBCOLOR(153, 153, 153) darkColor:HEXCOLOR(0xc3c3c8)];
        _historyLabel.text = NSLocalizedStringFromTable(@"ChatHistory", @"RongCloudKit", nil);
    }
    return _historyLabel;
}
@end
