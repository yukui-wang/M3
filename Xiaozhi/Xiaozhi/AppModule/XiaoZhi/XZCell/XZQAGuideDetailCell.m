//
//  XZQAGuideDetailCell.m
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZQAGuideDetailCell.h"
#import "XZQAGuideTips.h"
#import "XZQAGuideDetailItemsCell.h"
#import "XZQAGuideDetailModel.h"

@interface XZQAGuideDetailCell()<UITableViewDelegate,UITableViewDataSource> {
    UILabel *_topLabel;
    BOOL _clickEnbale;//放暴力点击
    UITableView *_tableView;
    
}

@end

@implementation XZQAGuideDetailCell

- (void)dealloc {
    SY_RELEASE_SAFELY(_topLabel);
    SY_RELEASE_SAFELY(_tableView);
    
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_contentBGView addSubview:_tableView];
    }
    _tableView.userInteractionEnabled = YES;
    _contentBGView.userInteractionEnabled = YES;
}


- (void)customLayoutSubviewsFrame:(CGRect)frame {
    [super customLayoutSubviewsFrame:frame];
    XZQAGuideDetailModel *model = (XZQAGuideDetailModel *)self.model;
    [_topLabel setFrame:CGRectMake(18, 8, _contentBGView.width-30, model.titleHeight)];
    [_tableView setFrame:CGRectMake(18, CGRectGetMaxY(_topLabel.frame)+8, _contentBGView.width-30, _contentBGView.height-(CGRectGetMaxY(_topLabel.frame)+8)-9)];
}

- (void)setModel:(XZQAGuideDetailModel *)model {
    [super setModel:model];
    _topLabel.text = model.title;
    [_tableView reloadData];
    [self customLayoutSubviewsFrame:self.frame];
}

- (void)buttonClickEnable {
    _clickEnbale = YES;
}

#pragma mark UITableViewDelegate,UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XZQAGuideDetailModel *model = (XZQAGuideDetailModel *)self.model;
    return model.tips.tips.count;
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
    XZQAGuideDetailModel *model = (XZQAGuideDetailModel *)self.model;

    if (indexPath.row < model.HeightArray.count) {
        return [model.HeightArray[indexPath.row]  integerValue];
    }
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    XZQAGuideDetailModel *model = (XZQAGuideDetailModel *)self.model;
    if (row < model.tips.tips.count) {
        NSString *cellIdentifier = @"XZQAGuideDetailCell1";
        XZQAGuideDetailItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[XZQAGuideDetailItemsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            cell.clickTextBlock = ^(NSString *text) {
                if (model.clickTextBlock) {
                    model.clickTextBlock(text);
                }
            };
        }
        cell.tLabel.text = model.tips.tips[row];
        cell.tLabel.numberOfLines = 0;
        cell.tLabel.lineBreakMode = NSLineBreakByWordWrapping;
        return cell;
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
    NSInteger row = indexPath.row;
    XZQAGuideDetailModel *model = (XZQAGuideDetailModel *)self.model;
    if (row < model.tips.tips.count) {
        if (model.clickTextBlock) {
            model.clickTextBlock(model.tips.tips[row]);
        }
        _clickEnbale = NO;
        [self performSelector:@selector(buttonClickEnable) withObject:nil afterDelay:1];
    }
}


@end
