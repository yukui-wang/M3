//
//  XZFrequentView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZFrequentView.h"
#import "XZModelButton.h"
#import <CMPLib/CMPOfflineContactMember.h>

@interface XZFrequentView () {
    UILabel *_infoLabel;
    UIScrollView *_contentView;
    UIButton *_sendButton;
    UIButton *_moreButton;

    NSMutableArray *_memberInfoList;
    NSInteger _selectCount;
    BOOL _isFirst;
}

@end

@implementation XZFrequentView

- (void)setup {
    _isFirst = YES;
    if (!_infoLabel) {
        _infoLabel= [[UILabel alloc] init];
        _infoLabel.text = @"常用联系人";
        _infoLabel.font = FONTSYS(12);
        _infoLabel.textColor = UIColorFromRGB(0x7f7f7f);
        [self addSubview:_infoLabel];
    }
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        [self addSubview:_contentView];
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
    }

    if (!_moreButton) {
        _moreButton = [self btnWithTitle:@"更多"];
        [_moreButton setTitleColor:UIColorFromRGB(0x006ff1) forState:UIControlStateNormal];
        _moreButton.backgroundColor = UIColorFromRGB(0x297FFB);
        [_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _moreButton.layer.cornerRadius = 15;
        _moreButton.layer.masksToBounds = YES;
        _moreButton.layer.borderWidth = 0;
        [_contentView addSubview:_moreButton];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    }
}

- (void)clearSelect {
    for (XZModelButton *btn in _memberInfoList) {
        btn.selected = NO;
        btn.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        btn.backgroundColor = [UIColor clearColor];
    }
    _selectCount = 0;
    [self hideSendButton];
}

- (NSArray *) selectMembers {
    NSMutableArray *selects = [NSMutableArray array];
    for (XZModelButton *btn in _memberInfoList) {
        if (btn.selected) {
            [selects addObject:btn.info];
        }
    }
    return selects;
}

- (void)loadData {
    if (!_isFirst) {
        return;
    }
    _isFirst = NO;
    [self handleFrequentContact:self.members];
}

- (void)handleFrequentContact:(NSArray *)array {
    if (!_memberInfoList) {
        _memberInfoList = [[NSMutableArray alloc] init];
    }
    for (CMPOfflineContactMember *member in array) {
        XZModelButton *button = [self btnWithTitle:member.name];
        [_contentView addSubview:button];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_memberInfoList addObject:button];
        button.info = member;
    }
    [self showAnimations];
}

- (XZModelButton *)btnWithTitle:(NSString *)title {
    XZModelButton *button = [XZModelButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(14);
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    return button;
}

- (void)moreButtonAction:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(frequentView:showSelectMemberView:)]) {
        [self.delegate frequentView:self showSelectMemberView:_isMultiSelect];
    }
}

- (void)sendButtonAction:(id)sender {
    [self didSelectedMembers:[self selectMembers]];
    [self clearSelect];
}

- (void)buttonClick:(XZModelButton *)sender {
    if (!_isMultiSelect) {
        self.userInteractionEnabled = NO;
        [self didSelectedMembers:[NSArray arrayWithObject:sender.info]];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.layer.borderColor = UIColorFromRGB(0x297FFB).CGColor;
        sender.backgroundColor =RGBACOLOR(41, 127, 251, 0.2);
    }
    else {
        sender.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        sender.backgroundColor = [UIColor clearColor];
    }
    sender.selected ? _selectCount++:_selectCount--;
    _selectCount > 0 ?[self showSendButton]:[self hideSendButton];
}

- (void)showSendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setImage:XZ_IMAGE(@"xz_member_send.png") forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendButton];
        [_sendButton setFrame:CGRectMake(self.width-44,CGRectGetMaxY(_contentView.frame)+14, 32, 32)];
    }
}

- (void)hideSendButton {
    [_sendButton removeFromSuperview];
    _sendButton = nil;
}


- (void)showAnimations {
    [self customLayoutViews];
    CGRect r = _contentView.frame;
    r.origin.x = self.width;
    _contentView.frame = r;
    r.origin.x = 0;
    __weak typeof(_contentView) weakView = _contentView;
    [UIView animateWithDuration:0.5 animations:^{
        weakView.frame = r;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)customLayoutSubviews {
    [self customLayoutViews];
}
- (void)customLayoutViews
{
    NSInteger h = FONTSYS(12).lineHeight +1;
    [_infoLabel setFrame:CGRectMake(18, 0, 100, h)];
    CGFloat y = h + 8;
    CGFloat x = 12;
    for (XZModelButton *btn in _memberInfoList) {
       CGSize s = [btn.titleLabel.text sizeWithFontSize:FONTSYS(14) defaultSize:CGSizeMake(CGFLOAT_MAX, 30)];
        NSInteger width = s.width+24;
        [btn setFrame:CGRectMake(x, 0, btn.memberWidth, 30)];
        x += width+10;
    }
    if (_moreButton && !_moreButton.hidden) {
        [_moreButton setFrame:CGRectMake(x, 0, 48, 30)];
        x += _moreButton.width+10;
    }
    [_contentView setContentSize:CGSizeMake(x, 30)];
    [_contentView setFrame:CGRectMake(0, y, self.width, 30)];
    if (_sendButton && !_sendButton.hidden) {
        [_sendButton setFrame:CGRectMake(self.width-44,CGRectGetMaxY(_contentView.frame)+14, 32, 32)];
    }

}

+ (CGFloat)defaultHeight {
    NSInteger h = FONTSYS(12).lineHeight +1;
    h += 94;//8+30+14+32+10
    return h;
}


- (void)setIsMultiSelect:(BOOL)isMultiSelect {
    _isMultiSelect = isMultiSelect;
    _moreButton.hidden = !isMultiSelect;
    [self loadData];
}

- (void)didSelectedMembers:(NSArray *)members {
    if(self.delegate && [self.delegate respondsToSelector:@selector(frequentView:didFinishSelectMember:)]) {
        [self.delegate frequentView:self didFinishSelectMember:members];
    }
}

@end
