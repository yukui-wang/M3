//
//  RCTextMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCTextMessageCell.h"
#import "RCIM.h"
#import "RCKitUtility.h"
#import "RCIMClient+Destructing.h"

@interface RCTextMessageCell ()

- (void)initialize;
@property (nonatomic, assign) BOOL isConversationAppear;
@end

@implementation RCTextMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 0.0f;
    float screenRatio = 0.7;
    if (SCREEN_WIDTH <= 320) {
        screenRatio = 0.6;
    }

    float maxWidth = (int)(collectionViewWidth * screenRatio) + 7;
    RCTextMessage *_textMessage = (RCTextMessage *)model.content;
    CGSize _textMessageSize;
    if (_textMessage.destructDuration > 0 && model.messageDirection == MessageDirection_RECEIVE &&
        ![[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:model.messageUId]) {
        _textMessageSize =
            [RCKitUtility getTextDrawingSizeWithText:NSLocalizedStringFromTable(@"ClickToView", @"RongCloudKit", nil)
                                        font:[UIFont systemFontOfSize:Text_Message_Font_Size]
                             constrainedSize:CGSizeMake(maxWidth - 33, 80000)];
    } else {
        _textMessageSize = [RCKitUtility getTextDrawingSizeWithText:_textMessage.content
                                                       font:[UIFont systemFontOfSize:Text_Message_Font_Size]
                                            constrainedSize:CGSizeMake(maxWidth - 33, 80000)];
    }
    _textMessageSize = CGSizeMake(ceilf(_textMessageSize.width), ceilf(_textMessageSize.height));
    CGFloat __label_height = _textMessageSize.height;
    //背景图的最小高度
//    CGFloat __bubbleHeight = __label_height + 8 + 8 < 40 ? 40 : (__label_height + 8 + 8);
    CGFloat __bubbleHeight = __label_height  < 40 ? 40 : (__label_height);
    __messagecontentview_height = __bubbleHeight;

    if ([model isKindOfClass:[RCCustomerServiceMessageModel class]] &&
        [((RCCustomerServiceMessageModel *)model)isNeedEvaluateArea]) { //机器人评价高度
        __messagecontentview_height += 15;
    }
    if (__messagecontentview_height < [RCIM sharedRCIM].globalMessagePortraitSize.height) {
        __messagecontentview_height = [RCIM sharedRCIM].globalMessagePortraitSize.height;
    }
    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
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

- (NSDictionary *)highlightedAttributeDictionary {
    return [self attributeDictionary];
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

    self.textLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.textLabel.attributeDictionary = [self attributeDictionary];
    self.textLabel.highlightedAttributeDictionary = [self highlightedAttributeDictionary];
    [self.textLabel setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];

    self.textLabel.numberOfLines = 0;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    if (RC_IOS_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
    }
    self.textLabel.delegate = self;
    [self.bubbleBackgroundView addSubview:self.textLabel];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];

    UITapGestureRecognizer *textMessageTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textMessageTap.numberOfTapsRequired = 1;
    textMessageTap.numberOfTouchesRequired = 1;
    [self.textLabel addGestureRecognizer:textMessageTap];
    self.textLabel.userInteractionEnabled = YES;

    self.burnView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 28)];
    [self.burnView setImage:IMAGE_BY_NAMED(@"text_burn_img")];
    self.burnView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bubbleBackgroundView addSubview:self.burnView];
    self.burnView.hidden = YES;
}
- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {

    if (self.textLabel.currentTextCheckingType == NSTextCheckingTypeLink) {
        // open url
        NSString *urlString =
            [self.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        // http://
        //        if (![urlString hasPrefix:@"http"]){
        //            urlString = [@"http://" stringByAppendingString:urlString];
        //        }

        if ([self.delegate respondsToSelector:@selector(didTapUrlInMessageCell:model:)]) {
            [self.delegate didTapUrlInMessageCell:urlString model:self.model];
            return;
        }
    } else if (self.textLabel.currentTextCheckingType == NSTextCheckingTypePhoneNumber) {
        // call phone number
        NSString *number = [@"tel://" stringByAppendingString:self.textLabel.text];
        if ([self.delegate respondsToSelector:@selector(didTapPhoneNumberInMessageCell:model:)]) {
            [self.delegate didTapPhoneNumberInMessageCell:number model:self.model];
            return;
        }
    }

    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}

- (void)setAutoLayout {
    [self.textLabel setTextColor:RCDYCOLOR(0x262626, 0xe0e0e0)];

    RCTextMessage *_textMessage = (RCTextMessage *)self.model.content;
    self.burnView.hidden = YES;
    if (_textMessage) {
        self.textLabel.text = _textMessage.content;
    } else {
        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCTextMessage object");
    }

    if (_textMessage.destructDuration > 0 && self.model.messageDirection == MessageDirection_RECEIVE &&
        ![[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId]) {
        self.textLabel.text = NSLocalizedStringFromTable(@"ClickToView", @"RongCloudKit", nil);
        self.burnView.hidden = NO;
    }

    float screenRatio = 0.7;
    if (SCREEN_WIDTH <= 320) {
        screenRatio = 0.6;
    }

    float maxWidth = (int)(self.baseContentView.bounds.size.width * screenRatio) + 7;
    CGSize __textSize = [RCKitUtility getTextDrawingSizeWithText:self.textLabel.text
                                                    font:[UIFont systemFontOfSize:Text_Message_Font_Size]
                                         constrainedSize:CGSizeMake(maxWidth - 33, 80000)];
    self.burnView.frame = CGRectMake(__textSize.width + 23, 5, 13, 28);
    if (_textMessage.destructDuration > 0 && self.model.messageDirection == MessageDirection_RECEIVE &&
        ![[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId]) {
        __textSize.width += 20;
    }
    CGFloat __textMaxWidth = maxWidth - 33;
    if (__textSize.width > __textMaxWidth) {
        __textSize.width = __textMaxWidth;
    }
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width, __textSize.height);

//    CGFloat __bubbleHeight = __labelSize.height + 8 + 8 < 40 ? 40 : (__labelSize.height + 8 + 8);
    CGFloat __bubbleHeight = __labelSize.height  < 40 ? 40 : (__labelSize.height);
    CGFloat __bubbleWidth = __labelSize.width + 16 + 10;
    if (__bubbleWidth >= maxWidth) {
        __bubbleWidth = maxWidth;
    }

    if ([self.model isKindOfClass:[RCCustomerServiceMessageModel class]] &&
        [((RCCustomerServiceMessageModel *)self.model)isNeedEvaluateArea]) {

        RCCustomerServiceMessageModel *csModel = (RCCustomerServiceMessageModel *)self.model;

        __bubbleHeight += 25;

        if (__bubbleWidth < 150) { //太短了，评价显示不下，加长吧
            __bubbleWidth = 150;
        }

        if (self.separateLine) {
            [self.acceptBtn removeFromSuperview];
            [self.rejectBtn removeFromSuperview];
            [self.separateLine removeFromSuperview];
            [self.tipLablel removeFromSuperview];
        }
        self.separateLine =
            [[UIView alloc] initWithFrame:CGRectMake(15, __bubbleHeight - 23, __bubbleWidth - 15 - 5, 0.5)];
        [self.separateLine setBackgroundColor:[UIColor lightGrayColor]];

        if (csModel.alreadyEvaluated) {
            self.tipLablel =
                [[UILabel alloc] initWithFrame:CGRectMake(__bubbleWidth - 80 - 7, __bubbleHeight - 18, 80, 15)];
            self.tipLablel.text = @"感谢您的评价";
            self.tipLablel.textColor = [UIColor lightGrayColor];
            self.tipLablel.font = [UIFont systemFontOfSize:13];
            self.acceptBtn =
                [[UIButton alloc] initWithFrame:CGRectMake(__bubbleWidth - 95 - 7 - 3, __bubbleHeight - 18, 15, 15)];
            [self.acceptBtn setImage:IMAGE_BY_NAMED(@"cs_eva_complete") forState:UIControlStateNormal];
            [self.acceptBtn setImage:IMAGE_BY_NAMED(@"cs_eva_complete_hover") forState:UIControlStateHighlighted];

            [self.bubbleBackgroundView addSubview:self.acceptBtn];
        } else {
            self.tipLablel =
                [[UILabel alloc] initWithFrame:CGRectMake(__bubbleWidth - 118 - 10, __bubbleHeight - 18, 80, 15)];
            self.tipLablel.text = @"您对我的回答";
            self.tipLablel.textColor = [UIColor lightGrayColor];
            self.tipLablel.font = [UIFont systemFontOfSize:13];

            self.acceptBtn =
                [[UIButton alloc] initWithFrame:CGRectMake(__bubbleWidth - 30 - 7 - 6, __bubbleHeight - 18, 15, 15)];
            self.rejectBtn =
                [[UIButton alloc] initWithFrame:CGRectMake(__bubbleWidth - 15 - 7, __bubbleHeight - 18, 15, 15)];
            [self.acceptBtn setImage:IMAGE_BY_NAMED(@"cs_yes") forState:UIControlStateNormal];
            [self.acceptBtn setImage:IMAGE_BY_NAMED(@"cs_yes_hover") forState:UIControlStateHighlighted];

            [self.self.rejectBtn setImage:IMAGE_BY_NAMED(@"cs_no") forState:UIControlStateNormal];
            [self.self.rejectBtn setImage:IMAGE_BY_NAMED(@"cs_yes_no") forState:UIControlStateHighlighted];
            [self.bubbleBackgroundView addSubview:self.acceptBtn];
            [self.bubbleBackgroundView addSubview:self.rejectBtn];

            [self.acceptBtn addTarget:self action:@selector(didAccepted:) forControlEvents:UIControlEventTouchDown];
            [self.rejectBtn addTarget:self action:@selector(didRejected:) forControlEvents:UIControlEventTouchDown];
        }

        [self.bubbleBackgroundView addSubview:self.tipLablel];
        [self.bubbleBackgroundView addSubview:self.separateLine];

    } else {
        [self.acceptBtn removeFromSuperview];
        [self.rejectBtn removeFromSuperview];
        [self.separateLine removeFromSuperview];
        [self.tipLablel removeFromSuperview];
        self.acceptBtn = nil;
        self.rejectBtn = nil;
        self.separateLine = nil;
        self.tipLablel = nil;
    }
    CGSize __bubbleSize = CGSizeMake(__bubbleWidth, __bubbleHeight);

    CGRect messageContentViewRect = self.messageContentView.frame;

    //拉伸图片
    // CGFloat top, CGFloat left, CGFloat bottom, CGFloat right
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.size.height = __bubbleSize.height;
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        float originX = (self.bubbleBackgroundView.frame.size.width - __labelSize.width) / 2 + 4; //加上气泡的角的宽度
        self.textLabel.frame =
            CGRectMake(originX, CGRectGetMidY(self.bubbleBackgroundView.frame) - __labelSize.height / 2,
                       __labelSize.width, __labelSize.height);
        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                         image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.size.height = __bubbleSize.height;
        messageContentViewRect.origin.x = self.baseContentView.bounds.size.width -
                                          (messageContentViewRect.size.width + 10 +
                                           [RCIM sharedRCIM].globalMessagePortraitSize.width + HeadAndContentSpacing);
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        float originX = (self.bubbleBackgroundView.frame.size.width - __labelSize.width) / 2 - 3; //减去气泡的角的宽度
        self.textLabel.frame =
            CGRectMake(originX, CGRectGetMidY(self.bubbleBackgroundView.frame) - __labelSize.height / 2,
                       __labelSize.width, __labelSize.height);
        self.bubbleBackgroundView.image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        CGRect statusFrame = self.statusContentView.frame;
        statusFrame.origin.x = statusFrame.origin.x + 5;
        [self.statusContentView setFrame:statusFrame];
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
            resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                         image.size.height * 0.2, image.size.width * 0.8)];
    }
    // self.bubbleBackgroundView.image = image;

    [self setDestructViewLayout];
}

