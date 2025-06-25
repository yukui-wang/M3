//
//  CMPBusinessCardMessageCell.m
//  M3
//
//  Created by 程昆 on 2019/10/24.
//

#import "CMPSignInMessageCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/CMPAppListModel.h>
#import <CMPLib/CMPDateHelper.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPThemeManager.h>

#define RCCOMBINECELLWIDTH 273.0f
#define RCCOMBINELABLEOFFSET 0.0f
#define RCCOMBINEARROWWIDTH 5.0f
#define RCCOMBINELABLESPACING 16.0f

NSString * const CMPLocationMarkImageMapApi = @"http://restapi.amap.com/v3/staticmap?location=%f,%f&zoom=%d&scale=%d&size=%@&markers=mid,,A:%f,%f&key=%@";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface CMPSignInMessageCell()

/*!
 消息的背景 View
 */
@property(nonatomic, strong) UIView *backView;

/*!
 展示消息的 签到信息 姓名
 */
@property(nonatomic, strong) UILabel *nameLabel;

/*!
 展示消息的 签到信息 日期
 */
@property(nonatomic, strong) UILabel *dateLabel;

/*!
 展示消息的 签到信息 时间
 */
@property(nonatomic, strong) UILabel *timeLabel;

/*!
 展示消息的 签到信息 签到类型
 */
@property(nonatomic, strong) UILabel *signTypeLabel;

/*!
 展示消息的 签到信息 签到地址图片
 */
@property(nonatomic, strong) UIImageView *addressImageView;

/*!
展示消息的 签到信息 签到地址
*/
@property(nonatomic, strong) UILabel *addressLabel;

/*!
展示消息的 签到信息 标识图片
*/
@property(nonatomic, strong) UIImageView *tagImageView;

/*!
展示消息的 签到信息 标识名称
*/
@property(nonatomic, strong) UILabel *tagLabel;


@property(nonatomic, strong) UILabel *lineLable;
@property(nonatomic, strong) UIImageView *shadowMaskView;

@property(nonatomic, strong) RCMessageModel *currentModel;

@end

@implementation CMPSignInMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    CMPSignMessage *signMessage = (CMPSignMessage *)model.content;
    __messagecontentview_height = [CMPSignInMessageCell calculateCellHeight:signMessage];
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(CMPSignMessage *)signMessage {
    return 209;
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
    [self.backView addSubview:self.nameLabel];
    [self.backView addSubview:self.dateLabel];
    [self.backView addSubview:self.timeLabel];
    [self.backView addSubview:self.signTypeLabel];
    [self.backView addSubview:self.addressImageView];
    [self.backView addSubview:self.addressLabel];
    [self.backView addSubview:self.lineLable];
    [self.backView addSubview:self.tagImageView];
    [self.backView addSubview:self.tagLabel];
    [self addGestureRecognizer];
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
    CMPSignMessage *signMessage = (CMPSignMessage *)model.content;
    long long signTime = signMessage.signTime;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:signTime * 0.001];
    NSString *monthDate = [CMPDateHelper strFromDate:date formatter:@"MM-dd"];
    NSString *weak = [CMPDateHelper getWeekdayString:[CMPDateHelper stringToCFGregorianDate2:[CMPDateHelper dateStrFromLongLong:signTime]]];
    NSString *time = [CMPDateHelper strFromDate:date formatter:@"HH:mm"];
    
    self.nameLabel.text =  signMessage.name;
    self.dateLabel.text = [NSString stringWithFormat:@"%@(%@)",monthDate,weak];
    self.timeLabel.text = time;
    self.signTypeLabel.text = signMessage.signType;
    self.addressImageView.image = [UIImage imageNamed:@"msg_demo_address"];
    self.addressLabel.text = signMessage.address;
    if ([NSString isNull:signMessage.addressImageUrl]) {
        NSString *key = [CMPCommonManager lbsWebAPIKey];
        NSString *mapApi = [NSString stringWithFormat:CMPLocationMarkImageMapApi,signMessage.longitude, signMessage.latitude, 16, 1, @"216*74",signMessage.longitude, signMessage.latitude, key];
        signMessage.addressImageUrl = mapApi;
    }
    if ([NSString isNull:signMessage.appName]) {
        NSString *appList = [CMPCore sharedInstance].currentUser.appList;
        CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
        CMPAppList_2 *appInfo = [appListModel appInfoWithType:@"default" ID:signMessage.messageCategory];
        signMessage.appName = appInfo.appName;
        signMessage.tagImageUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,appInfo.iconUrl];
    }
    [self.addressImageView sd_setImageWithURL:[NSURL URLWithString:signMessage.addressImageUrl] placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
    [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:signMessage.tagImageUrl] placeholderImage:nil options:SDWebImageAllowInvalidSSLCertificates];
    self.tagLabel.text = signMessage.appName;
    [self calculateContenViewSize:signMessage];
    [self setDestructViewLayout];
}

