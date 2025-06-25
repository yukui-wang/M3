//
//  CMPBusinessCardMessageCell.m
//  M3
//
//  Created by 程昆 on 2019/10/24.
//

#import "CMPGeneralBusinessMessageCell.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIView+CMPView.h>
#import "CMPGeneralBusinessMessage.h"
#import <CMPLib/UIImageView+WebCache.h>
#import <CMPLib/CMPAppListModel.h>
#import "CMPRCChatViewController.h"
#import <CMPLib/NSURL+CMPURL.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPMeetingManager.h"

#define RCCOMBINECELLWIDTH 273.0f
#define RCCOMBINELABLEOFFSET 0.0f
#define RCCOMBINEARROWWIDTH 5.0f
#define RCCOMBINELABLESPACING 14.0f
#define RCCOMBINEBACKVIEWWIDTH 268.0f
#define RCtagBarHeight 34.0f
#define RClineHeight 1.0f
#define RCtitleContentSpace 10.0f
#define RCContentLableSpace 4.0f
#define RCCbuttonHeight 28.0f
#define RCCbuttonWidth 82.0f

#define RCTITLEFONT [UIFont boldSystemFontOfSize:16]

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

typedef NS_ENUM(NSInteger, CMPBusinessMessageLayoutType) {
    CMPBusinessMessageLayoutTypeWithContentAndImage      ,
    CMPBusinessMessageLayoutTypeWithContentAndNoImage    ,
    CMPBusinessMessageLayoutTypeWithNoContentAndImage    ,
    CMPBusinessMessageLayoutTypeWithNoContentAndNoImage  ,
};

@interface CMPGeneralBusinessMessageCell()

/*!
 消息的背景 View
 */
@property(nonatomic, strong) UIView *backView;

/*!
 展示消息的 业务消息 标题
 */
@property(nonatomic, strong) UILabel *titleLabel;

/*!
 展示消息的 业务消息 内容
 */
@property(nonatomic, strong) NSMutableArray<UILabel *> *contentLables;

/*!
 展示消息的 业务消息 相关图片
 */
@property(nonatomic, strong) UIImageView *relatedImageView;

/*!
展示消息的 业务消息 标识图片
*/
@property(nonatomic, strong) UIImageView *tagImageView;

/*!
展示消息的 业务消息 标识名称
*/
@property(nonatomic, strong) UILabel *tagLabel;

/*!
 展示消息的 业务消息 快捷处理
 */
@property(nonatomic, strong) NSMutableArray<UIButton *> *quickProcessButtons;

@property(nonatomic, strong) UILabel *lineLable;
@property(nonatomic, strong) UIImageView *maskView;
@property(nonatomic, strong) UIImageView *shadowMaskView;

@property(nonatomic, strong) RCMessageModel *currentModel;
@property(nonatomic, assign) CMPBusinessMessageLayoutType currentLayoutType;

@end

@implementation CMPGeneralBusinessMessageCell