- (void)beginDestructing {
    RCTextMessage *textMessage = (RCTextMessage *)self.model.content;
    if (self.model.messageDirection == MessageDirection_RECEIVE && textMessage.destructDuration > 0 &&
        textMessage.destructDuration > 0) {
        [[RCIMClient sharedRCIMClient]
            messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.model.messageId]];
        ;
    }
}

- (void)setDestructViewLayout {
    RCTextMessage *_textMessage = (RCTextMessage *)self.model.content;
    if (_textMessage.destructDuration > 0) {
        self.destructView.hidden = NO;
        [self.messageContentView bringSubviewToFront:self.destructView];
        CGRect frame;
        if (_textMessage.destructDuration <= 99) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 15, 15);
        } else if (_textMessage.destructDuration <= 999) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5 - 5.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 26, 15);
        } else if (_textMessage.destructDuration <= 9999) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5 - 10.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 36, 15);
        }
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.destructBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        } else {
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.bubbleBackgroundView.frame) - 7.5,
                                                 CGRectGetMinY(self.bubbleBackgroundView.frame) - 2.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
    }
}

- (void)didAccepted:(id)sender {
    [self evaluate:YES];
}

- (void)didRejected:(id)sender {
    [self evaluate:NO];
}

- (void)evaluate:(BOOL)isresolved {
    if ([self.delegate respondsToSelector:@selector(didTapCustomerService:RobotResoluved:)]) {
        [self.delegate didTapCustomerService:self.model RobotResoluved:isresolved];
    }
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

- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    urlString = [RCKitUtility checkOrAppendHttpForUrl:urlString];
    if ([self.delegate respondsToSelector:@selector(didTapUrlInMessageCell:model:)]) {
        [self.delegate didTapUrlInMessageCell:urlString model:self.model];
        return;
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
