//
//  XZInterfaceCell.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//
#define kXZTextModelPattern @"(##[^#]+##)|\\[([^\\]]*?)\\]\\(([^\\]]*?)\\)"
#define kbottomHeight 40


#import "XZInterfaceCell.h"
#import "XZTapLabel.h"
#import "XZTextModel.h"
#import "XZTextInfoModel.h"
#import "XZMainCellModel.h"
#import "XZMemberDetailView.h"

#import "XZCreateAppIntentCard.h"

#import "XZCancelModel.h"
#import "XZCancelCard.h"
#import "XZOptionMemberModel.h"
#import "XZOptionMemberView.h"
#import "XZScheduleModel.h"
#import "XZScheduleView.h"
#import "XZBaseTableViewCell.h"

#import "XZLeaveTypesModel.h"
#import "XZLeaveTypesView.h"

#import "XZLeaveModel.h"
#import "XZLeaveCard.h"
#import "XZOptionIntentsView.h"
#import "XZSpeechLoadingView.h"
#import "XZTransWebViewController.h"
@interface XZInterfaceCell() {
    BOOL _isFirst;
    UILabel *_guideSpeakLabel;
    UILabel *_humenSpeakLabel;
    XZTapLabel *_robotSpeakLabel;
    UIView *_cardView;
    CGFloat _cellHeight;
    CGFloat _cellMinHeight;
    XZCreateAppIntentCard *_createCard;
    XZSpeechLoadingView *_loadingView;
}
@property(nonatomic,strong)XZTextInfoModel *tapTextInfo;
@property(nonatomic,strong)NSMutableArray *models;
@property(nonatomic,strong)NSMutableArray *modelViews;

@end

@implementation XZInterfaceCell

- (void)setup {
    self.separatorHide = YES;
    UIColor *bkColor = [UIColor clearColor];
    [self setBkViewColor:bkColor];
    self.backgroundColor = bkColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _isFirst = YES;
    [self showGuideView];
}

- (void)setCellHeight:(CGFloat)cellHeight {
    if (cellHeight > _cellHeight && _cellHeight >_cellMinHeight) {
        _cellHeight = cellHeight;
    }
    _cellMinHeight = cellHeight;
}

- (CGFloat)cellHeight {
    return MAX(_cellHeight, _cellMinHeight) ;
}

- (UILabel *)guideSpeakLabel {
    if (!_guideSpeakLabel) {
        _guideSpeakLabel = [[UILabel alloc] init];
        _guideSpeakLabel.backgroundColor = [UIColor clearColor];
        _guideSpeakLabel.textColor = [UIColor whiteColor];
        _guideSpeakLabel.font = FONTSYS(26);
        _guideSpeakLabel.textAlignment = NSTextAlignmentLeft;
        _guideSpeakLabel.numberOfLines = 0;
        _guideSpeakLabel.frame = CGRectMake(20, 4, 300, _guideSpeakLabel.font.lineHeight);
        _guideSpeakLabel.text = @"请问需要什么帮助?";
        [self.contentView addSubview:_guideSpeakLabel];
    }
    return _guideSpeakLabel;
}

- (UILabel *)humenSpeakLabel {
    if (!_humenSpeakLabel) {
        _humenSpeakLabel = [[UILabel alloc] init];
        _humenSpeakLabel.backgroundColor = [UIColor clearColor];
        _humenSpeakLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        _humenSpeakLabel.font = FONTSYS(20);
        _humenSpeakLabel.textAlignment = NSTextAlignmentLeft;
        _humenSpeakLabel.numberOfLines = 0;
        [self.contentView addSubview:_humenSpeakLabel];
    }
    return _humenSpeakLabel;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 17)];
        [_editButton setTitle:@"轻点编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
        [_editButton.titleLabel setFont: FONTSYS(12)];
        [_editButton setImage:XZ_IMAGE(@"xz_edit_text.png") forState:UIControlStateNormal];
        CGFloat imageWidth = 12;
        [_editButton setImageEdgeInsets:UIEdgeInsetsMake(0, _editButton.width-imageWidth, 0, 0)];
        [_editButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth)];
        _editButton.hidden = YES;
        [self.contentView addSubview:_editButton];
    }
    return _editButton;
    

}

