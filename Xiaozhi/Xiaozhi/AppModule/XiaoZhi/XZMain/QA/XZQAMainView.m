//
//  XZQAMainView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAMainView.h"
#import "SPTools.h"
@interface XZQAMainView () <UIGestureRecognizerDelegate>{
    CGFloat _keyboardHeight;
    NSMutableArray *_keywordBtnArray;
}
@end

@implementation XZQAMainView

- (void)setup {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.bounces = NO;
        [self addSubview:_tableView];
    }
    if (!_keyWordsView) {
        _keyWordsView = [[UIScrollView alloc] init];
        [self addSubview:_keyWordsView];
    }
    if (!_bottomBar) {
        _bottomBar = [[XZQABottomBar alloc] init];
        [self addSubview:_bottomBar];
    }
    if (!_bottomBarCoverView) {
        _bottomBarCoverView = [[XZQABottomCoverView alloc] init];
        [self addSubview:_bottomBarCoverView];
    }
    _bottomBarCoverView.hidden = YES;
    [self addNotifications];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    [_tableView addGestureRecognizer:tapGestureRecognizer];
}


- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self endEditing:YES];
}

- (void)showKeyWords:(NSArray *)keyWords {

    for (UIButton *btn in _keywordBtnArray) {
        [btn removeFromSuperview];
    }
    [_keywordBtnArray removeAllObjects];
    
    if (keyWords && keyWords.count > 0) {
         CGFloat x = 14;
        if (!_keywordBtnArray) {
            _keywordBtnArray = [[NSMutableArray alloc] init];
        }
        for (NSDictionary *keyWordDic in keyWords) {
            NSString *keyWord = keyWordDic[@"keywordText"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitleColor:UIColorFromRGB(0x586A95) forState:UIControlStateNormal];
            [button setTitle:keyWord forState:UIControlStateNormal];
            button.titleLabel.font = FONTSYS(14);
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 15;
            button.layer.masksToBounds = YES;
            CGSize size = [button.titleLabel sizeThatFits:CGSizeMake(10000000, button.titleLabel.font.lineHeight)];
            NSInteger width = size.width+1+28;
            [_keyWordsView addSubview:button];
            [button addTarget:self action:@selector(clickKeywords:) forControlEvents:UIControlEventTouchUpInside];
            if (x+width <= self.width && x+width+6 >self.width) {
                x += 6;
            }
            [button setFrame:CGRectMake(x, 6, width, 30)];
            x += button.width+6;
            [_keywordBtnArray addObject:button];
        }
        __weak typeof(self) wSelf= self;
        [self dispatchSyncToMain:^{
            [wSelf.keyWordsView setContentSize:CGSizeMake(x, wSelf.keyWordsView.height)];
            [wSelf.keyWordsView setFrame:CGRectMake(0, 0, 0, 42)];
            [wSelf customLayoutSubviews];
        }];
    }
}

- (void)customLayoutSubviews {
    CGFloat bottomSafeAreaH = _keyboardHeight  > 0 ? 0 : [SPTools xzSafeAreaInsets].bottom;
    CGFloat bHeight =  _bottomBar.viewHeight;
    [_bottomBar setFrame:CGRectMake(0, self.height-bHeight-_keyboardHeight-bottomSafeAreaH, self.width, bHeight)];
    CGFloat kHeight = _keyWordsView.height;
    [_keyWordsView setFrame:CGRectMake(0, _bottomBar.originY-kHeight, self.width, kHeight)];
    [_tableView setFrame:CGRectMake(0, 0, self.width, _keyWordsView.originY)];
    
    _bottomBarCoverView.frame = _bottomBar.frame;

}
- (void)clickKeywords:(UIButton *)btn {
    if (_bottomBar.inputContentBlock) {
        _bottomBar.inputContentBlock(btn.titleLabel.text);
    }
}

- (void)keyboardWillShow:(NSNotification *)noti{
    NSDictionary *obj = [noti userInfo];
    CGRect keyboardRect = [[obj objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:aDuration animations:^{
        [weakSelf customLayoutSubviews];
        [weakSelf scrollToBottom];
    } completion:^(BOOL finished) {
        
    }];
   
}

- (void)keyboardWillHide:(NSNotification *)noti{
    _keyboardHeight = 0;
    NSDictionary *obj = [noti userInfo];
    CGFloat aDuration = [[obj objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:aDuration animations:^{
        [weakSelf customLayoutSubviews];
    } completion:^(BOOL finished) {
        
    }];
}
- (void)keyboardShowStop {
    [self scrollTableViewBottom];
}
- (void)keyboardHideStop {
    
}

#pragma mark start

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollTableViewBottom {
    [_tableView  reloadData];
    NSInteger count = [_tableView numberOfRowsInSection:0];
    if (count >2) {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
        NSIndexPath *prePath = [NSIndexPath indexPathForRow:count-2 inSection:0];
        CGFloat lastHeight = [_tableView rectForRowAtIndexPath:lastPath].size.height;
        CGFloat preHeight = [_tableView rectForRowAtIndexPath:prePath].size.height;
        CGFloat tHeight = _tableView.height;
        if (lastHeight + preHeight >= tHeight ) {
            [_tableView scrollToRowAtIndexPath:prePath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else {
            [_tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
- (void)scrollToBottom{
    NSInteger count = [_tableView numberOfRowsInSection:0];
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
@end
