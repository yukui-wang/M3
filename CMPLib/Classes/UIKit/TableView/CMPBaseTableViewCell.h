//
//  CMPBaseTableViewCell.h
//  CMPCore
//
//  Created by wujiansheng on 2017/1/5.
//
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/UIImage+CMPImage.h>
#import <CMPLib/UIView+CMPView.h>
#import "CMPBaseTableViewCellSelectView.h"
@protocol CMPBaseTableViewCellDelegate;
@interface CMPBaseTableViewCell : UITableViewCell {
    // background view
    UIView          *_bkView;
    // selected background view
    CMPBaseTableViewCellSelectView          *_selectBkView;
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
@property (nonatomic,retain) CMPBaseTableViewCellSelectView *selectBkView;

@property (nonatomic,weak) NSIndexPath *indexPath;
@property (nonatomic,weak) id<CMPBaseTableViewCellDelegate> delegate;

- (void)setup;
- (void)setSeparatorFrame:(CGRect)aFrame;
- (void)setBkViewColor:(UIColor *)aColor;
- (void)setSeparatorColor:(UIColor *)aColor;
- (void)setSelectBkViewColor:(UIColor *)aColor;
- (void)setSelectedBkImage:(UIImage *)aImage;
- (void)setDefualtBkView;
- (void)setDefualtSelectedBkImage;
- (void)setClearBkViewColor;
- (void)customLayoutSubviewsFrame:(CGRect)frame;
- (void)layoutSubviewsWithFrame:(CGRect)frame; // 自定义布局子views, 不能与layoutSubviews一起写
-(void)addLineWithRow:(NSInteger)row RowCount:(NSInteger)rowCount separatorLeftMargin:(CGFloat)separatorLeftMargin;

@end


@protocol CMPBaseTableViewCellDelegate <NSObject>

-(void)cmpBaseTableViewCell:(CMPBaseTableViewCell *)cell didTapAct:(NSInteger)action ext:(id)ext;

@end
