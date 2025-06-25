//
//  CMPRedPacketMessageCell.m
//
//

#import "CMPAssociatedDocumentMessageCell.h"
#import "CMPChatManager.h"
#import "CMPRCV5Message.h"

#define Message_Font_Size 16

@implementation CMPAssociatedDocumentMessageCell {
    
    UILabel *titleLab;
    UILabel *sendTagLab;
    UILabel *senderLab;
    UILabel *timeTagLab;
    UILabel *timeLab;
    UILabel *btnLab;
    UIButton *clickBtn;
    UIView *lineV;
}

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CMPRCV5Message *message = (CMPRCV5Message *)model.content;
    CGSize size = [CMPAssociatedDocumentMessageCell getBubbleBackgroundViewSize:message];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)dealloc {
    
    SY_RELEASE_SAFELY(titleLab);
    SY_RELEASE_SAFELY(sendTagLab);
    SY_RELEASE_SAFELY(senderLab);
    SY_RELEASE_SAFELY(timeTagLab);
    SY_RELEASE_SAFELY(timeLab);
    SY_RELEASE_SAFELY(btnLab);
    SY_RELEASE_SAFELY(lineV);
    SY_RELEASE_SAFELY(_bubbleBackgroundView);
    SY_RELEASE_SAFELY(_textLabel);

    [super dealloc];
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
    _bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:_bubbleBackgroundView];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:titleLab];
    titleLab.font = [UIFont systemFontOfSize:16.0f];
    titleLab.textColor = UIColorFromRGB(0x3aadfb);
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.textLabel setFont:[UIFont systemFontOfSize:Message_Font_Size]];
    
    self.textLabel.numberOfLines = 2;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.bubbleBackgroundView addSubview:_textLabel];
    
    sendTagLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:sendTagLab];
    sendTagLab.text = SY_STRING(@"doc_sponsors");
    sendTagLab.textColor = UIColorFromRGB(0x9b9b9b);
    sendTagLab.font = [UIFont systemFontOfSize:16.0f];
    
    senderLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:senderLab];
    senderLab.font = [UIFont systemFontOfSize:16.0f];
    senderLab.textColor = UIColorFromRGB(0x333333);
    
    timeTagLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:timeTagLab];
    timeTagLab.text = SY_STRING(@"Launch_time");
    timeTagLab.textColor = UIColorFromRGB(0x9b9b9b);
    timeTagLab.font = [UIFont systemFontOfSize:16.0f];
    
    timeLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:timeLab];
    timeLab.font = [UIFont systemFontOfSize:16.0f];
    timeLab.textColor = UIColorFromRGB(0x333333);
    
    lineV = [[UIView alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:lineV];
    lineV.backgroundColor = UIColorFromRGB(0xe3e9ec);
    
    btnLab = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:btnLab];
    btnLab.text = SY_STRING(@"view_details");
    btnLab.textColor = UIColorFromRGB(0x3aadfb);
    
    clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bubbleBackgroundView addSubview:clickBtn];
    [clickBtn addTarget:self action:@selector(lookDetail) forControlEvents:UIControlEventTouchUpInside];
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;

	UILongPressGestureRecognizer *longPress =
	[[UILongPressGestureRecognizer alloc]
	 initWithTarget:self
	 action:@selector(longPressed:)];
	[self.bubbleBackgroundView addGestureRecognizer:longPress];
	[longPress release];
	
    UITapGestureRecognizer *textMessageTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(tapMessageCell:)];
    textMessageTap.numberOfTapsRequired = 1;
    textMessageTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:textMessageTap];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    [textMessageTap release];
    
    [sendTagLab sizeToFit];
    [timeTagLab sizeToFit];
}

- (void)longPressed:(id)sender {
	UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
	if (press.state == UIGestureRecognizerStateEnded) {
		return;
	} else if (press.state == UIGestureRecognizerStateBegan) {
		[self.delegate didLongTouchMessageCell:self.model
										inView:self.bubbleBackgroundView];
	}
}

- (void)tapMessageCell:(UIGestureRecognizer *)gestureRecognizer {
    
    CMPRCV5Message *msg = (CMPRCV5Message*)self.model.content;
    [[CMPChatManager sharedManager] openAccDoc:msg.gotoParam];
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)lookDetail {
    
    
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self changeViewContent:(CMPRCV5Message*)self.model.content];
    [self setAutoLayout];
}

