//
//  XZQAGuideSubPageView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAGuideSubPageView.h"
#import "XZQAGuidePageHeaderCell.h"
#import "XZQAGuidePageCell.h"

@implementation XZQAGuideSubPageView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.guideTips.tips.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        return [XZQAGuidePageHeaderCell cellHeightForText:self.guideTips.tipsSetName width:self.width];
    }
    else {
        CGFloat height = [XZQAGuidePageCell cellHeightForText:self.guideTips.tips[row-1] width:self.width];;
        if (row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
            //最后一行+12
            height += 12;
        }
        return height;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        NSString *identifierStr = @"XZGuidePageViewCellheader";
        XZQAGuidePageHeaderCell *cell = (XZQAGuidePageHeaderCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
        if (!cell) {
            cell = [[XZQAGuidePageHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
        }
        cell.titleLabel.text = self.guideTips.tipsSetName;
        cell.pushImgView.hidden = YES;
        return cell;
    }
    NSString *identifierStr = @"XZGuidePageViewCell";
    XZQAGuidePageCell *cell = (XZQAGuidePageCell *)[tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        cell = [[XZQAGuidePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    cell.titleLabel.text = self.guideTips.tips[row-1];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row-1;
    if (row >= 0 && row < self.guideTips.tips.count) {
        NSString *text = self.guideTips.tips[row];
        if (self.clickTextBlock) {
            self.clickTextBlock(text);
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
