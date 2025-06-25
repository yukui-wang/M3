//
//  RCActionSheetView.h
//  RongIMKit
//
//  Created by liyan on 2019/8/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define Space_Line 10

@interface RCActionSheetView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *maskView; //背景

@property (nonatomic, strong) UITableView *tableView; //展示表格

@property (nonatomic, strong) NSArray *cellArray; //表格数组

@property (nonatomic, copy) NSString *cancelTitle; //取消的标题设置

@property (nonatomic, strong) UIView *headView; //标题头视图

@property (nonatomic, assign) CGSize viewBounds; //父view的大小

@property (nonatomic, copy) void (^selectedBlock)(NSInteger); //选择单元格block

@property (nonatomic, copy) void (^cancelBlock)(); //取消单元格block

- (instancetype)initWithCellArray:(NSArray *)cellArray
                       viewBounds:(CGSize)viewBounds
                      cancelTitle:(NSString *)cancelTitle
                    selectedBlock:(void (^)(NSInteger))selectedBlock
                      cancelBlock:(void (^)())cancelBlock;

@end

NS_ASSUME_NONNULL_END