- (void)changeViewContent:(CMPRCV5Message*)msg {
    
    NSString *type = msg.appId;
    NSString *str = @"";
    if ([type integerValue] == 1) {
        str = SY_STRING(@"msg_coll");
    }
    else if ([type integerValue] == 4) {
        str = SY_STRING(@"msg_edoc");
    }
    else if ([type integerValue] == 3) {
        str = SY_STRING(@"msg_doc");
    }
	else if ([type integerValue] == 6){
		
		str = SY_STRING(@"msg_meeting");
	}
    else {
        str = msg.appName;
    }
    
    if (msg.content) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:msg.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [msg.content length])];
        self.textLabel.attributedText = attributedString;
        [paragraphStyle release];
        [attributedString release];
    }
    else {
        self.textLabel.text = @"";
    }

    titleLab.text = str;
    senderLab.text = msg.senderName;
    timeLab.text = msg.sendDate;
}

- (void)setAutoLayout {
    
    CMPRCV5Message *msg = (CMPRCV5Message *)self.model.content;
    NSString *contentStr = [[self class] getContentStr:msg];
    CGSize textLabelSize = [[self class] getTextLabelSize:contentStr];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    CGFloat pointY = 6;
    CGFloat pointX = 17;
    CGFloat tagW = sendTagLab.width;
    CGFloat senderW = 250 - (pointX + tagW);
    if (timeTagLab.width > sendTagLab.width) {
        tagW = timeTagLab.width;
    }
    
    titleLab.frame = CGRectMake(pointX, pointY, 50, 21);
    pointY += 31;
    self.textLabel.frame =
    CGRectMake(pointX, pointY, textLabelSize.width, textLabelSize.height);
    pointY += 7 + textLabelSize.height;
    sendTagLab.frame = CGRectMake(pointX, pointY, tagW, 16);
    senderLab.frame = CGRectMake(pointX + tagW, pointY, senderW, 16);
    pointY += 7 + 16;
    timeTagLab.frame = CGRectMake(pointX, pointY, tagW, 16);
    timeLab.frame = CGRectMake(pointX + tagW, pointY, senderW, 16);
    pointY += 15 + 16;
    lineV.frame = CGRectMake(pointX, pointY, 220, 1);
    btnLab.frame = CGRectMake(pointX, pointY + 12, 75, 16);
    messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
    self.messageContentView.frame = messageContentViewRect;
    self.bubbleBackgroundView.frame = CGRectMake(
                                                 0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);

    UIImage *image = nil;
    if (MessageDirection_RECEIVE == self.messageDirection) {
        
        image = [RCKitUtility imageNamed:@"chat_from_bg_normal"
                                ofBundle:@"RongCloud.bundle"];
       
    } else {
        
        image = [RCKitUtility imageNamed:@"chat_to_bg_white"
                                         ofBundle:@"RongCloud.bundle"];
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + HeadAndContentSpacing +
         [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
    }
    
    self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8,
                                                                                          image.size.width * 0.8,
                                                                                          image.size.height*0.2, image.size.width * 0.8
                                                                                          )];
}


+ (CGSize)getTextLabelSize:(NSString*)str {
    if ([str length] > 0) {
        float maxWidth = 225;
        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
        [paragraphStyle setLineSpacing:6];
        CGRect textRect = [str
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine |
                                    NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName :
                                            [UIFont systemFontOfSize:Message_Font_Size]
                                        ,NSParagraphStyleAttributeName:paragraphStyle}
                           context:nil];
        
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        
        if (textRect.size.height > 45) {
            textRect.size.height = 45;
        }
        return CGSizeMake(textRect.size.width, textRect.size.height);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);
    
    if (bubbleSize.width + 12 + 20 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 20;
    } else {
        bubbleSize.width = 50;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }
    
    bubbleSize.width = 255.0f;
    bubbleSize.height += 40;
    bubbleSize.height += 40;
    bubbleSize.height += 40;

    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CMPRCV5Message *)message {
    
    CGSize textLabelSize = [[self class] getTextLabelSize:[[self class] getContentStr:message]];
    return [[self class] getBubbleSize:textLabelSize];
}

+ (NSString*)getContentStr:(CMPRCV5Message*)msg {
    
    if ([NSString isNull:msg.content]) {
        return @"";
    }
    return msg.content;
}

@end