static CGFloat quickProcessButtonsHeight = 0;

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height;
    __messagecontentview_height = [CMPGeneralBusinessMessageCell calculateCellHeight:model];
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGFloat)calculateCellHeight:(RCMessageModel *)model {
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)model.content;
    NSString *title = businessMessage.messageContent;
    NSArray *dynamicData = businessMessage.dynamicData;
    if (![dynamicData isKindOfClass:NSArray.class]) {
        dynamicData = [NSArray array];
    };
    
    NSUInteger contentCount = dynamicData.count;
    NSString *relatedImageUrlStr = businessMessage.imageUrl;
    
    NSDictionary *extraDic = [model.extra JSONValue];
    NSArray<NSDictionary*> *quickProcessItems = [extraDic[@"quickProcessItems"] copy];
    
    NSString *messageCategory = businessMessage.messageCategory;
    if ([@"109" isEqualToString:messageCategory]) {
        if ([CMPMeetingManager isDateValidWithin30MinituesByTimestramp:model.sentTime]) {
            if (!quickProcessItems || [quickProcessItems isKindOfClass:NSArray.class]) {
                NSString *joinTitle = SY_STRING(@"meeting_join");
//                NSDictionary *info = businessMessage.messageCard;
//                if (info) {
//                    NSString *meetPwd = info[@"meetingPassword"];
//                    if (meetPwd && meetPwd.length) {
//                        joinTitle = SY_STRING(@"meeting_copyAndJoin");
//                    }
//                }
                quickProcessItems = @[@{@"display":joinTitle,@"enable":@"0"}];
            }
        }
    }
    
    NSUInteger quickProcessItemsCount = quickProcessItems.count;
    quickProcessButtonsHeight = 0;
    
    CMPBusinessMessageLayoutType layoutType;
    if (contentCount && [NSString isNotNull:relatedImageUrlStr]) {
        layoutType = CMPBusinessMessageLayoutTypeWithContentAndImage;
    } else if (contentCount && [NSString isNull:relatedImageUrlStr]) {
        layoutType = CMPBusinessMessageLayoutTypeWithContentAndNoImage;
    } else if (!contentCount && [NSString isNotNull:relatedImageUrlStr]) {
        layoutType = CMPBusinessMessageLayoutTypeWithNoContentAndImage;
    } else {
        layoutType = CMPBusinessMessageLayoutTypeWithNoContentAndNoImage;
    }
    
    CGFloat titleHeight = 0;
    CGFloat contentHeight = 0;
    CGFloat totalHeight = 0;
    
    if (layoutType == CMPBusinessMessageLayoutTypeWithContentAndImage) {
        titleHeight = [self getTitleHeightWithTitle:title layoutType:layoutType];
        contentHeight = [self getContentHeightWithDynamicData:dynamicData layoutType:layoutType];
        contentHeight = MAX(contentHeight, 50);
        totalHeight = titleHeight + contentHeight + RCCOMBINELABLESPACING * 2 + RCtitleContentSpace + RCtagBarHeight + RClineHeight;
    } else if (layoutType == CMPBusinessMessageLayoutTypeWithContentAndNoImage) {
        titleHeight = [self getTitleHeightWithTitle:title layoutType:layoutType];
        contentHeight = [self getContentHeightWithDynamicData:dynamicData layoutType:layoutType];
        totalHeight = titleHeight + contentHeight + RCCOMBINELABLESPACING * 2 + RCtitleContentSpace + RCtagBarHeight + RClineHeight;
    } else if (layoutType == CMPBusinessMessageLayoutTypeWithNoContentAndImage) {
        titleHeight = [self getTitleHeightWithTitle:title layoutType:layoutType];
        titleHeight = MAX(titleHeight,50);
        totalHeight = titleHeight + RCCOMBINELABLESPACING * 2 + RCtagBarHeight + RClineHeight;
    } else if (layoutType == CMPBusinessMessageLayoutTypeWithNoContentAndNoImage) {
        titleHeight = [self getTitleHeightWithTitle:title layoutType:layoutType];
        totalHeight = titleHeight +  RCCOMBINELABLESPACING * 2 + RCtagBarHeight + RClineHeight;
    }
    
    NSUInteger row = 0;
    if (quickProcessItemsCount > 0) {
        row = (quickProcessItemsCount - 1) / 3 + 1;
    }
    
    if (row > 0) {
//        NSDictionary *extraDic = [model.extra JSONValue];
//        NSArray<NSDictionary*> *quickProcessItems = [extraDic[@"quickProcessItems"] copy];
        NSString *display = nil;
        CGFloat modelHeight;
        NSMutableArray *heightArr = [NSMutableArray array];
        for (NSDictionary *quickProcessItem in quickProcessItems) {
           display = quickProcessItem[@"display"];
           modelHeight = [display getHeightWithWidth:RCCbuttonWidth font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:0];
           modelHeight += 14;
           [heightArr addObject:@(modelHeight)];
        }
        CGFloat maxValue = [[heightArr valueForKeyPath:@"@max.floatValue"] floatValue];
        quickProcessButtonsHeight = (6 + maxValue) * row;
        totalHeight += quickProcessButtonsHeight;
    }
    
    return totalHeight;
}

