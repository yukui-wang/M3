//
//  SyBaseTableViewCell.h
//  M1IPhone
//
//  Created by  on 12-10-29.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

// bottomBorderHeight
#define kPhoneSepHeight     0.5       //iphone 分割线高度
#define kPadSepHeight       0.7//1 //2       //ipad 分割线高度
#define kPhoneSepLineHeight_New 1
#define kSettingCell_LeftLabel_FontSize 14
#define kSettingCell_RightLabel_FontSize 12

#import <UIKit/UIKit.h>
#import "CMPConstant.h"
#import "UIImage+CMPImage.h"
#import "UIView+CMPView.h"
#import "SyBaseTableViewCellSelectView.h"
@interface SyBaseTableViewCell : UITableViewCell {
    // background view
    UIView          *_bkView;
    // selected background view
    SyBaseTableViewCellSelectView          *_selectBkView;
    // zhengxf add
    UIImageView     *_separatorImageView;           //sepLine
    UIImageView *_selectedBkImageView;
    UIImageView *_selectedFlagImageView;
    UIImageView  *_bkimageView;
    UIView *_topLineView;
}

@property (nonatomic ,retain)UIImageView *separatorImageView;// custom
@property (nonatomic, assign)BOOL showSelectedFlag;
@property (nonatomic, assign) BOOL fistImage;
@property (nonatomic, assign)CGFloat  separatorLeftMargin;//分割线左边距
@property (nonatomic, assign)CGFloat  separatorRightMargin;//分割线右边距
@property (nonatomic) BOOL separatorHide;
@property (nonatomic,retain) SyBaseTableViewCellSelectView *selectBkView;

- (void)setup; // pad、 phone共同调用
// 用于pad、phone公共View
- (void)setupForPhone; // phone
- (void)setupForPad; // pad 
// set cell separator frame (default image)
- (void)setSeparatorFrame:(CGRect)aFrame;
// set cell background view color
- (void)setBkViewColor:(UIColor *)aColor;
- (void)setSeparatorColor:(UIColor *)aColor;

// set cell selected background view color
- (void)setSelectBkViewColor:(UIColor *)aColor;
- (void)setSelectedBkImage:(UIImage *)aImage;

- (void)setDefualtBkView;
- (void)setDefualtSelectedBkImage;
- (void)setClearBkViewColor;

// pad、 phone共同调用
- (void)customLayoutSubviewsFrame:(CGRect)frame;

- (void)layoutSubviewsWithFrame:(CGRect)frame; // 自定义布局子views, 不能与layoutSubviews一起写
- (void)layoutSubviewsForPadWithFrame:(CGRect)frame;
- (void)layoutSubviewsForPhoneWithFrame:(CGRect)frame;
/**
 *  @author Guojl, 15-03-03 10:03:21
 *
 *  @brief  用于设置页面给cell添加上下边缘线
 *  @param row      section中的第几行
 *  @param rowCount section中的行数
 */
-(void)addEdgeLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount;
-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount;
-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount separatorLeftMargin:(CGFloat)separatorLeftMargin;

@end
