//
//  RCReferencingView.m
//  RongIMKit
//
//  Created by 张改红 on 2020/2/27.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCReferencingView.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"
#import "RCUserInfoCacheManager.h"
@interface RCReferencingView ()
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *inView;
@end

#define line_top_space 10
#define line_bottom_space 10
#define line_left_space 15
#define line_width 3
#define name_and_line_space 6
#define dismiss_right_space 15
#define name_height 20
#define dismiss_right 7
#define dismiss_width 18
#define name_and_content_space 7
@implementation RCReferencingView
- (instancetype)initWithModel:(RCMessageModel *)model inView:(UIView *)view {
    if (self = [super init]) {
        self.backgroundColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff) darkColor:HEXCOLOR(0x000000)];
        self.inView = view;
        self.referModel = model;
        [self addNotification];
        [self setUserDisplayName];
        [self setContentInfo];
        [self setupSubviews];
    }
    return self;
}

- (void)setOffsetY:(CGFloat)offsetY {
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect rect = self.frame;
                         rect.origin.y = offsetY;
                         self.frame = rect;
                     }];
}

#pragma mark - privite

- (void)setupSubviews {
    [self addSubview:self.leftLimitLine];
    [self addSubview:self.nameLabel];
    [self addSubview:self.contentView];
    [self addSubview:self.dismissButton];
    CGFloat contentWidth = self.inView.frame.size.width - line_left_space - line_width - name_and_line_space -
                           dismiss_right_space - dismiss_width;
    CGFloat contentHeight = 0;
    if ([self.referModel.content isKindOfClass:[RCImageMessage class]]) {
        [self.contentView addSubview:self.msgImageView];
        CGSize imgSize = [self getImageSize:(RCImageMessage *)self.referModel.content];
        if (imgSize.height > 55) {
            contentHeight = 55;
        } else {
            contentHeight = imgSize.height;
        }
        self.msgImageView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
        self.contentView.contentSize = CGSizeMake(contentWidth, self.msgImageView.frame.size.height);
    } else if ([self.referModel.content isKindOfClass:[RCRichContentMessage class]] ||
               [self.referModel.content isKindOfClass:[RCFileMessage class]]) {
        [self.contentView addSubview:self.textLabel];
        self.textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x2972ab) darkColor:HEXCOLOR(0x2972ab)];
        CGFloat textLabelHeight = [self textHeightWithText:self.textLabel.text];
        if (textLabelHeight > 40) {
            self.textLabel.numberOfLines = 2;
            contentHeight = 40;
        } else {
            contentHeight = textLabelHeight;
        }
        self.textLabel.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    } else {
        [self.contentView addSubview:self.textLabel];
        CGFloat textLabelHeight = [self textHeightWithText:self.textLabel.text];
        if (textLabelHeight > 55) {
            contentHeight = 55;
            self.textLabel.userInteractionEnabled = YES;
        } else {
            contentHeight = textLabelHeight;
        }
        self.textLabel.frame = CGRectMake(0, 0, contentWidth, textLabelHeight);
        self.contentView.contentSize = self.textLabel.frame.size;
    }

    self.frame = CGRectMake(0, self.inView.frame.size.height, self.inView.frame.size.width,
                            line_bottom_space + line_top_space + name_height + contentHeight + name_and_content_space);
    self.leftLimitLine.frame = CGRectMake(line_left_space, line_top_space, line_width,
                                          self.frame.size.height - line_top_space - line_bottom_space);
    self.dismissButton.frame =
        CGRectMake(self.frame.size.width - dismiss_width - dismiss_right, line_top_space, dismiss_width, dismiss_width);
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.leftLimitLine.frame) + name_and_line_space, line_top_space,
                                      CGRectGetMinX(self.dismissButton.frame) -
                                          CGRectGetMaxX(self.leftLimitLine.frame) - name_and_line_space,
                                      name_height);
    self.contentView.frame =
        CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + name_and_content_space,
                   contentWidth, contentHeight);
}