- (UILabel *)robotSpeakLabel {
    if (!_robotSpeakLabel) {
        _robotSpeakLabel = [self tapLabel];
        [self.contentView addSubview:_robotSpeakLabel];
    }
    return _robotSpeakLabel;
}

- (XZTapLabel *)tapLabel {
    XZTapLabel *tapLabel = [[XZTapLabel alloc] init];
    tapLabel.backgroundColor = [UIColor clearColor];
    tapLabel.textColor = [UIColor whiteColor];
    tapLabel.font = FONTSYS(20);
    tapLabel.numberOfLines = 0;
    tapLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
    [tapLabel addGestureRecognizer:tap];

    return tapLabel;
}

- (NSMutableArray *)models {
    if (!_models) {
        _models = [[NSMutableArray alloc] init];
    }
    return _models;
}

- (NSMutableArray *)modelViews {
    if (!_modelViews) {
        _modelViews = [[NSMutableArray alloc] init];
    }
    return _modelViews;
}

- (void)showGuideView {
    if (_isFirst) {
        [self guideSpeakLabel];
    }
    _isFirst = NO;
}

- (void)hideGuideView {
    if (_guideSpeakLabel) {
        [_guideSpeakLabel removeFromSuperview];
        _guideSpeakLabel = nil;
    }
}

- (void)labelTaped:(UITapGestureRecognizer *)tap {
    
    XZTapLabel *view = (XZTapLabel *)tap.view;
    XZTextInfoModel *info = self.tapTextInfo;
    if (info.tapModel.count > 0) {
        CGPoint point = [tap locationInView:view];
        NSUInteger loca =  [view  locationForPoint:point];
        for (XZTextTapModel *model in info.tapModel) {
            if (NSLocationInRange(loca, model.range))  {
                if (self.interfaceCellClickTextBlock) {
                    self.interfaceCellClickTextBlock(model.text);
                }
                break;
            }
        }
    }
}

- (void)appendHumenText:(NSString *)text {
    NSString *string = [NSString stringWithFormat:@"%@%@",self.humenSpeakLabel.text,text];
    self.humenSpeakLabel.text = string;
    [self layoutHumenSpeakLabel];
}

- (void)showHumenText:(NSString *)text {
    _editButton.hidden = NO;
    _createCard.hidden = NO;
    _frequentView.hidden = NO;
    [self hideGuideView];
    self.humenSpeakLabel.text = text;
    [self layoutHumenSpeakLabel];
    [self checkHeight];
}

- (void)layoutHumenSpeakLabel {
    CGSize s = [_humenSpeakLabel sizeThatFits:CGSizeMake(self.width-40, 100)];
    _humenSpeakLabel.textAlignment =  s.height > _humenSpeakLabel.font.lineHeight+2 ? NSTextAlignmentLeft:NSTextAlignmentRight;
    CGFloat y = 20;
    [_humenSpeakLabel setFrame:CGRectMake(20, y, self.width-40, s.height)];
    y += _humenSpeakLabel.height+2;
    
    CGRect r = _editButton.frame;
    r.origin.y = y;
    r.origin.x = self.width-_editButton.width-20;
    _editButton.frame = r;
    
    y += _editButton.height+16;
    if (_createCard && y > _createCard.originY) {
        CGRect r = _createCard.frame;
        r.origin.y = y;
        _createCard.frame = r;
    }
    [self showLoadingView];
}

- (void)showRobotText:(NSString *)text {
    self.tapTextInfo = [self modelForMessage:text];
    self.robotSpeakLabel.attributedText = self.tapTextInfo.info;
    [self customLayoutSubviews];
    [self checkHeight];
    [self hideLoadingView];
}


- (void)showLoadingView {
    CGRect r = CGRectMake(10, CGRectGetMaxY(_editButton.frame)+10, [XZSpeechLoadingView defWidth], 40);
    if (!_loadingView) {
        _loadingView = [[XZSpeechLoadingView alloc] initWithFrame:r];
        [self.contentView addSubview:_loadingView];
    }
    _loadingView.frame = r;
    [_loadingView show];
}

- (void)hideLoadingView {
    [_loadingView hide];
}


- (CGFloat)webviewMaxWidth {
    //iPad 最长用768  防止横竖屏切换会闪，或显示不全
    return self.width;
//    CGFloat width = self.width > 768 ? 768: self.width;
//    return width;
}

