//
//  RCReferencedContentView.m
//  RongIMKit
//
//  Created by 张改红 on 2020/2/27.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCReferencedContentView.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"
#import "RCUserInfoCacheManager.h"
#define leftLine_bottom_space 10
#define leftLine_left_space 15
#define leftLine_width 3
#define name_and_leftLine_space 6
#define name_height 15

@interface RCReferencedContentView () <RCAttributedLabelDelegate>
@property (nonatomic, strong) RCMessageModel *referModel;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) UIView *contentView;
@end
@implementation RCReferencedContentView
- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectZero;
    }
    return self;
}

- (void)setMessage:(RCMessageModel *)message contentSize:(CGSize)contentSize {
    [self resetReferencedContentView];
    self.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.referModel = message;
    self.contentSize = contentSize;
    [self addNotification];
    [self setUserDisplayName];
    [self setContentInfo];
    [self setupSubviews];
}
#pragma mark - RCAttributedLabelDelegate
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
    if ([content.referMsg isKindOfClass:[RCTextMessage class]] ||
        [content.referMsg isKindOfClass:[RCReferenceMessage class]]) {
        if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithURL:)]) {
            [self.delegate attributedLabel:label didSelectLinkWithURL:url];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didTapReferencedContentView:)]) {
            [self.delegate didTapReferencedContentView:self.referModel];
        }
    }
}

- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
    if ([content.referMsg isKindOfClass:[RCTextMessage class]] ||
        [content.referMsg isKindOfClass:[RCReferenceMessage class]]) {
        if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithPhoneNumber:)]) {
            [self.delegate attributedLabel:label didSelectLinkWithPhoneNumber:phoneNumber];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didTapReferencedContentView:)]) {
            [self.delegate didTapReferencedContentView:self.referModel];
        }
    }
}

- (void)attributedLabel:(RCAttributedLabel *)label didTapLabel:(NSString *)content {
    if ([self.delegate respondsToSelector:@selector(didTapReferencedContentView:)]) {
        [self.delegate didTapReferencedContentView:self.referModel];
    }
}

#pragma mark - helper
- (void)setContentInfo {
    RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
    if ([content.referMsg isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *msg = (RCFileMessage *)content.referMsg;
        self.textLabel.text = [NSString
            stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:FileMsg", @"RongCloudKit", nil), msg.name];
        self.textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x528EBD) darkColor:HEXCOLOR(0x4EB2FF)];
    } else if ([content.referMsg isKindOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *msg = (RCRichContentMessage *)content.referMsg;
        self.textLabel.text = [NSString
            stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:ImgTextMsg", @"RongCloudKit", nil), msg.title];
        self.textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x528EBD) darkColor:HEXCOLOR(0x4EB2FF)];
    } else if ([content.referMsg isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *msg = (RCImageMessage *)content.referMsg;
        self.msgImageView.image = msg.thumbnailImage;
        CGSize imageSize = [self getImageSize:msg];
        self.msgImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    } else if ([content.referMsg isKindOfClass:[RCTextMessage class]] ||
               [content.referMsg isKindOfClass:[RCReferenceMessage class]]) {
        // 设置 text 之前设置 textColor，textLabel 的 attributeDictionary 设置才有效
        self.textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x262626) darkColor:HEXCOLOR(0xe0e0e0)];
        self.textLabel.text = [RCKitUtility formatMessage:content.referMsg
                                                 targetId:self.referModel.targetId
                                         conversationType:self.referModel.conversationType
                                             isAllMessage:YES];
    } else if ([content.referMsg isKindOfClass:[RCMessageContent class]]) {
        self.textLabel.text = [RCKitUtility formatMessage:content.referMsg
                                                 targetId:self.referModel.targetId
                                         conversationType:self.referModel.conversationType
                                             isAllMessage:YES];
        if (self.textLabel.text.length <= 0 ||
            [self.textLabel.text isEqualToString:[[content.referMsg class] getObjectName]]) {
            self.textLabel.text = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
        }
        self.textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x262626) darkColor:HEXCOLOR(0xe0e0e0)];
    }
}

- (void)setupSubviews {
    [self addSubview:self.leftLimitLine];
    [self addSubview:self.bottomLimitLine];
    [self addSubview:self.nameLabel];
    [self addSubview:self.contentView];
    RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
    if ([content.referMsg isKindOfClass:[RCImageMessage class]]) {
        [self.contentView addSubview:self.msgImageView];
    } else if ([content.referMsg isKindOfClass:[RCRichContentMessage class]] ||
               [content.referMsg isKindOfClass:[RCFileMessage class]]) {
        [self.contentView addSubview:self.textLabel];
    } else {
        [self.contentView addSubview:self.textLabel];
    }
}

- (void)resetReferencedContentView {
    // 移除自身加载的全部view.
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    self.msgImageView = nil;
    self.textLabel = nil;
    self.nameLabel = nil;
    self.leftLimitLine = nil;
    self.bottomLimitLine = nil;
    self.contentView = nil;
}

