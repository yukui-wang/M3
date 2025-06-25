//
//  CMPServerEditTableView.m
//  M3
//
//  Created by MacBook on 2019/12/24.
//

#import "CMPServerEditTableView.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>


@implementation CMPServerEditTableView



- (void)layoutSubviews {
    
    UIView *view = [CMPCommonTool getSubViewWithClassName:@"UISwipeActionPullView" inView:self];
    [self setupRowActionView:view];
    
    [super layoutSubviews];
}

// 设置背景图片
- (void)setupRowActionView:(UIView *)rowActionView
{
    UIView *remarkContentView = rowActionView.subviews[0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_cell_delete_btn"]];
    imageView.cmp_size = CGSizeMake(40.f, 40.f);
    imageView.contentMode = UIViewContentModeCenter;
    imageView.cmp_x = 15.f;
    imageView.cmp_centerY = remarkContentView.height/2.f;
    imageView.backgroundColor = [UIColor cmp_colorWithName:@"app-bgc4"];
    [imageView cmp_setRoundView];
    [remarkContentView addSubview:imageView];
    [rowActionView setNeedsDisplay];
}


@end