- (void)showWebViewWithModel:(XZWebViewModel *)model {
    __weak typeof(self) weakSelf = self;
    XZTransWebViewController *webViewVC = [[XZTransWebViewController alloc] init];
    webViewVC.loadUrl = model.loadUrl;
    webViewVC.gotoParams = model.gotoParams;
    webViewVC.webviewFinishLoad = ^(CGFloat webHeight) {
        [weakSelf handleWebviewFinishLoad:webHeight];
    };
    webViewVC.viewRect = NSStringFromCGRect(CGRectMake(0, 0, [self webviewMaxWidth], 20));
    webViewVC.webViewModel = model;
    [self.contentView addSubview:webViewVC.view];
    model.viewController = webViewVC;
    _cardView = webViewVC.view;
    _cardView.frame =CGRectMake(0, CGRectGetMaxY(self.robotSpeakLabel.frame)+10, [self webviewMaxWidth], 20);
    _cardView.hidden = YES;
    self.robotSpeakLabel.hidden = YES;
    [self.models removeAllObjects];
    [self.models addObject:model];
   
    [self hideLoadingView];
    //干掉新建卡片
    [self hideCreateAppCard];
}

- (void)handleWebviewFinishLoad:(CGFloat)webHeight {
    XZWebViewModel *cellModel = [self.models firstObject];
    if (![cellModel isKindOfClass:[XZWebViewModel class]]) {
        cellModel = nil;
        return;
    }
    //设置webview 透明
    UIView *webView = cellModel.viewController.webView;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;

    cellModel.webviewHeight = webHeight;
    cellModel.viewController.viewRect = NSStringFromCGRect(CGRectMake(0, 0, [self webviewMaxWidth], webHeight));
    CGFloat orgY = self.robotSpeakLabel.height > 0 ? CGRectGetMaxY(self.robotSpeakLabel.frame)+10:CGRectGetMaxY(self.editButton.frame)+16;
    _cardView.frame = CGRectMake(0, orgY, [self webviewMaxWidth], webHeight);
    CGFloat height = CGRectGetMaxY(_cardView.frame)+kbottomHeight;
    if (_cellMinHeight < height && self.cardViewChangeHeight) {
        _cellHeight = height;
        self.cardViewChangeHeight();
    }
    else {
        [self customLayoutSubviews];
    }
    _cardView.hidden = NO;
    self.robotSpeakLabel.hidden = NO;
}

