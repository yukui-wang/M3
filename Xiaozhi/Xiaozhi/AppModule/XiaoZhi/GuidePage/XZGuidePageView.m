//
//  XZGuidePageView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuidePageView.h"
#import "XZGuidePage.h"
#import "XZCore.h"
#import "XZGuidePageCell.h"

@interface XZGuidePageView () {
    
}
@property(nullable,strong)XZGuidePage *guidePage;

@end


@implementation XZGuidePageView

- (void)setup {
    
    if (!_bkView) {
        _bkView = [[UIView alloc] init];
        [self addSubview:_bkView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font =  FONTSYS(26);
        _titleLabel.text = @"你可以这样问我：";
        _titleLabel.numberOfLines = 0;
        [_bkView addSubview:_titleLabel];
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_bkView addSubview:_tableView];
    }
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        [_bkView addSubview:_topLine];
    }
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        [_bkView addSubview:_bottomLine];
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.guidePage = [XZCore sharedInstance].guidePage;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dididEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dididEnterBackground {
    if (_subPageView && _subPageView.originX != 0) {
        [self removeSubPageView];
        [_bkView setFrame:self.bounds];
    }
}

- (void)layoutSubviewsFrame {
    CGSize s = [_titleLabel sizeThatFits:CGSizeMake(self.width-40, 200)];
    NSInteger height = s.height+1;
    [_titleLabel setFrame:CGRectMake(20, 4, self.width-40, height)];
    [_topLine setFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+10, self.width, 0.5)];
    [_bottomLine setFrame:CGRectMake(0, _bkView.height-0.5, self.width, 0.5)];
    [_tableView setFrame:CGRectMake(0, _topLine.originY, self.width , _bkView.height-_topLine.originY)];

}

- (void)customLayoutSubviews {
    if (_subPageView) {
        CGRect f = self.bounds;
        [_subPageView setFrame:f];
        f.origin.x = -f.size.width;
        [_bkView setFrame:f];
    }
    else {
        [_bkView setFrame:self.bounds];
    }
    [self layoutSubviewsFrame];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _guidePage.pages.count ;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [XZGuidePageCell cellHeight];
    NSInteger row = indexPath.row;
    if (row == 0 ) {
        height += 5;
    }
    if (row == _guidePage.pages.count-1) {
        height += 5;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSString *identifierStr = @"XZGuidePageViewCell";
    XZGuidePageCell *cell = (XZGuidePageCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        cell = [[XZGuidePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    if (row < _guidePage.pages.count) {
        [cell setupPageItem:_guidePage.pages[row] isTop:row==0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row < _guidePage.pages.count) {
        XZGuidePageItem *item = _guidePage.pages[row];
        [self showSubPageView:item];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView  {
    if (_tableView.contentOffset.y < - _tableView.height/4) {
        if (self.shouldDismissBlock) {
            self.shouldDismissBlock();
        }
    }
}

- (void)showSubPageView:(XZGuidePageItem *)item {
    _subPageView = [[XZGuideSubPageView alloc] initWithFrame:CGRectMake(self.width, 0, self.width, self.height) pageItem:item];
    [self addSubview:_subPageView];
    [_subPageView.backBtn addTarget:self action:@selector(hideSubGuidePageView) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = weakSelf.bounds;
        f.origin.x = -weakSelf.width;
        [weakSelf.bkView setFrame:f];
        f.origin.x = 0;
        weakSelf.subPageView.frame = f;
    } ];
    if (INTERFACE_IS_PHONE) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [_subPageView addGestureRecognizer:panGesture];
        _tableView.userInteractionEnabled = NO;
    }
}

- (void)hideSubGuidePageView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = weakSelf.bounds;
        f.origin.x = 0;
        [weakSelf.bkView setFrame:f];
        f.origin.x = weakSelf.width;
        weakSelf.subPageView.frame = f;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf removeSubPageView];
        }
    }];
}

- (void)removeSubPageView {
    [_subPageView removeFromSuperview];
    _subPageView = nil;
    [self customLayoutSubviews];
    //防止界面混乱。多手指操作
    _tableView.userInteractionEnabled = YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint translate = [gestureRecognizer locationInView:_subPageView];
    if (translate.x < 50) {
        return YES;
    }
    return NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point_inView = [panGesture translationInView:_subPageView];
        if (point_inView.x > 0) {
            CGRect f = self.bounds;
            f.origin.x = point_inView.x;
            [_subPageView setFrame:f];
            f.origin.x = point_inView.x -self.width;
            self.bkView.frame = f;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point_inView = [panGesture translationInView:_subPageView];
        if (point_inView.x > 0) {
            [self hideSubGuidePageView];
        }
    }
}



@end
