//
//  CMPUnknownFolderMessageTipCell.m
//  M3
//
//  Created by 程昆 on 2019/12/4.
//

#import "CMPUnknownFolderMessageTipCell.h"
#import <CMPLib/CMPConstant.h>

@interface CMPUnknownFolderMessageTipCell ()

/*!
 提示的Label
 */
@property(strong, nonatomic) RCTipLabel *messageLabel;

@end

@implementation CMPUnknownFolderMessageTipCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allowsSelection = NO;
        self.messageLabel = [RCTipLabel greyTipLabel];
        [self.baseContentView addSubview:self.messageLabel];
        self.messageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.allowsSelection = NO;
        self.messageLabel = [RCTipLabel greyTipLabel];
        [self.baseContentView addSubview:self.messageLabel];
        self.messageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;

    [self.messageLabel setText:SY_STRING(@"rc_msg_unknown_folder_tip")
           dataDetectorEnabled:NO];

    NSString *__text = self.messageLabel.text;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                    font:[UIFont systemFontOfSize:14.0f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 6);

    self.messageLabel.frame = CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f, 0,
                                         __labelSize.width, __labelSize.height);
}

@end