+ (NSAttributedString *)packageContent:(NSDictionary *)modelDic {
    NSString *key = [NSString isNotNull:modelDic[@"key"]] ? [NSString stringWithFormat:@"%@: ",modelDic[@"key"]] : @"" ;
    NSString *value = [NSString isNotNull:modelDic[@"value"]] ? modelDic[@"value"] : @"";
    NSMutableAttributedString *attributedKey = [[NSMutableAttributedString alloc] initWithString:key];
    [attributedKey addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] range:NSMakeRange(0, key.length)];
    [attributedKey addAttribute:NSForegroundColorAttributeName value:[UIColor cmp_colorWithName:@"sup-fc1"] range:NSMakeRange(0, key.length)];
    NSMutableAttributedString *attributedValue = [[NSMutableAttributedString alloc] initWithString:value];
    [attributedValue addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] range:NSMakeRange(0, value.length)];
    [attributedValue addAttribute:NSForegroundColorAttributeName value:[UIColor cmp_colorWithName:@"cont-fc"] range:NSMakeRange(0, value.length)];
    [attributedKey appendAttributedString:attributedValue];
    return [attributedKey copy];
}

+ (CGFloat)getTitleHeightWithTitle:(NSString *)title layoutType:(CMPBusinessMessageLayoutType)layoutType {
    CGFloat titleHeight;
    CGFloat textWidth;
    if (layoutType == CMPBusinessMessageLayoutTypeWithNoContentAndImage) {
        textWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 - 50 - 10;
    } else {
        textWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2;
    }
    titleHeight = [title getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 font:RCTITLEFONT numberOfLines:2];
    return titleHeight;
}

