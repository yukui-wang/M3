//
//  CMPBusinessCardMessageCell.m
//  M3
//
//  Created by 程昆 on 2019/10/24.
//

#import "CMPBusinessCardMessageCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIView+CMPView.h>
#import "CMPBusinessCardMessage.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPFaceView.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/TTTAttributedLabel.h>

#define RCCOMBINECELLWIDTH 273.0f
#define RCCOMBINELABLEOFFSET 0.0f
#define RCCOMBINEARROWWIDTH 5.0f
#define RCCOMBINELABLESPACING 16.0f

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface CMPBusinessCardMessageCell()

/*!
 消息的背景 View
 */
@property(nonatomic, strong) UIView *backView;

/*!
 展示消息的 个人名片 icon
 */
@property(nonatomic, strong) CMPFaceView *iconImageView;

/*!
 展示消息的 个人名片 姓名
 */
@property(nonatomic, strong) UILabel *nameLabel;

/*!
展示消息的 个人名片 个人简历
*/
@property(nonatomic, strong) TTTAttributedLabel *introductionLabel;

/*!
展示消息的 个人名片 标识名称
*/
@property(nonatomic, strong) UILabel *tagLabel;

@property(nonatomic, strong) UIImageView *shadowMaskView;

@property(nonatomic, strong) UILabel *lineLable;

@property(nonatomic, strong) RCMessageModel *currentModel;

@property(nonatomic, assign) CGFloat titleLableHeight;

@end

@implementation CMPBusinessCardMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    CMPBusinessCardMessage *businessCardMessage = (CMPBusinessCardMessage *)model.content;
    __messagecontentview_height = [CMPBusinessCardMessageCell calculateCellHeight:businessCardMessage];
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(CMPBusinessCardMessage *)businessCardMessage {
    return 101+11;
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
    self.allowsSelection = NO;
    [self.messageContentView addSubview:self.backView];
    [self.backView addSubview:self.iconImageView];
    [self.backView addSubview:self.nameLabel];
    [self.backView addSubview:self.introductionLabel];
    [self.backView addSubview:self.lineLable];
    [self.backView addSubview:self.tagLabel];
    [self addGestureRecognizer];
    self.messageActivityIndicatorView = nil;
}

- (void)addGestureRecognizer {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.backView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *backViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap:)];
    backViewTap.numberOfTapsRequired = 1;
    backViewTap.numberOfTouchesRequired = 1;
    [self.backView addGestureRecognizer:backViewTap];
    self.backView.userInteractionEnabled = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)backViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

#pragma mark - setModel
- (void)setDataModel:(RCMessageModel *)model {
    if (!model) {
        return;
    }
    [super setDataModel:model];
    self.currentModel = model;
    [self resetSubViews];
    CMPBusinessCardMessage *businessCardMessage = (CMPBusinessCardMessage *)model.content;
    
    self.nameLabel.text =  businessCardMessage.name;
    
    NSString *department = [NSString isNotNull:businessCardMessage.department] ? businessCardMessage.department : @"";
    NSString *post = [NSString isNotNull:businessCardMessage.post] ? businessCardMessage.post : @"";
    self.introductionLabel.text = [NSString stringWithFormat:@"%@\n%@",post,department];

//    NSString *imageUrlStr = [[CMPCore memberIconUrlWithId:businessCardMessage.personnelID] urlCFEncoded];
//    NSURL *imageUrl = [NSURL URLWithString:imageUrlStr];
//    [self.iconImageView sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
    SyFaceDownloadObj *obj = [[SyFaceDownloadObj alloc] init] ;
    obj.serverId = [CMPCore sharedInstance].serverID;
    obj.memberId = businessCardMessage.personnelId;
    obj.downloadUrl = [CMPCore memberIconUrlWithId:obj.memberId];
    self.iconImageView.memberIcon = obj;
    
    [self calculateContenViewSize:businessCardMessage];
    [self setDestructViewLayout];
}

- (void)resetSubViews {
    self.nameLabel.text = nil;
    self.introductionLabel.text = nil;
}

- (void)calculateContenViewSize:(CMPBusinessCardMessage *)businessCardMessage {
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage *maskImage = nil;
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
        maskImage = [UIImage cmp_autoImageNamed:@"chat_from_bg"];
        maskImage = [maskImage
                     resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.8,
                                                                  maskImage.size.height * 0.2, maskImage.size.width * 0.2)];
    } else {
        maskImage = [UIImage cmp_autoImageNamed:@"chat_to_bg"];
        maskImage = [maskImage
                     resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.2,
                                                                  maskImage.size.height * 0.2, maskImage.size.width * 0.8)];
        messageContentViewRect.origin.x = self.baseContentView.bounds.size.width - (RCCOMBINECELLWIDTH + HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
    }
    CGFloat messageContentViewHeight;
    messageContentViewHeight = [CMPBusinessCardMessageCell calculateCellHeight:businessCardMessage];
    messageContentViewRect.size = CGSizeMake(RCCOMBINECELLWIDTH, messageContentViewHeight);
    self.messageContentView.frame = messageContentViewRect;
    [self autoLayoutSubViews];
    [self setMaskImage:maskImage];
}

