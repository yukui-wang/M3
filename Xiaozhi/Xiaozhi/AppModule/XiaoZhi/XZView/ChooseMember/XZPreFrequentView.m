//
//  XZFrequentView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZPreFrequentView.h"
#import "XZModelButton.h"
#import <CMPLib/CMPOfflineContactMember.h>

@interface XZPreFrequentView () {
    UILabel *_infoLabel;
    UIScrollView *_contentView;
    UIButton *_sendButton;
    UIButton *_moreButton;

    NSMutableArray *_memberInfoList;
    NSInteger _selectCount;
    BOOL _isFirst;
}

@end

@implementation XZPreFrequentView

- (void)dealloc {
    SY_RELEASE_SAFELY(_members);
    SY_RELEASE_SAFELY(_infoLabel);
    SY_RELEASE_SAFELY(_contentView);
    SY_RELEASE_SAFELY(_memberInfoList);
    [super dealloc];
}

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
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setImage:XZ_IMAGE(@"xz_member_send_n.png") forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_sendButton];
    }
    if (!_moreButton) {
        _moreButton = [self btnWithTitle:@"更多"];
        [_moreButton setTitleColor:UIColorFromRGB(0x006ff1) forState:UIControlStateNormal];

        [_contentView addSubview:_moreButton];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    _sendButton.userInteractionEnabled = NO;
}

- (void)clearSelect {
    for (XZModelButton *btn in _memberInfoList) {
        btn.selected = NO;
        btn.backgroundColor = [UIColor whiteColor];
    }
    _selectCount = 0;
    _sendButton.userInteractionEnabled = NO;
    [_sendButton setImage:XZ_IMAGE(@"xz_member_send_n.png") forState:UIControlStateNormal];
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
    [button setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
    return button;
}

- (void)moreButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(frequentView:showSelectMemberView:)]) {
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
    sender.backgroundColor = sender.selected ? UIColorFromRGB(0xe3eefc) : [UIColor whiteColor];
    sender.selected ? _selectCount++:_selectCount--;
    _sendButton.userInteractionEnabled = _selectCount > 0;
    NSString *image = _selectCount > 0 ? @"xz_member_send.png" :@"xz_member_send_n.png";
    [_sendButton setImage:XZ_IMAGE(image) forState:UIControlStateNormal];
}

- (void)showAnimations {
    [self customLayoutViews];
    CGRect r = _contentView.frame;
    r.origin.x = self.width;
    _contentView.frame = r;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    r.origin.x = 0;
    _contentView.frame = r;
    [UIView commitAnimations];
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
    if (_isMultiSelect) {
        [_sendButton setFrame:CGRectMake(self.width-44, y, 32, 32)];
        [_contentView setFrame:CGRectMake(0, y, self.width-60, 30)];
    }
    else {
        [_contentView setFrame:CGRectMake(0, y, self.width, 30)];
    }
}

+ (CGFloat)defaultHeight {
    NSInteger h = FONTSYS(12).lineHeight +1;
    h += 8+30 +10;
    return h;
}


- (void)setIsMultiSelect:(BOOL)isMultiSelect {
    _isMultiSelect = isMultiSelect;
    _sendButton.hidden = !isMultiSelect;
    _moreButton.hidden = !isMultiSelect;
    [self loadData];
}


- (void)didSelectedMembers:(NSArray *)members
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(frequentView:didFinishSelectMember:)]) {
        [self.delegate frequentView:self didFinishSelectMember:members];
    }
}


@end
