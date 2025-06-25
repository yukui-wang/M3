//
//  CMPRCShakeWinMessageCell.m
//  M3
//
//  Created by 曾祥洁 on 2018/10/9.
//

#import "CMPRCShakeWinMessageCell.h"
#import "CMPRCShakeWinMessage.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPCore.h>
@interface CMPRCShakeWinMessageCell () {
//    UIImageView *_bubbleBackgroundView;
//    UIView *_backView;
    RCTipLabel *_tipLabel;
}
@end

@implementation CMPRCShakeWinMessageCell

//+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
//      withCollectionViewWidth:(CGFloat)collectionViewWidth
//         referenceExtraHeight:(CGFloat)extraHeight {
//    
//    CGSize size = [CMPRCShakeWinMessageCell getBubbleBackgroundViewSize];
//    CGFloat __messagecontentview_height = size.height;
//    __messagecontentview_height += extraHeight;
//    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
//}

- (void)dealloc {
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
//    if (!_backView) {
//        _backView = [[UIView alloc] init];
//        _backView.backgroundColor = [UIColor redColor];
//        [self.baseContentView addSubview:_backView];
//    }
    if (!_tipLabel) {
        _tipLabel = [RCTipLabel greyTipLabel];
        [self.baseContentView addSubview:_tipLabel];
        _tipLabel.marginInsets = UIEdgeInsetsMake(0.5f, 5, 0.5f, 5);
    }
}
- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    //CMPRCShakeWinMessage *message = (CMPRCShakeWinMessage *)model.content;
    RCMessageDirection messageDirection = model.messageDirection;
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:model.senderUserId];
    NSString *userName = userInfo.name ?: @"";
    
    NSString *content = @"";
    if (messageDirection == MessageDirection_RECEIVE) {
        content = [NSString stringWithFormat:@"%@%@",userName,NSLocalizedStringFromTable(@"sent you a window jitter", @"Localizable", nil)];
    } else if (messageDirection == MessageDirection_SEND) {
        content = NSLocalizedStringFromTable(@"You sent a window jitter", @"Localizable", nil);
    }
    [_tipLabel setText:content dataDetectorEnabled:NO];
    [self setAutoLayout];
}

- (void)setAutoLayout{
    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    NSString *__text = _tipLabel.text;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                    font:[UIFont systemFontOfSize:14.0f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 6);
    
    _tipLabel.frame = CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f, 10,
                                         __labelSize.width+10, __labelSize.height);
}



#pragma mark- Press Method
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model
                                        inView:_tipLabel];
    }
}
- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

//
//#pragma mark- Class Method
//+ (CGSize)getBubbleSize {
//    CGSize bubbleSize = CGSizeMake(246, 128);
//    return bubbleSize;
//}
//
//+ (CGSize)getBubbleBackgroundViewSize {
//    return [[self class] getBubbleSize];
//}
@end
