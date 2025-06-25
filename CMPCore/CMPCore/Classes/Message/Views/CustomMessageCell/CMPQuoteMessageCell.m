//
//  CMPQuoteMessageCell.m
//  M3
//
//  Created by Kaku Songu on 4/20/21.
//

#import "CMPQuoteMessageCell.h"
#import <CMPLib/KSLabel.h>
#import <CMPLib/Masonry.h>
#import <RongIMKit/RCIM.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UILabel+RTL.h>

#define kFontSize_QuotedMsg 12
#define kSpaceBetweenQuotedAndContent 0
#define kSppaceBetweenContentAndEdge 3
#define kHeight_SepLine 0.5

@interface CMPQuoteMessageCell()
{
    UIImageView *_sepLineV;
}
@property(nonatomic, strong) KSLabel *quotedLb;

@end

@implementation CMPQuoteMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 0.0f;
    float screenRatio = 0.7;
    if (SCREEN_WIDTH <= 320) {
        screenRatio = 0.6;
    }

    float maxWidth = (int)(collectionViewWidth * screenRatio) + 7;
    CMPQuoteMessage *_textMessage = (CMPQuoteMessage *)model.content;
    CGSize _textMessageSize;
    CGSize quotedSize;
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
        quotedSize = [RCKitUtility getTextDrawingSizeWithText:_textMessage.quotedShowStr font:[UIFont systemFontOfSize:kFontSize_QuotedMsg] constrainedSize:CGSizeMake(maxWidth - 33, 80000)];
    }
    _textMessageSize = CGSizeMake(ceilf(MAX(_textMessageSize.width, quotedSize.width)), ceilf(_textMessageSize.height));
    CGFloat __label_height = _textMessageSize.height + (quotedSize.height>0 ?(quotedSize.height+kSpaceBetweenQuotedAndContent*2+ kSppaceBetweenContentAndEdge*2+kHeight_SepLine):0);
    //背景图的最小高度
//    CGFloat __bubbleHeight = __label_height + 8 + 8 < 40 ? 40 : (__label_height + 8 + 8);
    CGFloat __bubbleHeight = __label_height < 40 ? 40 : (__label_height);
    
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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _quotedLb = [[KSLabel alloc] init];
    _quotedLb.backgroundColor = [UIColor clearColor];
    _quotedLb.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    _quotedLb.font = [UIFont systemFontOfSize:kFontSize_QuotedMsg];
    _quotedLb.numberOfLines = 0;
    [_quotedLb sizeToFit];
    [self.messageContentView addSubview:_quotedLb];
    
    _sepLineV = [[UIImageView alloc] init];
    _sepLineV.backgroundColor = [UIColor clearColor];
    [self.messageContentView addSubview:_sepLineV];
}

-(void)setDataModel:(RCMessageModel *)model
{
    CMPQuoteMessage *msgContent = (CMPQuoteMessage *)model.content;
    _quotedLb.text = msgContent.quotedShowStr;
    [super setDataModel:model];
}


- (void)setAutoLayout {
    _sepLineV.layer.sublayers = nil;
    [self.textLabel setTextColor:RCDYCOLOR(0x262626, 0xe0e0e0)];

    CMPQuoteMessage *_textMessage = (CMPQuoteMessage *)self.model.content;
    self.burnView.hidden = YES;
    if (_textMessage) {
        self.textLabel.text = _textMessage.content;
    } else {
//        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCTextMessage object");
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
    
    CGSize quotedSize = [RCKitUtility getTextDrawingSizeWithText:_textMessage.quotedShowStr font:[UIFont systemFontOfSize:kFontSize_QuotedMsg] constrainedSize:CGSizeMake(maxWidth - 33, 80000)];
    
    __textSize = CGSizeMake(ceilf(MAX(__textSize.width, quotedSize.width)), __textSize.height);
    
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

//    CGFloat __bubbleHeight = (__labelSize.height + 8 + 8 < 40 ? 40 : (__labelSize.height + 8 + 8))  + (quotedSize.height > 0 ? (quotedSize.height+kSpaceBetweenQuotedAndContent+kHeight_SepLine) : 0);
    CGFloat __bubbleHeight = (__labelSize.height < 40 ? 40 : (__labelSize.height ))  + (quotedSize.height > 0 ? (quotedSize.height+kSpaceBetweenQuotedAndContent*2+ kSppaceBetweenContentAndEdge*2 +kHeight_SepLine) : 0);
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
        self.quotedLb.frame = CGRectMake(originX, kSppaceBetweenContentAndEdge, __labelSize.width, quotedSize.height);
        _sepLineV.frame = CGRectMake(originX, CGRectGetMaxY(self.quotedLb.frame)+ (kSpaceBetweenQuotedAndContent/2), __labelSize.width, kHeight_SepLine);
        self.textLabel.frame =
        CGRectMake(originX, CGRectGetMaxY(_sepLineV.frame)+ kSpaceBetweenQuotedAndContent/2,
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
        self.quotedLb.frame = CGRectMake(originX, kSppaceBetweenContentAndEdge, __labelSize.width, quotedSize.height);
        _sepLineV.frame = CGRectMake(originX, CGRectGetMaxY(self.quotedLb.frame)+ (kSpaceBetweenQuotedAndContent/2), __labelSize.width, kHeight_SepLine);
        self.textLabel.frame =
            CGRectMake(originX, CGRectGetMaxY(_sepLineV.frame)+ kSpaceBetweenQuotedAndContent/2,
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
    [self drawLineOfDashByCAShapeLayer:_sepLineV lineLength:5 lineSpacing:3 lineColor:HEXCOLOR(0xBECAD2) lineDirection:YES];

    [self setDestructViewLayout];
}

- (void)setDestructViewLayout {
    RCTextMessage *_textMessage = (RCTextMessage *)self.model.content;
    if (_textMessage.destructDuration > 0) {
        self.destructView.hidden = NO;
        [self.messageContentView bringSubviewToFront:self.destructView];
        CGRect frame;
        if (_textMessage.destructDuration <= 99) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 8.5, 15, 15);
        } else if (_textMessage.destructDuration <= 999) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5 - 5.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 8.5, 26, 15);
        } else if (_textMessage.destructDuration <= 9999) {
            frame = self.destructView.frame = CGRectMake(CGRectGetMaxX(self.bubbleBackgroundView.frame) - 4.5 - 10.5,
                                                         CGRectGetMinY(self.bubbleBackgroundView.frame) - 8.5, 36, 15);
        }
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.destructBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        } else {
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.bubbleBackgroundView.frame) - 7.5,
                                                 CGRectGetMinY(self.bubbleBackgroundView.frame) - 8.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
    }
}


- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal {

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    [shapeLayer setBounds:lineView.bounds];

    if (isHorizonal) {

        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];

    } else{
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    }

    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    if (isHorizonal) {
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    } else {

        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);

    if (isHorizonal) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    } else {
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    }

    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