+ (CGFloat)getContentHeightWithDynamicData:(NSArray *)dynamicData layoutType:(CMPBusinessMessageLayoutType)layoutType {
    CGFloat contentHeight = 0.0;
    CGFloat textWidth;
    if (layoutType == CMPBusinessMessageLayoutTypeWithContentAndImage) {
        textWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 - 50 - 10;
    } else if (layoutType == CMPBusinessMessageLayoutTypeWithContentAndNoImage) {
        textWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2;
    } else {
        return 0;
    }
    for (int i = 0; i < dynamicData.count ; i++) {
        NSDictionary *modelDic = [dynamicData objectAtIndex:i];
        NSString *content =  [self packageContent:modelDic].string;
        CGFloat modelHeight = [content getHeightWithWidth:textWidth font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:1];
        contentHeight += modelHeight;
    }
    if (dynamicData.count > 0) {
        contentHeight += (dynamicData.count - 1) * RCContentLableSpace;
    }
    return contentHeight;
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
    [self.backView addSubview:self.relatedImageView];
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
    
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)model.content;
    NSString *title = businessMessage.messageContent;
    NSArray *dynamicData = businessMessage.dynamicData;
    if (![dynamicData isKindOfClass:NSArray.class]){
        dynamicData = [NSArray array];
    };
    
    NSUInteger contentCount = dynamicData.count;
    NSString *relatedImageUrlStr = businessMessage.imageUrl;
    NSString *messageCategory = businessMessage.messageCategory;
    
    NSDictionary *extraDic = [model.extra JSONValue];
    NSArray<NSDictionary*> *quickProcessItems = [extraDic[@"quickProcessItems"] copy];
    
    if ([@"109" isEqualToString:messageCategory]) {
        if ([CMPMeetingManager isDateValidWithin30MinituesByTimestramp:model.sentTime]) {
            if (!quickProcessItems || [quickProcessItems isKindOfClass:NSArray.class]) {
                NSString *joinTitle = SY_STRING(@"meeting_join");
//                NSDictionary *info = businessMessage.messageCard;
//                if (info) {
//                    NSString *meetPwd = info[@"meetingPassword"];
//                    if (meetPwd && meetPwd.length) {
//                        joinTitle = SY_STRING(@"meeting_copyAndJoin");
//                    }
//                }
                quickProcessItems = @[@{@"display":joinTitle,@"enable":@"0"}];
            }
        }
    }

    if (contentCount && [NSString isNotNull:relatedImageUrlStr]) {
        self.currentLayoutType = CMPBusinessMessageLayoutTypeWithContentAndImage;
    } else if (contentCount && [NSString isNull:relatedImageUrlStr]) {
        self.currentLayoutType = CMPBusinessMessageLayoutTypeWithContentAndNoImage;
    } else if (!contentCount && [NSString isNotNull:relatedImageUrlStr]) {
        self.currentLayoutType = CMPBusinessMessageLayoutTypeWithNoContentAndImage;
    } else if (!contentCount && [NSString isNull:relatedImageUrlStr]) {
        self.currentLayoutType = CMPBusinessMessageLayoutTypeWithNoContentAndNoImage;
    }
    
    self.titleLabel.text = title;
    if ([NSString isNotNull:relatedImageUrlStr]) {
        NSString *imageUrlStr = [relatedImageUrlStr urlCFEncoded];
        imageUrlStr = [CMPCore fullUrlForPath:imageUrlStr];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithPathString:imageUrlStr] options:SDWebImageDownloaderHandleCookies|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (finished && !error) {
                [self.relatedImageView setImage:image];
            }
        }];
    }
    
    if ([NSString isNull:businessMessage.appIconUrl]) {
        NSString *appList = [CMPCore sharedInstance].currentUser.appList;
        CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
        CMPAppList_2 *appInfo = [appListModel appInfoWithType:@"default" ID:messageCategory];
        NSString *iconUrl = [NSString isNotNull:appInfo.iconUrl] ? appInfo.iconUrl : @"";
        if ([NSString isNotNull:appInfo.iconUrl]) {
            businessMessage.appIconUrl = [NSString stringWithFormat:@"%@%@",[CMPCore sharedInstance].serverurl,iconUrl];
        } else {
            businessMessage.appIconUrl = @"";
        }
    }
    
    if ([NSString isNull:businessMessage.appName]) {
        NSString *appList = [CMPCore sharedInstance].currentUser.appList;
        CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
        CMPAppList_2 *appInfo = [appListModel appInfoWithType:@"default" ID:messageCategory];
        businessMessage.appName = appInfo.appName;
    }
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithPathString:businessMessage.appIconUrl] options:SDWebImageDownloaderHandleCookies|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (finished && !error) {
            [self.tagImageView setImage:image];
        }
    }];
    self.tagLabel.text = businessMessage.appName;
    
    CGFloat modelWidth;
    CGFloat modelHeight;
    UILabel *lable;
    NSAttributedString *content;
    
    if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithContentAndImage) {
        modelWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 - 50 - 10;
    } else if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithContentAndNoImage) {
        modelWidth = RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2;
    }
   
    for (NSDictionary *modelDic in dynamicData) {
        content = [CMPGeneralBusinessMessageCell packageContent:modelDic];
        modelHeight = [content.string getHeightWithWidth:modelWidth font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:1];
        lable = [[UILabel alloc] init];
        lable.numberOfLines = 1;
        lable.textAlignment = NSTextAlignmentLeft;
        lable.backgroundColor = [UIColor clearColor];
        lable.cmp_width = modelWidth;
        lable.cmp_height = modelHeight;
        lable.attributedText = content;
        [self.contentLables addObject:lable];
        [self.backView addSubview:lable];
    }
    
    NSString *display;
    UIButton *button;
    for (NSDictionary *quickProcessItem in quickProcessItems) {
        display = quickProcessItem[@"display"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:display forState:UIControlStateNormal];
        [button setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor cmp_colorWithName:@"white-bg"]];
        button.layer.cornerRadius = 14;
        button.layer.masksToBounds = YES;
        modelHeight = [display getHeightWithWidth:RCCbuttonWidth font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] numberOfLines:0];
        modelHeight += 14;
        button.cmp_size = CGSizeMake(RCCbuttonWidth, modelHeight);
        button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        button.titleLabel.numberOfLines = 0;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor cmp_colorWithName:@"gray-bgc1"].CGColor;
        [self.quickProcessButtons addObject:button];
        [self.backView addSubview:button];
        [button addTarget:self action:@selector(quickProcessButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *enable = quickProcessItem[@"enable"];
        [button setUserInteractionEnabled:![@"0" isEqualToString:enable]];
    }
    
    [self calculateContenViewSize:businessMessage];
    [self setDestructViewLayout];
}

