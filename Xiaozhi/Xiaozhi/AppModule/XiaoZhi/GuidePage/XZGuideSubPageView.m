//
//  XZGuideSubPageView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/13.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZGuideSubPageView.h"
#import "XZGuideSubPageCell.h"
@interface XZGuideSubPageView () <UITableViewDelegate,UITableViewDataSource> {
    UILabel *_titleLabel;
}
@property(nonatomic, strong)XZGuidePageItem *pageItem;

@end

@implementation XZGuideSubPageView

- (id)initWithFrame:(CGRect)frame pageItem:(XZGuidePageItem *)pageItem {
    if (self = [super initWithFrame:frame]) {
        self.pageItem = pageItem;
        _titleLabel.text = pageItem.title;
    }
    return self;
}

- (void)setup {
    if (!_backBtn) {
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
        [self.backBtn.titleLabel setFont:FONTSYS(16)];
        [self addSubview:self.backBtn];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = FONTSYS(26);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        [self addSubview:_topLine];
    }
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        [self addSubview:_bottomLine];
    }
}

- (void)customLayoutSubviews {
    NSInteger height = self.backBtn.titleLabel.font.lineHeight+1;
    [self.backBtn setFrame:CGRectMake(10, 5, 52, height+20)];
    height = _titleLabel.font.lineHeight+1;
    [_titleLabel setFrame:CGRectMake(70, 4, self.width-140, height)];
    [_topLine setFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame)+10, self.width, 0.5)];
    [_bottomLine setFrame:CGRectMake(0, self.height-0.5, self.width, 0.5)];
    [_tableView setFrame:CGRectMake(0, _topLine.originY, self.width, self.height-_topLine.originY)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pageItem.subheads.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    UIColor *color = section == self.pageItem.subheads.count-1 ?[UIColor clearColor]:[UIColor colorWithWhite:1 alpha:0.15];//之后一组不显示分割线
    [view setBackgroundColor:color];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.pageItem.subheads;
    if (section < array.count) {
        XZGuidePageSubItem *item = array[section];
        return item.words.count+1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        return [XZGuideSubPageCell headerCellHeight];
    }
    else {
        NSInteger section = indexPath.section;
        NSArray *array = self.pageItem.subheads;
        if (section < array.count) {
            XZGuidePageSubItem *subItem = array[section];
            if (row >= subItem.words.count) {
                //最后一行+12
                return [XZGuideSubPageCell cellHeight] +12;
            }
        }
    }
    return [XZGuideSubPageCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifierStr = @"XZGuidePageViewCell";
    XZGuideSubPageCell *cell = (XZGuideSubPageCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        cell = [[XZGuideSubPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *array = self.pageItem.subheads;
    if (section < array.count) {
        XZGuidePageSubItem *subItem = array[section];
        NSArray *words = subItem.words;
        if (row == 0 ) {
            NSString *word = subItem.title;
            [cell setupTextForHeader:word];
        }
        else if (row-1 < words.count) {
            NSString *word = words[row-1];
            [cell setupText:word];
        }
    }
    return cell;
}

@end