- (void)setUserDisplayName {
    NSString *name;
    if ([self.referModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
        NSString *referUserId = content.referMsgUserId;
        if (ConversationType_GROUP == self.referModel.conversationType) {
            RCUserInfo *userInfo =
                [[RCUserInfoCacheManager sharedManager] getUserInfo:referUserId inGroupId:self.referModel.targetId];
            self.referModel.userInfo = userInfo;
            if (userInfo) {
                name = userInfo.name;
            }
        } else {
            RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:referUserId];
            self.referModel.userInfo = userInfo;
            if (userInfo) {
                name = userInfo.name;
            }
        }
        if ([NSThread isMainThread]) {
            self.nameLabel.text = name;
        } else {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.nameLabel.text = name;
            });
        }
    }
}

- (CGSize)getImageSize:(RCImageMessage *)imageMsg {
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

- (NSDictionary *)attributeDictionary {
    if (self.referModel.messageDirection == MessageDirection_SEND) {
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

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoUpdate:)
                                                 name:RCKitDispatchUserInfoUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupUserInfoUpdate:)
                                                 name:RCKitDispatchGroupUserInfoUpdateNotification
                                               object:nil];
}

- (void)didTapImageView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapReferencedContentView:)]) {
        [self.delegate didTapReferencedContentView:self.referModel];
    }
}

#pragma mark - UserInfo Update
- (void)onUserInfoUpdate:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    if ([self.referModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
        if ([content.referMsgUserId isEqualToString:userInfoDic[@"userId"]]) {
            //重新取一下混合的用户信息
            [self setUserDisplayName];
        }
    }
}

- (void)onGroupUserInfoUpdate:(NSNotification *)notification {
    if (self.referModel.conversationType == ConversationType_GROUP &&
        [self.referModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *content = (RCReferenceMessage *)self.referModel.content;
        NSDictionary *groupUserInfoDic = (NSDictionary *)notification.object;
        if ([self.referModel.targetId isEqualToString:groupUserInfoDic[@"inGroupId"]] &&
            [content.referMsgUserId isEqualToString:groupUserInfoDic[@"userId"]]) {
            //重新取一下混合的用户信息
            [self setUserDisplayName];
        }
    }
}

#pragma mark - getter
- (UIView *)leftLimitLine {
    if (!_leftLimitLine) {
        _leftLimitLine = [[UIView alloc]
            initWithFrame:CGRectMake(0, 0, leftLine_width, self.frame.size.height - 0 - leftLine_bottom_space)];
        if (self.referModel.messageDirection == MessageDirection_SEND) {
            _leftLimitLine.backgroundColor =
                [RCKitUtility generateDynamicColor:HEXCOLOR(0xC1DCEF) darkColor:HEXCOLOR(0x7C7C7C)];
        } else {
            _leftLimitLine.backgroundColor =
                [RCKitUtility generateDynamicColor:HEXCOLOR(0xececed) darkColor:HEXCOLOR(0x7C7C7C)];
        }
        _leftLimitLine.layer.cornerRadius = 2;
        _leftLimitLine.layer.masksToBounds = YES;
    }
    return _leftLimitLine;
}

- (UIView *)bottomLimitLine {
    if (!_bottomLimitLine) {
        _bottomLimitLine =
            [[UIView alloc] initWithFrame:CGRectMake(0, self.contentSize.height - 1, self.contentSize.width, 1)];
        if (self.referModel.messageDirection == MessageDirection_SEND) {
            _bottomLimitLine.backgroundColor =
                [RCKitUtility generateDynamicColor:HEXCOLOR(0xC1DCEF) darkColor:HEXCOLOR(0x7C7C7C)];
        } else {
            _bottomLimitLine.backgroundColor =
                [RCKitUtility generateDynamicColor:HEXCOLOR(0xececed) darkColor:HEXCOLOR(0x7C7C7C)];
        }
    }
    return _bottomLimitLine;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        CGFloat nameX = CGRectGetMaxX(self.leftLimitLine.frame) + name_and_leftLine_space;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, 0, self.contentSize.width - nameX, name_height)];
        if (self.referModel.messageDirection == MessageDirection_SEND) {
            _nameLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x999999) darkColor:HEXCOLOR(0x999999)];
        } else {
            _nameLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x939393) darkColor:HEXCOLOR(0x939393)];
        }

        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        CGFloat contentH = self.contentSize.height - CGRectGetMaxY(self.nameLabel.frame) - leftLine_bottom_space - 5;
        _contentView =
            [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftLimitLine.frame) + name_and_leftLine_space,
                                                     CGRectGetMaxY(self.nameLabel.frame) + 5,
                                                     CGRectGetWidth(self.nameLabel.frame), contentH)];
    }
    return _contentView;
}

- (RCAttributedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[RCAttributedLabel alloc] initWithFrame:self.contentView.bounds];
        _textLabel.attributeDictionary = [self attributeDictionary];
        _textLabel.highlightedAttributeDictionary = [self attributeDictionary];
        [_textLabel setLineBreakMode:NSLineBreakByCharWrapping];
        _textLabel.delegate = self;
        _textLabel.font = [UIFont systemFontOfSize:TextFont];
        _textLabel.numberOfLines = 0;
        _textLabel.userInteractionEnabled = YES;
    }
    return _textLabel;
}

- (UIImageView *)msgImageView {
    if (!_msgImageView) {
        _msgImageView = [[UIImageView alloc] init];
        UITapGestureRecognizer *messageTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        messageTap.numberOfTapsRequired = 1;
        messageTap.numberOfTouchesRequired = 1;
        [_msgImageView addGestureRecognizer:messageTap];
        _msgImageView.userInteractionEnabled = YES;
    }
    return _msgImageView;
}
@end
