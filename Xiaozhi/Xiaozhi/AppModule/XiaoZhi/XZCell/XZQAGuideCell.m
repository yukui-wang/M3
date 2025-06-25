//
//  XZQAGuideCell.m
//  M3
//
//  Created by wujiansheng on 2018/10/22.
//
#define kXZButtonFont FONTSYS(16)
#import "XZQAGuideCell.h"
#import "XZQAGuideModel.h"

#import "XZQAGuideTips.h"
#import "XZQAGuideSubCell.h"
#import "XZQAGuideSubHeaderView.h"
#import "XZQAGuideSubFooterView.h"

@interface XZQAGuideCell()<UITableViewDelegate,UITableViewDataSource> {
    UILabel *_topLabel;
    BOOL _clickEnbale;//放暴力点击
    UITableView *_tableView;
    UILabel *_bottomLabel;

}

@end

@implementation XZQAGuideCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_topLabel);
    SY_RELEASE_SAFELY(_tableView);
    SY_RELEASE_SAFELY(_bottomLabel);

    [super dealloc];
}

- (void)setup {
    _clickEnbale = YES;
    [super setup];
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = FONTSYS(16);
        _topLabel.textColor = UIColorFromRGB(0x333333);
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.numberOfLines = 0;
        _topLabel.text = @"我可以回答下列问题：";
        [_contentBGView addSubview:_topLabel];
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_contentBGView addSubview:_tableView];
    }
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = FONTSYS(16);
        _bottomLabel.textColor = UIColorFromRGB(0x333333);
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.numberOfLines = 0;
        _bottomLabel.text = @"你也可以直接用语音问我哦";
        [_contentBGView addSubview:_bottomLabel];

    }
    _tableView.userInteractionEnabled = YES;
    _contentBGView.userInteractionEnabled = YES;
}


- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [super customLayoutSubviewsFrame:frame];
    [_topLabel setFrame:CGRectMake(18, 8, _contentBGView.width-30, _topLabel.font.lineHeight)];
    [_tableView setFrame:CGRectMake(18, 46, _contentBGView.width-30, _contentBGView.height-46*2)];
    [_bottomLabel setFrame:CGRectMake(18, _contentBGView.height-10-_bottomLabel.font.lineHeight, _contentBGView.width-30, _bottomLabel.font.lineHeight)];
}

- (void)setModel:(XZQAGuideModel *)model {
    [super setModel:model];
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)buttonClickEnable {
    _clickEnbale = YES;
}

- (void)showTipsDetail:(XZQAGuideTips *)tips {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    model.moreBtnClickAction(tips);
}


#pragma mark UITableViewDelegate,UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    return model.tipsSet.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (section < model.tipsSet.count) {
        XZQAGuideTips *tips = model.tipsSet[section];
        NSInteger number = tips.tips.count;
        //最多显示2个
        return number <2 ? number:2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kXZQAGuideCellHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (section < model.tipsSet.count) {
        XZQAGuideTips *tips = model.tipsSet[section];
        CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
        CGRect r = CGRectMake(0, 0, self.width, height);
        XZQAGuideSubHeaderView *view = [[XZQAGuideSubHeaderView alloc] initWithFrame:r];
        view.section = section;
        view.tips = tips;
        view.tableView = tableView;
        view.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) weakSelf = self;
        view.showTipsDetailBlock = ^(XZQAGuideTips *tips) {
            [weakSelf showTipsDetail:tips];
        };
        return [view autorelease];
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (section < model.tipsSet.count-1) {
        return kXZQAGuideCellFooterHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (section < model.tipsSet.count-1) {
        CGFloat height = [self tableView:tableView heightForFooterInSection:section];
        CGRect r = CGRectMake(0, 0, self.width, height);
        XZQAGuideSubFooterView *view = [[XZQAGuideSubFooterView alloc] initWithFrame:r];
        return [view autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kXZQAGuideCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (indexPath.section < model.tipsSet.count) {
        XZQAGuideTips *tips = model.tipsSet[section];
        if (row < tips.tips.count) {
            NSString *cellIdentifier = @"XZQAGuideSubCellIdentifier";
            XZQAGuideSubCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[XZQAGuideSubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.clickTextBlock = ^(NSString *text) {
                    if (model.clickTextBlock) {
                        model.clickTextBlock(text);
                    }
                };
            }
            cell.tLabel.text = tips.tips[row];
            return cell;
        }
    }
    
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_clickEnbale) {
        return;
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    XZQAGuideModel *model = (XZQAGuideModel *)self.model;
    if (indexPath.section < model.tipsSet.count) {
        XZQAGuideTips *tips = model.tipsSet[section];
        if (row < tips.tips.count) {
            if (model.clickTextBlock) {
                model.clickTextBlock(tips.tips[row]);
            }
            _clickEnbale = NO;
            [self performSelector:@selector(buttonClickEnable) withObject:nil afterDelay:1];
        }
    }
}


@end