- (void)robotSpeakWithModels:(NSArray *)models {
    [self hideLoadingView];
    [self hideCreateAppCard];
    [self.models removeAllObjects];
    [self.models addObjectsFromArray:models];
    [self.modelViews removeAllObjects];

    CGFloat y = _robotSpeakLabel ? CGRectGetMaxY(_robotSpeakLabel.frame)+10: CGRectGetMaxY(self.editButton.frame) +16;
    for (XZCellModel *model in models) {
        if ([model isKindOfClass:[XZMemberModel class]]) {
            XZMemberModel *memberModel = (XZMemberModel *)model;
            XZMemberDetailView  *memberView = [[XZMemberDetailView alloc] initWithFrame:CGRectMake(0, y, self.width, [XZMemberDetailView viewHeight:memberModel.canOperate])];
            [memberView setupInfo:memberModel];
            [self.contentView addSubview:memberView];
            [self.modelViews addObject:memberView];
            y += memberView.height +10;
        }
        else if ([model isKindOfClass:[XZCancelModel class]]) {
            XZCancelCard *cardView = [[XZCancelCard alloc] initWithFrame:CGRectMake(14, y, self.width-28, [XZCancelCard viewHeight])];
            [self.contentView addSubview:cardView];
            [self.modelViews addObject:cardView];
            y += cardView.height +10;
        }
        else if ([model isKindOfClass:[XZOptionMemberModel class]]) {
            XZOptionMemberModel *memberModel = (XZOptionMemberModel *)model;
            XZOptionMemberView *cardView = [[XZOptionMemberView alloc] initWithFrame:CGRectMake(14, y, self.width-28, [XZOptionMemberView viewHeightForModel:memberModel])];
            [cardView setupWithModel:memberModel];
            [self.contentView addSubview:cardView];
            [self.modelViews addObject:cardView];
            y += cardView.height +10;
            _createCard.hidden = YES;
            _frequentView.hidden = YES;
        }
        else if ([model isKindOfClass:[XZScheduleModel class]]) {
            XZScheduleModel *memberModel = (XZScheduleModel *)model;
            XZScheduleView *cardView = [[XZScheduleView alloc] initWithFrame:CGRectMake(0, y, self.width, 100)];
            [cardView setupWithModel:memberModel];
            [self.contentView addSubview:cardView];
            [self.modelViews addObject:cardView];
            y += cardView.height +10;
            _createCard.hidden = YES;
            _frequentView.hidden = YES;
            memberModel.viewHeight = cardView.height;
        }
        else if ([model isKindOfClass:[XZLeaveTypesModel class]]) {
            XZLeaveTypesModel *memberModel = (XZLeaveTypesModel *)model;
            XZLeaveTypesView *cardView = [[XZLeaveTypesView alloc] initWithFrame:CGRectMake(0, y, self.width, INTERFACE_IS_PAD?30:70)];
            [cardView setupWithModel:memberModel];
            [self.contentView addSubview:cardView];
            [self.modelViews addObject:cardView];
            y += cardView.height +10;
            _createCard.hidden = YES;
            _frequentView.hidden = YES;
        }
        else if ([model isKindOfClass:[XZLeaveModel class]]) {
            XZLeaveModel *memberModel = (XZLeaveModel *)model;
            XZLeaveCard *cardView = [[XZLeaveCard alloc] initWithFrame:CGRectMake(0, y, self.width, [memberModel cellHeight]-20)];
            [cardView setupWithModel:memberModel];
            [self.contentView addSubview:cardView];
            [self.modelViews addObject:cardView];
            y += cardView.height +10;
            _createCard.hidden = YES;
            _frequentView.hidden = YES;
        }
        else {
            if (self.modelViews.count >0) {
                y -= 10;//cell已包含间隔
            }
            model.cellWidth = self.width;
            XZBaseTableViewCell *cell = [[NSClassFromString(model.cellClass) alloc] init];
            [cell setFrame:CGRectMake(0, y, self.width, [model cellHeight])];
            cell.model = model;
            [cell customLayoutSubviewsFrame:cell.frame];
            [self.contentView addSubview:cell];
            [self.modelViews addObject:cell];
            y += cell.height;
        }
    }
    
    UIView *view = self.modelViews.lastObject;
    CGFloat height = CGRectGetMaxY(view.frame)+kbottomHeight;
    if (_cellMinHeight < height && self.cardViewChangeHeight) {
        _cellHeight = height;
        self.cardViewChangeHeight();
    }
    [self hideLoadingView];
}

- (void)showCreateAppCardWithAppName:(NSString *)name infoList:(NSArray *)infoList {
    if (!_createCard) {
        _createCard = [[XZCreateAppIntentCard alloc] init];
        [self.contentView addSubview:_createCard];
    }
    _createCard.hidden = NO;
    [_createCard setupWithAppName:name infoList:infoList];
    CGFloat cheight = [_createCard viewHeightForWidth:self.width-28];
    _createCard.frame = CGRectMake(14, MAX( CGRectGetMaxY(_robotSpeakLabel.frame)+10, 101), self.width-28, cheight);
    CGFloat height = CGRectGetMaxY(_createCard.frame)+kbottomHeight;
    if (_frequentView && !_frequentView.hidden) {
        _frequentView.frame = CGRectMake(0, CGRectGetMaxY(_createCard.frame)+10, self.width,[XZFrequentView defaultHeight]);
        height = CGRectGetMaxY(_frequentView.frame)+kbottomHeight;
    }
    if (_cellMinHeight < height && self.cardViewChangeHeight) {
        _cellHeight = height;
        self.cardViewChangeHeight();
    }
}

- (void)checkHeight {
    CGFloat height = CGRectGetMaxY(_robotSpeakLabel.frame) +kbottomHeight;
    if (_createCard && !_createCard.hidden) {
        if (_frequentView && !_frequentView.hidden) {
            height = CGRectGetMaxY(_frequentView.frame)+kbottomHeight;
        }
        else {
            height = CGRectGetMaxY(_createCard.frame)+kbottomHeight;
        }
    }
    else if (_cardView) {
        height = CGRectGetMaxY(_cardView.frame)+kbottomHeight;
    }
    else if (self.modelViews.count >0) {
        UIView *view = [self.modelViews lastObject];
        height = CGRectGetMaxY(view.frame)+kbottomHeight;
    }
    if (_cellMinHeight < height && self.cardViewChangeHeight) {
        _cellHeight = height;
        self.cardViewChangeHeight();
    }
}

