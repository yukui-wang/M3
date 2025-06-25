//
//  XZMainMemberCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZOptionMemberCell.h"
#import "XZOptionMemberModel.h"
#import "XZModelButton.h"
#import "XZTapLabel.h"
@interface XZOptionMemberCell() {
    UILabel *_contentLabel;
    NSMutableArray *_buttonList;
}

@end

@implementation XZOptionMemberCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_contentLabel);
    SY_RELEASE_SAFELY(_buttonList);
    [super dealloc];
}

- (void)setup {
    [super setup];
    if (!_contentLabel) {
        _contentLabel = [[XZTapLabel alloc] init];
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.numberOfLines = 0;
        [_contentBGView addSubview:_contentLabel];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTaped:)];
        [_contentLabel addGestureRecognizer:tap];
        SY_RELEASE_SAFELY(tap);
    }
}

- (void)labelTaped:(UITapGestureRecognizer *)tap {
    XZOptionMemberModel *textModel = (XZOptionMemberModel *)self.model;
    if( !textModel.canOperate) {
        return;
    }
    XZTapLabel *view = (XZTapLabel *)tap.view;
    XZTextInfoModel *info = textModel.textInfo;
    if (info.tapModel.count > 0) {
        CGPoint point = [tap locationInView:view];
        NSUInteger loca =  [view  locationForPoint:point];
        for (XZTextTapModel *model in info.tapModel) {
            if (NSLocationInRange(loca, model.range))  {
                textModel.canOperate = NO;
                if (textModel.clickTextBlock) {
                    textModel.clickTextBlock(model.text);
                }
//                [textModel cellHeight];
//                [self setModel:textModel];
                break;
            }
        }
    }
}

- (void)customLayoutSubviewsFrame:(CGRect)frame {
    XZOptionMemberModel *model = (XZOptionMemberModel *)self.model;
    [_iconView setFrame:CGRectMake(12, 0, 36, 36)];
    [_contentBGView setFrame:CGRectMake(54, 0, model.lableWidth +31, model.lableHeight+20)];
    _iconView.image = XZ_IMAGE(@"xz_icon_cell.png");
    _contentBGView.image = [XZ_IMAGE(@"xz_chat_robot.png") resizableImageWithCapInsets:UIEdgeInsetsMake(19, 24, 19, 18) resizingMode:UIImageResizingModeStretch];
    [_contentLabel setFrame:CGRectMake(18, 10, model.lableWidth, model.lableHeight)];
    
}

- (void)setModel:(XZOptionMemberModel *)model {
    [super setModel:model];
    [_contentLabel setAttributedText:model.textInfo.info];
    if (_buttonList && _buttonList.count >0) {
        if (!model.canOperate) {
            for (UIButton *button in _buttonList) {
                button.userInteractionEnabled = NO;
            }
        }
        return;
    }
    if (!_buttonList) {
        _buttonList = [[NSMutableArray alloc] init];
    }
    for (NSDictionary *dic in model.showInfoList) {
        XZModelButton *button = [self buttonWithInfo:dic];
        [self addSubview:button];
        [button addTarget:self action:@selector(clickMemberButton:) forControlEvents:UIControlEventTouchUpInside];
    }

    [self customLayoutSubviewsFrame:self.frame];
}

- (XZModelButton *)buttonWithInfo:(NSDictionary *)info {
    NSString *title = info[@"title"];
    CMPOfflineContactMember *member = info[@"member"];
    CGFloat orgY = [info[@"orgY"] floatValue];
    CGSize size = CGSizeFromString(info[@"size"]);

    XZModelButton *button = [XZModelButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.cornerRadius = 12;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    button.info = member;
    [button setFrame:CGRectMake(65, orgY, size.width, size.height)];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    return button;
}

- (void)clickMemberButton:(XZModelButton *)button {
    XZOptionMemberModel *model = (XZOptionMemberModel *)self.model;
    if (model.canOperate) {
        model.canOperate = NO;
        if (model.didChoosedMembersBlock) {
            model.didChoosedMembersBlock(@[button.info],YES);
        }
    }
}

@end
