//
//  CMPRCConvertMissionCell.m
//  M3
//
//  Created by 曾祥洁 on 2018/9/27.
//

#import "CMPRCConvertMissionCell.h"
#import "CMPRCSystemImMessage.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSObject+JSON.h>
@interface CMPRCConvertMissionCell () {
    UIImageView *_bubbleBackgroundView;
    UILabel *_typeLabel;            //类型
    UILabel *_contentLabel;         //内容
    UILabel *_targetNameLabel;      //负责人
    UIView  *_cutLine;              //分割线
    UILabel *_detailsLabel;         //查看详情
    UILabel *_senderLabel;
    UILabel *_timeLabel;
}

@end
@implementation CMPRCConvertMissionCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    
    CGSize size = [CMPRCConvertMissionCell getBubbleBackgroundViewSize];
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
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] init];
        [self.messageContentView addSubview:_bubbleBackgroundView];
        _bubbleBackgroundView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
        [_bubbleBackgroundView addGestureRecognizer:longPress];
        UITapGestureRecognizer *textMessageTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
        textMessageTap.numberOfTapsRequired = 1;
        textMessageTap.numberOfTouchesRequired = 1;
        [_bubbleBackgroundView addGestureRecognizer:textMessageTap];
    }
    
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = UIColorFromRGB(0x999999);
        _typeLabel.font = FONTSYS(16);
        _typeLabel.backgroundColor = [UIColor clearColor];
        [_bubbleBackgroundView addSubview:_typeLabel];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = UIColorFromRGB(0x1b4086);
        _contentLabel.font = FONTSYS(14);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 2;
        [_bubbleBackgroundView addSubview:_contentLabel];
    }
    if (!_senderLabel) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.textColor = UIColorFromRGB(0x999999);
        _senderLabel.font = FONTSYS(14);
        _senderLabel.backgroundColor = [UIColor clearColor];
        [_bubbleBackgroundView addSubview:_senderLabel];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorFromRGB(0x999999);
        _timeLabel.font = FONTSYS(14);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        [_bubbleBackgroundView addSubview:_timeLabel];
    }
}


- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    CMPRCSystemImMessage *message = (CMPRCSystemImMessage *)model.content;
    CMPRCSystemImMessageExtraMessage *extraMessage = message.extraData.message;
    
    if (message.category == RCSystemImMessageCategoryTask) {
        _typeLabel.text = @"任务通知";
        _contentLabel.text = message.content ?: @"";
        if (![NSString isNull:message.sendName]) {
            _senderLabel.text = [NSString stringWithFormat:@"%@%@", SY_STRING(@"rc_task_principal"), message.sendName];
        } else {
            NSDictionary *messageDic = extraMessage.extra;
            if (![messageDic isKindOfClass:[NSDictionary class]]) {
                return;
            }
            // 责任人数组
            NSString *managers = messageDic[@"managers"] ?: @"";
            _senderLabel.text = [NSString stringWithFormat:@"%@%@", SY_STRING(@"rc_task_principal"), managers];
        }
        if (![message.sendTime isKindOfClass:[NSNull class]]) {
            _timeLabel.text = [self getTimeStringWithString:extraMessage.t withFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        }
    } else if (message.category == RCSystemImMessageCategoryColHasten) {
        _typeLabel.text = @"催办通知";
        _contentLabel.text = message.content ?: @"";
        if (![NSString isNull:message.sendName]) {
            _senderLabel.text = [NSString stringWithFormat:@"%@", message.sendName];
        } else {
            _senderLabel.text = extraMessage.sn;
        }
        _timeLabel.text = [self getTimeStringWithString:extraMessage.t withFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    [self setAutoLayout];
}


- (void)setAutoLayout{
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize];
    CGRect messageContentViewRect = self.messageContentView.frame;
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        self.messageContentView.frame = messageContentViewRect;
        [_typeLabel setFrame:CGRectMake(16, 10, 245,_typeLabel.font.lineHeight)];
        [_contentLabel setFrame:CGRectMake(16, 40, 245,40)];
        [_senderLabel setFrame:CGRectMake(16, 90, 160,_senderLabel.font.lineHeight)];
        [_timeLabel setFrame:CGRectMake(176, _senderLabel.cmp_top, 85,_timeLabel.font.lineHeight)];
        _bubbleBackgroundView.frame = CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        _bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8,image.size.width * 0.8,image.size.height*0.2, image.size.width * 0.8)];
        
    } else {
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + HeadAndContentSpacing +
         [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        [_typeLabel setFrame:CGRectMake(10, 10, 245,_typeLabel.font.lineHeight)];
        [_contentLabel setFrame:CGRectMake(10, 40, 245,40)];
        [_senderLabel setFrame:CGRectMake(10, 90, 160,_senderLabel.font.lineHeight)];
        [_timeLabel setFrame:CGRectMake(170, _senderLabel.cmp_top, 85,_timeLabel.font.lineHeight)];
        _bubbleBackgroundView.frame = CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_white" ofBundle:@"RongCloud.bundle"];
        _bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8,image.size.width * 0.5,image.size.height*0.2, image.size.width * 0.5)];
    }
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

+ (CGSize)getBubbleSize {
    CGSize bubbleSize = CGSizeMake(271, 130);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize {
    return [[self class] getBubbleSize];
}

- (NSString *)getTimeStringWithString:(NSString *)aStr withFormat:(NSString *)format{
    NSDateFormatter *originFormat = [[NSDateFormatter alloc]init];
    [originFormat setDateFormat:format];
    NSDate *date = [originFormat dateFromString:aStr];
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    NSString *strDiff = nil;
    if(isToday) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"HH:mm";
        NSString *string = [fmt stringFromDate:date];
        strDiff= string;
    }else{
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MM-dd";
        NSString *string = [fmt stringFromDate:date];
        strDiff= string;
    }
    return strDiff;
}


- (void)setLabel:(UILabel *)label Text:(NSString*)text lineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing < 0.01 || !text) {
        label.text = text;
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, [text length])];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:label.lineBreakMode];
    [paragraphStyle setAlignment:label.textAlignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    label.attributedText = attributedString;
}


@end