- (void)hideCreateAppCard {
    [_createCard removeFromSuperview];
    _createCard = nil;
    //干掉按钮
    NSMutableArray *tempArray = [NSMutableArray array];
    for (UIView *view in self.modelViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
            [tempArray addObject:view];
        }
    }
    [self.modelViews removeObjectsInArray:tempArray];
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 15;
    button.layer.masksToBounds = YES;
    CGSize s = [button.titleLabel sizeThatFits:CGSizeMake(200, 40)];
    NSInteger width = s.width+24;
    [button setFrame:CGRectMake(0, 0, width, 30)];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    if ([title rangeOfString:@"发送"].location != NSNotFound) {
        [button setBackgroundColor:UIColorFromRGB(0x297FFB)];
    }
    else {
        button.layer.borderWidth = 1;
        button.layer.borderColor = UIColorFromRGB(0x8a81a2).CGColor;
    }
    return button;
}

- (void)clickButton:(UIButton *)sender {
    if (self.interfaceCellClickTextBlock) {
        self.interfaceCellClickTextBlock(sender.titleLabel.text);
    }
}

- (void)showButtons:(NSArray *)array {
    if (_frequentView) {
        //有常用联系人不显示按钮，需求定的
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    for (UIView *view in self.modelViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
            [tempArray addObject:view];
        }
    }
    [self.modelViews removeObjectsInArray:tempArray];
    
    CGFloat x = 19;
    CGFloat y = CGRectGetMaxY(_robotSpeakLabel.frame)+10;
    if(_createCard) {
        y = CGRectGetMaxY(_createCard.frame)+10;
    }
    else if (self.modelViews.count >0) {
        UIView *view = [self.modelViews lastObject];
        y = CGRectGetMaxY(view.frame)+10;
    }
    for (NSString *title in array) {
        UIButton *button = [self buttonWithTitle:title];
        CGRect r = button.frame;
        r.origin.x = x;
        r.origin.y = y;
        button.frame = r;
        [self.contentView addSubview:button];
        [self.modelViews addObject:button];
        x += r.size.width+4;
    }

    UIView *view = self.modelViews.lastObject;
    CGFloat height = CGRectGetMaxY(view.frame)+kbottomHeight;
    if (_cellMinHeight < height && self.cardViewChangeHeight) {
        _cellHeight = height;
        self.cardViewChangeHeight();
    }
}

#pragma mark 常用联系人
- (void)showFrequentViewWithMembers:(NSArray *)members multi:(BOOL)multi{
    //先把取消按钮去掉
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.modelViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
            [array addObject:view];
        }
    }
    [self.modelViews removeObjectsInArray:array];
    
    //显示常用联系人
    CGFloat y = _createCard? CGRectGetMaxY(_createCard.frame)+10:CGRectGetMaxY(_robotSpeakLabel.frame)+10;
    CGFloat height = [XZFrequentView defaultHeight];
    if (!_frequentView) {
        _frequentView = [[XZFrequentView alloc] initWithFrame:CGRectMake(0, y, self.width,height)];
        [self.contentView addSubview:_frequentView];
        _frequentView.backgroundColor = [UIColor clearColor];
    }
    _frequentView.frame = CGRectMake(0, y, self.width,height);
    _frequentView.members = members;
    _frequentView.isMultiSelect = multi;
    [self customLayoutSubviews];
}

- (void)hideFrequentView {
    [_frequentView removeFromSuperview];
    _frequentView = nil;
}

- (void)showOptionIntents:(NSArray *)array {
    [self hideLoadingView];
    [self.robotSpeakLabel setText:kChooseIntentInfo];
    XZOptionIntentsView *view = [[XZOptionIntentsView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxX(_robotSpeakLabel.frame)+10, self.width, [XZOptionIntentsView viewHeight:array.count])];
    [view setupData:array];
    [self.contentView addSubview:view];
    _cardView = view;
    [self customLayoutSubviews];
    [self checkHeight];
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [self customLayoutSubviews];
}

