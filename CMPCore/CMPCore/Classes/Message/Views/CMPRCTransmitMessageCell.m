//
//  CMPRCTransmitMessageCell.m
//  M3
//
//  Created by wujiansheng on 2018/7/2.
//

#import "CMPRCTransmitMessageCell.h"
#import "CMPRCTransmitMessage.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSDate+CMPDate.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPRCTransmitMessageCell () {
    UIImageView *_bubbleBackgroundView;
    UILabel *_typeLabel;
    UILabel *_contentLabel;
    UILabel *_senderLabel;
    UILabel *_timeLabel;
    UIView  *_lineView;
    UILabel *_showLabel;
}

@end

@implementation CMPRCTransmitMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CMPRCTransmitMessage *msg = (CMPRCTransmitMessage *)model.content;
    CGSize size = [CMPRCTransmitMessageCell getBubbleBackgroundViewSize:msg];
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)dealloc {
    SY_RELEASE_SAFELY(_bubbleBackgroundView);
    SY_RELEASE_SAFELY(_typeLabel);
    SY_RELEASE_SAFELY(_contentLabel);
    SY_RELEASE_SAFELY(_senderLabel);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_lineView);
    SY_RELEASE_SAFELY(_showLabel);

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
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] init];
        [self.messageContentView addSubview:_bubbleBackgroundView];
        _bubbleBackgroundView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
        [_bubbleBackgroundView addGestureRecognizer:longPress];
        [longPress release];
        UITapGestureRecognizer *textMessageTap =  [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)] autorelease];
        textMessageTap.numberOfTapsRequired = 1;
        textMessageTap.numberOfTouchesRequired = 1;
        [_bubbleBackgroundView addGestureRecognizer:textMessageTap];
    }
    
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = UIColorFromRGB(0x666666);
        _typeLabel.font = FONTSYS(16);
        _typeLabel.backgroundColor = [UIColor clearColor];
        [_bubbleBackgroundView addSubview:_typeLabel];
    }
    if (!_contentLabel) {
        //最多三行，自适应高度
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.font = FONTSYS(14);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 3;
        [_bubbleBackgroundView addSubview:_contentLabel];
    }
    if (!_senderLabel) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.textColor = UIColorFromRGB(0x666666);
        _senderLabel.font = FONTSYS(14);
        _senderLabel.backgroundColor = [UIColor clearColor];
        [_bubbleBackgroundView addSubview:_senderLabel];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorFromRGB(0x666666);
        _timeLabel.font = FONTSYS(14);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [_bubbleBackgroundView addSubview:_timeLabel];
    }
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xd4d4d4);
        [_bubbleBackgroundView addSubview:_lineView];
    }
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] init];
        _showLabel.textColor = [CMPThemeManager sharedManager].themeColor;
        _showLabel.font = FONTSYS(14);
        _showLabel.textAlignment = NSTextAlignmentCenter;
        _showLabel.backgroundColor = [UIColor clearColor];
        _showLabel.text = SY_STRING(@"view_details");
        [_bubbleBackgroundView addSubview:_showLabel];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    CMPRCTransmitMessage *message = (CMPRCTransmitMessage *)model.content;
    if (![NSString isNull:message.title]) {
        _typeLabel.text = message.title;
    }
    
    if (![NSString isNull:message.content]) {
        _contentLabel.text = message.content;
    }
    
    if (![NSString isNull:message.sendName]) {
        NSString *sendName = nil;
        if ([message.appId integerValue] == 30) {
            sendName = [NSString stringWithFormat:@"%@%@", SY_STRING(@"rc_task_principal"), message.sendName];
        } else {
            sendName = message.sendName;
        }
        _senderLabel.text = sendName;
    }
    
    if (![message.sendTime isKindOfClass:[NSNull class]]) {
        // 当天时间显示时分（14:42）
        // 非当天时间显示日期
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.sendTime.longLongValue / 1000];
        if ([date cmp_isToday]) {
            _timeLabel.text = [CMPDateHelper strFromDate:date formatter:kDateFormate_HH_MM];
        } else {
            _timeLabel.text = [CMPDateHelper strFromDate:date formatter:kDateFormate_YYYY_MM_DD];
        }
    }
    
    BOOL showDetail = [[self class] canShowDetail:message];
    _lineView.hidden = !showDetail;
    _showLabel.hidden = !showDetail;
    [self setAutoLayout];
}

