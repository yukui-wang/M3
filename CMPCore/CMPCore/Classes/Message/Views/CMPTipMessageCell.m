//
//  CMPTipMessageCell.m
//  CMPCore
//
//  Created by CRMO on 2017/9/8.
//
//

#import "CMPTipMessageCell.h"
#import "CMPRCGroupNotificationObject.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/NSObject+JSON.h>
#import "RCGroupNotificationMessage+Format.h"


@implementation CMPTipMessageCell

- (void)setDataModel:(RCMessageModel *)model {
     [super setDataModel:model];
    RCMessageContent *content = model.content;
    if (![content isKindOfClass:[RCGroupNotificationMessage class]]) {
        return;
    }

    RCGroupNotificationMessage *message = (RCGroupNotificationMessage *)content;
    NSString *operation = message.operation;
    
    if ([operation isEqualToString:CMPRCGroupNotificationOperationReplacement]) { // 群主变更
        self.tipMessageLabel.text = [message replacementMessage];
        [self layoutTipLabel];
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationBulletin]) { // 群公告变更
        self.tipMessageLabel.text = SY_STRING(@"msg_rebulletin");
        [self layoutTipLabel];
    }
}

- (void)layoutTipLabel {
    RCTipLabel *tipLabel = self.tipMessageLabel;
    CGSize size = [CMPTipMessageCell getTextLabelSize:tipLabel.text];
    CGFloat viewWidth = self.bounds.size.width;
    tipLabel.frame = CGRectMake((viewWidth - size.width - 15) / 2, 10, size.width + 15, size.height + 1);
}

+ (CGSize)getTextLabelSize:(NSString *)message {
    if ([message length] > 0) {
        float maxWidth =
        [UIScreen mainScreen].bounds.size.width -
        (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 -
        35;
        CGRect textRect = [message
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine |
                                    NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{
                                        NSFontAttributeName :
                                            [UIFont systemFontOfSize:14]
                                        }
                           context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}


+ (CGSize)sizeForMessageModel:(RCMessageModel *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    RCMessageContent *content = model.content;
    if (![content isKindOfClass:[RCGroupNotificationMessage class]]) {
        return [super sizeForMessageModel:model withCollectionViewWidth:collectionViewWidth referenceExtraHeight:extraHeight];
    }
    
    RCGroupNotificationMessage *message = (RCGroupNotificationMessage *)content;
    NSString *operation = message.operation;
    if ([operation isEqualToString:CMPRCGroupNotificationOperationReplacement]) { // 群主变更
        CGSize size = [CMPTipMessageCell getTextLabelSize:[message replacementMessage]];
        return CGSizeMake([[UIScreen mainScreen] bounds].size.width, size.height + 21);
    } else {
        return [super sizeForMessageModel:model withCollectionViewWidth:collectionViewWidth referenceExtraHeight:extraHeight];
    }
}

@end