- (void)resetSubViews {
    self.nameLabel.text = nil;
    self.addressLabel.text = nil;
}

- (void)calculateContenViewSize:(CMPSignMessage *)signMessage {
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
    messageContentViewHeight = [CMPSignInMessageCell calculateCellHeight:signMessage];
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
    
    CGFloat dateLabelWidth = [self.dateLabel.text getWidthWithHeight:18 font:self.dateLabel.font];
    CGFloat nameLabelWidth = [self.nameLabel.text getWidthWithHeight:18 font:self.nameLabel.font];
    CGFloat maxNameLabelWidth = self.backView.frame.size.width - RCCOMBINELABLESPACING * 2 - dateLabelWidth - 6;
    if (nameLabelWidth > maxNameLabelWidth) {
        nameLabelWidth = maxNameLabelWidth;
    }
   
    self.nameLabel.frame = CGRectMake(RCCOMBINELABLESPACING, 14, nameLabelWidth, 18);
    self.dateLabel.frame = CGRectMake(self.nameLabel.cmp_right + 6, self.nameLabel.cmp_top, self.backView.frame.size.width - self.nameLabel.cmp_right - 6 - RCCOMBINELABLESPACING, self.nameLabel.cmp_height);
    self.timeLabel.frame = CGRectMake(self.nameLabel.cmp_left, self.nameLabel.cmp_bottom + 4,  [self.timeLabel.text getWidthWithHeight:30 font:self.timeLabel.font], 30);
    self.signTypeLabel.frame = CGRectMake(self.timeLabel.cmp_right + 10, self.nameLabel.cmp_bottom + 10,  self.backView.frame.size.width - self.timeLabel.cmp_right - 10 - RCCOMBINELABLESPACING, 18);
    self.addressImageView.frame = CGRectMake(self.nameLabel.cmp_left, self.timeLabel.cmp_bottom + 4, self.backView.frame.size.width - RCCOMBINELABLESPACING * 2, 74);
    self.addressLabel.frame = CGRectMake(self.nameLabel.cmp_left, self.addressImageView.cmp_bottom + 6, self.backView.frame.size.width - RCCOMBINELABLESPACING * 2, 20);
    self.lineLable.frame = CGRectMake(0, self.addressLabel.cmp_bottom + 8, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
    self.tagImageView.frame = CGRectMake(self.nameLabel.cmp_left, self.lineLable.cmp_bottom + 6, 18, 18);
    self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 6, self.backView.frame.size.width - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING , 18);
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

- (UIImageView *)addressImageView {
    if (!_addressImageView) {
        _addressImageView = [[UIImageView alloc] init];
    }
    return _addressImageView;
}

- (UILabel *)nameLabel {
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    }
    return _nameLabel;
}

- (UILabel *)dateLabel {
    if(!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _dateLabel.numberOfLines = 1;
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    }
    return _dateLabel;
}

- (UILabel *)timeLabel {
    if(!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightRegular];
        _timeLabel.numberOfLines = 1;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    return _timeLabel;
}

- (UILabel *)signTypeLabel {
    if(!_signTypeLabel) {
        _signTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signTypeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _signTypeLabel.numberOfLines = 1;
        _signTypeLabel.textAlignment = NSTextAlignmentLeft;
        _signTypeLabel.backgroundColor = [UIColor clearColor];
        _signTypeLabel.textColor = [UIColor cmp_colorWithName:@"theme-fc"];
    }
    return _signTypeLabel;
}

- (UILabel *)addressLabel {
    if(!_addressLabel) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _addressLabel.numberOfLines = 0;
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    }
    return _addressLabel;
}

- (UILabel *)lineLable {
    if(!_lineLable) {
        _lineLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLable.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    }
    return _lineLable;
}

- (UIImageView *)tagImageView {
    if (!_tagImageView) {
        _tagImageView = [[UIImageView alloc] init];
        _tagImageView.layer.masksToBounds = YES;
        _tagImageView.layer.cornerRadius = 9;
    }
    return _tagImageView;
}

- (UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _tagLabel.textAlignment = NSTextAlignmentLeft;
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
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
    NSString * title = [CMPSignInMessageCell getCombineMessageSummaryTitle:combineMessage];
    CGFloat height = [title getHeightWithWidth:RCCOMBINECELLWIDTH - RCCOMBINELABLESPACING  font:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
    return height;
}

#pragma clang diagnostic pop

@end
