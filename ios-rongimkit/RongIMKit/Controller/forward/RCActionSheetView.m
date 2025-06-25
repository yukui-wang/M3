//
//  RCActionSheetView.m
//  RongIMKit
//
//  Created by liyan on 2019/8/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCActionSheetView.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
@implementation RCActionSheetView

- (instancetype)initWithCellArray:(NSArray *)cellArray
                       viewBounds:(CGSize)viewBounds
                      cancelTitle:(NSString *)cancelTitle
                    selectedBlock:(void (^)(NSInteger))selectedBlock
                      cancelBlock:(void (^)())cancelBlock {
    self = [super init];
    if (self) {
        _headView = nil;
        _cellArray = cellArray;
        _cancelTitle = cancelTitle;
        _selectedBlock = selectedBlock;
        _cancelBlock = cancelBlock;
        _viewBounds = viewBounds;
        [self createUI];
    }
    return self;
}

#pragma mark------ 创建UI视图
- (void)createUI {
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.tableView];
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.5;
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.cornerRadius = 10;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = 57.0;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = self.headView;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"OneCell"];
    }
    return _tableView;
}

#pragma mark <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? _cellArray.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneCell"];
    if (indexPath.section == 0) {
        cell.textLabel.text = _cellArray[indexPath.row];
        if (indexPath.row == _cellArray.count - 1) {
            UIBezierPath *maskPath =
                [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.viewBounds.width - (Space_Line * 2),
                                                                   tableView.rowHeight)
                                      byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                            cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = cell.contentView.bounds;
            maskLayer.path = maskPath.CGPath;
            cell.layer.mask = maskLayer;
        }
    } else {
        cell.textLabel.text = _cancelTitle;
        cell.layer.cornerRadius = 10;
    }
    cell.contentView.backgroundColor =
        [RCKitUtility generateDynamicColor:[UIColor clearColor] darkColor:HEXCOLOR(0x2c2c2e)];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = RGBCOLOR(0, 118, 255);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.selectedBlock) {
            self.selectedBlock(indexPath.row);
        }
    } else {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return Space_Line;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, Space_Line)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

#pragma mark------ 绘制视图
- (void)layoutSubviews {
    [super layoutSubviews];
    [self show];
}

//滑动弹出
- (void)show {
    _tableView.frame =
        CGRectMake(Space_Line, self.viewBounds.height, self.viewBounds.width - (Space_Line * 2),
                   _tableView.rowHeight * (_cellArray.count + 1) + _headView.bounds.size.height + (Space_Line * 2));
    [UIView animateWithDuration:.2
                     animations:^{
                         CGRect rect = _tableView.frame;
                         rect.origin.y -= _tableView.bounds.size.height;
                         _tableView.frame = rect;
                     }];
}

//滑动消失
- (void)dismiss {
    [UIView animateWithDuration:.2
        animations:^{
            CGRect rect = _tableView.frame;
            rect.origin.y += _tableView.bounds.size.height;
            _tableView.frame = rect;
        }
        completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
}

#pragma mark------ 触摸屏幕其他位置弹下
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

@end
