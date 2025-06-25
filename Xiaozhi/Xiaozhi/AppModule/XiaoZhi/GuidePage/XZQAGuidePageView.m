//
//  XZQAGuidePageView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAGuidePageView.h"
#import "XZQAGuideTips.h"
#import "XZQAGuidePageHeaderCell.h"
#import "XZQAGuidePageCell.h"

@implementation XZQAGuidePageView
- (id)initWithQAInfo:(XZQAGuideInfo *)guideInfo {
    if (self = [super init]) {
        self.guideInfo = guideInfo;
        self.titleLabel.text = self.guideInfo.welcoming;
    }
    return self;
}
- (void)dididEnterBackground {
    if (_subPage && _subPage.originX != 0) {
        [self removeSubPageView];
        [self.tableView setFrame:self.bounds];
    }
}

- (void)customLayoutSubviews {
    if (_subPage) {
        CGRect f = self.bounds;
        [_subPage setFrame:f];
        f.origin.x = -f.size.width;
        [self.bkView setFrame:f];
    }
    else {
        [self.bkView setFrame:self.bounds];
    }
    [self layoutSubviewsFrame];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _guideInfo.tipsSet.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    UIColor *color = section == _guideInfo.tipsSet.count-1 ?[UIColor clearColor]:[UIColor colorWithWhite:1 alpha:0.15];//之后一组不显示分割线
    [view setBackgroundColor:color];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section < _guideInfo.tipsSet.count) {
        XZQAGuideTips *tips = _guideInfo.tipsSet[section];
        return MIN(3, tips.tips.count+1);
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;

    if (section < _guideInfo.tipsSet.count) {
        XZQAGuideTips *tips = _guideInfo.tipsSet[section];
        NSInteger row = indexPath.row;
        if (row == 0) {
            return [XZQAGuidePageHeaderCell cellHeightForText:tips.tipsSetName width:self.width];
        }
        else {
            CGFloat height = [XZQAGuidePageCell cellHeightForText:tips.tips[row-1] width:self.width];
            if (row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
                //最后一行+12
                height += 12;
            }
            return height;
        }
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section  >= _guideInfo.tipsSet.count) {
        NSString *identifierStr = @"customCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
        }
        return cell;
    }
    XZQAGuideTips *tips = _guideInfo.tipsSet[section];
    if (row == 0) {
        //tipsSetName
        NSString *identifierStr = @"XZGuidePageViewCellheader";
        XZQAGuidePageHeaderCell *cell = (XZQAGuidePageHeaderCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
        if (!cell) {
            cell = [[XZQAGuidePageHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
        }
        cell.titleLabel.text = tips.tipsSetName;
        cell.pushImgView.hidden = ![tips showMore];
        return cell;
    }
    //具体的tips
    NSString *identifierStr = @"XZGuidePageViewCell";
    XZQAGuidePageCell *cell = (XZQAGuidePageCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        cell = [[XZQAGuidePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    cell.titleLabel.text = tips.tips[row-1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    if (section >= 0 && section < _guideInfo.tipsSet.count) {
        XZQAGuideTips *tips = _guideInfo.tipsSet[section];
        if (row == 0) {
            if ([tips showMore]) {
                [self showQASubPageView:tips];
            }
        }
        else if (row < tips.tips.count+1) {
            NSString *text = tips.tips[row-1];
            if (self.clickTextBlock) {
                self.clickTextBlock(text);
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showQASubPageView:(XZQAGuideTips *)tip {
    _subPage = [[XZQAGuideSubPageView alloc] init];
    _subPage.guideTips = tip;
    _subPage.clickTextBlock = self.clickTextBlock;
    [_subPage.backBtn addTarget:self action:@selector(hideSubGuidePageView) forControlEvents:UIControlEventTouchUpInside];
    _subPage.frame = CGRectMake(self.width, 0, self.width, self.height);
    [self addSubview:_subPage];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = weakSelf.bounds;
        f.origin.x = -weakSelf.width;
        [weakSelf.bkView setFrame:f];
        f.origin.x = 0;
        weakSelf.subPage.frame = f;
    } ];
    if (INTERFACE_IS_PHONE) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [_subPage addGestureRecognizer:panGesture];
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)hideSubGuidePageView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = weakSelf.bounds;
        f.origin.x = 0;
        [weakSelf.bkView setFrame:f];
        f.origin.x = weakSelf.width;
        weakSelf.subPage.frame = f;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf removeSubPageView];
        }
    }];
    
}

- (void)removeSubPageView {
    [_subPage removeFromSuperview];
    _subPage = nil;
    [self customLayoutSubviews];
    //防止界面混乱。多手指操作
    self.tableView.userInteractionEnabled = YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint translate = [gestureRecognizer locationInView:_subPage];
    if (translate.x < 50) {
        return YES;
    }
    return NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point_inView = [panGesture translationInView:_subPage];
        if (point_inView.x > 0) {
            CGRect f = self.bounds;
            f.origin.x = point_inView.x;
            [_subPage setFrame:f];
            f.origin.x = point_inView.x -self.width;
            self.bkView.frame = f;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point_inView = [panGesture translationInView:_subPage];
        if (point_inView.x > 0) {
            [self hideSubGuidePageView];
        }
    }
}

@end