- (void)setContentInfo {
    if ([self.referModel.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *msg = (RCFileMessage *)self.referModel.content;
        self.textLabel.text = [NSString
            stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:FileMsg", @"RongCloudKit", nil), msg.name];
    } else if ([self.referModel.content isKindOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *msg = (RCRichContentMessage *)self.referModel.content;
        self.textLabel.text = [NSString
            stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RC:ImgTextMsg", @"RongCloudKit", nil), msg.title];
    } else if ([self.referModel.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *msg = (RCImageMessage *)self.referModel.content;
        self.msgImageView.image = msg.thumbnailImage;
    } else if ([self.referModel.content isKindOfClass:[RCTextMessage class]] ||
               [self.referModel.content isKindOfClass:[RCReferenceMessage class]]) {
        self.textLabel.text = [RCKitUtility formatMessage:self.referModel.content
                                                 targetId:self.referModel.targetId
                                         conversationType:self.referModel.conversationType
                                             isAllMessage:YES];
    } else if ([self.referModel.content isKindOfClass:[RCMessageContent class]]) {
        self.textLabel.text = [RCKitUtility formatMessage:self.referModel.content
                                                 targetId:self.referModel.targetId
                                         conversationType:self.referModel.conversationType
                                             isAllMessage:YES];
        if (self.textLabel.text.length <= 0 ||
            [self.textLabel.text isEqualToString:[[self.referModel.content class] getObjectName]]) {
            self.textLabel.text = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
        }
    }
}

- (void)didClickDismissButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissReferencingView:)]) {
        [self.delegate dismissReferencingView:self];
    }
}

- (CGFloat)textHeightWithText:(NSString *)text {
    CGFloat maxWidth = self.inView.frame.size.width - line_left_space - line_width - name_and_line_space -
                       dismiss_right_space - dismiss_width;
    CGSize size =
        [RCKitUtility getTextDrawingSize:text font:self.textLabel.font constrainedSize:CGSizeMake(maxWidth, MAXFLOAT)];
    return size.height;
}

- (void)setUserDisplayName {
    NSString *name;
    if (ConversationType_GROUP == self.referModel.conversationType) {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.referModel.senderUserId
                                                                         inGroupId:self.referModel.targetId];
        self.referModel.userInfo = userInfo;
        if (userInfo) {
            name = userInfo.name;
        }
    } else {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.referModel.senderUserId];
        self.referModel.userInfo = userInfo;
        if (userInfo) {
            name = userInfo.name;
        }
    }
    self.nameLabel.text = name;
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

- (void)didTapContentView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapReferencingView:)]) {
        [self.delegate didTapReferencingView:self.referModel];
    }
}

#pragma mark - UserInfo Update
- (void)onUserInfoUpdate:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    if ([self.referModel.senderUserId isEqualToString:userInfoDic[@"userId"]]) {
        //重新取一下混合的用户信息
        [self setUserDisplayName];
    }
}

- (void)onGroupUserInfoUpdate:(NSNotification *)notification {
    if (self.referModel.conversationType == ConversationType_GROUP) {
        NSDictionary *groupUserInfoDic = (NSDictionary *)notification.object;
        if ([self.referModel.targetId isEqualToString:groupUserInfoDic[@"inGroupId"]] &&
            [self.referModel.senderUserId isEqualToString:groupUserInfoDic[@"userId"]]) {
            //重新取一下混合的用户信息
            [self setUserDisplayName];
        }
    }
}
#pragma mark - getter
- (UIView *)leftLimitLine {
    if (!_leftLimitLine) {
        _leftLimitLine =
            [[UIView alloc] initWithFrame:CGRectMake(line_top_space, line_left_space, line_width,
                                                     self.frame.size.height - line_top_space - line_bottom_space)];
        _leftLimitLine.backgroundColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xececed) darkColor:HEXCOLOR(0x7C7C7C)];
        _leftLimitLine.layer.cornerRadius = 2;
        _leftLimitLine.layer.masksToBounds = YES;
    }
    return _leftLimitLine;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x939393) darkColor:HEXCOLOR(0x939393)];
        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
    }
    return _contentView;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setImage:[RCKitUtility imageNamed:@"referencing_view_dismiss_icon" ofBundle:@"RongCloud.bundle"]
                        forState:UIControlStateNormal];
        [_dismissButton addTarget:self
                           action:@selector(didClickDismissButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 0;
        [_textLabel setLineBreakMode:NSLineBreakByCharWrapping];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.textColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x262626) darkColor:HEXCOLOR(0xe0e0e0)];
        UITapGestureRecognizer *messageTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContentView:)];
        messageTap.numberOfTapsRequired = 1;
        messageTap.numberOfTouchesRequired = 1;
        [_textLabel addGestureRecognizer:messageTap];
        _textLabel.userInteractionEnabled = YES;
    }
    return _textLabel;
}

- (UIImageView *)msgImageView {
    if (!_msgImageView) {
        _msgImageView = [[UIImageView alloc] init];
        UITapGestureRecognizer *messageTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContentView:)];
        messageTap.numberOfTapsRequired = 1;
        messageTap.numberOfTouchesRequired = 1;
        [_msgImageView addGestureRecognizer:messageTap];
        _msgImageView.userInteractionEnabled = YES;
    }
    return _msgImageView;
}
@end