- (void)customLayoutSubviews {
    CGSize s = [_humenSpeakLabel sizeThatFits:CGSizeMake(self.width-40, 100)];
    _humenSpeakLabel.textAlignment =  s.height > _humenSpeakLabel.font.lineHeight+2 ? NSTextAlignmentLeft:NSTextAlignmentRight;
    CGFloat y = 20;
    [_humenSpeakLabel setFrame:CGRectMake(20, y, self.width-40, s.height)];
    y += _humenSpeakLabel.height+2;
    
    CGRect r = _editButton.frame;
    r.origin.y = y;
    r.origin.x = self.width-_editButton.width-20;
    _editButton.frame = r;
  
    y += _editButton.height+16;
    if (_robotSpeakLabel) {
        s = [_robotSpeakLabel sizeThatFits:CGSizeMake(self.width-40, 100)];
        [_robotSpeakLabel setFrame:CGRectMake(20, y, self.width-40, s.height)];
        y += _robotSpeakLabel.height+10;
    }
    if (_cardView) {
        XZWebViewModel *model = self.models.firstObject;
        if (model && [model isKindOfClass:[XZWebViewModel class]]) {
            CGRect  r = _cardView.frame;
            r.origin.y = y;
            r.size.width = self.width-r.origin.x*2;
            r.size.height = model.webviewHeight;
            _cardView.frame = r;
            XZWebViewModel *model = self.models.firstObject;
            XZTransWebViewController *controller = model.viewController;
            controller.viewRect = NSStringFromCGRect(_cardView.bounds);
        }
        else {
            CGRect  r = _cardView.frame;
            r.origin.y = y;
            r.size.width = self.width-r.origin.x*2;
            _cardView.frame = r;
        }
    }
    if (_createCard && !_createCard.hidden) {
        CGFloat cheight = [_createCard viewHeightForWidth:self.width-28];
        CGRect r = _createCard.frame;
        if (_robotSpeakLabel.text.length >0) {
            r.origin.y = CGRectGetMaxY(_robotSpeakLabel.frame)+10;
        }
        r.size.width = self.width-28;
        r.size.height = cheight;
        _createCard.frame = r;
    }
    if (_frequentView) {
        CGRect  r = _frequentView.frame;
        r.origin.y = _createCard && !_createCard.hidden? CGRectGetMaxY(_createCard.frame)+10:CGRectGetMaxY(_robotSpeakLabel.frame)+10;
        r.size.width = self.width;
        _frequentView.frame = r;
    }
    
    CGFloat btnY = _createCard && !_createCard.hidden? CGRectGetMaxY(_createCard.frame)+10:y;
    for (UIView *aview in self.modelViews) {
        CGRect r = aview.frame;
        r.origin.y = btnY;
        if (![aview isKindOfClass:[UIButton  class]]) {
            r.size.width = self.width-r.origin.x*2;
        }
        aview.frame = r;
    }
}

- (NSArray *)cellModels {
    NSMutableArray *result = [NSMutableArray array];
    if (_humenSpeakLabel.text.length > 0) {
        [result addObject:[XZMainCellModel humenSpeak:_humenSpeakLabel.text alignment:_humenSpeakLabel.textAlignment]];
    }
    if (_robotSpeakLabel.text.length > 0) {
        [result addObject:[XZMainCellModel robotSpeak:_robotSpeakLabel.text ]];
    }
    for (XZCellModel *model in self.models) {
        if ([model isKindOfClass:[XZMemberModel class]]) {
            XZMemberModel *memberModel = (XZMemberModel *)model;
            //因为要关联其他的意图，如打电话，发短信，就重新建一个model
            XZMemberModel *historyhModel = [[XZMemberModel alloc] init];
            historyhModel.member = memberModel.member;
            historyhModel.cellClass = memberModel.cellClass;
            historyhModel.canOperate = NO;
            [result addObject:historyhModel];
        }
        else if ([model isKindOfClass:[XZOptionMemberModel class]]) {
            //历史记录重复人员不显示卡片，只显示提示文字
            XZOptionMemberModel *optionModel = (XZOptionMemberModel *)model;
            optionModel.canOperate = YES;
            [result addObject:[XZMainCellModel robotSpeak:optionModel.param.showContent]];
        }
        else if ([model isKindOfClass:[XZWebViewModel class]]){
            XZWebViewModel *webModel = (XZWebViewModel *)model;
            if (webModel.showInHistory) {
                [result addObject:model];
            }
            else {
                webModel.nav = nil;
                webModel.viewController.webViewModel = nil;
                webModel.viewController = nil;
            }
        }
        else if (![model isKindOfClass:[XZLeaveTypesModel class]]){
            [result addObject:model];
        }
    }
    return result;
}