- (void)autoLayoutSubViews{
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
        self.backView.frame = CGRectMake(RCCOMBINEARROWWIDTH + RCCOMBINELABLEOFFSET, 0, self.messageContentView.frame.size.width - RCCOMBINEARROWWIDTH - RCCOMBINELABLEOFFSET * 2, self.messageContentView.frame.size.height) ;
    }else {
        self.backView.frame = CGRectMake(RCCOMBINELABLEOFFSET, 0, self.messageContentView.frame.size.width - RCCOMBINEARROWWIDTH - RCCOMBINELABLEOFFSET * 2, self.messageContentView.frame.size.height) ;
    }
    self.iconImageView.frame = CGRectMake(RCCOMBINELABLESPACING, 10, 50, 50);
    self.nameLabel.frame = CGRectMake(self.iconImageView.cmp_right + 10, 10, self.backView.frame.size.width - RCCOMBINELABLESPACING * 2 - self.iconImageView.cmp_width - 10, 22);
    self.introductionLabel.frame = CGRectMake(self.nameLabel.cmp_left, self.nameLabel.cmp_bottom + 2, self.nameLabel.cmp_width, 18+20);
    self.lineLable.frame = CGRectMake(0, self.introductionLabel.cmp_bottom + 8, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
    self.tagLabel.frame = CGRectMake(self.iconImageView.cmp_left, self.lineLable.cmp_bottom + 6, self.backView.frame.size.width - RCCOMBINELABLESPACING * 2, 18);
}

- (void)setDestructViewLayout {
    RCCombineMessage *combineMessage = (RCCombineMessage *)self.model.content;
    if (combineMessage.destructDuration > 0 && [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId]) {
        self.destructView.hidden = NO;
        if (self.messageDirection == MessageDirection_RECEIVE) {
            self.messageHasReadStatusView.frame = CGRectMake(9, 0, 25, 25);
            self.destructView.frame = CGRectMake(CGRectGetMaxX(self.backView.frame)+4.5, CGRectGetMaxY(self.backView.frame)-13-8.5, 21, 12);
        } else {
            self.messageHasReadStatusView.frame = CGRectMake(9-24, 0, 25, 25);
            self.destructView.frame = CGRectMake(CGRectGetMinX(self.backView.frame)-25.5, CGRectGetMaxY(self.backView.frame)-13-8.5, 21, 12);
        }
    } else {
        self.destructView.hidden = YES;
        self.destructView.frame = CGRectZero;
        self.messageHasReadStatusView.frame = CGRectMake(9, 0, 25, 25);
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        NSLog(@"long press end");
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.backView];
    }
}

- (void)setMaskImage:(UIImage *)maskImage {
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];
    
    _shadowMaskView.frame = CGRectMake(-0.2, -0.2, self.messageContentView.frame.size.width + 1.2, self.messageContentView.frame.size.height + 1.2);
    [self.messageContentView addSubview:_shadowMaskView];
    [self.messageContentView bringSubviewToFront:self.backView];
}

#pragma mark - lazyload
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.userInteractionEnabled = NO;
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (CMPFaceView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[CMPFaceView alloc] init];
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.layer.cornerRadius = 25;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    return _nameLabel;
}

- (UILabel *)introductionLabel {
    if(!_introductionLabel) {
        _introductionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _introductionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _introductionLabel.numberOfLines = 0;
        _introductionLabel.textAlignment = NSTextAlignmentLeft;
        _introductionLabel.backgroundColor = [UIColor clearColor];
        _introductionLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
        _introductionLabel.lineSpacing = 5;
    }
    return _introductionLabel;
}

- (UILabel *)lineLable {
    if(!_lineLable) {
        _lineLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLable.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    }
    return _lineLable;
}

- (UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _tagLabel.textAlignment = NSTextAlignmentLeft;
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _tagLabel.text = SY_STRING(@"rc_msg_business_card_name");
    }
    return _tagLabel;
}

+ (NSString *)getCombineMessageSummaryTitle:(RCCombineMessage *)message {
    if (!message) {
        return @"";
    }
    NSString * title = @"";
    if (message.conversationType == ConversationType_GROUP) {
        title = NSLocalizedStringFromTable(@"GroupChatHistory", @"RongCloudKit", nil);
        title = [NSString stringWithFormat:@"%@%@",message.nameList.firstObject,SY_STRING(@"rc_group_chat_record")];
    }else {
        if (message.nameList && message.nameList.count > 1) {
            title= [NSString stringWithFormat:NSLocalizedStringFromTable(@"ChatHistoryForXAndY",@"RongCloudKit", nil),[message.nameList firstObject],[message.nameList lastObject]];
        }else if(message.nameList && message.nameList.count == 1){
            title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"ChatHistoryForX",@"RongCloudKit", nil),[message.nameList firstObject]];
        }
    }
    return title;
}

+ (CGFloat)getTitleLableHeightWithMessageModel:(RCCombineMessage *)combineMessage {
    NSString * title = [CMPBusinessCardMessageCell getCombineMessageSummaryTitle:combineMessage];
    CGFloat height = [title getHeightWithWidth:RCCOMBINECELLWIDTH - RCCOMBINELABLESPACING  font:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
    return height;
}

#pragma clang diagnostic pop

@end
