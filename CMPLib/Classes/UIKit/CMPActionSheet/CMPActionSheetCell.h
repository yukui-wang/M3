//
//  CMPActionSheetCell.h
//  BeeBee
//
//  Created by quwan on 2017/6/15.
//  Copyright © 2017年 quwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CMPActionSheetStyle){
    
    CMPActionSheetDefault,
    CMPActionSheetIconAndTitle,
    CMPActionSheetIcon
};



@interface CMPActionSheetCell : UITableViewCell

@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIImageView *iconImg;
@property (nonatomic,strong)UIView *bottomLine;
@property (nonatomic,strong)UIView *coverView;

/**
 只有一个标题

 @param title 标题
 @param height cell高度
 */
- (void)setupCMPActionSheetDefaultCellWithTitle:(NSString *)title
                                    CellHeight:(CGFloat)height;

/**
 图标+标题

 @param title 标题
 @param font 字体
 @param icon 图标
 @param height 高度
 */
- (void)setupCMPActionSheetIconAndTitleWithTitle:(NSString *)title
                                      titleFont:(UIFont *)font
                                           icon:(UIImage *)icon
                                     cellHeight:(CGFloat)height;

/**
 只有一个图标

 @param icon 图标
 @param height 高度
 */
- (void)setupCMPActionSheetIconAndTitleWithIcon:(UIImage *)icon
                                    cellHeight:(CGFloat)height;
@end