- (void)clearData {
    _humenSpeakLabel.text = @"";
    _robotSpeakLabel.text = @"";
    [_robotSpeakLabel removeFromSuperview];
    _robotSpeakLabel = nil;
    _editButton.hidden = YES;
    

    if ([[_models firstObject] isKindOfClass:[XZWebViewModel class]]) {
        XZWebViewModel *model = [_models firstObject];
        if (model.canDisappear) {
            [_cardView removeFromSuperview];
            _cardView  = nil;
            [_models removeAllObjects];
        }
    }
    else {
        [_cardView removeFromSuperview];
        _cardView  = nil;
        [_models removeAllObjects];

    }

    _cellHeight = _cellMinHeight;
    for (UIView *view in self.modelViews) {
        [view removeFromSuperview];
    }
    [self.modelViews removeAllObjects];
}

- (void)clearCreateCard {
    [_createCard removeFromSuperview];
    _createCard = nil;
}

- (NSString *)humenText {
    return _humenSpeakLabel.text;
}

- (XZTextInfoModel *)modelForMessage:(NSString*)msg {
    UIColor *textColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:20];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor,NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:msg attributes:attributes];
    //    NSString *pattern = @"##[^#]+##";
    //    NSString *pattern = @"\\[([^\\]]*?)\\]\\(([^\\]]*?)\\)";//识别[xxx](xxx)
    NSString *pattern = kXZTextModelPattern;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regex matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
    __weak typeof(self) weakSelf = self;
    NSMutableArray * tapModels = [NSMutableArray array];
    __block NSInteger deleteLenght = 0;
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.range;
        NSRange rang1 = [obj rangeAtIndex:1];
        NSRange rang2 = [obj rangeAtIndex:2];
        NSRange rang3 = [obj rangeAtIndex:3];
        NSString *showStr = nil;
        NSString *valueStr = nil;
        if (rang1.location != NSNotFound) {
            //##xx##
            showStr = [msg substringWithRange:NSMakeRange(rang1.location+2, rang1.length-4)];
            valueStr = showStr;
        }
        else {
            //[XX](XX)
            showStr = [msg substringWithRange:rang2];
            valueStr = [msg substringWithRange:rang3];
            if ([NSString isNull:valueStr]) {
                valueStr = showStr;
            }
        }
        UIColor *replaceColor = UIColorFromRGB(0xff9601);
        if (![weakSelf cannotTapString:showStr] ) {
            replaceColor = UIColorFromRGB(0x1865ef);
        }
        NSDictionary *replaceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:replaceColor,NSForegroundColorAttributeName,font,NSFontAttributeName, nil];
        NSMutableAttributedString *replaceString = [[NSMutableAttributedString alloc] initWithString:showStr attributes:replaceAttributes];
        
        NSRange replacedRange = NSMakeRange(range.location-deleteLenght, range.length);
        [attributedString replaceCharactersInRange:replacedRange withAttributedString:replaceString];
        NSRange repaceRange = NSMakeRange(range.location-deleteLenght, showStr.length);
        if (![weakSelf cannotTapString:showStr]) {
            XZTextTapModel *model = [[XZTextTapModel alloc] init];
            model.range = repaceRange;
            model.text = showStr;
            model.valueStr = valueStr;
            model.tapType = XZTextTapTypeNormal;
            [tapModels addObject:model];
        }
        deleteLenght += (range.length - showStr.length);
    }];
    
    XZTextInfoModel *model = [[XZTextInfoModel alloc] init];
    model.info = attributedString;
    model.tapModel = tapModels;
    return model;
}

- (BOOL)cannotTapString:(NSString *)string {
    NSArray *array = [NSArray arrayWithObjects:@"小明", nil];
    return [array containsObject:string];
}


@end
