//
//  RCMessageBaseCell.m
//  RongIMKit
//
//  Created by xugang on 15/1/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCMessageBaseCell.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCMessageSelectionUtility.h"
#import "RCIM.h"
NSString *const KNotificationMessageBaseCellUpdateSendingStatus = @"KNotificationMessageBaseCellUpdateSendingStatus";
#define SelectButtonSize CGSizeMake(20, 20)
#define SelectButtonSpaceLeft 5 //选择按钮据屏幕左侧 5

@interface RCMessageBaseCell ()

@property (nonatomic, strong) UITapGestureRecognizer *multiSelectTap;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, assign) BOOL isConversationAppear;

- (void)setBaseAutoLayout;

@end

@implementation RCMessageBaseCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    NSLog(@"Warning, you not implement sizeForMessageModel:withCollectionViewWidth:referenceExtraHeight: method for "
          @"you custom cell %@",
          NSStringFromClass(self));
    return CGSizeMake(0, 0);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupMessageBaseCellView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMessageBaseCellView];
    }
    return self;
}

- (void)setupMessageBaseCellView {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageCellUpdateSendingStatusEvent:)
                                                 name:KNotificationMessageBaseCellUpdateSendingStatus
                                               object:nil];

    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangedMessageMultiSelectStatus:)
    //    name:RCMessageMultiSelectStatusChanged object:nil];
    self.model = nil;
    self.baseContentView = [[UIView alloc] initWithFrame:CGRectZero];
    _isDisplayReadStatus = NO;
    [self.contentView addSubview:_baseContentView];
}

- (void)setDataModel:(RCMessageModel *)model {
    self.model = model;
    self.messageDirection = model.messageDirection;
    _isDisplayMessageTime = model.isDisplayMessageTime;
    if (self.isDisplayMessageTime) {
        [self.messageTimeLabel setText:[RCKitUtility ConvertChatMessageTime:model.sentTime / 1000]
                   dataDetectorEnabled:NO];
        if (RC_IOS_SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [self.messageTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
        }
    }

    [self setBaseAutoLayout];
    [self updateUIForMultiSelect];
}
- (void)setBaseAutoLayout {
    if (self.isDisplayMessageTime) {
        CGSize timeTextSize_ = [RCKitUtility getTextDrawingSize:self.messageTimeLabel.text
                                                           font:[UIFont systemFontOfSize:12.f]
                                                constrainedSize:CGSizeMake(self.bounds.size.width, TIME_LABEL_HEIGHT)];
        timeTextSize_ = CGSizeMake(ceilf(timeTextSize_.width + 10), ceilf(timeTextSize_.height));

        self.messageTimeLabel.hidden = NO;
        [self.messageTimeLabel setFrame:CGRectMake((self.bounds.size.width - timeTextSize_.width) / 2, 10,
                                                   timeTextSize_.width, TIME_LABEL_HEIGHT)];
        [_baseContentView setFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    } else {
        if (_messageTimeLabel) {
            self.messageTimeLabel.hidden = YES;
        }
        [_baseContentView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - (0))];
    }
}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    DebugLog(@"%s", __FUNCTION__);
}

#pragma mark Multi select
- (void)onChangedMessageMultiSelectStatus:(NSNotification *)notification {
    [self setDataModel:self.model];
}

