//
//  RCReferenceMessageCell.m
//  RongIMKit
//
//  Created by 张改红 on 2020/2/27.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCReferenceMessageCell.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#define contentFont 16
#define bubble_top_space 10
#define bubble_bottom_space 7
#define refer_and_text_space 9
@interface RCReferenceMessageCell () <RCAttributedLabelDelegate, RCReferencedContentViewDelegate>
@end
@implementation RCReferenceMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    float screenRatio = 0.637;
    if (SCREEN_WIDTH <= 320) {
        screenRatio = 0.6;
    }
    float maxWidth = (int)(collectionViewWidth * screenRatio) + 7;
    RCReferenceMessage *refenceMessage = (RCReferenceMessage *)model.content;
    CGSize textLabelSize = [[self class] getTextLabelSize:refenceMessage.content
                                                 maxWidth:maxWidth - 33
                                                     font:[UIFont systemFontOfSize:contentFont]];
    CGSize contentSize = [[self class] contentInfoSizeWithContent:model maxWidth:maxWidth - 33];
    CGSize bubbleBackgroundViewSize =
        CGSizeMake(textLabelSize.width, textLabelSize.height + contentSize.height + bubble_top_space +
                                            bubble_bottom_space + refer_and_text_space);
    CGFloat __messagecontentview_height = bubbleBackgroundViewSize.height;
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
    [self.messageContentView addSubview:self.bubbleBackgroundView];

    self.referencedContentView = [[RCReferencedContentView alloc] init];
    self.referencedContentView.delegate = self;
    [self.bubbleBackgroundView addSubview:self.referencedContentView];

    self.contentLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.attributeDictionary = [self attributeDictionary];
    self.contentLabel.highlightedAttributeDictionary = [self attributeDictionary];
    [self.contentLabel setFont:[UIFont systemFontOfSize:contentFont]];
    self.contentLabel.numberOfLines = 0;
    [self.contentLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.contentLabel setTextAlignment:NSTextAlignmentLeft];
    self.contentLabel.delegate = self;
    [self.bubbleBackgroundView addSubview:self.contentLabel];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];

    UITapGestureRecognizer *textMessageTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textMessageTap.numberOfTapsRequired = 1;
    textMessageTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:textMessageTap];
    self.contentLabel.userInteractionEnabled = YES;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout {
    self.contentLabel.textColor = RCDYCOLOR(0x262626, 0xe0e0e0);
    RCReferenceMessage *refenceMessage = (RCReferenceMessage *)self.model.content;
    if (refenceMessage) {
        self.contentLabel.text = refenceMessage.content;
    }
    float screenRatio = 0.637;
    if (SCREEN_WIDTH <= 320) {
        screenRatio = 0.6;
    }
    float maxWidth = (int)(self.baseContentView.frame.size.width * screenRatio) + 7;
    CGSize textLabelSize = [[self class] getTextLabelSize:refenceMessage.content
                                                 maxWidth:maxWidth - 33
                                                     font:[UIFont systemFontOfSize:contentFont]];
    CGSize contentSize = [[self class] contentInfoSizeWithContent:self.model maxWidth:maxWidth - 33];
    CGSize bubbleBackgroundViewSize =
        CGSizeMake(textLabelSize.width + 16 + 10, textLabelSize.height + contentSize.height + bubble_top_space +
                                                      bubble_bottom_space + refer_and_text_space);
    CGRect messageContentViewRect = self.messageContentView.frame;
    [self.referencedContentView setMessage:self.model contentSize:contentSize];
    //拉伸图片
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.referencedContentView.frame = CGRectMake(20, 10, contentSize.width, contentSize.height);
        self.contentLabel.frame = CGRectMake(20, CGRectGetMaxY(self.referencedContentView.frame) + refer_and_text_space,
                                             textLabelSize.width, textLabelSize.height);
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;
        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        self.referencedContentView.frame = CGRectMake(12, 10, contentSize.width, contentSize.height);
        self.contentLabel.frame = CGRectMake(12, CGRectGetMaxY(self.referencedContentView.frame) + refer_and_text_space,
                                             textLabelSize.width, textLabelSize.height);
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                image.size.height * 0.2, image.size.width * 0.8)];
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if (self.contentLabel.currentTextCheckingType == NSTextCheckingTypeLink) {
        // open url
        NSString *urlString =
            [self.contentLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([self.delegate respondsToSelector:@selector(didTapUrlInMessageCell:model:)]) {
            [self.delegate didTapUrlInMessageCell:urlString model:self.model];
            return;
        }
    } else if (self.contentLabel.currentTextCheckingType == NSTextCheckingTypePhoneNumber) {
        // call phone number
        NSString *number = [@"tel://" stringByAppendingString:self.contentLabel.text];
        if ([self.delegate respondsToSelector:@selector(didTapPhoneNumberInMessageCell:model:)]) {
            [self.delegate didTapPhoneNumberInMessageCell:number model:self.model];
            return;
        }
    }

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (NSDictionary *)attributeDictionary {
    if (self.messageDirection == MessageDirection_SEND) {
        return @{
            @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : RCDYCOLOR(0x2972ab, 0xFFBE6A)},
            @(NSTextCheckingTypePhoneNumber) : @{
                NSForegroundColorAttributeName :
                    [RCKitUtility generateDynamicColor:[UIColor blueColor] darkColor:HEXCOLOR(0x00FF85)]
            }
        };
    } else {
        return @{
            @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : RCDYCOLOR(0x2972ab, 0xFFBE6A)},
            @(NSTextCheckingTypePhoneNumber) : @{
                NSForegroundColorAttributeName :
                    [RCKitUtility generateDynamicColor:[UIColor blueColor] darkColor:HEXCOLOR(0x00FF85)]
            }
        };
    }
    return nil;
}