- (void)resetSubViews {
    self.titleLabel.text = nil;
    self.relatedImageView.image = nil;
    self.tagImageView.image = nil;
    self.tagLabel.text = nil;
    [self.contentLables makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentLables removeAllObjects];
    [self.quickProcessButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.quickProcessButtons removeAllObjects];
}

- (void)calculateContenViewSize:(CMPGeneralBusinessMessage *)businessMessage {
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
    messageContentViewHeight = [CMPGeneralBusinessMessageCell calculateCellHeight:self.currentModel];
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
    
    if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithContentAndImage) {
        self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING, RCCOMBINELABLESPACING,RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 , [self.titleLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 font:self.titleLabel.font numberOfLines:2]);
        UILabel *lable;
        CGFloat x;
        CGFloat y;
        CGFloat height;
        for (int i = 0; i < self.contentLables.count ; i++) {
            lable = [self.contentLables objectAtIndex:i];
            height = lable.cmp_height;
            x = self.titleLabel.cmp_left;
            y = self.titleLabel.cmp_bottom + RCtitleContentSpace + i * ( height + RCContentLableSpace);
            lable.cmp_x = x;
            lable.cmp_y = y;
        }
        self.relatedImageView.frame = CGRectMake(self.contentLables.firstObject.cmp_right + 10, self.contentLables.firstObject.cmp_top, 50, 50);
        if ([CMPGeneralBusinessMessageCell getContentHeightWithDynamicData:((CMPGeneralBusinessMessage *)(self.currentModel.content)).dynamicData layoutType:self.currentLayoutType] <= 50) {
           self.lineLable.frame = CGRectMake(0, self.relatedImageView.cmp_bottom + RCCOMBINELABLESPACING, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
        } else {
            self.lineLable.frame = CGRectMake(0, self.contentLables.lastObject.cmp_bottom + RCCOMBINELABLESPACING, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
        }
        self.tagImageView.frame = CGRectMake(self.titleLabel.cmp_left, self.lineLable.cmp_bottom + 8, 18, 18);
        self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 8, RCCOMBINEBACKVIEWWIDTH - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING , 18);
        self.relatedImageView.hidden = NO;
    } else if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithContentAndNoImage) {
        self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING, RCCOMBINELABLESPACING,RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 , [self.titleLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 font:self.titleLabel.font numberOfLines:2]);
         UILabel *lable;
         CGFloat x;
         CGFloat y;
         CGFloat height;
         for (int i = 0; i < self.contentLables.count ; i++) {
            lable = [self.contentLables objectAtIndex:i];
            height = lable.cmp_height;
            x = self.titleLabel.cmp_left;
            y = self.titleLabel.cmp_bottom + RCtitleContentSpace + i * ( height + RCContentLableSpace);
            lable.cmp_x = x;
            lable.cmp_y = y;
        }
        self.lineLable.frame = CGRectMake(0, self.contentLables.lastObject.cmp_bottom + RCCOMBINELABLESPACING, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
        self.tagImageView.frame = CGRectMake(self.titleLabel.cmp_left, self.lineLable.cmp_bottom + 8, 18, 18);
        self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 8, RCCOMBINEBACKVIEWWIDTH - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING , 18);
        self.relatedImageView.hidden = YES;
    } else if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithNoContentAndImage) {
       self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING, RCCOMBINELABLESPACING,RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 - 50 - 10 , [self.titleLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 - 50 - 10 font:self.titleLabel.font numberOfLines:2]  );
       self.relatedImageView.frame = CGRectMake(RCCOMBINEBACKVIEWWIDTH - 50 - RCCOMBINELABLESPACING, self.titleLabel.cmp_top, 50, 50);
       self.lineLable.frame = CGRectMake(0, self.relatedImageView.cmp_bottom + RCCOMBINELABLESPACING, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
       self.tagImageView.frame = CGRectMake(self.titleLabel.cmp_left, self.lineLable.cmp_bottom + 8, 18, 18);
       self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 8, RCCOMBINEBACKVIEWWIDTH - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING , 18);
        self.relatedImageView.hidden = NO;
    } else if (self.currentLayoutType == CMPBusinessMessageLayoutTypeWithNoContentAndNoImage) {
       self.titleLabel.frame = CGRectMake(RCCOMBINELABLESPACING, RCCOMBINELABLESPACING,RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 , [self.titleLabel.text getHeightWithWidth:RCCOMBINEBACKVIEWWIDTH - RCCOMBINELABLESPACING * 2 font:self.titleLabel.font numberOfLines:2]);
       self.lineLable.frame = CGRectMake(0, self.titleLabel.cmp_bottom + RCCOMBINELABLESPACING, self.backView.frame.size.width, 1/[UIScreen mainScreen].scale);
       self.tagImageView.frame = CGRectMake(self.titleLabel.cmp_left, self.lineLable.cmp_bottom + 8, 18, 18);
       self.tagLabel.frame = CGRectMake(self.tagImageView.cmp_right + 4, self.lineLable.cmp_bottom + 8, RCCOMBINEBACKVIEWWIDTH - self.tagImageView.cmp_right - 4 - RCCOMBINELABLESPACING , 18);
       self.relatedImageView.hidden = YES;
    }
    
    UIButton *button;
    CGFloat x;
    CGFloat y;
    CGFloat height =  RCCbuttonHeight;
    NSUInteger row = 0;
    NSUInteger column = 0;
    for (int i = 0; i < self.quickProcessButtons.count ; i++) {
        row = i / 3;
        column = i % 3;
        button = [self.quickProcessButtons objectAtIndex:i];
        x =(RCCbuttonWidth + 10) * column;
        y = self.tagImageView.cmp_bottom + 9 + 6 + row  * (height + 6);
        button.cmp_x = x;
        button.cmp_y = y;
    }
    
}