- (void)updateUIForMultiSelect {
    [self.contentView removeGestureRecognizer:self.multiSelectTap];
    if ([RCMessageSelectionUtility sharedManager].multiSelect && self.allowsSelection) {
        self.baseContentView.userInteractionEnabled = NO;
        self.selectButton.hidden = NO;
        [self.contentView addGestureRecognizer:self.multiSelectTap];
    } else {
        self.baseContentView.userInteractionEnabled = YES;
        self.selectButton.hidden = YES;
        CGRect frame = self.baseContentView.frame;
        frame.origin.x = 0;
        self.baseContentView.frame = frame;
        return;
    }
    [self updateSelectButtonStatus];

    CGRect frame = self.baseContentView.frame;
    CGFloat selectButtonY = frame.origin.y +
                            ([RCIM sharedRCIM].globalMessagePortraitSize.height - SelectButtonSize.height) /
                                2; //如果消息有头像，头像距离 baseContentView 顶部距离为 10
    if (MessageDirection_RECEIVE == self.model.messageDirection) {
        if (frame.origin.x < 3) { // cell不是左顶边的时候才会偏移
            frame.origin.x = SelectButtonSpaceLeft + 20;
        }
        self.baseContentView.frame = frame;
    }
    CGRect selectButtonFrame = CGRectMake(SelectButtonSpaceLeft, selectButtonY, 20, 20);
    self.selectButton.frame = selectButtonFrame;
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    _allowsSelection = allowsSelection;
    if (self.model) {
        [self updateUIForMultiSelect];
    }
}

- (void)onSelectMessageEvent {
    if ([[RCMessageSelectionUtility sharedManager] isContainMessage:self.model]) {
        [[RCMessageSelectionUtility sharedManager] removeMessageModel:self.model];
        [self updateSelectButtonStatus];
    } else {
        if ([RCMessageSelectionUtility sharedManager].selectedMessages.count >= 100) {
            UIViewController *rootVC = [RCKitUtility getKeyWindow].rootViewController;
            UIAlertController *alertController = [UIAlertController
                alertControllerWithTitle:nil
                                 message:NSLocalizedStringFromTable(@"ChatTranscripts", @"RongCloudKit", nil)
                          preferredStyle:UIAlertControllerStyleAlert];
            [alertController
                addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action){
                                                 }]];
            [rootVC presentViewController:alertController animated:YES completion:nil];
        } else {
            [[RCMessageSelectionUtility sharedManager] addMessageModel:self.model];
            [self updateSelectButtonStatus];
        }
    }
}

- (void)updateSelectButtonStatus {
    UIImage *image = [RCKitUtility
        imageNamed:([[RCMessageSelectionUtility sharedManager] isContainMessage:self.model] ? @"message_cell_select"
                                                                                            : @"message_cell_unselect")
          ofBundle:@"RongCloud.bundle"];
    [self.selectButton setImage:image forState:UIControlStateNormal];
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_selectButton setImage:[RCKitUtility imageNamed:@"message_cell_unselect" ofBundle:@"RongCloud.bundle"]
                       forState:UIControlStateNormal];
        [_selectButton addTarget:self
                          action:@selector(onSelectMessageEvent)
                forControlEvents:UIControlEventTouchUpInside];
        _selectButton.hidden = YES;
        [self.contentView addSubview:_selectButton];
        CGRect selectButtonFrame = CGRectMake(SelectButtonSpaceLeft, 0, 20, 20);
        _selectButton.frame = selectButtonFrame;
    }
    return _selectButton;
}

- (UITapGestureRecognizer *)multiSelectTap {
    if (!_multiSelectTap) {
        _multiSelectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageEvent)];
        _multiSelectTap.numberOfTapsRequired = 1;
        _multiSelectTap.numberOfTouchesRequired = 1;
    }
    return _multiSelectTap;
}

//大量cell不显示时间，使用延时加载
- (RCTipLabel *)messageTimeLabel {
    if (!_messageTimeLabel) {
        _messageTimeLabel = [RCTipLabel greyTipLabel];
        _messageTimeLabel.backgroundColor =
            [RCKitUtility generateDynamicColor:HEXCOLOR(0xc9c9c9) darkColor:HEXCOLOR(0x232323)];
        _messageTimeLabel.textColor = RCDYCOLOR(0xffffff, 0x707070);
        _messageTimeLabel.font = [UIFont systemFontOfSize:12.f];
        [self.contentView addSubview:_messageTimeLabel];
    }
    return _messageTimeLabel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