+ (CGSize)contentInfoSizeWithContent:(RCMessageModel *)model maxWidth:(CGFloat)maxWidth {
    RCReferenceMessage *refenceMessage = (RCReferenceMessage *)model.content;
    RCMessageContent *content = refenceMessage.referMsg;
    CGFloat height = 35;
    if ([content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *msg = (RCImageMessage *)content;
        height = [self getImageSize:msg].height + height;
    } else {
        NSString *text;
        if ([content isKindOfClass:[RCFileMessage class]]) {
            RCFileMessage *msg = (RCFileMessage *)content;
            text = [NSString
                stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:FileMsg", @"RongCloudKit", nil), msg.name];
        } else if ([content isKindOfClass:[RCRichContentMessage class]]) {
            RCRichContentMessage *msg = (RCRichContentMessage *)content;
            text =
                [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:ImgTextMsg", @"RongCloudKit", nil),
                                           msg.title];
        } else if ([content isKindOfClass:[RCTextMessage class]] ||
                   [content isKindOfClass:[RCReferenceMessage class]]) {
            text = [RCKitUtility formatMessage:content
                                      targetId:model.targetId
                              conversationType:model.conversationType
                                  isAllMessage:YES];
        } else if ([content isKindOfClass:[RCMessageContent class]]) {
            text = [RCKitUtility formatMessage:content
                                      targetId:model.targetId
                              conversationType:model.conversationType
                                  isAllMessage:YES];
            if (text.length <= 0 || [text isEqualToString:[[content class] getObjectName]]) {
                text = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
            }
        }
        height =
            height + [self getTextLabelSize:text maxWidth:maxWidth - 10 font:[UIFont systemFontOfSize:TextFont]].height;
    }
    return CGSizeMake(maxWidth, height);
}

+ (CGSize)getTextLabelSize:(NSString *)message maxWidth:(CGFloat)maxWidth font:(UIFont *)font {
    if ([message length] > 0) {
        CGSize textSize =
            [RCKitUtility getTextDrawingSize:message font:font constrainedSize:CGSizeMake(maxWidth, MAXFLOAT)];
        textSize.height = ceilf(textSize.height);
        return CGSizeMake(maxWidth, textSize.height);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getImageSize:(RCImageMessage *)imageMsg {
    CGSize imageSize = imageMsg.thumbnailImage.size;
    //兼容240
    CGFloat imageWidth = 120;
    CGFloat imageHeight = 120;
    if (imageSize.width > 121 || imageSize.height > 121) {
        imageWidth = imageSize.width / 2.0f;
        imageHeight = imageSize.height / 2.0f;
    } else {
        imageWidth = imageSize.width;
        imageHeight = imageSize.height;
    }
    //图片half
    imageSize = CGSizeMake(imageWidth, imageHeight);
    return imageSize;
}

#pragma mark - RCReferencedContentViewDelegate
- (void)didTapReferencedContentView:(RCMessageModel *)message {
    RCReferenceMessage *refer = (RCReferenceMessage *)message.content;
    if ([refer.referMsg isKindOfClass:[RCFileMessage class]] ||
        [refer.referMsg isKindOfClass:[RCRichContentMessage class]] ||
        [refer.referMsg isKindOfClass:[RCImageMessage class]]) {
        if ([self.delegate respondsToSelector:@selector(didTapReferencedContentView:)]) {
            [self.delegate didTapReferencedContentView:message];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
            [self.delegate didTapMessageCell:self.model];
        }
    }
}

#pragma mark - RCAttributedLabelDelegate & RCReferencedContentViewDelegate
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    urlString = [RCKitUtility checkOrAppendHttpForUrl:urlString];
    if ([self.delegate respondsToSelector:@selector(didTapUrlInMessageCell:model:)]) {
        [self.delegate didTapUrlInMessageCell:urlString model:self.model];
        return;
    }
}

/**
 Tells the delegate that the user did select a link to a phone number.

 @param label The label whose link was selected.
 @param phoneNumber The phone number for the selected link.
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
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

@end