- (void)setDestructViewLayout {
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)self.model.content;
    if (businessMessage.destructDuration > 0 && [[RCIMClient sharedRCIMClient] getDestructMessageRemainDuration:self.model.messageUId]) {
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
    
    _shadowMaskView.frame = CGRectMake(-0.2, -0.2, self.messageContentView.frame.size.width + 1.2, self.messageContentView.frame.size.height + 1.2 - quickProcessButtonsHeight);
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

- (UIImageView *)relatedImageView {
    if (!_relatedImageView) {
        _relatedImageView = [[UIImageView alloc] init];
        _relatedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _relatedImageView.layer.masksToBounds = YES;
    }
    return _relatedImageView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = RCTITLEFONT;
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

-(NSMutableArray<UIButton *> *)quickProcessButtons {
    if (!_quickProcessButtons) {
        _quickProcessButtons = [NSMutableArray array];
    }
    return _quickProcessButtons;
}

-(void)quickProcessButtonAction:(UIButton *)sender {
    NSUInteger index = [self.quickProcessButtons indexOfObject:sender];
    NSDictionary *extraDic = [self.currentModel.extra JSONValue];
    CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)self.currentModel.content;
    NSArray<NSDictionary*> *quickProcessItems = [extraDic[@"quickProcessItems"] copy];
    NSDictionary *quickProcessHandleParam = extraDic[@"quickProcessHandleParam"];
    
    NSMutableDictionary *pramaDic = [NSMutableDictionary dictionaryWithDictionary:quickProcessHandleParam];
    pramaDic[@"attitude"] = [quickProcessItems objectAtIndex:index][@"value"];
    pramaDic[@"attitudeKey"] = [quickProcessItems objectAtIndex:index][@"key"];
    pramaDic[@"feedbackFlag"] = [quickProcessItems objectAtIndex:index][@"value"];
    pramaDic[@"messageCategory"] = businessMessage.messageCategory;
    
    NSString *operation = [quickProcessItems objectAtIndex:index][@"operation"];
    if ([operation isEqualToString:@"pierce"]) { //operation 为 pierce 时,点击快批执行点击卡片穿透
        if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
            [self.delegate didTapMessageCell:self.model];
        }
    } else {
        CMPRCChatViewController *delegate = (CMPRCChatViewController *)self.delegate;
        [delegate generalBusinessMessageCell:self didSelectedButton:index quickprocessRequestParam: [pramaDic copy]];
    }
    
}

#pragma clang diagnostic pop

@end