- (void)setAutoLayout{
    CMPRCTransmitMessage *message = (CMPRCTransmitMessage *)self.model.content;
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:message];
    CGSize contentSize = [[self class] getContentSize:message];
    CGRect messageContentViewRect = self.messageContentView.frame;
    messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
    messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
    CGFloat leftMarg = 0;
    CGFloat rightMarg = 0;
    CGFloat timeMarg = 0;
    UIImage *image = nil;
    UIEdgeInsets  edgeInsets;
    if (MessageDirection_RECEIVE == self.messageDirection) {
        leftMarg = 7;
        image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        edgeInsets = UIEdgeInsetsMake(image.size.height * 0.8,image.size.width * 0.8,image.size.height*0.2, image.size.width * 0.8);
    }
    else {
        rightMarg = 6;
        timeMarg = 6;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + HeadAndContentSpacing +
         [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        
        image = [RCKitUtility imageNamed:@"chat_to_bg_white" ofBundle:@"RongCloud.bundle"];
        edgeInsets = UIEdgeInsetsMake(image.size.height * 0.8,image.size.width * 0.5,image.size.height*0.2, image.size.width * 0.5);
    }
    
    [_typeLabel setFrame:CGRectMake(10+leftMarg, 10, 245,_typeLabel.font.lineHeight)];
    [_contentLabel setFrame:CGRectMake(10+leftMarg, 40, contentSize.width,contentSize.height)];
    CGFloat y = CGRectGetMaxY(_contentLabel.frame)+10;
    [_senderLabel setFrame:CGRectMake(10+leftMarg, y, 160,_senderLabel.font.lineHeight)];
    [_timeLabel setFrame:CGRectMake(bubbleBackgroundViewSize.width-timeMarg-129, y, 120,_timeLabel.font.lineHeight)];
    if (!_lineView.hidden) {
        [_lineView setFrame:CGRectMake(leftMarg, bubbleBackgroundViewSize.height-36.5, bubbleBackgroundViewSize.width-leftMarg-rightMarg-2, 0.5)];
        y = CGRectGetMaxY(_lineView.frame)+0.5;
        [_showLabel setFrame:CGRectMake(10+leftMarg, y+2, bubbleBackgroundViewSize.width-20+leftMarg-rightMarg, bubbleBackgroundViewSize.height-y-5)];
    }
    self.messageContentView.frame = messageContentViewRect;
    _bubbleBackgroundView.frame = CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
    _bubbleBackgroundView.image = [image resizableImageWithCapInsets:edgeInsets];
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model
                                        inView:_bubbleBackgroundView];
    }
}


- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {    
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

+ (BOOL)canShowDetail:(CMPRCTransmitMessage *)msg {
    if (msg.actionType && msg.actionType.integerValue == 0) {
        return NO;//0：只读
    }
    return YES;//1：可穿透
}


+ (CGSize)getContentSize:(CMPRCTransmitMessage *)msg {
    NSString *content = msg.content;
    UIFont *font = FONTSYS(16);
    CGFloat fontHeight = font.lineHeight;
    NSInteger heigth = 16;
    NSInteger maxHeight = ceilf(fontHeight *3);//最多3行
    if (![NSString isNull:content]) {
        CGSize size = [content sizeWithFontSize:font defaultSize:CGSizeMake(220, 10000)];
        heigth = MIN(maxHeight, size.height);
    }
    CGSize bubbleSize = CGSizeMake(220, heigth);
    return bubbleSize;
}


+ (CGSize)getBubbleSize:(CMPRCTransmitMessage *)msg {
    CGSize size = [[self class] getContentSize:msg];
    CGFloat height = size.height +40;
    height += [[self class] canShowDetail:msg] ?74: 37;
    CGSize bubbleSize = CGSizeMake(246, height);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CMPRCTransmitMessage *)msg {
    return [[self class] getBubbleSize:msg];
}

@end
