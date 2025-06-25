//
//  CMPCombineMessageCell.m
//  RongIMKit
//
//  Created by liyan on 2019/8/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "CMPCombineMessageCell.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPConstant.h>
#import "M3-Swift.h"
#import "RCForwardManager+SendProvider.h"
#import <CMPLib/CMPThemeManager.h>

#define RCCOMBINECELLWIDTH 273.0f
#define RCCOMBINELABLEOFFSET 0.0f
#define RCCOMBINEARROWWIDTH 5.0f
#define RCCOMBINELABLESPACING 16.0f
#define RCCOMBINEBACKVIEWWIDTH 268.0f

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface CMPCombineMessageCell()

@property(nonatomic, strong) UIImageView *shadowMaskView;

@property(nonatomic, strong) UILabel *lineLable;

@property(nonatomic, strong) RCMessageModel *currentModel;

@property(nonatomic, assign) CGFloat titleLableHeight;

@end

@implementation CMPCombineMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    CMPCombineMessage *combineMessage = (CMPCombineMessage *)model.content;
    __messagecontentview_height = [CMPCombineMessageCell calculateCellHeight:combineMessage];
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(CMPCombineMessage *)combineMessage {
    CGFloat height = [self getRidContentLabelHeightWithMessageModel:combineMessage];
    for (int i = 0; i < combineMessage.contentModels.count ; i++) {
        ContentModel *model = [combineMessage.contentModels objectAtIndex:i];
        NSString *content =  [RCForwardManager packageContent:model];
        CGFloat modelHeight = [content getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:1];
        height += modelHeight;
        if (i == 2) {
            break;
        }
    }
    return height;
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
    [self.backView addSubview:self.lineLable];
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
    
    CMPCombineMessage *combineMessage = (CMPCombineMessage *)model.content;
    self.titleLabel.text = combineMessage.title;

    CGFloat modelWidth;
    CGFloat modelHeight;
    UILabel *lable;
    NSString *content;
    
    for (int i = 0;i < combineMessage.contentModels.count;i++ ) {
        ContentModel *model = combineMessage.contentModels[i];
        content = [RCForwardManager packageContent:model];
        modelWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2;
        modelHeight = [content getHeightWithWidth:modelWidth font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:1];
        lable = [[UILabel alloc] init];
        lable.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        lable.numberOfLines = 0;
        lable.textAlignment = NSTextAlignmentLeft;
        lable.backgroundColor = [UIColor clearColor];
        lable.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        lable.cmp_width = modelWidth;
        lable.cmp_height = modelHeight;
        lable.text = content;
        [self.contentLables addObject:lable];
        [self.backView addSubview:lable];
        if (i == 2) {
            break;
        }
    }
    
    [self calculateContenViewSize:combineMessage];
    //[self updateStatusContentView:self.model];
    [self setDestructViewLayout];
}

- (void)resetSubViews {
    self.titleLabel.text = nil;
    [self.contentLables makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentLables removeAllObjects];
}

- (void)calculateContenViewSize:(CMPCombineMessage *)combineMessage {
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
    messageContentViewHeight = [CMPCombineMessageCell calculateCellHeight:combineMessage];
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
    self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING, 10, self.backView.frame.size.width - RCCOMBINELABLESPACING * 2, [CMPCombineMessageCell getTitleLableHeightWithMessageModel:(CMPCombineMessage *)self.currentModel.content]);
    self.lineLable.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 10, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
    
    UILabel *lable;
    CGFloat x;
    CGFloat y;
    CGFloat height;
    for (int i = 0; i < self.contentLables.count ; i++) {
        lable = [self.contentLables objectAtIndex:i];
        height = lable.cmp_height;
        x = RCCOMBINELABLESPACING;
        y = CGRectGetMaxY(self.lineLable.frame) + 10 + i * height;
        lable.cmp_x = x;
        lable.cmp_y = y;
    }
}

- (void)setDestructViewLayout {
    CMPCombineMessage *combineMessage = (CMPCombineMessage *)self.model.content;
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

- (NSMutableArray<UILabel *> *)contentLables {
    if (!_contentLables) {
        _contentLables = [NSMutableArray array];
    }
    return _contentLables;
}

- (UILabel *)lineLable {
    if(!_lineLable) {
        _lineLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _lineLable.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    }
    return _lineLable;
}

+ (CGFloat)getTitleLableHeightWithMessageModel:(CMPCombineMessage *)combineMessage {
    NSString * title = combineMessage.title;
    CGFloat height = [title getHeightWithWidth:RCCOMBINECELLWIDTH - RCCOMBINELABLESPACING  font:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
    return height;
}

+ (CGFloat)getRidContentLabelHeightWithMessageModel:(CMPCombineMessage *)combineMessage {
    CGFloat height = [self getTitleLableHeightWithMessageModel:combineMessage] + 10 * 4;
    return height;
}

#pragma clang diagnostic pop

@end
