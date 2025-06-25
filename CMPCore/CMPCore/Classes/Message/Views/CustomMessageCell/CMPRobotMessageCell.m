//
//  CMPRobotMessageCell.m
//  M3
//
//  Created by Shoujian Rao on 2022/2/21.
//

#import "CMPRobotMessageCell.h"
#import "M3-Swift.h"
#import "CMPRobotMsg.h"
#import <CMPLib/CMPConstant.h>

#define RCCOMBINECELLWIDTH_robot 273.0f
#define RCCOMBINELABLEOFFSET_robot 0.0f
#define RCCOMBINEARROWWIDTH_robot 5.0f
#define RCCOMBINELABLESPACING_robot 14.0f
#define RCCOMBINEBACKVIEWWIDTH_robot 268.0f
#define RCtitleContentSpace_robot 10.0f
#define RCtagBarHeight_robot 34.0f
#define RClineHeight_robot 1.0f
@interface CMPRobotMessageCell()

/*!
 消息的背景 View
 */
@property(nonatomic, strong) UIView *backView;

/*!
 展示消息的 业务消息 标题
 */
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;

/*!
展示消息的 业务消息 标识图片
*/
@property(nonatomic, strong) UIImageView *tagImageView;
/*!
展示消息的 业务消息 标识名称
*/
@property(nonatomic, strong) UILabel *tagLabel;

@property(nonatomic, strong) UILabel *lineLable;
@property(nonatomic, strong) UIImageView *maskView;
@property(nonatomic, strong) UIImageView *shadowMaskView;

@property(nonatomic, strong) RCMessageModel *currentModel;
@end

@implementation CMPRobotMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    __messagecontentview_height = [CMPRobotMessageCell calculateCellHeight:model];
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(RCMessageModel *)model{
    CMPRobotMsg *robotMessage = (CMPRobotMsg *)model.content;
    CGFloat titleHeight = [self getTitleHeightWithTitle:robotMessage.title];
    CGFloat contentHeight = [self getContentHeightWithContent:robotMessage.content];
    CGFloat totalHeight = titleHeight + contentHeight + RCCOMBINELABLESPACING_robot * 2 + RCtitleContentSpace_robot + RCtagBarHeight_robot + RClineHeight_robot;
    return totalHeight;
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
    [self.backView addSubview:self.titleLabel];
    [self.backView addSubview:self.contentLabel];
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

- (void)backViewTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)resetSubViews {
    self.titleLabel.text = nil;
    self.contentLabel.text = nil;
    self.tagImageView.image = nil;
    self.tagLabel.text = nil;
}
#pragma mark - setModel
- (void)setDataModel:(RCMessageModel *)model {
    if (!model) {
        return;
    }
    [super setDataModel:model];
    self.currentModel = model;
    [self resetSubViews];
    
    CMPRobotMsg *robotMessage = (CMPRobotMsg *)model.content;
    
    self.titleLabel.text = robotMessage.title;
    self.contentLabel.text = robotMessage.content;
    [self.tagImageView setImage:[UIImage imageNamed:@"cmp_robot_msg_icon"]];
    self.tagLabel.text = SY_STRING(@"rc_msg_robot_msg");
    
    [self calculateContenViewSize:robotMessage];
//    [self setDestructViewLayout];//阅后即焚
}

- (void)calculateContenViewSize:(CMPRobotMsg *)robotMessage {
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
        messageContentViewRect.origin.x = self.baseContentView.bounds.size.width - (RCCOMBINECELLWIDTH_robot + HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
    }
    CGFloat messageContentViewHeight;
    messageContentViewHeight = [CMPRobotMessageCell calculateCellHeight:self.currentModel];
    messageContentViewRect.size = CGSizeMake(RCCOMBINECELLWIDTH_robot, messageContentViewHeight);
    self.messageContentView.frame = messageContentViewRect;

    [self autoLayoutSubViews];
    [self setMaskImage:maskImage];
}

- (void)autoLayoutSubViews{
    if (self.currentModel.messageDirection == MessageDirection_RECEIVE) {
        self.backView.frame = CGRectMake(RCCOMBINEARROWWIDTH_robot + RCCOMBINELABLEOFFSET_robot, 0, self.messageContentView.frame.size.width - RCCOMBINEARROWWIDTH_robot - RCCOMBINELABLEOFFSET_robot * 2, self.messageContentView.frame.size.height) ;
    }else {
        self.backView.frame = CGRectMake(RCCOMBINELABLEOFFSET_robot, 0, self.messageContentView.frame.size.width - RCCOMBINEARROWWIDTH_robot - RCCOMBINELABLEOFFSET_robot * 2, self.messageContentView.frame.size.height) ;
    }

    self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING_robot, RCCOMBINELABLESPACING_robot,RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 , [self.titleLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 font:self.titleLabel.font numberOfLines:2]);

    self.contentLabel.frame = CGRectMake(RCCOMBINELABLESPACING_robot, self.titleLabel.cmp_bottom+RCtitleContentSpace_robot,RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 , [self.contentLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 font:self.contentLabel.font numberOfLines:2]);
    
    self.lineLable.frame = CGRectMake(0, self.contentLabel.cmp_bottom + RCCOMBINELABLESPACING_robot, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
    self.tagImageView.frame = CGRectMake(self.contentLabel.cmp_left, self.lineLable.cmp_bottom + 8, 18, 18);
    self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 8, RCCOMBINEBACKVIEWWIDTH_robot - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING_robot , 18);
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

+ (CGFloat)getTitleHeightWithTitle:(NSString *)title{
//    CGFloat textWidth = RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2;
    CGFloat titleHeight = [title getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 font:[UIFont boldSystemFontOfSize:16] numberOfLines:2];
    return titleHeight;
}

+ (CGFloat)getContentHeightWithContent:(NSString *)title{
    CGFloat contentHeight = [title getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH_robot - RCCOMBINELABLESPACING_robot * 2 font:[UIFont systemFontOfSize:12] numberOfLines:2];
    return contentHeight;
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
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    }
    return _titleLabel;
}
- (UILabel *)contentLabel {
    if(!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 2;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    }
    return _contentLabel;
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
@end
